# Tests Studio uniquement

`TintPresentationMeshes.edit.luau` est un passage unique en Edit pour les meshes gris neutre de `Workspace.PresentationV2.DetailedEnvironmentAssets` et `DetailedRefuge`. Il sauvegarde des clones réversibles dans `ServerStorage.BeforePresentationMeshTints_20261029`, applique des variantes rouille/olive/toile/pierre et vérifie que la géométrie reste identique. Arrêter Play avant exécution ; ne jamais installer au démarrage. Les constructeurs correspondants sont `studio/InstallDetailedEnvironment.luau` et `studio/UpgradeRefugeAssets.luau`.

`AddFinalWeaponCoreLights.edit.luau` ajoute des PointLights aux noyaux Neon des 3 armes finales, sur les modèles répliqués et leurs prototypes. Passage ponctuel Edit avec assertions et sauvegarde sous `ServerStorage.BeforeFinalWeaponCorePointLights_20261029` ; ne jamais installer au démarrage. Le contrôle Play des ViewportFrames et de `WeaponVisuals.Build` est dans `final-weapon-core-point-lights-play-check-20261029.json`. Vérification des instances uniquement, sans capture pixel.

`refuge-camp-shop-portals-play-retest-20261029.json` documente le trajet physique Play après le recentrage/réduction du camp : les 4 boutiques et trois rangées de portails sont atteignables, les invites sont dans leur portée, et le camp ne chevauche ni allées ni stands. Le tutoriel a été masqué temporairement pour ce contrôle ; ne pas en déduire que son interaction normale est validée.

`refuge-sign-clearance-play-check-20261029.json` vérifie la réduction des 16 panneaux de portail, leur exclusion des collisions/raycasts, les 19 prompts/cadres et l'ARMURERIE réelle en Play. Les aperçus des trois dernières armes ont chacun cinq couleurs distinctes ; aucune capture pixel exploitable. Correctif [`CompactRefugePortalSigns.edit.luau`](CompactRefugePortalSigns.edit.luau) à lancer une fois seulement en Edit ; sauvegarde avant changement : `ServerStorage.BeforeRefugeSignClearance_20261029`. Ne jamais l'installer au démarrage.

`weapon-model-play-user-followup-20261029.json` documente le retest Play demandé : 31 cartes 3D remplies, 30/30 modèles hors poings présents, zéro entrée `ModelPending` et zéro texte de modélisation. Vérification par instances runtime, sans capture pixel ; Play arrêté ensuite.

`refuge-weapon-visuals-and-portal-fit-play-check-20261029.json` couvre les accents Neon des trois armes finales et le resserrage des panneaux du refuge : 31 aperçus avec géométrie, 19 invites actives, 19 alignements X/Z, 16 panneaux redimensionnés, puis parcours des trois rangées. Sauvegardes Edit dans `ServerStorage.BeforeFinalWeaponEmissionAccents_20261029` et `ServerStorage.BeforeRefugePortalSignFit_20261029`. Aucune capture pixel ; la console garde l'assertion d'une sonde de test trop stricte sur Y, distincte d'une erreur jeu.

`weapon-model-play-retest-20261029-final.json` est le nouveau retest demandé : 31 cartes/caméras, 0 aperçus vides, 337 pièces 3D, 30 modèles source/335 pièces, aucun libellé ni identifiant du catalogue sans modèle. La capture et le clic automatisés ont échoué ; les instances sont vérifiées, pas les pixels. Les deux messages AssistantCommand en console viennent des probes de diagnostic et sont détaillés dans le rapport.

`weapon-palette-runtime-fallback-play-check-20261029.json` vérifie la recoloration de secours sur 16 imports temporairement grisés sans modifier leurs sources ; aucune validation pixel.

`weapon-models-current-play-check-20261029.json` confirme en Play 30 modèles source, 30 constructions non vides et la page ARMES réelle (31 ViewportFrames avec caméra/géométrie, aucun libellé de modélisation). Les trois aperçus finaux ont 5 couleurs chacun et un noyau Neon ; le paquet d'affichage de test est synthétique, aucun achat/équipement effectué.

`imported-environment-pivot-repair-play-check-20261029.json` vérifie le recalage des pivots de 17 modèles importés sans déplacer leurs 114 BaseParts, puis leur réplication en Play. Sauvegarde réversible et script de restauration documentés dans le rapport.

`refuge-weapon-play-audit-20261029.json` consigne le retest Play : 19/19 portails et 4/4 dalles de boutique accessibles par PathfindingService, puis 16/16 armes importées colorées via `WeaponVisuals.Build`. Captures pixel, arme en première personne, mobile et multijoueur non vérifiés ; aucun achat ni changement de données.

## Reprise palette / tutoriel — 29 octobre 2026

Le rapport `weapon-palette-audit-reapplied-play-check-20261029.json` est invalidé : l'audit initial a lu la teinte au lieu de la saturation et un `require` isolé a renvoyé un cache obsolète. La restauration a repris `ServerStorage.BeforeWeaponPalettePass4_20261029`. Le rapport Play correct est `weapon-model-play-check-20261029-session5.json` : 30 modèles répliqués, 31 aperçus armurerie avec caméra/géométrie, aucun texte « model/modéliser ». Pour relire la saturation, utiliser `local _, saturation = color:ToHSV()` ; lire `GameplayConfig.Source` directement au lieu du cache `require` de `execute_luau`. Ne pas relancer une recoloration pour ce bug d'étiquette.

`GameHub` : TEST-TUTORIAL-RESPONSIVE-SCALE-PLAY-20261029 vérifie la mise à l’échelle initiale et les changements de taille du ScreenGui. Le test sur 800×600 est dans `tutorial-responsive-scale-play-check-20261029.json`. Les interactions souris/clavier n'ont pas été validées ; ne pas en déduire une validation mobile/manette.
## Retests d'armes et de rangées du refuge — 29 octobre 2026

`weapon-armory-play-check-20261029-fresh.json` documente la page ARMURERIE (31 cartes/aperçus) puis l'équipement temporaire des 30 armes hors poings en `SessionStudio` (30/30 visuels personnage, 335 pièces). Le fixture restitue `Fists`, puis Play doit être arrêté.

`BuildRefugeTierInfrastructure.edit.luau` est un constructeur ponctuel à exécuter une seule fois en Edit sur la place attendue ; il crée une sauvegarde avant les 3 cadres et 18 seuils. Ne jamais installer ce constructeur en démarrage ou le lancer en Play. `refuge-tier-infrastructure-play-check-20261029.json` consigne ensuite les 19 prompts et le parcours réel en Play. Aucune sauvegarde `.rbxl` ou publication.

## Dégagement des portails et accès PVP

`ConnectRefugePortalWalkways.edit.luau` remplace les bandes qui traversaient les cadres par 6 allées derrière les rangées et 18 raccords devant les seuils. Il sauvegarde les anciennes bandes sous `ServerStorage.BeforeRefugePortalWalkwayRouteFix_20261029`. Passage ponctuel, une fois en Edit seulement ; jamais au démarrage ou en Play. Le rapport `refuge-portal-walkways-play-check-20261029.json` distingue les vérifications de géométrie du trajet joueur non confirmé.

`WidenRefugePortalWalkways.edit.luau` est une réparation ponctuelle Edit : elle sauvegarde les voies, passe les six allées latérales de 4 à 8 studs et les 18 raccords de 3 à 8,5 studs, avec une finition ardoise moins sombre. Elle vérifie chaque branche, l'ouverture des portails et l'absence de collision/contact/requête. Backup `BeforeRefugePortalRouteWidth_20261029`; rapport Play `refuge-portal-route-width-play-check-20261029.json`. Jamais en Play ni au démarrage.

`refuge-portal-activation-spotcheck-20261029.json` distingue le test serveur des niveaux du test d'activation. Ville est autorisée et Usine/Laboratoire refusés au niveau 1 ; l'activation UI reste en attente tant que la caméra client de Studio est 1×1. Pas de script de diagnostic persistant.

`AlignRefugeImportedLane.edit.luau` corrige en Edit un décalage d'import confirmé : les maillages de route `concrete`, `yellow` et `paint` sont 32 studs à droite du `CentralPath`. Le script vérifie les positions et l'absence de collision/contact/requête, sauvegarde les trois MeshParts dans `ServerStorage.BeforeRefugeImportedLaneAlignment_20261029`, puis les aligne à X=0 et affirme 7,7 studs de dégagement minimum avec les cadres proches. Exécuter une seule fois dans la place attendue, après comparaison, uniquement en Edit ; jamais au démarrage ou en Play. Vérifier ensuite les 19 portails et la route en Play, puis arrêter Play.

`PolishRefugeWayfinding.edit.luau` est une réparation unique à lancer dans Studio Edit après comparaison des 19 couples cadre/champ, du panneau de rang III et de l'arène. Elle sauvegarde les modèles touchés sous `ServerStorage.BeforeRefugeWayfindingPolish_20261029`, écarte les portails de l'allée, déplace l'arène sur l'aile droite, crée l'accès pavé, et teinte la lame de machette via `SurfaceAppearance.Color` sans remplacer sa `ColorMap`. Le script affirme l'alignement, l'écart des cadres et l'absence de recoupement avec le panneau. Ne jamais l'installer ou l'exécuter en Play. Résultat Play : `refuge-wayfinding-polish-play-check-20261029.json`.

`BuildPvPArena.luau` reste un constructeur ponctuel, jamais un script de démarrage ; il place l'arène à X=130 et crée la branche PVP pour une nouvelle construction. `RefineRefugePortalSpacing.edit.luau` conserve l'espacement final X −80, −52, −28, 28, 52, 80.

`AdjustWeaponColorGrade.edit.luau` est une modification ponctuelle en Edit : elle exige l'ancien `SurvivalFilmGrade.Saturation=-0.2`, sauvegarde l'effet dans `ServerStorage.BeforeWeaponColorGrade_20261029`, puis le relève à `-0.05` sans changer le reste de Lighting. `AdjustApocalypseColorGrade.edit.luau` corrige aussi le second filtre qui neutralisait le résultat : backup dans `ServerStorage.BeforeApocalypseGradeColorPass_20261029`, saturation `ApocalypseGrade` de `-0.28` à `-0.05`. Les deux filtres doivent se répliquer en Play sans modifier l'heure, la luminosité ni l'exposition ; arrêter Play ensuite. Jamais au démarrage. Rapport final `apocalypse-color-grade-play-check-20261029.json` ; capture visuelle non obtenue.

`ReorganizeRefugeEntry.edit.luau` déplace en Edit les quatre boutiques, leurs coquilles importées, l'arène et l'allée centrale après contrôle du placeId et des positions sources. Une sauvegarde réversible et des assertions de collision/prompts précèdent la validation ; Play confirme la réplication. Exécuter une seule fois, uniquement en Edit, ne jamais installer au démarrage. Résultat `refuge-entry-layout-play-check-20261029.json`.

`HighlightFinalWeaponCores.edit.luau` sauvegarde puis renforce en Edit les noyaux lumineux d'ArcPike, BlackoutEdge et EclipseGlaive dans les modèles répliqués et les prototypes. Vérifier l'absence de `BeforeFinalWeaponCoreGlow_20261029` avant l'unique exécution ; jamais en Play ou au démarrage. `RecolorWeaponModels.edit.luau` conserve cette règle lors d'une recoloration ultérieure. Résultat `final-weapon-core-glow-play-check-20261029.json`.

`PortalGuidanceLighting.edit.luau` applique en Edit un éclairage d'orientation léger et coloré sur les 19 cadres de portail (PointLight, portée 16, ombres désactivées), et renforce leurs accents néon par zone. Il sauvegarde les cadres sous `ServerStorage.BeforePortalGuidanceLighting_20261029`, puis vérifie que les 19 champs et prompts restent présents. Reproductible, idempotent et jamais destiné au démarrage. Après exécution, vérifier la réplication en Play et arrêter Play ; rapport `portal-guidance-lighting-result-20261029.json`. La capture Studio n'a pas répondu, donc le rendu à l'écran reste à confirmer.

`RefineRefugePortalSpacing.edit.luau` est une correction ponctuelle Edit des dix-huit destinations : champs/cadres en rangées à X `{−72, −48, −20, 20, 48, 72}`, allée centrale de 24 × 170 studs et guides néon de bord. Sauvegarde préalable dans `ServerStorage.BeforeRefugePortalSpacing_20261029`, prompts et conditions inchangés ; vérifier les déplacements, l’alignement cadre/champ et l’absence de recouvrement, puis valider la réplication en Play. Jamais au démarrage.

`EnhanceFinalWeaponPalettes.edit.luau` applique la palette haute saturation aux trois armes finales et à leurs prototypes, enlève la variante expérimentale des 55 MeshParts et aligne les couleurs dans `GameplayConfig`. Sauvegarde préalable `ServerStorage.BeforeFinalWeaponPaletteFix_Pass2_20261029`; Edit uniquement, jamais au démarrage. Contrôler couleurs, matériau et réplication en Play ; aucun paramètre de dégâts/progression n’est changé.

## Recoloration ponctuelle des modèles d'armes

`RecolorWeaponModels.edit.luau` est une réparation unique à exécuter dans le DataModel Edit après comparaison des modèles présents. Elle pré-vérifie les 16 armes et le nommage des pièces, sauvegarde l'état courant dans `ServerStorage.BeforeWeaponPalettePass3_20261029`, puis colore toutes les pièces des 16 modèles répliqués et des prototypes disponibles par rôle (lame, cœur, poignée, manche, quincaillerie). Elle refuse les MeshParts texturés sans stratégie de tint. Lire `ServerStorage.WeaponPalettePass3EditResult`. Ce fichier n'est pas un script de démarrage ni un test Play ; ne pas l'ajouter au jeu. Une passe Blender locale seule ne change pas les modèles déjà importés.

`FixPortalFrameGeometry.edit.luau` est une réparation unique en Edit. Elle vérifie les 19 associations cadre/champ et les pivots, copie les cadres actuels sous `ServerStorage.BeforePortalFrameGeometryFix_20261029`, puis translate leurs pièces physiques pour faire coïncider la géométrie et le pivot. Elle termine avec une assertion d'écart inférieur à 0,05 stud. Jamais en Play ou au démarrage. Résultat vérifié dans `refuge-portal-hub-redesign-result.json`.

`FixRefugePortalSignage.edit.luau` corrige une fois les panneaux depuis les noms/niveaux réels de `WorldConfig`, masque les anciennes lettres mesh et ajoute trois en-têtes de rangée. Il sauvegarde les 18 cadres concernés sous `ServerStorage.BeforeRefugePortalSignage_20261029`, puis vérifie les 18 panneaux et trois rangées. Edit uniquement, jamais au démarrage ; Play valide la réplication des textes. La capture Studio a expiré, donc le rapport sépare les assertions de données de la confirmation visuelle.

`FixRefugeTravelSigns.edit.luau` répare en Edit les 13 panneaux des portails qui étaient trop larges ou reprenaient le nom de la Citadelle : nom et niveau relus dans `WorldConfig`, plaque ramenée de 42 à 22 studs. Les panneaux sont copiés dans `ServerStorage.BeforeRefugeTravelSigns_20261029` avant modification. Les trois autres panneaux compacts restent tels quels ; Harbor, Power et Metro utilisent leurs cadres visuels. Vérifier en Play les 19 prompts et les 16 panneaux présents, puis arrêter Play. Résultat `refuge-travel-signs-play-check-20261029.json`. Ne jamais installer au démarrage.

`FixRefugeDisconnectedModels.edit.luau` corrige en Edit quatre abris et le terminal dont les pivots étaient à la bonne cible mais les pièces 3D restaient à plusieurs centaines de studs. Le script sauvegarde les cinq modèles dans `ServerStorage.BeforeRefugeGeometryPass2_20261029`, translate leur géométrie pour poser la base au sol et affirme une erreur inférieure à 0,05 stud. La correction est aussi dans `RefugePortalHubRedesign.server.luau` pour les futurs placements. Jamais en Play ou au démarrage. Résultat Play/Edit : `refuge-geometry-pass2-result.json`.

`FixRefugeCampPortalOverlap.edit.luau` sauvegarde puis réduit et déplace le groupe importé `Refuge_04_Vie_du_camp`, dont les panneaux et accessoires recouvraient les nouvelles rangées de portails. Le test assert la base au sol, les limites de la cour, zéro recouvrement avec les cadres et l'arène PVP. Exécuter une seule fois en Edit ; ne pas installer en démarrage. Vérifier d'abord l'absence de sauvegarde existante `BeforeRefugeCampPortalClearance_20261029`. Le constructeur ponctuel `RefugePortalHubRedesign.server.luau` reprend ce placement pour les reconstructions.

Après le déplacement de l'arène et de son allée, le camp doit rester à `(160, 280)` et le banc qui occupait cet espace à `(40, 380)`. `ClearRefugeCampFromPVP.edit.luau` documente les assertions Edit et Play et réutilise la sauvegarde `BeforeRefugeCampArenaClearance_20261029`. Usage ponctuel en Edit uniquement ; ne jamais l'installer au démarrage. Rapport Play : `refuge-camp-pvp-clearance-play-check-20261029.json`.

## Arène PvP

Après installation de `SurvivorArena`, démarrer Play puis injecter `PvPArena.server.luau` comme Script ordinaire dans le serveur. Le harnais vérifie les limites, le refus hors arène, l'absence de chevauchement avec les zones zombies et le refus de s'infliger des dégâts ; il ne déplace ni personnage ni données, puis s'autodétruit. Une seule session ne prouve pas les dégâts entre deux joueurs. Rapport `pvp-arena-result.json`, guide `docs/reference/PVP.md`. Jamais en Edit ou en démarrage.

## Nuit et lampe torche

`NightLighting.client.luau` est une fixture visuelle temporaire en Play SessionStudio : menu masqué, caméra fixe réglable via `PlayerGui.NightLightingQA.Camera`, aucun déplacement ou gain de progression. F déclenche la torche réelle ; `Check:Invoke()` vérifie cœur/halo, option graphique et budget de quatre ombres fixes. Éteindre la torche, appeler `Restore:Invoke()`, puis Stop et rétablir le simulateur. Jamais en Edit/démarrage. Rapport `night-lighting-result.json`, guide `docs/reference/AMBIANCE_NUIT.md`.

## HUD critique et raccourcis adaptatifs

En Play SessionStudio, installer MaximumHUD.server, appeler `PrepareMaximumHUD:Invoke(false)` ; CriticalHUD.client fournit six contrôles et restaure ses valeurs locales. ResponsiveShortcuts.client prend un snapshot PC, téléphone paysage, portrait et retour PC ; supprimer son résultat local avant chaque nouvelle sonde. `RestoreMaximumHUD:Invoke()` impératif avant Stop, puis simulateur default/LandscapeLeft. Rapport critical-responsive-hud-result.json et guide UI_MOBILE.md. Ne jamais installer en Edit.

## Réapparition et contrat Ville

En Play SessionStudio, exécuter CityRespawn.server comme Script temporaire et lire CityRespawnQAResult ; puis CityContractPacing.server et lire CityContractPacingQAResult. Le second restaure Meta/statistiques/flags/santé ; Stop efface les morts de zombies et les séries temporaires. Rapport city-respawn-result.json, guide CONTRATS_EXPRESS.md. Ne jamais installer en Edit.

## Parcours portail Usine

En Play SessionStudio après Jouer, installer PortalWalk.server comme Script temporaire. Parcourir l’entrée au niveau 1, puis `SetPortalWalkLevel:Invoke(5)` avant l’entrée et le retour au clavier. Appeler `RestorePortalWalkQA:Invoke()` avant Stop. Rapport portal-walk-result.json, guide ZONES.md. Ne pas installer en Edit.

## Repère d’achat de l’atelier

En Play SessionStudio, installer AffordableUpgradeHint.server comme Script temporaire. `SetAffordableUpgradeHint:Invoke("Low"/"Exact"/"Stamina"/"Maxed")` prépare les cas ; inspecter le raccourci client, puis impérativement `RestoreAffordableUpgradeHint:Invoke()` avant Stop. Rapport affordable-upgrade-hint-result.json, guide ENDURANCE.md. Jamais en Edit.

## Lisibilité du HUD téléphone

En Play SessionStudio après démarrage et stabilisation du simulateur, exécuter ReadableMobileHUD.client comme LocalScript temporaire ; lire PlayerGui.ReadableMobileHUDQAResult. Rejouer en portrait et paysage avec ContextButtonFrame visible et masqué. Quatre snapshots (14+14+23+23) : readable-mobile-hud-result.json. Stop et remise du simulateur à default/LandscapeLeft. Ne rien installer en Edit.

## Animation de vie

En Play SessionStudio, exécuter HUDHealthMotion.client comme LocalScript temporaire et lire PlayerGui.HUDHealthMotionQAResult. Quatre contrôles, restauration santé/max/option automatique puis Stop. Rapport hud-health-motion-result.json ; voir docs/reference/UI_MOBILE.md. Ne rien installer en Edit.

## Cour du refuge

En Play SessionStudio, exécuter RefugeCourtyard.server comme Script temporaire et lire ServerStorage.RefugeCourtyardQAResult. 14 contrôles, rapport refuge-courtyard-result.json. Le constructeur BuildRefugeCourtyard est ponctuel en Edit et ne doit jamais démarrer comme script. Voir docs/reference/REFUGE.md.

## Élites

En Play SessionStudio uniquement : RemoteFunction EliteQABridge, EliteBridge.client dans PlayerGui, puis Elites.server comme Script temporaire. Lire ServerStorage.ElitesQAResult : le harnais restaure ses données et sa caméra, puis arrêter Play pour effacer les compteurs temporaires de chasse. Les morts sont attribuées par le harnais, pas par des attaques utilisateur. 59 contrôles passés : elites-result.json.

## Rangs de pets

Play SessionStudio : LevelRewardsQABridge + PetRanksBridge.client (rafale dans un seul callback), puis Script ordinaire PetRanks.server. Lire PetRanksQAResult. PreparePetRankUI Ready/RankOnly/Locked/BeyondCap/TechnicalLimit ; poser PetRanksQAPhase côté client pour PetRanksUI.client. RankOnly ne rouvre pas la page. Retirer l’attribut et appeler RestorePetRanksQA avant Stop. Le rapport historique pet-ranks-result.json ne couvre que l’ancien plafond de trois rangs ; exécuter le harnais actualisé avant de revendiquer une validation de la progression sans plafond pratique. Guide EVOLUTION_PETS.md. Ne pas installer ces QA en Edit.


## Mitrailleuse

Play SessionStudio : FirearmsQABridge/FirearmsBridge.client, puis LMG.server (30). Pour moteurs : LMGMotionBridge + LMGMotion.client puis LMGMotion.server (19), restitutions automatiques. LMGCatalog.server prépare34/35, ReadLMGCatalog lit l’état par service ordinaire ; RestoreLMGCatalog impératif avant Stop après tests manuels. Carbine.server actualisé28 checks. Rapport lmg-result.json et guide MITRAILLEUSE.md. Aucun QA en Edit/démarrage.


## Métro

Play SessionStudio : MetroQABridge + MetroBridge.client puis Metro.server (55 checks, rapport metro-spawn-fix-result.json), restitution automatique et RestoreMetroQA après toute préparation manuelle. MetroCombatQABridge + MetroCombatBridge.client puis MetroCombat.server (3 vrais tirs) séparément. Régressions séquentielles : ContractZones (55) et LevelRewards (35), avec LevelRewardsQABridge/LevelRewardsBridge.client. Jamais ces QA en Edit. Constructeur BuildMetroExpansion ponctuel uniquement Edit, pas en démarrage. Rapport metro-result.json et guide METRO.md.


## Décharge

Play SessionStudio : créer ArcQABridge, installer ArcBridge.client puis Arc.server comme Script ordinaire. Respecte les vrais délais20s entre les trois activations (environ45s). Lire ArcQAResult ; restitution automatique. Ensuite ArcRegression.server (six contrôles module), AbilityBindings.client (neuf bindings/conflits). Rapport arc-result.json et guide DECHARGE.md. Ne pas installer en Edit.


## Calendrier de connexion

Play SessionStudio : LevelRewardsQABridge + LevelRewardsBridge.client, puis Script ordinaire LoginCalendar.server. Lire ServerStorage.LoginCalendarResult (41 checks). PrepareLoginCalendarUI(Ready/Claimed/Full), définir LoginCalendarQAPhase côté client puis exécuter LoginCalendarUI.client (5 assertions/cas), retirer l’attribut puis RestoreLoginCalendarQA impérativement avant Stop. Aucun test de reconnexion réelle ou de passage réel à minuit. Rapport login-calendar-result.json et guide CONNEXION.md.


## Guetteur et régression carabine

Play SessionStudio uniquement. FirearmsQABridge + FirearmsBridge.client puis Marksman.server ou Carbine.server comme Script ordinaire ; résultats MarksmanQAResult/CarbineQAResult. Marksman restaure automatiquement et laisse PrepareMarksmanUI(27/28) et RestoreMarksmanQA. Pour le modèle porté : RemoteFunction MarksmanMotionBridge, LocalScript MarksmanMotion.client puis Script MarksmanMotion.server ; lire MarksmanMotionResult, restitution automatique. Caméra temporaire et échantillonnage Heartbeat, pas de preuve FPS. Guides/preuves dans GUETTEUR.md ; ne jamais installer ces scripts en Edit.


## Primes express par zone

En Play SessionStudio : LevelRewardsQABridge et le pont générique LevelRewardsBridge.client.luau, puis ContractZones.server.luau comme Script temporaire ordinaire. Lire ContractZonesQAResult (49 checks). UI : PrepareContractZoneUI(multiplier,count), puis RestoreContractZoneQA avant Stop. Contrats Ville : Contracts.server.luau (sept régressions). Trois contenus de texte UI vérifiés ; pas de preuve visuelle ou mobile. Rapport contract-zones-result.json et guide CONTRATS_EXPRESS.md.

## Première chasse du jour

En Play SessionStudio : créer LevelRewardsQABridge, installer le pont générique LevelRewardsBridge.client.luau puis FirstDailyHunt.server.luau comme Script temporaire ordinaire. Lire ServerStorage.FirstDailyHuntQAResult (21 checks). Préparation UI : PrepareFirstHuntUI:Invoke(Locked/Ready/Claimed/Full), puis RestoreFirstHuntQA:Invoke() impérativement. Quatre propriétés de carte vérifiées, rendu nul : pas de preuve visuelle/clic. Rapport first-daily-hunt-result.json et guide PREMIERE_CHASSE.md. Ne rien installer en Edit.

## Cadence du HUD

En Play SessionStudio : HubStatus.server.luau comme Script temporaire, puis HubStatus.client.luau. Lire PlayerGui.HubStatusQAResult, appeler ServerStorage.RestoreHubStatusQA:Invoke(), puis Stop. Six checks de propriétés/cadence avec rendu nul ; rapport hub-status-result.json et guide HUD_CADENCE.md. Les transitions de menu/options enregistrées sont provoquées par attributs, pas des preuves d'interaction clavier ou de rendu. Ne pas installer en Edit.

## Centrale foudroyée

Voir docs/reference/CENTRALE.md avant reprise : rendu Play inactif lors de cette passe. QA uniquement en SessionStudio : RemoteFunction PowerQABridge, PowerBridge.client.luau puis Power.server.luau comme Script ordinaire. Résultat PowerQAResult (49 contrôles), bindables PreparePowerQA et RestorePowerQA pour les approches de portails. Tirs séparés : PowerCombatQABridge, PowerCombatBridge.client.luau puis PowerCombat.server.luau, résultat PowerCombatQAResult (trois vrais tirs). Métadonnées/statistiques/position restaurées, Stop après essais. Portails natifs, nouveaux pets/UI et captures rapprochées Play restent à vérifier quand RenderStepped reprend. Les scripts QA Harbor ont reçu un correctif de nombre minimum de zones et de vitesse SprintConfig au lieu d'une ancienne constante 16 ; leur harnais complet n'a pas été rejoué dans ce lot.

## Amélioration Souffle

En Play SessionStudio : créer RemoteFunction StaminaUpgradeQABridge, installer StaminaUpgradeBridge.client.luau, puis StaminaUpgrade.server.luau comme Script temporaire. Lire ServerStorage.StaminaUpgradeQAResult. Le test inclut une réapparition réelle ; profil/statistiques/position restaurés. Pour l'UI, PrepareStaminaUpgradeUI:Invoke(), ReadStaminaUpgradeQA:Invoke(), puis RestoreStaminaUpgradeQA:Invoke(). Réinitialiser simulateur et Stop. Résultats dans stamina-upgrade-result.json, règles dans docs/reference/ENDURANCE.md. Ne pas installer en Edit.

## Primes de niveau

Le harnais courant couvre dix primes jusqu'au niveau 28 et trois frontières du plafond de pièces (34 contrôles). `level-rewards-capacity-result.json` conserve cette passe et deux contrôles des propriétés du bouton client ; rendu inactif, aucune validation visuelle ajoutée. Le rapport initial à neuf primes reste historique.

Créer LevelRewardsQABridge (RemoteFunction) en Play, installer LevelRewardsBridge.client.luau et LevelRewards.server.luau comme scripts temporaires ordinaires. SessionStudio obligatoire. Lire ServerStorage.LevelRewardsQAResult ; 34 contrôles actuels, restauration automatique après le test serveur. Pour des essais UI, PrepareLevelRewardUI:Invoke(niveau 1 ou niveau de prime), ReadLevelRewardQA:Invoke(), puis impérativement RestoreLevelRewardQA:Invoke(). Réinitialiser simulateur et arrêter Play. Rapport courant level-rewards-capacity-result.json, rapport initial level-rewards-result.json ; détails PRIMES_DE_NIVEAU.md. Ne rien installer en Edit.

## HUD compact et images cartoon

`CompactCartoonUI.client.luau` : snapshot en lecture seule, uniquement en Play, après ouverture d'un onglet et stabilisation du simulateur. Contrôle dimensions, trois images chargées, TextFits et boutons contenus dans les cartes ; cible tactile minimale de 44 px. Pour changer de page, employer les vrais boutons ou B/N/G (réappuyer sur le raccourci de la page courante ferme le menu). Aucun ajout aux scripts actifs. Résultats et limites dans `compact-cartoon-ui-result.json` et `docs/reference/UI_MOBILE.md`.

## Carabine et objectif d'arsenal

Session Play neuve SessionStudio : créer FirearmsQABridge (RemoteFunction) côté serveur, installer FirearmsBridge.client.luau, puis Carbine.server.luau comme Script temporaire. Lire ServerStorage.CarbineQAResult (27 contrôles lors de la passe enregistrée). Le profil, les statistiques et la position sont restaurés après le pcall. Ne pas installer en Edit.

Pour la présentation, préparer une arène avec profil restaurable (IdeasMovement.server.luau), accorder/équiper Carbine et niveau 22 dans ce snapshot. Installer CarbinePresentation.client.luau ; à PlayerGui.CarbinePresentationQAResult == AwaitNativeShot, cliquer une fois ; à AwaitQuietNativeShot, cliquer une seconde fois. Le sampler FPS se connecte avant ce second clic pour ne pas manquer l'animation locale pendant la latence serveur. Lire le JSON final (dix contrôles). Appeler ServerStorage.RestoreIdeasQA:Invoke(), restaurer le simulateur et arrêter Play après les essais UI. WorldMechanisms.server/client couvre les 33 régressions de revolver/pompe avec le nouveau timing de réception. Résultat complet dans carbine-result.json ; guide PROGRESSION_ARMES.md pour les preuves et limites.

## Changements de format en cours de session

En Play SessionStudio après Jouer/Entrée/A et hors menus, installer temporairement `ResponsiveHUD.client.luau` dans PlayerScripts. Lire PlayerGui.ResponsiveHUDQAResult (six assertions en tactile, quatre en PC). Rejouer après chaque mode PC/portrait/paysage et attendre que le viewport ait changé ; les sept boutons CAS doivent exister sans duplication. `AbilityBindings.client.luau` vérifie aussi les huit conditions de raccourcis, y compris l'absence de collision avec SurvivalStart. Rapport `responsive-hud-result.json` ; arrêt de Play et simulateur default/LandscapeLeft à la fin.

Pour diagnostiquer les clics, une sonde ordinaire InputBegan doit accepter Touch et MouseButton1 : le simulateur téléphone convertit la souris en tactile. Comparer les coordonnées réellement reçues aux objets de GetGuiObjectsAtPosition avant de déclarer un bouton défectueux. Ne pas supposer qu'un `Success` de l'outil a activé le bouton. ButtonStart n'est pas arrivé dans la sonde de cette passe ; A et Entrée, oui.

## Commandes de capacités

Dans une session Play SessionStudio avec tous les contrôleurs chargés, installer temporairement `AbilityBindings.client.luau` dans PlayerScripts. Lire PlayerGui.AbilityBindingsQAResult : sept mappings clavier/manette et aucune collision parmi les actions Survival/Survivor/Fists. Cela vérifie les bindings, pas des périphériques physiques.

Le rapport `ability-controls-result.json` ajoute des entrées natives enregistrées par un observateur serveur et le clic mobile sur une Égide sélectionnée. Pour rejouer : préparer un personnage niveau 20 au sol en Ville dans une fixture SessionStudio restaurable, équiper un pistolet et retirer une balle ; observer les transitions GunReloading autour de R, puis AbilityId/ReadyAt autour de T, J et DPadLeft. Préparer la simulation mobile avant de démarrer Play pour tester le sélecteur ; trois clics depuis ONDE choisissent Égide. Confirmer GuardUntil/délai serveur après le clic principal. Restaurer profil/personnage et simulateur, puis arrêter Play. Ne jamais installer ces QA en Edit ou en public.

## Mécanismes en troisième personne

En Play neuf SessionStudio, cliquer Jouer puis installer `WorldMechanisms.server.luau` temporairement dans ServerScriptService. Installer `WorldMechanisms.client.luau` dans PlayerScripts ; attendre ClientReady côté Client sur ReplicatedStorage.WorldMechanismsQABridge. Côté serveur, définir l'attribut Run de cette RemoteFunction à true. Lire ServerStorage.WorldMechanismsQAResult jusqu'au résultat final (33 assertions lors de la passe enregistrée). Le harnais accorde des armes au profil temporaire, teste de vrais tirs et rechargements, échantillonne les mécanismes et isole la pose Slam côté client pour ReducedMotion. Il restaure le profil et enlève la plateforme même après une assertion en échec ; arrêter Play après lecture. Ne jamais installer en Edit ou en public.

Le repos après rechargement se contrôle sur LastPosition/LastAngle : les maxima peuvent inclure la première frame encore ancienne. L'essai de pompe demande une cadence de rendu suffisante pour observer son mouvement de .22 à .65 s après le tir. Résultat `world-mechanisms-result.json`, portée et limites dans `docs/reference/ANIMATIONS_ARMES.md`.

## Idées : vitesse, course et vue

En Play SessionStudio uniquement : installer `IdeasMovement.server.luau` comme Script serveur temporaire. Lire `ServerStorage.IdeasMovementQAResult` (cinq assertions) ; ce harnais laisse une arène et un profil préparé au pistolet. Installer `IdeasRun.client.luau` temporairement dans PlayerScripts puis maintenir W/Maj au moins 2 s pour échantillonner les vrais déplacements. Lire `PlayerGui.IdeasRunQAResult`. Pour un second passage, supprimer le résultat précédent ou définir l'attribut ResultName du script, replacer le personnage au départ et dégager la piste. Confirmer ReducedMotion avant un essai réduit. L'angle total inclut Animator et ne mesure pas isolément l'atténuation ajoutée.

À la fin, appeler `ServerStorage.RestoreIdeasQA:Invoke()` pour restaurer le profil et enlever l'arène, puis arrêter Play. Ne pas installer ces scripts en Edit. `Expansion.server.luau` vérifie les bonus avec la base SprintConfig ; `Movement.server.luau` couvre glissade/franchissement. Résultats du lot dans `ideas-result.json`, explications et limites dans `docs/reference/IDEES_IMPLEMENTEES.md`.

## Fusil à pompe

Dans une session Play neuve SessionStudio, créer FirearmsQABridge et installer FirearmsBridge.client.luau côté Client. Exécuter d'abord Firearms.server.luau (33 régressions), puis Shotgun.server.luau (30 contrôles, chargeur du fusil encore neuf), puis ShotgunKill.server.luau (cinq contrôles et vraie mort Civilian). Lire les StringValue FirearmsQAResult, ShotgunQAResult et ShotgunKillQAResult dans ServerStorage. Un seul harnais à la fois. Après préparation d'un personnage démarré/équipé avec un chargeur plein, ShotgunPresentation.client.luau attend un vrai clic de tir pendant 90 s, puis teste pompe, effets et deux recharges. Lire PlayerGui.ShotgunPresentationQAResult. Son compteur final comprend trois tirs (un natif, deux remotes de test), dont un muet ; ses assertions intermédiaires vérifient un événement/flash/son et sept traceurs pour le premier tir.

Fixtures temporaires uniquement, arrêter Play après tous les essais même en cas d'échec. Les achats des harnais passent par le service économique ; l'achat par clic PC et TIR simulé ont été vérifiés séparément. Rapport shotgun-result.json. Aucun test production ou tactile/manette physique.

## Dossiers d'expédition

Créer ExpeditionsQABridge (RemoteFunction) dans ReplicatedStorage serveur Play. Installer ExpeditionsBridge.client.luau dans PlayerScripts côté Client, puis Expeditions.server.luau comme Script serveur temporaire. Lire ServerStorage.ExpeditionsQAResult jusqu'au JSON final. Le harnais modifie le profil temporaire, attribue un décès à un vrai zombie et teste douze réclamations par le vrai remote client ; il restaure ensuite le profil. Arrêter Play même en cas d'échec. Résultats et captures inspectées décrits dans expeditions-result.json et docs/reference/EXPEDITIONS.md. La sérialisation JSON n'est pas un test de reconnexion DataStore.

Coordonnées d'entrée : la correction d'origine ci-dessous est spécifique au téléphone simulé testé. Sur PC, le centre absolu sans cette correction a fonctionné pour le bouton de dossier ; le centre corrigé n'a pas réclamé la récompense. Toujours vérifier le changement serveur, ne pas généraliser une seule formule à tous les simulateurs.

## Capacités et animations

Dans une session Play SessionStudio, installer temporairement Abilities.server.luau comme Script serveur. Attendre ReplicatedStorage.AbilitiesQAControl == "ReadyFrost", puis côté Client appeler UseAbility:FireServer("Frost", Vector3.new(0,0,-1)). Quand l'état passe à ReadyAegis, appeler UseAbility:FireServer("Aegis"). Le harnais mesure une cible à 58 studs, hors axe/hors portée, la garde pendant l'attaque et le retour des dégâts à son expiration. Lire ServerStorage.AbilitiesQAResult.

Pour le soin et la frappe, utiliser AbilityVisuals.server.luau, attendre ReadyHeal puis envoyer UseAbility:FireServer("SecondSouffle"); attendre ReadySlam, puis envoyer UseAbility:FireServer("Slam"). Lire ServerStorage.AbilityVisualsQAResult. Compter les instances d'effet dans Workspace.LocalPulseFX côté Client pendant leur courte durée : en rendu normal, le soin ajoute 12 étincelles et 8 segments de halo ; la frappe ajoute 12 fissures et 12 segments de vague. Ces deux harnais restaurent le niveau, les PV et le pivot ; arrêter Play après lecture des résultats. Ils ne doivent jamais être installés en Edit.

## Onde de choc et coordonnées du simulateur

Créer PulseQABridge (RemoteFunction) dans ReplicatedStorage côté serveur Play, puis installer PulseBridge.client.luau comme LocalScript temporaire dans PlayerScripts **côté Client**. Installer Pulse.server.luau comme Script serveur temporaire et lire ServerStorage.PulseQAResult jusqu'au JSON final. Ce harnais utilise une vraie réapparition, des cibles factices et de vrais zombies ; il respecte le délai privé existant au lieu de le réinitialiser. Restaurer les options, puis arrêter Play même en cas d'échec. Aucun de ces fichiers n'est installé en Edit.

Pour les clics automatiques sur un téléphone simulé, le centre AbsolutePosition + AbsoluteSize/2 peut inclure une origine de ScreenGui décalée (ici Y=-58). Le ciblage par instance_path n'a pas atteint le bouton pendant ces essais. Les coordonnées qui ont fonctionné sont : **centre absolu du bouton − AbsolutePosition du ScreenGui ancêtre**, envoyées explicitement à moveTo, avec attente puis mouseButtonDown/attente/mouseButtonUp. Confirmer Activated ou la transition serveur ; « Success » du seul outil ne prouve pas le clic.

Le verrouillage de souris de la vue subjective peut nécessiter, pour le test souris en émulation mobile, une libération temporaire après Camera. Cette fixture doit être retirée ; ne pas modifier les contrôles mobiles du jeu pour compenser l'outil. Le clic portrait ONDE a été confirmé avec FistsPunch d'origine. Le clic Jouer a été confirmé depuis un menu préparé, pas comme essai physique ou démarrage initial sans fixture. Résultats pulse-result.json.

## Extension du port

Harbor.server.luau est un Script serveur temporaire SessionStudio : contrôles de scène/spawns, accès 19/20, vrais callbacks de morts avec dégâts létaux attribués par le test, fragments et fusion, bonus et réapparition. HarborCombat.server.luau exige le pont Firearms côté Client et sa RemoteFunction : tirs réels dans le port, recharge et récompenses d'un matelot. Il ancre temporairement les racines des zombies du port et restaure leurs états ; arrêter Play après le test, y compris en cas d'échec. Résultats ServerStorage.HarborQAResult et HarborCombatQAResult. Consulter harbor-result.json pour les preuves obtenues et les limites.

Ne jamais installer ces fichiers en Edit ou les publier. Exécuter un seul harnais à la fois sur un joueur Studio chargé, avec PersistenceMode=SessionStudio. Ils modifient temporairement inventaire, monnaie, personnage et état de menu. Arrêter Play à la fin même en cas d'échec.

## Armes

`ApplyFinalWeaponContrastPalettes.edit.luau` est un passage ponctuel Edit pour ArcPike, BlackoutEdge et EclipseGlaive. Il sauvegarde les modèles répliqués et prototypes dans `ServerStorage.BeforeFinalWeaponContrastPass_20261029`, puis applique les accents complémentaires et noyaux lumineux. `RecolorWeaponModels.edit.luau` reprend la palette. Rapport `weapon-final-contrast-palette-play-check-20261029.json` : vérification du vrai `WeaponVisuals.Build`, pas une capture pixel. Ne pas exécuter en Play ni au démarrage.

`VerifyFinalWeaponPaletteEnforcement.server.luau` est un fixture Play temporaire : il confirme d'abord que les trois modèles n'ont ni `TextureID` ni `SurfaceAppearance`, les grise puis teste aussi une palette saturée erronée, vérifie les rôles accent/métal/cœur dans le vrai `WeaponVisuals.Build` et restaure leurs couleurs/matériaux. Il s'autodétruit après avoir écrit son résultat ; ne jamais l'installer en Edit ni comme script de démarrage. **TEST-FINAL-WEAPON-PALETTE-ENFORCEMENT-20261029** : [`weapon-final-palette-enforcement-play-check-20261029.json`](weapon-final-palette-enforcement-play-check-20261029.json), six cas réussis, console vide. La capture pixel n'est pas disponible.

`weapon-model-play-recheck-20261029-final.json` documente le contrôle Play du catalogue et la suppression de l'ancien libellé « À modéliser ». Il vérifie les 31 entrées, 16 modèles importés, 14 modèles construits par `WeaponVisuals` et zéro aperçu vide. Contrôle des instances/pièces, pas de capture visuelle ; Play arrêté ensuite.

Le harnais Firearms couvre maintenant Pistolet, SMG et Revolver (33 contrôles dans revolver-result.json). Après préparation d'un personnage démarré et équipé du revolver en SessionStudio, RevolverPresentation.client.luau peut être installé comme LocalScript temporaire dans PlayerScripts côté Client : il tire/recharge deux fois, échantillonne la pose réellement rendue et les étapes sonores, puis restaure ReducedMotion/SFXEnabled. Résultat PlayerGui.RevolverPresentationQAResult. Les munitions de session sont consommées puis rechargées ; arrêter Play après essai. Ne jamais installer ce sampler en Edit.

1. Partir d'une session Play neuve : les chargeurs sont propres à la session.

2. Créer en serveur Play une RemoteFunction nommée FirearmsQABridge dans ReplicatedStorage.

3. Installer temporairement FirearmsBridge.client.luau comme LocalScript dans PlayerScripts ; attendre sa liaison.

4. Installer Firearms.server.luau comme Script temporaire dans ServerScriptService.

5. Lire ServerStorage.FirearmsQAResult jusqu'à obtention du JSON final. Lire aussi la console si le résultat reste Running.

6. Arrêter Play pour supprimer le pont et les scripts temporaires. Le pont n'est pas un composant du jeu.

Le pont permet au harnais serveur de demander de vraies émissions client. RemoteEvent:FireServer ne fonctionne pas dans un Script serveur. La rafale est émise en un seul appel client, pour éviter que la latence des allers-retours transforme le test en tirs espacés.

## Autres harnais

Expansion.server.luau, Movement.server.luau et Contracts.server.luau s'exécutent en Script serveur temporaire. Leurs résultats sont respectivement ExpansionQAResult, MovementQAResult et ContractsQAResult dans ServerStorage. Attendre la fin et la restauration de chaque harnais avant de lancer le suivant.

Les résultats JSON sont datés et limités à leur scénario. Ils ne prouvent pas le rendu visuel, le multijoueur, la persistance réelle ni la fluidité sur toutes les cartes/appareils. Le nombre de contrôles Expansion peut varier avec les fragments aléatoires inspectés.

## Séries d'éliminations

`refuge-shop-walkway-play-check-20261029.json` documente les chemins latéraux des quatre boutiques : géométrie Edit, absence de recouvrement avec les cadres et chemins calculés en Play. Une navigation du personnage a aussi réussi jusqu'au connecteur et devant Upgrades. Pas de capture pixel, d'essai mobile/multijoueur ni d'achat. `AddRefugeShopWalkways.edit.luau` est une commande Edit ponctuelle ; elle refuse les doublons et peut être annulée en supprimant le dossier `ShopAccessWalkways`.

`zombie-zone-sleep-play-check-20261029.json` documente le test SessionStudio de la mise en veille physique hors zone active : compte des 114 modèles, réveil des six de Ville, retour au refuge, mesures PhysicsStepTime et limites. Ce n'est pas un benchmark FPS ni un test multijoueur.

Pour connaître les différences actuelles entre disque et Studio, lire handoff-audit-latest.json : les 40 scripts correspondent désormais aux fichiers locaux, y compris Expeditions. Les audits datés antérieurs sont historiques.

## Terrain et guide de zone

TerrainMovementBridge.client.luau se lie à une RemoteFunction temporaire TerrainMovementQABridge dans ReplicatedStorage. TerrainVaults.server.luau demande de vrais FireServer client sur cinq obstacles permanents, ou huit lorsque le port existe. Installer uniquement en Play de test et lire TerrainVaultsQAResult dans ServerStorage. Le pont est détruit à la fin du harnais : pour répéter, recréer la RemoteFunction et son LocalScript client. TerrainLocomotion.server.luau porte un attribut ZoneId (City/Factory/Lab/Harbor) ; après TerrainLocomotionReady, piloter immédiatement avec Maj+W, C puis Ctrl après la glissade. Lancer le sampler et les entrées dans une seule séquence d'outils pour éviter de dépasser sa fenêtre de mesure. Relâcher toutes les touches avant un autre harnais. Résultat TerrainLocomotionQA_<Zone>. Arrêter Play ensuite.

zone-guide-result.json conserve les états des guides et les mesures iPhone simulé paysage/portrait. Les captures montrent la flèche écran ; Enabled/Adornee du Billboard ne prouvent pas son rendu visible. Les niveaux de test sont réservés à SessionStudio. La console du dernier contrôle contenait seulement une assertion de fixture corrigée avant mutation, et ne doit pas être décrite comme vide.

KillChains.server.luau s'exécute en Script serveur temporaire après chargement du profil SessionStudio. Il attend les vraies échéances de huit secondes et tue/réapparaît le personnage de test. Lire ServerStorage.KillChainsQAResult. Il conserve puis restaure Meta, monnaie, XP, niveau, position et préférences de menu ; arrêter Play après lecture pour supprimer tous les effets temporaires. Les callbacks synthétiques vérifient le cycle du compteur, pas l'attribution d'une vraie élimination par ZombieDirector. Le résultat du 22 octobre est kill-chains-result.json. notification-layout-result.json couvre la passe UI ultérieure sur PC et téléphone simulé : gains/séries, fragments, boosts et munitions simultanés, avec mesures des rectangles et captures inspectées. pending-studio-sync.json est historique.

## Navigation souris M

mouse-navigation-result.json contient les 11 contrôles de la passe du 22 octobre. Pour reproduire les interactions, utiliser une session Studio PC neuve et les outils d'entrée utilisateur :

1. Cliquer JOUER, appuyer sur M ; vérifier MouseUnlocked=true, MouseUnlockButton.Modal=true, pointeur visible et MouseBehavior.Default pendant 30 images.

2. Cliquer Options : la fenêtre Options doit s'ouvrir, et non la boutique située plus bas. M reste inactif pendant ce menu ; sa fermeture remet le pointeur au centre.

3. En mode souris libre, maintenir le clic : aucun SwingAt serveur et aucune balle de pistolet ne doivent être consommés. Tester ensuite la reprise avec M.

4. Une sonde temporaire peut interrompre la préparation d'un coup par MouseUnlocked=true puis false après 20/30 ms ; vérifier que le son de préparation existe mais qu'aucune frappe différée n'arrive au serveur. Cette sonde est synthétique, distincte d'un essai humain de rapidité.

5. Réapparaître : le mode doit être réinitialisé. Configurer ensuite le téléphone simulé avant Play : bouton M masqué et modalité inactive, même après une touche M virtuelle.

Les profils utilisés doivent rester SessionStudio. L'armement temporaire du pistolet et la réapparition sont des fixtures ; arrêter Play après les contrôles. La libération du pointeur ne suspend pas le monde et ne change aucune validation serveur de combat.


## Panneau admin personnel
Dans une session Studio Play du compte autorisé, installer temporairement Admin.server.luau dans ServerScriptService. Lire ServerStorage.AdminQAResult ; le script restaure le profil même en cas d'échec. Arrêter Play après. Ne jamais installer en Edit. Résultat : admin-result.json ; limites et essais client dans docs/reference/ADMIN_PANEL.md.

## Délégation du panel admin
Le rapport `admin-delegation-result.json` couvre seulement la comparaison source, le chargement du panel propriétaire et une lecture sans écriture de la liste DataStore. Il ne prouve pas l'ajout/retrait, le clic de l'onglet, l'écriture persistante ou le message entre serveurs. Le harnais `Admin.server.luau` contient deux refus de délégation à exécuter en Play SessionStudio ; aucun harnais QA n'est installé en Edit.

## Recentrage des meshes de chaussée importés
`AlignRefugeImportedLane.edit.luau` est un passage ponctuel en Edit pour `89391796839094`. Il vérifie les positions, interactions et sauvegarde avant de centrer les trois meshes à X=0. Ne pas installer en démarrage ni exécuter en Play. Le résultat du contrôle Play est `refuge-imported-lane-alignment-play-check-20261029.json`.

`weapon-final-palette-client-play-check-20261029.json` est une lecture Play du vrai aperçu armurerie : aucun achat, grant ou équipement ; le script d'ouverture s'autodétruit. Elle vérifie les couleurs des trois derniers modèles dans les clones de `ViewportFrame` et les prototypes serveur. La capture Windows a expiré : ce résultat ne remplace pas l'inspection pixel ni une vue d'arme équipée.

`EnhanceStarterFirearmAccents.edit.luau` est une réparation ponctuelle en Edit des seuls pistolet et revolver, dont le corps et le canon étaient gris identiques. Elle vérifie la place, le mode Edit, les noms de pièces et l’absence de texture non prise en charge, clone les deux modèles dans `ServerStorage.BeforeStarterFirearmAccent_20261029`, puis applique une couleur d’accent au corps et une teinte contrastée au canon. La relance refuse d’écraser la sauvegarde. Contrôle Play dans `starter-firearm-accents-play-check-20261029.json` ; capture visuelle non disponible.
