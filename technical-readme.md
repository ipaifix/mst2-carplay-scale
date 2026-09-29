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

## Hook Java confirmé

Le hook retenu est `org.dsi.ifc.carplay.ServiceConfiguration`, plus précisément le constructeur complet qui reçoit les dimensions logiques et physiques. La classe exacte provient du `MIBHMI.jxe` P0468 du véhicule. Elle est beaucoup plus petite que `ASLHandler` et se situe immédiatement avant la sérialisation DSI.

La chaîne exacte observée est :

```text
ASLHandler.sendStartService()
  -> new ServiceConfiguration(..., x/y, physicalHeight/physicalWidth, ...)
  -> DSICarplay.startService(config)
  -> tsd.mibstd2.hmi.dsi.carplay.DSICarplayImpl
  -> SerializerGen.serialize(config)
```

Le sérialiseur P0468 lit directement les 16 champs publics dans leur ordre stock. Le shadow conserve ces champs, les trois constructeurs, les accesseurs et `toString()`. Après les affectations stock, un appel entièrement protégé lit la configuration, journalise les valeurs puis ajuste au besoin uniquement `physicalDisplayHeight` et `physicalDisplayWidth`.

Alternatives écartées :

- `ASLHandler.sendStartService()` : point fonctionnel évident mais classe volumineuse, fortement couplée et dangereuse à remplacer depuis un autre firmware ;
- proxy DSI : l'implémentation exacte est générée et beaucoup plus large que le DTO ;
- `SerializerGen` : classe générée massive et critique pour tous les services DSI ;
- proxy LR généré : nom hashé et classe très large, donc inadapté sans dump exact.

L'absence de configuration, une valeur invalide ou `scale=100` laisse strictement les dimensions intactes. Seules les valeurs 110/115/120/125 déclenchent un arrondi au millimètre le plus proche. La résolution logique, les offsets, la résolution tactile et les capacités restent inchangés. Le log est limité à 64 Kio avant rotation par écrasement.

L'installateur remet systématiquement la configuration à `scale=100`. Une valeur supérieure et le chargement permanent nécessitent chacun une action distincte dans le menu Toolbox.

## Données véhicule reçues

Le dump a confirmé le `runHMI.sh` vivant, le bootstrap J9, la version HMI `H29.319.29.3`, les classes P0468 exactes et la variante xPaiiN `full`. Le fichier vivant comporte deux lignes identiques pour `NavActiveIgnore.jar`; elles sont préservées sans correction automatique.

Les fichiers bruts (`dump/`, photo et log VCDS) sont exclus de Git, car ils sont volumineux et peuvent contenir des identifiants du véhicule.

## Références

- https://github.com/xPaiiN/mst2-carplay-vc
- https://github.com/olli991/mib-std2-pq-zr-toolbox
- https://github.com/grajen3/mib2-lsd-patching
- https://eclipse.dev/openj9/docs/xbootclasspath/
- https://eclipse.dev/openj9/docs/cmdline_specifying/
