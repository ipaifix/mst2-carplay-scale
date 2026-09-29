# Sources Java

L'étape C utilise le plus petit shadow confirmé sur le firmware P0468T :

- `org.dsi.ifc.carplay.ServiceConfiguration` reproduit exactement l'API publique et le comportement stock observés dans le dump véhicule ;
- `com.mst2.carplayscale.NeutralProbe` écrit une seule ligne de diagnostic, sans modifier aucune valeur.

Le JAR neutre ne change ni la résolution logique, ni les dimensions physiques, ni le tactile. Sa construction exige les deux JAR d'analyse convertis depuis le dump local ; ils ne sont jamais versionnés.
