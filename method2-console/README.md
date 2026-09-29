# Méthode console — premier essai neutre

Après exécution de `scripts/build-neutral-jar.sh`, le paquet local contient :

```text
mst2-carplay-scale-patch/
├── mst2-carplay-scale.jar
├── carplayscale_boot_block.shinc
├── carplayscale_common.sh
├── install.sh
├── trial.sh
├── enable.sh
├── disable.sh
├── status.sh
└── uninstall.sh
```

La build actuelle est la phase C neutre P0468T : elle ne modifie aucune dimension. `install.sh` installe le mécanisme et arme uniquement le prochain démarrage en Trial Boot. Il ne crée jamais le marqueur permanent.

## Premier essai véhicule

1. copier le dossier complet `mst2-carplay-scale-patch` à la racine d'une carte SD ;
2. conserver sur une seconde carte un fichier vide `carplayscale-disable` prêt à servir ;
3. depuis la console/Telnet, lancer `sh install.sh` dans le dossier copié ;
4. vérifier que la sortie indique `installed safely; next boot is a one-shot trial` ;
5. redémarrer une seule fois et vérifier le HMI, puis connecter CarPlay ;
6. ne pas lancer `enable.sh` à ce stade ;
7. récupérer `/tsd/var/carplayscale/carplayscale.log` et le `runHMI.sh` vivant.

Le marqueur de réussite attendu après une connexion CarPlay contient :

```text
phase=C neutral ServiceConfiguration shadow loaded
```

Au redémarrage suivant, le JAR ne sera plus chargé tant qu'un nouveau `trial.sh` ou un `enable.sh` explicite n'est pas lancé.
