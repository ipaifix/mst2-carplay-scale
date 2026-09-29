# Sources Java

L'étape C utilise le plus petit shadow confirmé sur le firmware P0468T :

- `org.dsi.ifc.carplay.ServiceConfiguration` reproduit exactement l'API publique et le comportement stock observés dans le dump véhicule ;
- `com.mst2.carplayscale.CarPlayScale` lit une configuration strictement validée, journalise les paramètres et ajuste uniquement les dimensions physiques lorsqu'une échelle supérieure à 100 % est explicitement sélectionnée.

À 100 %, le JAR ne change ni la résolution logique, ni les dimensions physiques, ni le tactile. Les seules valeurs acceptées sont 100/110/115/120/125 ; toute absence ou erreur revient à 100. Sa construction exige les deux JAR d'analyse convertis depuis le dump local ; ils ne sont jamais versionnés.
