# Architecture technique

## Périmètre confirmé

L’analyse a été faite le 29 septembre 2026 sur les révisions suivantes :

- `xPaiiN/mst2-carplay-vc` : `f1ac169d1ce40b291d9a2ab6a0d97fe53474754f` ;
- `olli991/mib-std2-pq-zr-toolbox` : `73ef9932d6a880972d1abb91c5f53ea60d910a9f` ;
- `grajen3/mib2-lsd-patching` : `d57796ff243dfdfdf32dacad468b1eaf76b638e3`.

Le dépôt `mib2-lsd-patching` documente un **MIB2 High Harman**. Ses sources CarPlay sont utiles pour comprendre le flux, mais ne prouvent pas l’identité binaire des classes MST2 P0468T.

## Chaîne de démarrage

`/tsd/hmi/runHMI.sh` construit la variable `BOOTCLASSPATH`, puis lance `de.vw.mib.MIBMain`. OpenJ9 reconnaît `-Xbootclasspath/p:<path>` et place les ressources indiquées avant le bootstrap class path stock. Les options situées à droite ont la priorité générale sur celles situées à gauche ; en présence de classes dupliquées, il ne faut cependant pas dépendre de cet ordre implicite.

Notre règle est donc plus stricte : deux JAR séparés sont admis uniquement si leurs classes shadowées sont disjointes. L’installation ne fusionne ni ne réécrit la ligne xPaiiN.

## Bloc géré dans `runHMI.sh`

L’infrastructure insère un seul bloc borné par :

```text
# mst2-carplay-scale: begin
# mst2-carplay-scale: end
```

Le bloc est placé après la dernière affectation `BOOTCLASSPATH=` existante. Il :

1. inspecte `/media/mp00*/carplayscale-disable` ;
2. vérifie que le JAR existe et n’est pas vide ;
3. consomme `trial` avant de modifier `BOOTCLASSPATH` ;
4. sinon accepte `enabled` ;
5. ajoute uniquement `mst2-carplay-scale.jar`.

L’Emergency SD Disable a priorité sur `trial` et `enabled`. Lorsqu’une carte d’urgence est présente, le trial n’est pas consommé : aucune action liée au patch n’a lieu durant ce boot.

## Modification atomique

L’installateur :

1. vérifie que `runHMI.sh` est non vide et contient `BOOTCLASSPATH=` ainsi que `de.vw.mib.MIBMain` ;
2. refuse un bloc existant incomplet ou dupliqué ;
3. sauvegarde le fichier vivant dans `runHMI.sh.carplayscale.bak` sans supprimer les autres patches ;
4. retire uniquement un ancien bloc carplayscale dans un fichier temporaire ;
5. insère le bloc canonique après la dernière affectation du bootclasspath ;
6. vérifie le résultat, les marqueurs et l’unique référence au JAR ;
7. exécute `sh -n` ;
8. remplace le fichier par `mv` depuis le même répertoire.

La désinstallation répète les validations mais retire uniquement le bloc géré. La sauvegarde n’est pas restaurée automatiquement et reste disponible pour une récupération manuelle.

## Hook Java proposé

Le meilleur candidat actuel est `org.dsi.ifc.carplay.ServiceConfiguration`, plus précisément le constructeur qui reçoit les dimensions logiques et physiques. Il est beaucoup plus petit que `ASLHandler` et se situe avant la sérialisation DSI, quel que soit le proxy réellement utilisé.

Cette décision reste **provisoire** jusqu’à extraction P0468T. Alternatives étudiées :

- `ASLHandler.sendStartService()` : point fonctionnel évident mais classe volumineuse, fortement couplée et dangereuse à remplacer depuis un autre firmware ;
- `DSICarplayProxy$1` : surface minuscule dans le dump MIB2 High, mais classe synthétique et backend-spécifique ;
- `ServiceConfigurationSerializer` : proche du transport, mais critique pour le protocole et non confirmé sur MST2 ;
- proxy LR généré : nom hashé et classe très large, donc inadapté sans dump exact.

À `scale=100`, le futur constructeur shadowé devra reproduire bit pour bit les affectations stock. Les valeurs physiques ne seront ajustées qu’après la phase de logging réelle.

## Données requises avant l’étape C

- le `MIBHMI.jxe` ou un dump de classes du `MST2_EU_VW_ZR_P0468T` réellement installé ;
- le `runHMI.sh` vivant, après installation de xPaiiN ;
- le JAR xPaiiN effectivement installé ou au minimum son SHA-256 ;
- si possible, `info.txt` du skin actif et les valeurs `Layout.Carplay.Canvas_Dimension.*` ;
- la sortie de version JVM/J9 et les chemins exacts du bootstrap class path ;
- confirmation des outils shell disponibles (`awk`, `grep`, `sed`, `sh -n`, `mv`, `mount`).

## Références

- https://github.com/xPaiiN/mst2-carplay-vc
- https://github.com/olli991/mib-std2-pq-zr-toolbox
- https://github.com/grajen3/mib2-lsd-patching
- https://eclipse.dev/openj9/docs/xbootclasspath/
- https://eclipse.dev/openj9/docs/cmdline_specifying/
