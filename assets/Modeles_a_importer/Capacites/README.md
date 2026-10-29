# Cristal de l'Égide

- `AegisCrystal.fbx` : modèle statique à importer avec l'outil **Importer 3D** de Roblox Studio.
- `AegisCrystal.png` : aperçu rendu dans Blender.
- Source Blender et action de présentation 49 images : `../../ability_motion/AegisCrystal.blend`.
- Script générateur : `../../build_aegis_crystal.py`.

Le FBX contient 19 meshes (coque facettée ouverte, cœur lumineux, cage et rivets), 543 faces au total, environ 0,353 × 0,353 × 0,9 unité Blender après réimport dans Blender 5.2. Les objets importés sont géométriques ; garde-les groupés dans un `Model`, utilise `Aegis_PrismShell` comme `PrimaryPart`, puis place le modèle dans `ReplicatedStorage` sous le nom `AegisCrystalTemplate`. `PulseClient` fait pulser `Aegis_LightCore` quand il existe, sinon la pièce primaire. Copie la lumière `AstralGlow` du template actuel sur `Aegis_PrismShell` pour garder son halo. L'animation de rotation/flottement de la source `.blend` est une animation de présentation ; le FBX reste statique et l'orbitation en jeu est gérée par `PulseClient`.

Le pont Studio MCP utilisé ici ne fournit pas d'import direct de FBX local. Le modèle n'est donc pas encore intégré à la place ; vérifie l'échelle et le rendu dans l'aperçu Studio avant de remplacer le template actuel.
