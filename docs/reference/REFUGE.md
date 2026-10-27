# Cour du refuge

La cour agrandit le refuge derrière l’apparition : sol 240 × 132 studs, centre (16, 0, 295), de X −104 à 136 et de Z 229 à 361. Elle rejoint l’esplanade des portails par un recouvrement ; chemin central, six lampes, bancs, deux abris et clôtures forment une zone de repos. Aucun marchand, récompense ou zone de combat n’a été ajouté.

La scène est enregistrée sous `Workspace.RefugeCourtyard` (93 descendants). `studio/BuildRefugeCourtyard.luau` est un constructeur ponctuel exécuté en Edit, jamais un script de démarrage ; il refuse de construire si le modèle existe. Les sources locales seules ne reconstruisent pas toute la scène. Supprimer ce modèle uniquement en Edit retire cette extension.

## Vérifications

- Capture d’ensemble Edit : cour, abris, éclairage et jonction avec les portails visibles.
- En Play SessionStudio, clavier S depuis le spawn jusqu’à Z290, puis W jusqu’à Z218 : `CurrentZone` reste REFUGE et vie 100. Maintien E : arrivée dans la Ville.
- 14 contrôles `studio/qa/RefugeCourtyard.server.luau`, rapport `refuge-courtyard-result.json` : sol et absence d’obstacle central à six points, hors zones de combat, dimensions du sol et destination du portail Ville. Test temporaire uniquement en Play, puis Stop ; console vide.

Ces preuves ne couvrent pas tous les trajets latéraux, le mobile tactile, le multijoueur ni l’équilibrage visuel à différentes conditions d’éclairage. Pas de sauvegarde .rbxl ni publication confirmée.
