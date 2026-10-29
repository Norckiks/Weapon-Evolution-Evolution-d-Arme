# Regression ledger

Ce registre suit les chemins touchés par l'intégration des modèles d'armes et la disposition des imports du refuge. Les dépendances viennent des références locales et des scripts inspectés dans Studio ; le graphe Graphify consulté est antérieur à ces modifications.

## Modèles équipés et infrastructure des rangées

- Armes : TEST-WEAPON-ARMORY-PLAY-FRESH-20261029 vérifie les 31 aperçus, puis équipe séparément les 30 armes hors poings en `SessionStudio`; attendu : 30/30 visuels personnage, 335 pièces, restauration à Fists et nettoyage du fixture. Rapport [`studio/qa/weapon-armory-play-check-20261029-fresh.json`](studio/qa/weapon-armory-play-check-20261029-fresh.json). La capture première personne reste nécessaire pour confirmer les pixels.
- Refuge : TEST-REFUGE-TIER-INFRASTRUCTURE-PLAY-20261029 contrôle 3 portiques, 18 seuils, 90 pièces décoratives non bloquantes, six lumières, 19 prompts et parcours en Play. Rapport [`studio/qa/refuge-tier-infrastructure-play-check-20261029.json`](studio/qa/refuge-tier-infrastructure-play-check-20261029.json).
- Tout déplacement de rangée relance les assertions Edit de `BuildRefugeTierInfrastructure.edit.luau`, puis vérifie l’accès physique à chaque rang et l’arène en Play ; aucune fixture QA ne doit être conservée dans le jeu.

## Armurerie et ouverture du tutoriel

- Armes : **TEST-WEAPON-MODELS-PLAY-SESSION5-20261029** ouvre l'armurerie depuis l'état du service serveur et vérifie 31 rangées/aperçus avec caméra et géométrie, 30 modèles répliqués, aucun texte de modélisation. Rapport [`studio/qa/weapon-model-play-check-20261029-session5.json`](studio/qa/weapon-model-play-check-20261029-session5.json). L'ancien audit palette est invalide et son erreur documentée dans son JSON ; ne pas l'utiliser comme critère.
- Tutoriel : **TEST-TUTORIAL-RESPONSIVE-SCALE-PLAY-20261029** exige que `layoutTutorial` s'appuie sur la taille ScreenGui, garde une UIScale positive quand la caméra est 1×1, et réagisse aux changements de taille. Rapport [`studio/qa/tutorial-responsive-scale-play-check-20261029.json`](studio/qa/tutorial-responsive-scale-play-check-20261029.json). Le clic d'étape, le portrait/paysage et la manette restent à tester physiquement.
## GameplayConfig

- Consommateurs : `GameHub`, `WeaponVisuals`, `FistsClient`, `EconomyService`, `WeaponMotion` et `AdminService` lisent le catalogue ou l'ordre des armes.
- Preuve de dépendance : `rg -n 'Weapons|WeaponOrder|ModelPending' studio`.
- Acceptation : **TEST-WEAPON-MODELS-PLAY-SESSION5-20261029**, ouvrir ARMURERIE en Play et vérifier 31 aperçus 3D, géométrie et absence de texte « model/modéliser ». Rapport courant : [`studio/qa/weapon-model-play-check-20261029-session5.json`](studio/qa/weapon-model-play-check-20261029-session5.json).
- Propagation : tout changement d'identifiant, de définition ou d'accès aux modèles relance ce test.
- Retest actuel : [`studio/qa/weapon-models-current-play-check-20261029.json`](studio/qa/weapon-models-current-play-check-20261029.json) construit les 30 armes hors poings en Play (30/30 géométrie non vide, 335 MeshParts sources, 0 `ModelPending` courant). L'armurerie n'a pas été rouverte pendant ce retest ; le clic automatisé a expiré. Le rapport Session5 reste la preuve runtime des cartes et de leurs ViewportFrames.

## WeaponVisuals

- Consommateurs actifs : aperçus `ViewportFrame` de `GameHub` et viewmodel première personne de `FistsClient`.
- Preuve de dépendance : `rg -F -n 'WeaponVisuals.Build' studio`.
- Acceptation : TEST-WEAPON-MODELS-001 couvre les 16 aperçus, le viewmodel Hook à la caméra et l'équipement soudé de Hook.
- Acceptation caméra : **TEST-WEAPON-PREVIEW-FRAMING-001** reconstruit les 31 aperçus en Play, vérifie la projection des huit coins de chaque modèle sous la rotation ±0,32 radian, et exige une emprise maximale ≤ 1,0. Résultat : [`studio/qa/weapon-preview-camera-fit-result.json`](studio/qa/weapon-preview-camera-fit-result.json).
- Propagation : tout changement de clone, pivot, manche ou tableau `pieces` relance les trois parcours Play ; les compteurs de meshes ne remplacent pas une capture visuelle.

## Palette et modèles d'armes

- Acceptation de la palette de secours : [`studio/qa/weapon-palette-runtime-fallback-play-check-20261029.json`](studio/qa/weapon-palette-runtime-fallback-play-check-20261029.json) : 16/16 imports temporairement grisés récupèrent une palette, 16/16 modèles déjà colorés sont préservés, sources restaurées.
- Palette finale : **TEST-FINAL-WEAPON-PALETTE-ENFORCEMENT-20261029** force ArcPike, BlackoutEdge et EclipseGlaive à reprendre leurs palettes définies même si un import contient déjà cinq couleurs saturées incorrectes. En Play, griser puis recolorer incorrectement les sources doit produire les trois teintes de rôle, un cœur Neon, cinq couleurs distinctes et une restauration exacte des modèles sources. Rapport [`studio/qa/weapon-final-palette-enforcement-play-check-20261029.json`](studio/qa/weapon-final-palette-enforcement-play-check-20261029.json).
- Accent local des noyaux finaux : [`studio/qa/final-weapon-core-point-lights-play-check-20261029.json`](studio/qa/final-weapon-core-point-lights-play-check-20261029.json) vérifie une lumière colorée sur chaque modèle répliqué/prototype et sur les clones `WeaponVisuals.Build`. Toute réimportation de ces modèles doit conserver ou réappliquer `WeaponCoreGlow` ; vérifier le rendu pixel sur les armes portées lorsque la capture Studio fonctionne.

- Consommateurs : `GameHub` (`WeaponPreview`) et `FistsClient`; les prototypes sont conservés dans `ServerStorage.ImportedModelPrototypes.Weapons`.
- Mesurer HSV avec `local _, saturation = part.Color:ToHSV()` ; ne pas confondre le premier retour, la teinte, avec la saturation. Pour la configuration actuelle, lire `GameplayConfig.Source` si le cache `require` de `execute_luau` est en cause.
- Propagation : tout changement de clone ou palette relance `GameHub` et `FistsClient` en Play. Réimport FBX, matériau ou texture relance le contrôle de tint ; toute `SurfaceAppearance` exige un tint compatible avec sa carte de couleur.
- Acceptation UI/équipement : **TEST-WEAPON-MODELS-PLAY-SESSION5-20261029**. Rapport [`studio/qa/weapon-model-play-check-20261029-session5.json`](studio/qa/weapon-model-play-check-20261029-session5.json). La capture pixel et l'arme en première personne restent requises pour confirmer le rendu visuel.
## EconomyService

- Consommateurs : `CharacterCombat` lit `EquippedWeaponVisual` et `WeaponMechanism`; `FistsClient` masque l'arme monde en première personne et affiche le viewmodel.
- Preuve de dépendance : `rg -n 'EquippedWeaponVisual|WeaponMechanism|VisualWeaponId' studio`.
- Acceptation : TEST-WEAPON-MODELS-001 accorde temporairement Hook en Studio, l'équipe et contrôle 17 soudures sur la main droite ; Play est arrêté ensuite pour effacer le grant de session.
- Propagation : les changements de prise, de soudure ou d'équipement relancent le contrôle serveur et le contrôle première personne. Ne jamais installer les fixtures QA au démarrage ou publier pour tester.

## Géométrie des cadres de portail

- Consommateurs : `Workspace.ImportedEnvironmentModels.Refuge.PortalFrames` est la présentation des champs `Workspace.ProgressionZones.RefugePortals.Travel_*` ; leur fonctionnement et leurs prompts doivent rester inchangés.
- Preuve de dépendance : association par suffixe `City` et les 18 identifiants de `WorldConfig` ; comparer chaque `Model:GetBoundingBox().Position` au pivot et au champ `Travel_*` correspondant.
- Acceptation : **TEST-REFUGE-FRAME-GEOMETRY-001** et **TEST-REFUGE-PORTAL-SIGNAGE-001**. En Edit, comparer les bounds à chaque pivot/champ et les textes à `WorldConfig`; en Play, vérifier 19 cadres, 18 libellés, trois en-têtes, l'écart inférieur à 0,05 stud et aucune pièce bloquante. Les helpers Edit ponctuels sont `studio/qa/FixPortalFrameGeometry.edit.luau` et `studio/qa/FixRefugePortalSignage.edit.luau`. Résultat : [`studio/qa/refuge-portal-hub-redesign-result.json`](studio/qa/refuge-portal-hub-redesign-result.json).
- Propagation : tout déplacement, réimport, clonage ou réorganisation relance la mesure physique et l'assertion des noms/niveaux, pas seulement la vérification des pivots. Les copies de restauration sont dans `ServerStorage.BeforePortalFrameGeometryFix_20261029` et `ServerStorage.BeforeRefugePortalSignage_20261029`.

## Dégagement de l'allée et entrée PVP

- Consommateurs : `Workspace.ProgressionZones.RefugePortals.Travel_*`, `Workspace.ImportedEnvironmentModels.Refuge.PortalFrames`, `Workspace.SurvivorArena.FightBounds`, `Workspace.RefugeCourtyard.PVPAccessPath` et `PvPService.Contains`.
- Acceptation : **TEST-REFUGE-WAYFINDING-POLISH-001**. En Edit, comparer les 19 champs/cadres, écart des portails ≥10 studs, marge de l'allée ≥8 studs, l'arène à X=130, le panneau de rang III séparé de l'arène et le chemin connecté. En Play, tester le trajet aller/retour et l'état de santé ; aucune progression ni récompense. Rapport : [`studio/qa/refuge-wayfinding-polish-play-check-20261029.json`](studio/qa/refuge-wayfinding-polish-play-check-20261029.json).
- Propagation : tout déplacement de `SurvivorArena` doit déplacer son `FightBounds` avec le modèle ; vérifier `PvPService.Contains` sur le même point avant/après. Les changements de scène réversibles sont sous `ServerStorage.BeforeRefugeWayfindingPolish_20261029`.

## Géométrie des abris et du terminal

- Consommateurs : les modèles importés `Refuge_Abri_01` à `Refuge_Abri_04` et `Refuge_03_Terminal` sous `Workspace.ImportedEnvironmentModels.Refuge` ; le constructeur `studio/qa/RefugePortalHubRedesign.server.luau` repositionne leurs pivots.
- Preuve de dépendance : mesure reproductible de `Model:GetPivot()` contre `Model:GetBoundingBox()` sur les cinq modèles en Edit ; avant correction, leurs géométries physiques étaient à 383–452 studs des positions prévues.
- Acceptation : **TEST-REFUGE-DETACHED-ENVIRONMENT-001**. Exécuter `studio/qa/FixRefugeDisconnectedModels.edit.luau` en Edit, puis contrôler base au sol dans les cinq cibles, zéro collision/contact/requête et mêmes positions en Play. L'assertion est reprise dans le constructeur du refuge. Résultat : [`studio/qa/refuge-geometry-pass2-result.json`](studio/qa/refuge-geometry-pass2-result.json).
- Propagation : chaque changement de pivot ou réimport de décor relance les bornes physiques ; ne jamais se satisfaire du seul `GetPivot()`. Sauvegarde : `ServerStorage.BeforeRefugeGeometryPass2_20261029`.

## Rang des améliorations et évolution des pets

- Consommateurs : `GameplayConfig`, `EconomyService` et `GameHub` pour Vie, Vitesse, Souffle et Puissance ; `PetRanks` pour les bonus et le coût en copies.
- Contrat : les anciens rangs/prix gardent leurs effets ; les achats restent validés/débités côté serveur. Les rangs progressent jusqu'au garde-fou technique, les effets décroissent après rang 25 (statistiques) ou 5 (pets), les prix de statistiques plafonnent au portefeuille de 2 milliards et le coût de copies à 100 000.
- Harnais : `studio/qa/StaminaUpgrade.server.luau`, `studio/qa/PetRanks.server.luau` et `studio/qa/PetRanksUI.client.luau` ont été adaptés pour tester la progression après les anciens plafonds, la saturation des prix, le garde-fou et les reçus/données existants. Ils ne sont pas des scripts runtime.
- État de cette passe : sources comparées aux scripts Studio en Edit et changements synchronisés ; les harnais n'ont pas été lancés en Play. Exécuter uniquement en SessionStudio et restaurer les profils/personnages avant Stop.

## Empreinte du camp dégagée des portails

- Consommateurs : `Workspace.ImportedEnvironmentModels.Refuge.Refuge_04_Vie_du_camp`, les `PortalFrames` et `Workspace.SurvivorArena.FightBounds`.
- Preuve de dépendance : les quatre meshes fusionnés occupaient 180,45 × 118 studs et croisaient les rangées de portails ; leurs parties sont non-collidables, donc un simple comptage de collisions ne détectait pas la superposition visuelle.
- Acceptation : **TEST-REFUGE-CAMP-PORTAL-CLEARANCE-001**. Le harnais `studio/qa/FixRefugeCampPortalOverlap.edit.luau` sauvegarde, réduit et déplace le groupe ; mesurer l'empreinte, la base Y, les 19 cadres et l'arène en Edit et Play. Résultat : [`studio/qa/refuge-camp-portal-clearance-result.json`](studio/qa/refuge-camp-portal-clearance-result.json).
- Propagation : toute retouche de l'échelle, du centre, des portails ou de l'arène relance le contrôle de recouvrement XZ ; le constructeur du refuge reprend l'assertion. Sauvegarde : `ServerStorage.BeforeRefugeCampPortalClearance_20261029`.

## Pivots des imports Ville et refuge

- Consommateurs : déplacements Studio et scripts appelant `Model:PivotTo()` sur `Workspace.ImportedEnvironmentModels.City` et `Workspace.ImportedEnvironmentModels.Refuge`.
- Défaut corrigé : 17 pivots sans `PrimaryPart` étaient à 63,5–399,7 studs du centre des bounds ; ils partageaient des coordonnées d'origine d'export Blender. Les `WorldPivot` sont recentrés sans déplacer les descendants.
- Acceptation : [`studio/qa/imported-environment-pivot-repair-play-check-20261029.json`](studio/qa/imported-environment-pivot-repair-play-check-20261029.json) : 17 pivots alignés en Play, 114 BaseParts inchangés et console vide. Backup `ServerStorage.BeforeImportedEnvironmentPivotRepair_20261029` ; restauration ponctuelle [`studio/qa/RestoreImportedEnvironmentPivots.edit.luau`](studio/qa/RestoreImportedEnvironmentPivots.edit.luau).
