# Refuge et place des portails

## Teinte des nouveaux imports de décor — 29 octobre 2026

Le contrôle live a trouvé les imports ajoutés dans `Workspace.PresentationV2.DetailedEnvironmentAssets` et `DetailedRefuge` uniformément gris neutre (`MeshPart.Color` 163,162,165), malgré leurs textures de mesh. Les sources ponctuelles `studio/InstallDetailedEnvironment.luau` et `studio/UpgradeRefugeAssets.luau` attribuent maintenant des variantes rouille, vert récupéré, toile kaki et pierre aux épaves, herbes, débris, abris et camions. Le passage Edit unique [`TintPresentationMeshes.edit.luau`](../../studio/qa/TintPresentationMeshes.edit.luau) sauvegarde les deux groupes et vérifie que leurs bounds ne bougent pas.

Cette passe QA est préparée, mais son application dans la scène Studio et son retest Play restent à faire après reconnexion de l’outil Studio ; aucune couleur de scène n’est revendiquée comme déjà corrigée.

## Retest de la séparation camp, boutiques et trajets — 29 octobre 2026

Le camp importé est maintenant au centre `(169.5, 4.116, 275)`, taille `(64.42, 8.23, 42.21)`. Ses 4 MeshParts ne recouvrent ni les 16 segments d'allée ni les quatre boutiques ; la marge mesurée jusqu'à une allée est de 8.29 studs. En Play, le personnage a atteint réellement les quatre invites de boutique, toutes à moins de 10 studs, puis les portails City, Power et Gridfall sans quitter le refuge. Les 19 prompts des portails de zone étaient actifs. Rapport et limites : [`refuge-camp-shop-portals-play-retest-20261029.json`](../../studio/qa/refuge-camp-shop-portals-play-retest-20261029.json).

Le tutoriel de première partie a été masqué uniquement pour cet essai de navigation ; sa fermeture normale n'a pas été testée. Les invites n'ont pas été activées, aucun achat n'a été fait. La scène Edit n'a pas été enregistrée en `.rbxl`.

## Dégagement des panneaux et corrections de raycast — 29 octobre 2026

Les 13 panneaux de 22 studs étaient trop proches de colonnes espacées de 24 studs ; la correction applique une largeur uniforme de 18 studs aux 16 panneaux autonomes, pour au moins 6 studs de marge dans chaque rangée. Les panneaux City, Factory et Lab bloquaient aussi collisions, contacts et requêtes spatiales ; ils sont maintenant décoratifs uniquement. `studio/BuildProgressionZones.luau` applique les mêmes propriétés aux panneaux qu'il construit. Les champs, prompts et cadres importés restent en place.

Vérification Play : 19/19 prompts actifs, 19/19 cadres alignés, 16/16 panneaux sans collision/requête et 0 impact dans les raycasts ciblés. Sauvegarde réversible des anciennes plaques : `ServerStorage.BeforeRefugeSignClearance_20261029`. Correctif [`CompactRefugePortalSigns.edit.luau`](../../studio/qa/CompactRefugePortalSigns.edit.luau) : passage ponctuel en Edit, ne pas installer au démarrage. Le générateur local `BuildProgressionZones.luau` n'est pas un script actif (absent du manifeste). Rapport [`refuge-sign-clearance-play-check-20261029.json`](../../studio/qa/refuge-sign-clearance-play-check-20261029.json). Aucun achat ou changement de profil. La capture visuelle a expiré : ces mesures ne valident pas les pixels.

## Audit d'accès Play — 29 octobre 2026

Avec le personnage au spawn, `PathfindingService` trouve un point d'approche à 6 studs pour chacun des 19 portails et les quatre boutiques. Pour les stands, les invites sont à 9,1 studs depuis le centre de la dalle, dans leur portée maximale de 10 studs. Les points d'arrivée utilisent la hauteur du personnage ; viser le centre des champs en hauteur ou l'intérieur des modèles de stand donnait de faux `NoPath`.

La session n'a modifié ni profil, ni scène, ni achats. Studio est revenu en Edit, console vide. Les MeshParts de 16 armes passés par `WeaponVisuals.Build` ont au moins cinq couleurs distinctes et une saturation moyenne de 0,67 à 0,82 ; les pixels et l'arme équipée n'ont pas pu être capturés. Rapport [`refuge-weapon-play-audit-20261029.json`](../../studio/qa/refuge-weapon-play-audit-20261029.json).

## Accès aux quatre boutiques — 29 octobre 2026

Les quatre boutiques de côté étaient séparées de l'allée centrale par une grande cour sans chemin balisé. Deux allées latérales en X=−125/+125 passent à l'extérieur des abris ; des connecteurs rejoignent le chemin central à Z=274, puis quatre branches courtes arrivent devant les invites. Huit filets lumineux reprennent les guides turquoise déjà utilisés dans la cour. Les 16 pièces sont décoratives (`CanCollide`, `CanTouch` et `CanQuery` désactivés) ; elles ne changent ni les invites, ni les achats, ni les zones.

En Edit : zéro intersection géométrique avec les 19 cadres de portail ; la branche s'arrête à 0,7 stud du point de prompt, bien dans sa portée. En Play SessionStudio, `PathfindingService` a trouvé une route vers l'axe central, les deux allées et les quatre boutiques. La navigation du personnage a réussi vers le connecteur central puis devant l'atelier d'améliorations. Niveau 1, pièces 0 et XP 0 après restauration ; aucun achat. Rapport [`refuge-shop-walkway-play-check-20261029.json`](../../studio/qa/refuge-shop-walkway-play-check-20261029.json).

Limites : aucune capture visuelle exploitable, aucun test mobile ou multijoueur, et la place n'a pas été enregistrée en `.rbxl` ni publiée. Le constructeur ponctuel [`BuildRefugeCourtyard.luau`](../../studio/BuildRefugeCourtyard.luau) reproduit ces voies ; ne jamais l'installer comme script de démarrage. Le passage Edit unique est [`AddRefugeShopWalkways.edit.luau`](../../studio/qa/AddRefugeShopWalkways.edit.luau) ; pour annuler seulement ce lot, supprimer `Workspace.RefugeCourtyard.ShopAccessWalkways`.

## Élargissement des voies de portails — 29 octobre 2026

Le diagnostic de la scène a trouvé des raccords de seulement 3 studs pour des ouvertures de portail de 9,5 studs, et des allées latérales de 4 studs. Les 18 raccords font maintenant 8,5 studs et les 6 allées 8 studs ; leur finition ardoise bleu-gris les distingue de l'asphalte sombre et du chemin central. Le raccord reste plus étroit que l'ouverture. Les centres et hauteurs n'ont pas bougé ; aucune collision, détection de toucher ou requête n'est ajoutée. Backup Edit : `ServerStorage.BeforeRefugePortalRouteWidth_20261029`. Passage ponctuel [`WidenRefugePortalWalkways.edit.luau`](../../studio/qa/WidenRefugePortalWalkways.edit.luau), Edit seulement.

Play `SessionStudio` : 6/6 allées et 18/18 raccords répliqués aux bonnes largeurs/couleurs, zéro pièce bloquante, 19 champs et 19 prompts actifs. Le personnage a réellement rejoint la première rangée et son seuil, puis l'allée de troisième rangée. Aucun achat, `TutorialComplete` ni changement de profil. Rapport [`refuge-portal-route-width-play-check-20261029.json`](../../studio/qa/refuge-portal-route-width-play-check-20261029.json). La capture pixel reste indisponible ; l'amélioration est mesurée et parcourue, mais son apparence finale n'est pas confirmée en capture.

Spot-check portail/niveaux du 29 octobre : `ZoneService.CanAccess` dans le serveur Play confirme Ville accessible au niveau 1 et Usine/Laboratoire refusés. L'interaction par clavier et le bouton de maintien custom n'ont pas été exercés : la caméra du client est restée à 1×1 et `ProximityPromptService.PromptShown` n'a pas rendu le bouton visible, même à 3,6 studs du champ Ville. Ce test ne prouve ni la réussite ni une panne de la prompt ; aucune modification de profil, d'XP ou de pièces. Studio arrêté en Edit, console vide. Rapport [`refuge-portal-activation-spotcheck-20261029.json`](../../studio/qa/refuge-portal-activation-spotcheck-20261029.json).

## Allées continues derrière les rangées — 29 octobre 2026

Les six bandes transversales précédentes traversaient visuellement les socles et les piliers des portails. Elles ont été remplacées par 6 allées décalées de 9 studs derrière chaque rangée et 18 raccords courts centrés devant les seuils. La géométrie reste décorative et non-collidable ; les raccords rejoignent l'allée centrale et les six accès de leur rangée. Copie de retour arrière : `ServerStorage.BeforeRefugePortalWalkwayRouteFix_20261029`. Passage ponctuel Edit : [`ConnectRefugePortalWalkways.edit.luau`](../../studio/qa/ConnectRefugePortalWalkways.edit.luau), à exécuter une seule fois, jamais en Play ni au démarrage.

En Play, 19/19 invites actives, 19/19 cadres alignés horizontalement sur leurs champs, 6 allées et 18 raccords répliqués, zéro collision haute dans leur volume de marche ; la console était vide. Après fermeture du menu/tutoriel uniquement dans la session de test (sans envoyer `TutorialComplete`), le personnage a réellement atteint l'allée de rangée, le seuil d'un portail puis l'allée extérieure. Coordonnées confirmées par `HumanoidRootPart` : `(39.8,3.8,271.2)`, `(28.6,3.9,264.8)`, `(57.3,3.9,268.9)`. Capture pixel non obtenue, et la place n'a pas été sauvegardée ni publiée. Rapport : [`refuge-portal-walkways-play-check-20261029.json`](../../studio/qa/refuge-portal-walkways-play-check-20261029.json).

## Recentrage des meshes de chaussée importés — 29 octobre 2026

En Edit, la chaussée béton, ses lignes jaunes et le marquage central étaient tous décalés de 32 studs à droite du `CentralPath` ; leurs bornes recoupaient les cadres de portails. Les trois MeshParts non-collidables sont maintenant centrés à X=0, avec une sauvegarde sous `ServerStorage.BeforeRefugeImportedLaneAlignment_20261029`. Le passage unique est [`AlignRefugeImportedLane.edit.luau`](../../studio/qa/AlignRefugeImportedLane.edit.luau).

En Play, les trois meshes restent à X=0 et les ouvertures centrales des 19 portails n'ont aucune collision extérieure. La navigation Studio a réussi vers `(0, 3, 320)`. Rapport : [`refuge-imported-lane-alignment-play-check-20261029.json`](../../studio/qa/refuge-imported-lane-alignment-play-check-20261029.json). Play est arrêté, Studio revenu en Edit ; aucun profil n'a changé et le lieu n'a pas été enregistré ou publié. Capture pixel et vérification à pied par une personne non réalisées.

## Portiques de rang et seuils d'approche — 29 octobre 2026

Trois portiques transversaux soutiennent visuellement les rangées I à III et 18 seuils sombres avec bandes de couleur balisent chaque destination. Les 90 pièces sont ancrées et sans collision, contact ou requête ; les six lumières servent d'accent. Sauvegarde réversible : `ServerStorage.BeforeRefugeTierInfrastructure_20261029`. Constructeur ponctuel Edit : [`BuildRefugeTierInfrastructure.edit.luau`](../../studio/qa/BuildRefugeTierInfrastructure.edit.luau) ; ne jamais l'installer au démarrage ou l'exécuter en Play.

Play SessionStudio : 19 invites présentes ; déplacement réel vers l'en-tête et le portail de la rangée I, l'allée, un portail de rangée III, l'accès PVP et le refuge, santé finale 100. Rapport : [`refuge-tier-infrastructure-play-check-20261029.json`](../../studio/qa/refuge-tier-infrastructure-play-check-20261029.json). La capture Studio ayant expiré, le rendu pixel reste non inspecté ; mobile, multijoueur, performance appareil, sauvegarde `.rbxl` et publication non réalisés.

## Allée plus dégagée, aile PVP et lame de machette — 29 octobre 2026

Le contrôle géométrique a révélé que l'arène PVP recoupait en X/Z l'en-tête de la troisième rangée et qu'elle occupait le milieu du passage entre les portails. L'arène a été déplacée sur l'aile droite : centre de dalle `(130, 0.37, 326)`, `FightBounds` inchangé en dimensions. Une allée pavée de 110×10 studs et deux guides lumineux la relient au chemin central. Le panneau de rang III n'est plus dans les bounds de l'arène.

Les 18 portails d'expédition sont maintenant placés aux X `−80, −52, −28, 28, 52, 80` sur les rangées Z `260, 305, 350`. La marge entre l'allée centrale et les cadres les plus proches est de 9,9 studs ; l'écart minimal entre cadres d'une rangée reste de 11,8 studs. Les 19 champs et invites restent appariés et actifs.

La lame de `Machete` était le seul MeshPart récent dont la teinte `SurfaceAppearance.Color` restait pâle. Sa teinte a été passée de `(164,209,193)` à `(52,220,174)` ; la carte de couleur et la géométrie restent en place. Les autres armes gardent leurs couleurs existantes.

`studio/qa/PolishRefugeWayfinding.edit.luau` est le passage unique en Edit. Le constructeur ponctuel `studio/BuildPvPArena.luau` reflète le placement latéral et l'accès pavé ; `studio/qa/RefineRefugePortalSpacing.edit.luau` reflète les nouvelles colonnes. Sauvegarde réversible dans `ServerStorage.BeforeRefugeWayfindingPolish_20261029`.

Play SessionStudio : 19/19 portails alignés et prompts actifs ; 335 MeshParts répliqués et teinte machette présente. Le personnage a parcouru l'accès depuis le refuge jusqu'à l'intérieur de `FightBounds`, puis est revenu à l'allée centrale avec 100 PV. Pas de duel multijoueur, de capture pixel, de contrôle mobile ni de performance appareil. Résultat : [`refuge-wayfinding-polish-play-check-20261029.json`](../../studio/qa/refuge-wayfinding-polish-play-check-20261029.json). Pas de DataStore, sauvegarde `.rbxl` ou publication.

## Accent coloré des cadres — 29 octobre 2026

Les 19 pièces métalliques des cadres étaient gris uniforme, alors que chaque portail avait une couleur d'accent propre. Leur métal est maintenant teinté depuis la couleur de son portail, à saturation 0,42 et valeur 0,31. Les champs, cadres, panneaux, invites, lumières et collisions gardent leur disposition et leurs réglages. Une copie réversible des modèles avant retouche est sous `ServerStorage.BeforeRefugeFrameAccent_20261029`.

Play client : 19/19 teintes répliquées, 19/19 lumières, cadres centrés en X/Z sur leurs champs, zéro pièce bloquante, console vide. Rapport : [`refuge-frame-accent-play-check-20261029.json`](../../studio/qa/refuge-frame-accent-play-check-20261029.json). Capture pixel indisponible ; l'effet esthétique à l'écran reste à inspecter.

## Ré-audit des portails — 29 octobre 2026

Dans l'instance Studio actuelle, les 19 champs ont chacun une invite activée, un panneau lisible, un cadre assorti et un repère lumineux. Le centre horizontal de chaque cadre correspond exactement à celui de son champ ; l'écart minimal entre cadres est de 11,8 studs. Zéro pièce de cadre/champ ne bloque les déplacements, et les anciennes étiquettes de Citadelle restent invisibles sur les cadres clonés. Cette vérification ne révèle pas de défaut de placement. Les captures d'écran Studio/Windows ont expiré : l'aspect visuel et la lisibilité en pixels restent à contrôler. Les mesures sont dans [`weapon-color-refuge-audit-20261029.json`](../../studio/qa/weapon-color-refuge-audit-20261029.json).

## Ailes boutiques, allée et arène — 29 octobre 2026

Après la première disposition, les cadres des portails les plus proches de l'allée étaient trop près d'un chemin de 12 studs. `studio/qa/RefineRefugePortalSpacing.edit.luau` a sauvegardé les 18 rangées de voyage et l'allée sous `ServerStorage.BeforeRefugePortalSpacing_20261029`, déplacé leurs champs/cadres vers X `−72, −48, −20, 20, 48, 72`, et élargi l'allée non-collidable à 24 × 170 studs avec deux guides néon latéraux. Les dix-huit paires cadre/champ sont appariées, avec 11,8 studs minimum entre cadres, 19 prompts actifs en comptant Ville et zéro chevauchement avec les boutiques, le camp, le terminal, l'arène ou les abris. En Play, les 18 destinations et 19 prompts se répliquent correctement. Les captures Play/Windows ont expiré : cette validation porte sur les propriétés et bornes, pas sur des pixels ni un trajet à pied. Détail : [`final-weapon-portal-layout-play-check-20261029.json`](../../studio/qa/final-weapon-portal-layout-play-check-20261029.json).

Les kiosques sont maintenant répartis à gauche et à droite de l'axe central : Atelier `(-110, 225)`, Armurerie `(110, 225)`, Pets `(-110, 247)` et Robux `(110, 247)`. Les quatre modèles importés ont suivi leur kiosque ; leurs `WorldPivot` ne sont plus décollés de la géométrie. `GameplayConfig.C.Shops` correspond à ces positions, et chaque prompt garde son `ShopPage` et reste activé. L'allée mesure 24 × 170 studs, centrée en `(0, 290)`, jusqu'au portail Ville, avec deux guides lumineux au bord. L'arène conserve sa taille 51,25 × 32 studs et passe à Z=326 entre les rangées des portails Z=305 et Z=350.

`studio/qa/ReorganizeRefugeEntry.edit.luau` a posé une sauvegarde réversible sous `ServerStorage.BeforeRefugeEntryLayout_20261029` puis vérifié les 4 boutiques, 19 cadres, l'allée et 0 intersection arène-portail. Play côté serveur : positions des 4 kiosques à moins de 0,025 stud des cibles, 4/4 prompts activés avec la bonne page, 4/4 coquilles alignées, 19 cadres, console vide ; Play arrêté et Studio revenu en Edit. Rapport : [`refuge-entry-layout-play-check-20261029.json`](../../studio/qa/refuge-entry-layout-play-check-20261029.json).

Limite : les captures Studio/Windows expirent ; ces bornes et associations ne valident pas l'esthétique finale en pixels, la navigation réelle à pied, le mobile ni le multijoueur. Le `.rbxl` n'a pas été enregistré et l'expérience n'a pas été publiée.

## Repères lumineux des destinations — 29 octobre 2026

Les 19 cadres ont maintenant un PointLight d'accent propre à leur destination (portée 16 studs, intensité 0,55, ombres désactivées) et leurs pièces d'accent néon reprennent la palette de la zone. Cette retouche aide à lire les portails dans le refuge nocturne sans déplacer les champs, modifier les prompts ou éclairer largement la cour. `studio/qa/PortalGuidanceLighting.edit.luau` est le passage ponctuel Edit, jamais un script de démarrage ; sauvegarde réversible dans `ServerStorage.BeforePortalGuidanceLighting_20261029`.

En Play, le client reçoit 19/19 cadres, lumières, champs et prompts ; la console est vide et Play a été arrêté. Les captures Studio et Windows ont expiré : ces mesures ne confirment pas la lisibilité en pixels. Mobile, performance sous appareil réel et trajets de portails non vérifiés. Rapport : [`portal-guidance-lighting-result-20261029.json`](../../studio/qa/portal-guidance-lighting-result-20261029.json).

La cour active mesure 380 × 190 studs, centrée en (16, 0, 295), de X −174 à 206 et de Z 200 à 390. L’allée centrale fait maintenant 24 × 170 studs. Le portail Ville reste près du spawn (champ à (0, 4,5, 208)); les 18 autres destinations occupent trois rangées de six, aux Z 260, 305 et 350. Les X sont espacés de 24, 28, 40, 28 et 24 studs, ce qui laisse au moins 11,8 studs entre cadres voisins ; les noms et niveaux restent lisibles sur les cadres. Bancs, lampes, abris, terminal et clôtures ont été écartés des voies.

Les 19 modèles visuels sont rangés sous `Workspace.ImportedEnvironmentModels.Refuge.PortalFrames`. Neuf cadres importés ont été repositionnés et dix cadres assortis créés depuis le modèle Citadelle. Chaque cadre est centré sur son champ fonctionnel, ancré et sans collision, contact ni requête ; les 19 prompts, destinations, conditions et rayons d’activation sont inchangés. Les 112 MeshParts importés de la Ville ont reçu une palette par matériau/suffixe : béton, asphalte, briques, rouille, métal, bois, verre et accents, soit 13 couleurs distinctes.

La cour reste sous `Workspace.RefugeCourtyard` (93 descendants). `studio/BuildRefugeCourtyard.luau` est l’ancien constructeur ponctuel de la base ; `studio/qa/RefugePortalHubRedesign.server.luau` applique la nouvelle disposition en Edit et ne doit jamais être installé comme script de démarrage. Les changements de scène sont sauvegardés à part dans `ServerStorage.BeforeRefugeHubRedesign_20261029`. Les sources seules ne reconstruisent pas tous les modèles importés.

## Vérifications

- Mesures Edit initiales : 19/19 champs appariés et pivots alignés, aucun chevauchement de champs, aucune pièce bloquante, 0 différence des réglages de prompt avec la copie de sauvegarde. La Ville compte 112 MeshParts en 13 couleurs. Le contrôle initial ne mesurait pas l'écart entre pivots et pièces 3D ; voir la correction ci-dessous.
- Captures Studio inspectées : vue d’ensemble de la place sombre et capture de la Ville sous éclairage QA temporairement neutralisé ; le réglage original (nuit, ombres et exposition) a été restauré après les captures.
- En Play, profil de test niveau 1 : le champ de l’Usine niveau 5 reste verrouillé ; E sur Ville transporte vers `VILLE EN RUINE` à (0, 3,9, 10), vie 100, pièces 0. Studio est revenu en Edit. Aucun achat ou changement de profil n’a été demandé.
- Rapport détaillé : `studio/qa/refuge-portal-hub-redesign-result.json`.

## Correction de la géométrie des cadres (29 octobre 2026)

Une inspection après le premier rapport a révélé que l'assertion d'alignement comparait seulement le pivot du modèle au champ : 17 cadres sur 19 avaient leur pivot en place, mais leurs MeshParts restaient jusqu'à 389,7 studs plus loin. `studio/qa/FixPortalFrameGeometry.edit.luau` a sauvegardé les 19 cadres dans `ServerStorage.BeforePortalFrameGeometryFix_20261029`, puis déplacé 162 pièces pour aligner la géométrie réelle. Mesure Edit : 19/19 cadres, écart maximal 0,005 stud, aucune pièce bloquante. En Play les mêmes valeurs se répliquent côté client ; le portail Ville conduit à `VILLE EN RUINE`, vie 100, 0 pièce, console vide. La session a été arrêtée et Studio est revenu en Edit. L'ancienne mesure de pivots seule ne prouvait pas l'alignement visuel ; les captures après correction montrent les cadres dans leurs rangées.

Une autre inspection a trouvé dix cadres clonés qui affichaient toujours « Citadelle / niveau 80 ». `studio/qa/FixRefugePortalSignage.edit.luau` a sauvegardé les 18 cadres non-Ville dans `ServerStorage.BeforeRefugePortalSignage_20261029`, masqué 36 anciennes lettres mesh et créé des panneaux visuels nom/niveau à partir de `WorldConfig`, avec trois bandeaux de rangée (05–45, 60–160, 180–280). Mesure Edit : 18/18 textes corrects, aucun ancien texte visible, trois bandeaux, aucune pièce bloquante. En Play, les 18 mêmes textes et trois bandeaux étaient présents côté client ; console vide puis Stop/Edit. La capture écran a expiré dans Play et Edit : la lisibilité à l'écran reste à confirmer visuellement.

## Plaques des portails d'expédition corrigées — 29 octobre 2026

Une nouvelle inspection des modèles `Travel_*` a trouvé 13 panneaux supplémentaires, distincts des plaques posées sur les cadres : les zones 100 à 280 affichaient encore « Citadelle des cendres - niv. 80 », et les niveaux 45–80 avaient des panneaux de 42 studs pour des portails espacés de 30. `studio/qa/FixRefugeTravelSigns.edit.luau` a sauvegardé les 13 panneaux dans `ServerStorage.BeforeRefugeTravelSigns_20261029`, puis corrigé leur texte depuis `WorldConfig` et ramené leur largeur à 22 studs (8 studs de dégagement entre panneaux voisins). Les trois plaques déjà compactes restent inchangées. Harbor, Power et Metro n'ont pas de `ZoneSign` autonome ; leurs cadres conservent leur signalétique.

Play côté client confirme 19/19 prompts, 16/16 panneaux présents avec nom et niveau exacts, aucun panneau au-dessus de 22 studs, et 36/36 textes recto-verso corrects sur les 18 cadres. Console vide ; Play arrêté et Studio revenu en Edit. Ces mesures géométriques ne remplacent pas l'approbation visuelle en pixels ; les captures Studio ont expiré. Rapport : [`refuge-travel-signs-play-check-20261029.json`](../../studio/qa/refuge-travel-signs-play-check-20261029.json). Les constructeurs ponctuels `BuildCraterExpansion`, `BuildGlassSeaExpansion`, `BuildSkylineExpansion`, `BuildOrbitalWreckExpansion`, `BuildDepthsExpansion`, `BuildIronSanctumExpansion`, `BuildLastConvoyExpansion`, `BuildGridfallExpansion`, `BuildBlackoutCoreExpansion` et `BuildEclipseVaultExpansion` mettent maintenant à jour le nom/niveau et la largeur des panneaux clonés ; `BuildFrontierExpansions` crée des plaques de portail compactes.

## Géométrie détachée des abris et du terminal (29 octobre 2026)

La vérification des `GetBoundingBox()` a révélé une seconde catégorie d'import dont le pivot avait bougé sans les MeshParts : quatre abris étaient physiquement à Z 618–817 au lieu de Z 235/365 ; le terminal était à Z 629 au lieu de Z 300. `studio/qa/FixRefugeDisconnectedModels.edit.luau` a sauvegardé les cinq modèles dans `ServerStorage.BeforeRefugeGeometryPass2_20261029` et translaté 22 pièces afin que les quatre abris et le terminal retrouvent leur base, au sol, dans les emplacements définis par la cour. Les erreurs de position de base mesurées après correction sont de 0 stud pour les cinq modèles.

`studio/qa/RefugePortalHubRedesign.server.luau` applique désormais cette correction après `PivotTo` et l'assertion finale vérifie cinq modèles, pour éviter qu'une nouvelle reconstruction ne réintroduise le décalage des pivots importés. Contrôle Play côté client : cinq bases à moins de 0,05 stud, zéro pièce de décor bloquante, 19 cadres appariés aux champs, 18 panneaux, trois bandeaux et zéro bloqueur de portail. Capture visuelle non confirmée dans cette passe ; ces preuves valident le placement et les propriétés physiques. Détail : [`refuge-geometry-pass2-result.json`](../../studio/qa/refuge-geometry-pass2-result.json).

## Décor du camp superposé aux portails (29 octobre 2026)

Le groupe fusionné par matériau `Refuge_04_Vie_du_camp` occupait 180,45 × 118 studs, centré au milieu des rangées. Son empreinte recouvrait les champs des portails et ses panneaux d'expédition étaient positionnés dans la même bande ; l'absence de collision ne détectait donc pas ce conflit visuel. `FixRefugeCampPortalOverlap.edit.luau` a sauvegardé les quatre MeshParts dans `ServerStorage.BeforeRefugeCampPortalClearance_20261029`, puis les a réduits à 42 % et déplacés dans l'aile droite. Empreinte finale : 75,79 × 49,65 studs, base Y=0, centre (135, 310). Assertions Edit et Play : zéro recouvrement projeté avec les 19 cadres, aucun recouvrement PVP, décor dans la cour, zéro pièce bloquante. Le constructeur ponctuel `RefugePortalHubRedesign.server.luau` reprend ce déplacement et ces assertions.

La session Play a confirmé les bornes répliquées côté client, les 19 cadres et l'absence de texte d'arme « à modéliser » ; une nouvelle session propre a démarré sans message Console, puis Play a été arrêté. Le clic de démarrage automatisé a expiré ; le tutoriel d'accueil garde le déplacement à l'arrêt tant qu'il n'est pas terminé, donc aucun trajet joueur n'a été mesuré. Capture de la scène actuelle indisponible : le placement est vérifié par bounds et non approuvé visuellement. Rapport : [`refuge-camp-portal-clearance-result.json`](../../studio/qa/refuge-camp-portal-clearance-result.json).

Une commande d’inspection de Studio a généré une erreur de diagnostic en cherchant `Workspace.PVPZone`, qui n’existe pas ; aucune erreur de script de jeu n’est apparue dans cette sortie. Ces essais ne couvrent pas le mobile, le multijoueur, tous les trajets latéraux ou l’ensemble des interactions du refuge. Aucun `.rbxl` n’a été enregistré et l’expérience n’a pas été publiée.

### Correction du chevauchement camp/arène PvP (29 octobre 2026)

La relocalisation précédente du camp en `(135, 310)` est devenue obsolète après le déplacement ultérieur de l’arène PvP à X=130 et l’ajout de son accès : le modèle recouvrait l’arène. En Edit, les quatre MeshParts du camp ont été conservés à la même échelle et déplacés au centre `(160, 280)`. Le banc qui occupait le nouvel emplacement a été déplacé avec ses quatre pièces à `(40, 380)`. La copie antérieure du camp est conservée dans `ServerStorage.BeforeRefugeCampArenaClearance_20261029`.

Assertions Edit et Play : 4 MeshParts répliqués, 19 cadres de portail sans recouvrement (marge d’au moins 1 stud), séparation d’au moins 2 studs de l’allée d’accès PvP et de l’arène ; les six bancs sont présents et le banc déplacé est répliqué. La console Play est vide et Studio est revenu en Edit. Le constructeur [`studio/qa/RefugePortalHubRedesign.server.luau`](../../studio/qa/RefugePortalHubRedesign.server.luau) reprend la position corrigée et la nouvelle place du banc. Rapport : [`refuge-camp-pvp-clearance-play-check-20261029.json`](../../studio/qa/refuge-camp-pvp-clearance-play-check-20261029.json).

Contrôle géométrique et réplication uniquement : pas de capture visuelle exploitable, test mobile, multijoueur ni déplacement du joueur dans cette passe. La place n’a pas été enregistrée en `.rbxl` et n’a pas été publiée.
## Ajustement des panneaux des portails — 29 octobre 2026

Les panneaux dynamiques d’expédition dépassaient de 2,9 studs de chaque côté des cadres importés de 12,2 studs. En Edit, les 15 panneaux d’expédition présents passent de 18 à 14 studs, et le panneau principal Ville passe à 20 studs ; les destinations Harbor, Metro et Power n’ont pas de panneau dynamique, car leur cadre porte déjà une étiquette 3D intégrée. La sauvegarde des panneaux est `ServerStorage.BeforeRefugePortalSignFit_20261029`. Le constructeur local `BuildProgressionZones.luau` reprend ces dimensions (Ville 20, autres 14), sans être installé comme script de démarrage.

En Play : 19/19 invites actives, champs et cadres sans décalage horizontal, marge minimale de 10 studs entre panneaux d’une même rangée ; le personnage a atteint une porte de chacune des trois rangées et a rejoint le centre. Aucun achat, grant ou tutoriel complété. Les statistiques visibles (niveau, pièces, arme équipée) sont restées inchangées. Rapport [`refuge-weapon-visuals-and-portal-fit-play-check-20261029.json`](../../studio/qa/refuge-weapon-visuals-and-portal-fit-play-check-20261029.json). Capture pixel indisponible : le gain d’alignement est mesuré, pas validé visuellement. Les modifications Edit ne sont pas enregistrées en `.rbxl`.
