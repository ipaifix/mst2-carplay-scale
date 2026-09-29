# Étape A — analyse technique

## 1. Classes réellement shadowées par xPaiiN

Inventaire du JAR `required-files/region-eu/variant1/mst2-carplay-vc-full-eu-v1.jar` à la révision `f1ac169` (SHA-256 `c6fc87aa355add85cf22d18c48b86f3239aab7245dd077a655555a85b8bad31c`) :

### Classes ajoutées par le patch

- `com.mst2.carplay.bridge.Mst2NowPlayingBridge` et ses classes internes ;
- `com.mst2.carplay.navi.Mst2NaviBridge` et ses classes internes.

### Classes VW remplacées

- `de.vw.mib.asl.internal.carplay.common.CarPlayGlobalProperies` ;
- `de.vw.mib.asl.internal.carplay.common.NavigationHandler` ;
- `de.vw.mib.asl.internal.kombipictureserver.usecaces.CoverArt` et `CoverArt$1` ;
- `de.vw.mib.bap.mqbab2.audiosd.functions.ActiveSource` ;
- `de.vw.mib.bap.mqbab2.audiosd.functions.CurrentStationHandle` ;
- `de.vw.mib.bap.mqbab2.audiosd.functions.CurrentStationInfo` ;
- `de.vw.mib.bap.mqbab2.audiosd.functions.SourceState`.

Le JAR ne contient ni `de.vw.mib.asl.internal.carplay.target.ASLHandler`, ni `org.dsi.ifc.carplay.ServiceConfiguration`, ni un proxy `DSICarplay`.

## 2. Modification de `runHMI.sh` par xPaiiN

Le script courant :

- retire d’abord ses anciennes lignes contenant `mst2-carplay-vc.jar` ou `cpvc-cover-bridge` ;
- repère la dernière ligne commençant par `BOOTCLASSPATH=` ;
- ajoute `BOOTCLASSPATH="$BOOTCLASSPATH -Xbootclasspath/p:$MIBJAR/mst2-carplay-vc.jar"` ;
- ajoute éventuellement le keepalive du bridge natif ;
- valide avec `sh -n` ;
- exige exactement une ligne JAR et, selon la variante, une ligne bridge ;
- installe le résultat par `mv` ;
- à la désinstallation, retire d’abord uniquement ses propres lignes du fichier vivant et n’utilise les sauvegardes qu’en repli.

Cette stratégie récente est nettement plus sûre que l’ancien script Toolbox `NavActiveIgnore`, dont la désinstallation restaure aveuglément un `runHMI.sh.bak`.

## 3. Deuxième JAR bootclasspath

OpenJ9 supporte `-Xbootclasspath/p:`. Un second JAR est techniquement supportable et le mécanisme xPaiiN montre déjà l’usage d’un JAR prioritaire séparé.

La condition de sécurité est l’absence de classe commune. Avec l’inventaire actuel de xPaiiN, le hook envisagé ne crée pas d’intersection. Si une future version de xPaiiN ajoute la même classe, l’installation devra être bloquée ou les patches fusionnés explicitement.

## 4. Plus petit point d’interception

Ordre de préférence provisoire :

1. constructeur exact de `ServiceConfiguration` P0468T ;
2. petit adaptateur/sérialiseur exact P0468T, seulement si son implémentation est confirmée stable ;
3. `ASLHandler.sendStartService()` en dernier recours.

Le constructeur `ServiceConfiguration` observé reçoit directement `xResolution`, `yResolution`, `physicalDisplayHeight` et `physicalDisplayWidth`. Un shadow fidèle peut donc journaliser puis ajuster uniquement les deux derniers champs sans recopier toute la logique audio, tactile, HMI et d’état d’`ASLHandler`.

## 5. Risques d’un remplacement d’`ASLHandler`

- classe de plusieurs centaines de lignes et nombreuses dépendances internes ;
- champs, signatures, événements et constantes susceptibles de varier entre trains ;
- erreurs de décompilation possibles (`super.getClass()` est déjà suspect dans la source de référence) ;
- rupture de liaison possible dès le chargement, avant tout usage de CarPlay ;
- comportement audio, tactile, Siri, navigation et cycle de connexion exposé à des régressions ;
- la source disponible analysée vient de MIB2 High Harman, pas du P0468T.

Conclusion : aucun `ASLHandler.class` ne doit être construit depuis cette source de référence.

## 6. Architecture proposée

- JAR indépendant `/tsd/hmi/HMI/jar/mst2-carplay-scale.jar` ;
- namespace persistant `/tsd/var/carplayscale/` ;
- bloc shell unique et marqué dans `runHMI.sh` ;
- configuration `scale=100|110|115|120|125` lue avec fallback 100 ;
- phase C neutre avant tout scaling ;
- phase D logging borné ;
- phase E modification des dimensions physiques uniquement ;
- intégration GEM seulement après validation console et véhicule.

## 7. Trial Boot et Emergency SD Disable

Le Trial Boot n’est consommé qu’après confirmation que le JAR existe et qu’aucune carte d’urgence n’est présente. Sa suppression doit réussir avant l’ajout au bootclasspath. Le marqueur permanent n’est consulté qu’ensuite.

Une présence de `carplayscale-disable` sous `/media/mp00*` force un boot sans le JAR. Elle ne supprime ni configuration ni marqueur permanent.

## 8. Tests prévus et présents

- stock, xPaiiN et troisième patch inconnu ;
- double installation ;
- ordre des lignes ;
- Trial consommé puis second boot stock ;
- permanent ;
- emergency SD ;
- disable et uninstall chirurgicaux ;
- fichier vide ;
- absence de `BOOTCLASSPATH=` ;
- absence de `MIBMain` ;
- JAR absent/vide ;
- bloc invalide et résultat syntaxiquement invalide ;
- sauvegarde exacte et absence de remplacement en cas d’échec.

## 9. Informations P0468T manquantes

Le train est connu et supporté par la Toolbox, mais cela ne garantit pas l’ABI Java. Les classes exactes, le proxy DSI réellement instancié, la JVM et le `runHMI.sh` vivant restent à obtenir. Ces éléments bloquent le JAR neutre, pas l’infrastructure shell host-side.
