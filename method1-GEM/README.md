# Installation avec MIB STD2 Toolbox

Cette méthode ne nécessite ni Telnet ni console. Le dossier à copier sur la carte SD est :

```text
method1-GEM/custom
```

Copier le dossier `custom` complet à la racine de la carte utilisée avec la Toolbox. S'il existe déjà, fusionner son contenu sans supprimer les autres personnalisations. La carte doit alors contenir notamment :

```text
custom/
├── carplayscale/
├── greenmenu/
│   ├── carplay-scale.esd
│   └── scripts/
└── java/
    └── mst2-carplay-scale.jar
```

## Importer le menu

1. insérer la carte dans le MIB ;
2. ouvrir le Green Engineering Menu ;
3. ouvrir `MIB STD2 Toolbox` → `Customization` → `GreenMenu` ;
4. lancer `Copy custom Green Engineering Menu screens and scripts to unit` ;
5. attendre le message de fin, quitter puis rouvrir complètement le Green Engineering Menu ;
6. ouvrir `MIB STD2 Toolbox` → `Customization` → `CarPlay Display Scale`.

## Premier essai obligatoire

1. choisir `Install neutral patch + arm one trial boot` ;
2. vérifier que l'écran affiche `installed safely; next boot is a one-shot trial` ;
3. ne pas choisir `Enable permanently` ni une échelle supérieure à 100 % ;
4. redémarrer le MIB ;
5. vérifier le fonctionnement général, puis connecter CarPlay ;
6. au redémarrage suivant, le trial étant consommé, le patch ne sera plus chargé ;
7. revenir dans le menu et choisir `Copy CarPlay Scale logs to SD`.

L'installation force toujours `scale=100`, y compris lors d'une réinstallation. Les valeurs 110/115/120/125 et l'activation permanente sont disponibles dans le menu, mais restent des actions séparées et explicites.

## Tester une échelle

Après validation du premier essai à 100 % :

1. choisir `Set scale` puis 110, 115, 120 ou 125 % ;
2. choisir `Arm another one-shot trial` ;
3. redémarrer et contrôler l'affichage ainsi que toute la surface tactile ;
4. redémarrer une seconde fois pour confirmer le retour automatique au mode non chargé ;
5. utiliser `Copy CarPlay Scale logs to SD` pour conserver le résultat.

## Activer le mode permanent

Seulement après un Trial Boot réussi à l'échelle choisie :

1. sélectionner de nouveau l'échelle voulue ;
2. choisir `Enable permanently` ;
3. redémarrer et refaire un contrôle complet ;
4. conserver une carte de secours et utiliser `Disable patch` au moindre problème.

Le mode permanent et la configuration sont stockés dans l'unité. La carte Toolbox n'est donc pas nécessaire pendant l'utilisation normale.

Pour utiliser les commandes du menu, conserver ou réinsérer la carte contenant le dossier `custom`.

## Carte de secours

Préparer une seconde carte avec un fichier vide `carplayscale-disable` à sa racine. Ne pas l'insérer pendant un essai normal. Si un démarrage échoue, insérer cette carte puis redémarrer : le bloc shell ignorera le JAR avant le lancement de Java.
