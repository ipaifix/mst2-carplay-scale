# Contribuer

Les contributions sont bienvenues, en particulier pour documenter de nouvelles variantes de firmware sans compromettre la sécurité des unités.

## Avant une pull request

1. ne jamais ajouter de firmware, de JAR propriétaire, de dump complet ou de donnée identifiant un véhicule ;
2. conserver le comportement par défaut à 100 % et le Trial Boot comme première activation ;
3. ne modifier que le bloc borné `mst2-carplay-scale` dans `runHMI.sh` ;
4. exécuter `sh tests/run-shell-tests.sh` ;
5. pour une modification Java, exécuter aussi `tests/run-java-tests.sh` avec les dépendances extraites localement du firmware exact.

La prise en charge d'un nouveau firmware doit inclure la vérification de l'ABI stock, les empreintes attendues, des tests host-side et une validation initiale en Trial Boot à 100 %. Ne pas supposer qu'une classe issue d'un train logiciel est compatible avec un autre.
