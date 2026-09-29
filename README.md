# MST2 CarPlay Display Scale

Patch expérimental, indépendant et réversible pour étudier les paramètres d’affichage annoncés par un MIB2 Standard TechniSat/Preh à Apple CarPlay.

> **État actuel : étapes A à F construites et validées hors véhicule.** Le dump P0468T a permis de confirmer le hook Java exact. L'installation force le mode stock 100 % ; le logging, les échelles supérieures et le mode permanent sont présents mais n'ont pas encore été validés dans la voiture.

## Principes de sécurité

- aucune modification de `MIBHMI.jxe`, du skin ou du framebuffer ;
- le patch xPaiiN `mst2-carplay-vc` reste indépendant et intact ;
- l’installation active seulement un **Trial Boot** à usage unique ;
- le chargement permanent nécessite une action séparée ;
- une carte SD portant `carplayscale-disable` neutralise le chargement avant Java ;
- la désinstallation retire uniquement le bloc et le JAR `mst2-carplay-scale` ;
- toute modification de `runHMI.sh` est préparée, validée puis remplacée atomiquement.

## Arborescence

```text
analysis/                    analyse de l’étape A
method2-console/             infrastructure console de l’étape B
tests/                       fixtures et tests host-side
method1-GEM/                 paquet et menu MIB STD2 Toolbox
src/                         shadow P0468, logging et échelle physique
scripts/                     construction reproductible du JAR Java
build/                       sorties de build, non versionnées
```

## État des phases

- [x] A — analyse des dépôts et inventaire des classes xPaiiN
- [x] B — scripts Trial/Permanent/Disable/Emergency/Uninstall et tests shell
- [x] C — comportement neutre à 100 % validé hors véhicule
- [x] D — journalisation de `ServiceConfiguration` validée hors véhicule
- [x] E — échelle physique 100/110/115/120/125 % validée hors véhicule
- [x] F — interface Green Engineering Menu validée hors véhicule

## Tests locaux

```sh
sh tests/run-shell-tests.sh
```

Ces tests n’utilisent pas le véhicule. Ils simulent `/tsd`, les deux emplacements SD, plusieurs variantes de `runHMI.sh`, le Trial Boot et les échecs de validation.

Le test Java nécessite le JDK 8 et les deux JAR d'analyse produits localement depuis le dump P0468 :

```sh
JAVA_HOME=/chemin/vers/jdk8 \
MIBHMI_JAR=/chemin/vers/MIBHMI-P0468.jar \
MIBSTD2_BASE_JAR=/chemin/vers/tsd-mibstd2-hmi-v2-P0468.jar \
sh tests/run-java-tests.sh
```

Il vérifie l'identité de l'API publique avec la classe stock, les trois constructeurs, les dimensions inchangées, la version de bytecode J2SE 1.4 et le contenu minimal du JAR.

# Recovery / Bootloop

## Niveau 1 — Trial Boot

Le marqueur `/tsd/var/carplayscale/trial` est supprimé **avant** l’ajout du JAR au bootclasspath. Après un essai, le reboot suivant ne charge donc plus le patch.

## Niveau 2 — carte SD

Créer un fichier vide nommé :

```text
carplayscale-disable
```

à la racine d’une carte SD, l’insérer puis redémarrer. Le bloc shell inspecte `/media/mp00*` avant Java et n’ajoute pas le JAR, même si le mode permanent est actif.

## Niveau 3 — Telnet

```sh
rm -f /tsd/var/carplayscale/enabled /tsd/var/carplayscale/trial
```

Cette commande ne touche ni à `mst2-carplay-vc.jar`, ni à ses fichiers d’état.

## Niveau 4 — réparation manuelle

La sauvegarde dédiée est :

```text
/tsd/hmi/runHMI.sh.carplayscale.bak
```

Elle représente le `runHMI.sh` vivant au moment de la première installation et conserve donc les autres patches déjà présents. Une désinstallation normale préfère toujours la suppression chirurgicale du bloc `mst2-carplay-scale` dans le fichier vivant.

## Important

Le premier essai véhicule doit conserver l'échelle 100 % et utiliser uniquement le Trial Boot. Ne pas activer le mode permanent ni une échelle supérieure avant confirmation du redémarrage HMI, de CarPlay et des valeurs stock dans le log. Pour une installation sans console, voir [method1-GEM/README.md](method1-GEM/README.md).
