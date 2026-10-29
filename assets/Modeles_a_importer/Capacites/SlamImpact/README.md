# Impact de la Frappe tellurique

- `SlamImpact.fbx` : meshes éclatés de basalte, fissures ambrées, éclats et anneau d'énergie ; à importer avec **Importer 3D** de Roblox Studio.
- `SlamImpact.png` : aperçu Blender de l'asset.
- Source avec l'action `SlamImpact_PopAndSettle` : `../../../ability_motion/SlamImpactStudy.blend`.
- Générateur reproductible : `../../../build_slam_impact.py`.

Après import, regroupe les meshes dans un `Model` nommé `SlamImpactTemplate` sous `ReplicatedStorage`. `PulseClient` le clone, l'ancre au sol sous le joueur, le fait jaillir puis disparaître. Sans template, l'effet existant est conservé et reçoit des éclats 3D supplémentaires. L'action Blender est une prévisualisation ; l'animation en jeu est pilotée par tweens Roblox, le FBX transporte la géométrie statique.

L'import direct d'un FBX local n'est pas disponible par le pont Studio MCP utilisé pour ce projet ; le template reste optionnel jusqu'à l'import manuel. Le `.blend` interactif ouvert par l'utilisateur n'a pas été modifié.
