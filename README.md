# MST2 CarPlay Display Scale

Patch expérimental, indépendant et réversible pour étudier les paramètres d’affichage annoncés par un MIB2 Standard TechniSat/Preh à Apple CarPlay.

> **État actuel : étapes A et B en cours.** L’analyse technique et l’infrastructure de démarrage sécurisé sont présentes. Aucun JAR Java installable n’est encore fourni : il faut d’abord extraire et comparer les classes exactes du firmware `MST2_EU_VW_ZR_P0468T`.

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
method1-GEM/                 réservé à l’intégration Toolbox (étape F)
src/                         réservé au JAR neutre puis au hook Java
build/                       sorties de build, non versionnées
```

## État des phases

- [x] A — analyse des dépôts et inventaire des classes xPaiiN
- [x] B — scripts Trial/Permanent/Disable/Emergency/Uninstall et tests shell
- [ ] C — JAR neutre basé sur les classes exactes P0468T
- [ ] D — journalisation de `ServiceConfiguration`
- [ ] E — échelle physique 100/110/115/120/125 %
- [ ] F — interface Green Engineering Menu

## Tests locaux

```sh
sh tests/run-shell-tests.sh
```

Ces tests n’utilisent pas le véhicule. Ils simulent `/tsd`, les deux emplacements SD, plusieurs variantes de `runHMI.sh`, le Trial Boot et les échecs de validation.

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

Ne rien copier sur le véhicule depuis ce dépôt tant que l’étape C n’a pas produit un JAR neutre validé pour P0468T. Voir [technical-readme.md](technical-readme.md) et [analysis/phase-a.md](analysis/phase-a.md).
