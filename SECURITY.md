# Sécurité

Ce projet modifie la séquence de lancement du HMI d'une unité embarquée. Une version incompatible ou une interruption pendant l'installation peut rendre l'interface indisponible.

## Versions prises en charge

Seul `MST2_EU_VW_ZR_P0468T` est actuellement validé. Ne pas utiliser le JAR P0468 sur un autre train logiciel, même si le matériel semble identique.

## Signaler un problème

Utiliser de préférence le signalement privé de vulnérabilité GitHub lorsqu'il est disponible. Ne jamais joindre publiquement un dump complet, un VIN, des coordonnées, des identifiants Bluetooth ou un journal contenant des données personnelles.

Pour un dysfonctionnement non sensible, ouvrir une issue en indiquant uniquement le train logiciel exact, l'action Toolbox exécutée, l'échelle choisie et les lignes pertinentes de `carplayscale.log` après anonymisation.

## Récupération

Le Trial Boot doit toujours précéder l'activation permanente. Une carte SD contenant un fichier vide `carplayscale-disable` à sa racine neutralise le chargement du JAR avant Java. Les autres procédures sont détaillées dans la section Recovery du [README](README.md#recovery--bootloop).
