# Modèles pour Weapon Evolution — lot de travail

Ce dossier rassemble les FBX disponibles. Le 28 octobre 2026, l'utilisateur les a importés dans Studio et les modèles de décor ont été placés. Les 16 armes de mêlée Hook à EclipseGlaive sont maintenant reliées au catalogue, aux aperçus et à l'équipement ; les rigs et poses zombies restent des références non intégrées. Le lot ne couvre pas toutes les zones ni tous les zombies.

Dernier inventaire Play attesté (29 octobre) : 30 modèles pour les 30 armes hors poings, 335 MeshParts au total, dont 16 modèles Blender et 14 modèles MeshPart générés séparément par Roblox Studio. Rapport [`weapon-mesh-models-play-check-20261029.json`](../../studio/qa/weapon-mesh-models-play-check-20261029.json). Cette preuve runtime ne garantit pas que la copie Studio ouverte actuellement ni l'écran vu par l'utilisateur contiennent ces modèles.

- `Armes/` : 16 bases de mêlée, une par identifiant du catalogue. `Arsenal.blend` est la source et `Apercu_arsenal.png` montre les silhouettes avec des accents saturés distincts. Les couleurs de lame couvrent maintenant la silhouette entière, avec un cœur plus clair ; il s'agit de matériaux FBX, sans textures peintes. `manifest.json` donne les noms, `verification.json` contrôle géométrie et palette après réimport Blender. `Hook_mesh_test.json` a uniquement servi à tester l'API Studio et n'est pas un fichier à importer.
- `Armes_existantes/` : Machete et Sledgehammer, deux exports Blender précédents qui ne sont pas raccordés. Les modèles Play rapportés pour ces identifiants sont des MeshParts Roblox générés séparément (assets `76546528260139` et `105802326641489`), pas ces deux FBX.
- `Refuge_et_Ville/` : 37 modules de l'ancienne étude de refuge et de Ville. Ce sont des éléments de décor, pas une scène prête à remplacer l'existant. L'arène PVP de référence est volontairement omise. Les positions, collisions, matériaux et portails doivent être contrôlés avant remplacement. Détails : `../refuge_city_rework/README.md`.
- `Zombies_Ville/` : trois rigs et leurs clips Idle, Walk et Attack de l'étude Blender précédente. Les clips nécessitent un rig compatible et une intégration d'animation Roblox ; ce ne sont pas des zombies prêts à apparaître en jeu.

## État d'intégration

Les 16 modèles Blender sont conservés dans `ServerStorage.ImportedModelPrototypes.Weapons` à l'échelle 0,01 ; le dernier audit Play rapporte 30 modèles répliqués sous `ReplicatedStorage.WeaponModels` en comptant les 14 MeshParts Roblox générés. Les modèles font 2,27 à 3,74 studs de haut. `WeaponVisuals` normalise la prise sur le manche et construit les aperçus, le viewmodel et la représentation soudée au personnage. Les 12 rigs/poses restent dans `ServerStorage.ImportedModelPrototypes.ZombieAnimationReferences`. Ils contiennent `AnimationController`, Bones et `Motor6D`, mais aucun `Humanoid`, `Animator` ou objet `Animation` ; ne pas les substituer directement aux templates zombies actuels.

Les 37 décors Refuge/Ville sont dans `Workspace.ImportedEnvironmentModels` et ancrés sans collision/contact/requête. Les modèles fonctionnels de portail et boutique restent en place ; leurs 19 invites portail et 4 invites boutique étaient présentes après placement. La copie intégrale des 68 imports Studio est dans `ServerStorage.BeforeImportedModelPlacement` ; trois doublons sont sous `EarlierDuplicateImports`. Les deux FBX `Armes_existantes/Machete.fbx` et `Sledgehammer.fbx` n'ont pas été trouvés parmi les modèles importés.

Les déplacements, portails, matériaux sous la vraie nuit et performances des décors restent à contrôler ; ces vérifications concernent Refuge/Ville, pas les armes reliées. Les décors actuels n'ont pas de collision ; les sols et routes existants restent les surfaces physiques.

## Vérifications et limites

Les 16 FBX recolorés ont été exportés puis réimportés dans Blender 5.2.3 ; géométrie, accent non gris et palette unique par arme sont vérifiés. L'aperçu Blender est inspecté ; la couleur dans Roblox et le remplacement des anciens modèles déjà importés restent à vérifier dans Studio.

Un essai d'envoi de la géométrie réelle du crochet a été effectué depuis Studio : `CreateAssetAsync and CreateAssetVersionAsync are not available yet`. Aucun de ces nouveaux FBX n'a été importé automatiquement. Les autres zones et les espèces qui réutilisent des gabarits restent à modéliser.
