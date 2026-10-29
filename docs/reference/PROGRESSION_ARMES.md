# Progression des armes

## Inventaire des modèles 3D — dernier audit Play du 29 octobre 2026

Le rapport [`weapon-mesh-models-play-check-20261029.json`](../../studio/qa/weapon-mesh-models-play-check-20261029.json) compte 30 modèles pour les 30 armes hors poings : 16 FBX Blender Hook–EclipseGlaive et 14 MeshParts générés/importés dans Studio (Pipe, Bat, Axe, Sledgehammer, Machete, Pistol, Revolver, SMG, Shotgun, Katana, Carbine, Marksman, LMG et LimitedBlade), soit 335 MeshParts. `WeaponVisuals.Build` construit une géométrie pour chaque arme ; zéro `ModelPending` et zéro modèle absent dans cette session. Les 14 derniers MeshParts proviennent d'assets Roblox individuels, pas des FBX locaux ; ne pas les décrire comme simples Parts procédurales.

Les validations de géométrie et de palette sont basées sur les propriétés des instances Play. Elles ne prouvent pas que la scène Studio ouverte actuellement, une autre copie du place ou le rendu pixel affiché à l'utilisateur contient les mêmes modèles. Le signalement « à modéliser » n'a pas été reproduit dans ces audits ; comparer la copie Studio et demander le nom/capture de la carte si le libellé persiste.

## Lisibilite des trois armes finales en ambiance nuit — 29 octobre 2026

ArcPike, BlackoutEdge et EclipseGlaive gardent leurs couleurs distinctes, et leur silhouette principale passe en Neon dans le clone commun de `WeaponVisuals.Build`. Les autres armes conservent leurs accents SmoothPlastic. Les noyaux Neon et leurs PointLights restent en place ; l’éclairage global du refuge n’est pas augmenté. Comme le même constructeur alimente les aperçus, le viewmodel, l’arme sur personnage et les modèles de caisses, la correction suit ces chemins partagés.

Play : les trois silhouettes et noyaux finaux sont Neon avec les teintes attendues ; l’ARMURERIE garde 31 aperçus remplis, 31 caméras et 337 pièces. Rapport [`refuge-weapon-visuals-and-portal-fit-play-check-20261029.json`](../../studio/qa/refuge-weapon-visuals-and-portal-fit-play-check-20261029.json). La capture pixel a expiré : la lisibilité réelle à l’écran reste à confirmer.

## Lumière locale des noyaux finaux — 29 octobre 2026

ArcPike, BlackoutEdge et EclipseGlaive avaient déjà cinq couleurs et un noyau Neon, mais le refuge est très sombre et Neon ne projette pas de lumière sur les pièces voisines. Le passage Edit [`AddFinalWeaponCoreLights.edit.luau`](../../studio/qa/AddFinalWeaponCoreLights.edit.luau) ajoute une PointLight accordée à la couleur du noyau dans chacun des trois modèles répliqués et prototypes (Brightness 0.65, Range 6, Shadows désactivé). Les sources et les clones du vrai `WeaponVisuals.Build` ont été contrôlés en Play : une lumière valide par arme, et les 31 aperçus de l'armurerie restent remplis. Rapport : [`final-weapon-core-point-lights-play-check-20261029.json`](../../studio/qa/final-weapon-core-point-lights-play-check-20261029.json).

La capture pixel Studio n'a pas répondu ; la force visuelle du halo, l'arme portée, mobile et multijoueur restent à valider. La modification est dans la scène Edit non enregistrée.

## Vérification des trois derniers aperçus runtime — 29 octobre 2026

Après ouverture de l'ARMURERIE réellement rendue en Play, ArcPike, BlackoutEdge et EclipseGlaive affichent chacun cinq couleurs distinctes dans leurs ViewportFrames. La page compte 31 cartes/aperçus, 31 caméras, 337 pièces géométriques (335 MeshParts d'armes et deux poings) et aucun texte « model/modéliser ». C'est une mesure des propriétés des aperçus ; aucune capture pixel exploitable n'était disponible. Détails et limites : [`refuge-sign-clearance-play-check-20261029.json`](../../studio/qa/refuge-sign-clearance-play-check-20261029.json).

## Palette de secours à l'import — 29 octobre 2026

`WeaponVisuals.Build` applique une palette au clone uniquement si un modèle importé marqué `Silhouette`/`Noyau` est monochrome ou sous-saturé. Les modèles déjà colorés restent inchangés. Le contrôle Play a réussi sur 16/16 sources grises et 16/16 sources à palette existante ; propriétés des sources restaurées. Rapport [`weapon-palette-runtime-fallback-play-check-20261029.json`](../../studio/qa/weapon-palette-runtime-fallback-play-check-20261029.json). Cela vérifie les instances et couleurs, pas le rendu pixel des aperçus ou de la main.

## Retest runtime des 16 armes importées — 29 octobre 2026

En Play, le vrai `WeaponVisuals.Build` produit 16/16 modèles avec au moins cinq couleurs distinctes par arme ; leur saturation moyenne va de 0,67 à 0,82. ArcPike, BlackoutEdge et EclipseGlaive ont chacun un noyau Neon. Cela vérifie les propriétés des instances construites en runtime, pas leur rendu pixel ni la vue première personne ; les captures Studio/Windows ont expiré. Rapport [`refuge-weapon-play-audit-20261029.json`](../../studio/qa/refuge-weapon-play-audit-20261029.json).

## Contraste des trois dernières palettes — 29 octobre 2026

Les couleurs étaient bien assignées, mais chacune des trois armes restait dans une seule famille chromatique. `ApplyFinalWeaponContrastPalettes.edit.luau` ajoute des accents complémentaires sur les modèles répliqués et leurs prototypes, avec sauvegarde sous `ServerStorage.BeforeFinalWeaponContrastPass_20261029` : ArcPike jaune/cyan, BlackoutEdge bleu/ambre et EclipseGlaive violet/magenta-or. `RecolorWeaponModels.edit.luau` reprend ces accents lors d'une future recoloration.

En Play, le vrai `WeaponVisuals.Build` conserve les trois palettes : 19/19/17 pièces, 5 couleurs par modèle, saturation moyenne 0,81/0,81/0,68 ; noyaux cyan/ambre/magenta et quincaillerie assortie. Console vide, Play arrêté, Edit restauré, aucune modification de profil ou achat. Capture de la page ARMES impossible ; les couleurs des instances sont mesurées, mais les pixels restent à confirmer. Rapport : [`weapon-final-contrast-palette-play-check-20261029.json`](../../studio/qa/weapon-final-contrast-palette-play-check-20261029.json).

Recontrôle Play du 29 octobre : les modèles reconstruits par le client depuis `WeaponVisuals.Build` gardent encore 5 couleurs saturées chacun (moyenne HSV : ArcPike 0,81, BlackoutEdge 0,81, EclipseGlaive 0,68 ; noyaux `63eeff`, `ffbe4a`, `ff65d8`). Aucun achat ni équipement du profil. L'écran de jeu n'a pas été capturé ; ces propriétés n'excluent pas une différence de rendu sur un autre client ou une autre version de la place.

## Contrôle Play des couleurs des trois dernières armes — 29 octobre 2026

Dans la page ARMES du client Play, ArcPike, BlackoutEdge et EclipseGlaive ont chacun leur aperçu 3D visible avec caméra : respectivement 19, 19 et 17 pièces, cinq couleurs distinctes par modèle, saturation moyenne 0,829 / 0,762 / 0,626. Les modèles répliqués et prototypes serveur sont présents ; les MeshParts n'ont ni `TextureID`, `SurfaceAppearance` ni MaterialVariant qui masque leur `Color`. Rapport : [`weapon-final-palette-client-play-check-20261029.json`](../../studio/qa/weapon-final-palette-client-play-check-20261029.json).

Ce rapport documente la palette précédente et est supersédé par « Contraste des trois dernières palettes » ci-dessus. Le rendu des pixels et l'arme équipée à la première personne restent à vérifier.

## Nouveau retest du signalement « à modéliser » — 29 octobre 2026

En Play sur la place `89391796839094`, l'armurerie réelle du client contient 31 rangées et 31 aperçus 3D avec caméra et géométrie ; aucun aperçu n'est vide et aucun libellé `model/modéliser` n'apparaît dans les rangées. Les 30 modèles répliqués sont présents. Le testeur avait `Fists` équipés, donc aucune arme distincte n'était visible en main. Aucun achat ni équipement n'a été fait. Rapport : [`weapon-model-play-check-20261029-session6.json`](../../studio/qa/weapon-model-play-check-20261029-session6.json).

Le test confirme les instances et leur géométrie, mais sans capture pixel il ne confirme pas leur apparence ni leur qualité de rendu. Play arrêté, Studio Edit.

## Vérification Play des modèles — 29 octobre 2026

L'ancienne note palette était erronée : elle confondait la teinte HSV avec la saturation et se basait sur un cache `require` obsolète. La modification de couleur a été annulée ; son rapport est marqué invalide. Le test correct lit désormais `GameplayConfig.Source` et utilise le second retour de `Color3:ToHSV()`.

Dans Studio Edit puis Play, `ReplicatedStorage.WeaponModels` contient 30 modèles (16 imports Blender et 14 modèles MeshPart générés), totalisant 335 pièces. L'armurerie a 31 rangées/aperçus : 31 ont une caméra et de la géométrie, aucun aperçu n'est vide et aucun texte « model/modéliser » n'est présent. Ce retest n'a pas reproduit « À modéliser ». Le profil Play avait les poings équipés ; ce contrôle ne montre donc pas d'arme en main. Rapport : [`weapon-model-play-check-20261029-session5.json`](../../studio/qa/weapon-model-play-check-20261029-session5.json). La capture pixel et le clic physique n'ont pas été vérifiés.
## Retest des modèles réellement équipés — 29 octobre 2026

En Play SessionStudio, les 30 armes hors poings ont été équipées l'une après l'autre avec le fixture QA temporaire : 30/30 `EquippedWeaponVisual` présents, 335 pièces réunies, aucun modèle absent. La restauration a rendu les poings au joueur et retiré le contrôle de test ; aucun achat ni changement persistant n'a été fait. Le précédent contrôle de la page ARMURERIE restait positif (31 aperçus avec caméra et géométrie, aucun `ModelPending`). Rapport : [`weapon-armory-play-check-20261029-fresh.json`](../../studio/qa/weapon-armory-play-check-20261029-fresh.json).

La vue première personne n'a pas été capturée visuellement ; ce test mesure l'équipement du personnage, pas les pixels de l'arme en main sur l'écran du joueur. Pas de mobile, multijoueur ou sauvegarde `.rbxl`.

## Teinte des quatorze modèles MeshPart générés — 29 octobre 2026

Les textures générées recouvraient la propriété `MeshPart.Color` ; le pistolet et le revolver apparaissaient gris, avec saturation minimum 0,11. Les 43 `TextureID` des quatorze armes ont été conservées en cartes `SurfaceAppearance.ColorMap`, et les tintes saturées sont configurées via `SurfaceAppearance.Color`. Le pistolet a une palette ambre/cyan/or et le revolver bois/or/cyan. Les autres palettes avaient déjà des teintes distinctes.

En Play, le vrai `WeaponVisuals.Build` a produit 335 MeshParts pour les trente armes hors poings ; 43 cartes couleur répliquées, zéro modèle manquant et zéro `ModelPending`. Sauvegarde Studio réversible avant correction : `ServerStorage.BeforeWeaponTextureTint_20261029`. Voir le [rapport du contrôle couleur/refuge](../../studio/qa/weapon-color-refuge-audit-20261029.json).

Le contrôle est basé sur les instances et propriétés runtime, sans capture pixel ; la lisibilité à l'écran reste à confirmer. Les changements restent dans l'instance Studio Edit non enregistrée en `.rbxl`.

## Modèles MeshPart des armes précédemment en Parts — 29 octobre 2026

Dans Studio `Évolution des armes` (`89391796839094`), les quatorze armes de base sans modèle importé ont reçu un modèle MeshPart généré : Pipe, Bat, Axe, Sledgehammer, Machete, Pistol, Revolver, SMG, Shotgun, Katana, Carbine, Marksman, LMG et LimitedBlade. Les 16 armes Blender déjà présentes restent inchangées. `WeaponVisuals.Build` clone les modèles depuis `ReplicatedStorage.WeaponModels`, ce qui les utilise à la fois pour les aperçus et l'arme équipée.

Vérification en Play client : les 30 armes hors poings produisent 335 MeshParts au total ; chaque modèle a un pivot `Manche` centré, sans entrée `ModelPending`. Voir [`le rapport Play`](../../studio/qa/weapon-mesh-models-play-check-20261029.json).

Les modèles sont segmentés en 2 à 5 MeshParts et ne comportent pas d'animation de pièces internes. Le test vérifie instances, pivot et construction du module ; aucune capture pixel de la page ARMES n'a pu être obtenue. Les changements restent dans l'instance Studio Edit non enregistrée en `.rbxl` et les assets locaux ne les restaurent pas.

## Palette renforcée des armes finales — 29 octobre 2026

En Edit, `studio/qa/EnhanceFinalWeaponPalettes.edit.luau` a sauvegardé GameplayConfig, les trois modèles répliqués et leurs prototypes sous `ServerStorage.BeforeFinalWeaponPaletteFix_Pass2_20261029`. Les MeshParts de la Pique de la grille, de la Trancheuse du blackout et du Glaive de l'éclipse ont maintenant cinq couleurs saturées par arme, avec des accents or `RGB(255,207,25)`, bleu `RGB(24,146,255)` et violet `RGB(164,68,255)`. Les 55 MeshParts des trois modèles répliqués ont leurs variantes expérimentales effacées ; les cœurs restent Neon. Le catalogue conserve les mêmes coûts, niveaux, dégâts, portées et cadences.

En Play, les couleurs/configurations et les aperçus des trois armes se répliquent, avec 19/19/17 pièces et zéro variante résiduelle ; les 31 ViewportFrames ont caméra et géométrie, sans libellé de modèle manquant ni `ModelPending`. La capture Play et la capture Windows ont expiré : la couleur est vérifiée par propriétés, pas en pixels. Rapport commun au refuge : [`final-weapon-portal-layout-play-check-20261029.json`](../../studio/qa/final-weapon-portal-layout-play-check-20261029.json).

## Retest Play après nouveau signalement — 29 octobre 2026

Dans la place Studio `Évolution des armes` (`89391796839094`), j’ai ouvert l’armurerie en Play à partir du profil serveur réel avec un script temporaire autodétruit. Les 31 ViewportFrames ont une caméra, de la géométrie et des limites non nulles ; aucun texte visible ne contient « model/modéliser » et `GameplayConfig` rapporte zéro `ModelPending`. Les 16 modèles importés (292 MeshParts) sont répliqués. Les 14 armes restantes hors poings — Hache, Batte, Carabine, Lame du survivant, Mitrailleuse, Lame Nova, Machette, Guetteur, Tuyau, Pistolet, Revolver, Mitraillette, Fusil à pompe et Masse — ont un aperçu 3D construit en `Part` par `WeaponVisuals`, mais n’ont pas de modèle MeshPart/FBX importé. Le joueur est resté équipé des poings ; pas d’achat, grant ou équipement. Play a été arrêté, Studio est en Edit.

Résultat : le libellé et l’aperçu vide ne sont pas reproduits dans cette session. Une capture Play inspectable n’a pas été obtenue, donc le rendu pixel n’est pas validé. Output contenait un diagnostic Studio `AssistantCommand: Material/palette check failed ArcPike`, sans pile `GameHub` ou `EconomyService`. Rapport : [`weapon-model-play-check-20261029-session2.json`](../../studio/qa/weapon-model-play-check-20261029-session2.json). Si le joueur voit « à modéliser » dans une version autre que cette instance Studio, il faut le nom de l’arme et une capture de sa carte pour comparer la version/client concernés.

## Noyaux lumineux des armes de fin de progression — 29 octobre 2026

Les MeshParts d'ArcPike, BlackoutEdge et EclipseGlaive portaient déjà les accents or, bleu et violet, mais leur bande centrale `Noyau` restait en SmoothPlastic et pouvait se perdre dans le refuge sombre. Le passage Edit [`HighlightFinalWeaponCores.edit.luau`](../../studio/qa/HighlightFinalWeaponCores.edit.luau) sauvegarde puis applique une teinte vive (HSV saturation 0,723, valeur 0,976) et `Enum.Material.Neon` sur les 3 modèles répliqués et leurs 3 prototypes. `RecolorWeaponModels.edit.luau` reprend la même règle pour les recolorations futures. Backup : `ServerStorage.BeforeFinalWeaponCoreGlow_20261029`.

Play client : `WeaponVisuals.Build` conserve le noyau Neon pour ArcPike (19 pièces), BlackoutEdge (19) et EclipseGlaive (17) ; leurs couleurs répliquées sont respectivement or, bleu et violet. Console vide, Play arrêté, Studio revenu en Edit. La capture de fenêtre Studio a expiré : matériaux, teintes et géométrie contrôlés, rendu à l'écran non inspecté. Rapport : [`final-weapon-core-glow-play-check-20261029.json`](../../studio/qa/final-weapon-core-glow-play-check-20261029.json).

## Vérification Play de l'armurerie affichée — 29 octobre 2026

Dans Studio `Évolution des armes` (`89391796839094`), l'onglet `ARMURERIE` a été ouvert depuis l'état du service réel via un Script serveur temporaire auto-détruit. L'UI côté client montre 31 cartes d'armes et 31 `ViewportFrame`; aucun viewport n'est dépourvu de caméra ou de géométrie, et aucun texte « model/modéliser » n'apparaît. La ligne `PROCHAIN PALIER` est une invitation à acheter l'arme suivante et ne représente pas une carte d'arme. Le personnage avait `Fists` équipés : pas de modèle distinct attendu dans sa main. Le niveau et les pièces sont restés à 1 et 0 ; aucun achat, grant ni équipement n'a été effectué. Play arrêté, Studio revenu en Edit. Voir le [rapport Play](../../studio/qa/weapon-armory-play-check-20261029.json).

Limites : capture fenêtre Studio expirée, donc les instances et leur géométrie ont été inspectées mais pas l'image en pixels. Trois avertissements `GuiService.SelectedObject` invalides ont été émis pendant l'automatisation du menu ; aucune erreur de script de jeu observée. Cette instance ne reproduit pas le signalement.

## Retest du signalement « à modéliser » — 29 octobre 2026

Dans une session Play fraîche de la place `89391796839094`, l’armurerie a été ouverte avec un envoi d’état du service serveur réel depuis un script temporaire Play-only, détruit ensuite. Les 31 rangées ont chacune un `ViewportFrame`, une caméra et une géométrie 3D non vide ; aucun texte ne contient « model » ou « modéliser ». `GameplayConfig` présente zéro `ModelPending`, `WeaponVisuals.Build` génère 663 pièces pour les 30 armes hors poings et les 16 modèles importés sont répliqués au client. Le personnage de cette session avait `Fists` équipés, donc aucun modèle distinct n’est attendu dans sa main. Le problème signalé n’a pas été reproduit et aucun achat, grant ou équipement n’a été effectué. Play arrêté, Studio revenu en Edit. Rapport : [`weapon-model-play-retest-20261029-current.json`](../../studio/qa/weapon-model-play-retest-20261029-current.json).

Limites : pas de capture d’écran inspectable (capture Studio expirée), donc présence, caméra, géométrie et texte contrôlés par les instances runtime. L’automatisation des clics a expiré ; deux messages Output provenaient des commandes temporaires d’inspection (`Activate` invalide et `SelectedObject` invalide), aucune erreur de script de jeu n’a été constatée.

## Retest du signalement « à modéliser » en Play — 29 octobre 2026

Dans une session Play neuve de la place Studio actuelle, la page ARMURERIE a été construite côté client : 31 armes listées, 31 `ViewportFrame` avec caméra, aucun aperçu vide et aucun libellé contenant « model » ou « modél ». Les 30 armes hors poings génèrent 663 pièces depuis `WeaponVisuals.Build`; les poings reçoivent deux gants dans l'interface (665 pièces d'aperçu au total). Les 16 modèles importés totalisent 292 MeshParts, dont zéro pièce à saturation quasi nulle. La Machette et la Masse sont des modèles Roblox en pièces (respectivement 23 et 27 pièces), non des FBX Blender importés ; leur palette a été renforcée avec des métaux teal, des arêtes menthe et des accents rouille/corail. En Play, leur saturation HSV minimale mesurée est de 0,259 pour la Machette et 0,136 pour la Masse.

Une vérification d'attache temporaire antérieure sur la main droite a soudé 23/23 pièces de la Machette et 27/27 de la Masse, sans pièce ancrée, puis détruit ces modèles de test. Pour ce retest, un snapshot `GameState` synthétique a ouvert l'armurerie sans achat, grant ni modification du profil. La console est restée vide et Play a été arrêté, Studio revenu en Edit. Mesures et instances confirmées, pas une capture visuelle : l'outil de capture de Studio a expiré. Le test complet est dans [`weapon-model-play-verification-20261029.json`](../../studio/qa/weapon-model-play-verification-20261029.json).

## Cadrage des aperçus 3D — 29 octobre 2026

La caméra fixe coupait 9 aperçus sur 31 au bord du cadre, dont Katana, LMG, Lance de rupture, Pique, Lance du relais, Lance orbitale, ArcPike, EclipseGlaive et LimitedBlade. `GameHub.weaponPreview` calcule maintenant la distance et le centre de caméra depuis les bornes du modèle, avec une marge adaptée au FOV et au ratio du viewport ; les aperçus tournent autour de leur centre géométrique. Le test géométrique couvre les 31 armes et une rotation de ±0,32 radian : la pire emprise projetée est 85,6 % du cadre et aucun coin ne sort de l’image. Le script actif de Studio et la source locale sont synchronisés. Résultat : [`weapon-preview-camera-fit-result.json`](../../studio/qa/weapon-preview-camera-fit-result.json).

La page ARMES n’a pas été ouverte à l’écran dans cette passe : le calcul prouve le cadrage géométrique, pas l’inspection visuelle des vignettes. Les 16 modèles importés sont colorés dans la scène Studio actuelle (292 pièces ; saturation minimale par pièce 0,50, aucune sous 0,18). La moyenne de saturation par modèle va de 0,626 à 0,829 ; ArcPike 0,829, BlackoutEdge 0,762 et EclipseGlaive 0,626. Le faux audit ultérieur est invalidé plus haut ; ces mesures proviennent du modèle sauvegardé et restauré.

## Vérification Play après signalement « à modéliser » — 29 octobre 2026

Le libellé obsolète a été retiré de `GameHub` : aucune arme n'est désormais annoncée « à modéliser ». Session Play propre : 31 entrées de catalogue, zéro `ModelPending`, zéro aperçu vide parmi les 30 armes autres que les poings. `WeaponVisuals.Build` produit 663 pièces sur ces aperçus. Le client reçoit 16 modèles importés (Hook à EclipseGlaive) ; les 14 autres armes utilisent les modèles 3D en pièces déjà construits par `WeaponVisuals`. Les poings ajoutent leurs gants dans l'aperçu d'interface.

Le script Studio d'origine est conservé dans `ServerStorage.BeforeWeaponModelLabelFix_20261029`. La console Play était vide au démarrage normal et après la vérification, puis Play a été arrêté. L'écran ARMES n'a pas été capturé visuellement dans cette passe ; contrôle du catalogue et de la géométrie par instances seulement. Résultat : [`weapon-model-play-recheck-20261029-final.json`](../../studio/qa/weapon-model-play-recheck-20261029-final.json).

## Couleur complète des modèles importés (29 octobre 2026)

La palette précédente ne teignait que `Silhouette`, `Noyau`, `Pommeau` et les ailerons. Les bandes de poignée, manche, garde et rivets conservaient le gris par défaut de l'import FBX. `RecolorWeaponModels.edit.luau` applique maintenant une teinte de lame, un cœur plus clair, une poignée textile assombrie dans la même famille de couleur, un manche métal teinté et une quincaillerie métallique dont la saturation minimale est contrôlée à 0,35. Ces MeshParts n'ont ni `TextureID` ni `SurfaceAppearance` ; la couleur de pièce agit donc sur leur rendu.

Edit et Play : les 16 armes importées, 292 pièces répliquées et 292 pièces prototypes, soit 584 affectations de couleur/matériau, avec 16 accents par arme. Les mesures Play donnent une saturation moyenne minimale de 0,67 par modèle, 0,92 pour la lame minimale et 0,58 pour la quincaillerie minimale. Sauvegarde de la palette juste avant cette passe : `ServerStorage.BeforeWeaponPalettePass3_20261029`. Les anciens fichiers FBX restent dans l'archive `Armes_pre_palette_20261029.zip`. Rapport : [`weapon-color-roundtrip-20261029.json`](../../studio/qa/weapon-color-roundtrip-20261029.json).

## Application garantie des palettes finales — 29 octobre 2026

`WeaponVisuals.Build` force maintenant les accents complémentaires d'ArcPike, BlackoutEdge et EclipseGlaive à chaque clone, même si le mesh source semble déjà multicolore et saturé. Avant, ce cas sautait la palette définie et pouvait conserver de mauvaises teintes après un réimport. Les autres modèles conservent la règle de détection de palette existante. Sauvegarde de la version précédente : `ServerStorage.BeforeWeaponPaletteEnforcement_20261029.WeaponVisuals`.

En Play, six cas ont réussi sur le vrai module `ReplicatedStorage.WeaponVisuals` : trois armes avec source grisée et avec import saturé aux mauvaises teintes. Les clones ont repris les couleurs accent/métal/cœur exactes, cinq couleurs distinctes et un cœur Neon. Tous les `Color`, `Material` et `MaterialVariant` sources ont été restaurés. Rapport : [`weapon-final-palette-enforcement-play-check-20261029.json`](../../studio/qa/weapon-final-palette-enforcement-play-check-20261029.json). La console est vide et Play est arrêté. La capture pixel et l'arme portée n'ont pas été validées visuellement.

Context7 / documentation Roblox : [`SurfaceAppearance.Color`](https://create.roblox.com/docs/art/modeling/surface-appearance) teinte la ColorMap par multiplication. Les trois sources testées n'ont ni `TextureID` ni `SurfaceAppearance`, donc leur `MeshPart.Color` est la couleur de rendu pertinente pour ce contrôle.

## Modèles 3D intégrés — 28 octobre 2026

Les 16 FBX importés, de Hook à EclipseGlaive, sont répliqués dans `ReplicatedStorage.WeaponModels`. `WeaponVisuals.Build` clone leurs MeshParts, centre le pivot sur `Manche` et fournit la même géométrie à l'aperçu de l'armurerie, au viewmodel de première personne et à l'arme attachée au personnage. Le catalogue n'a plus `ModelPending` pour ces armes ; l'UI ne les marque plus « À modéliser ». Machette et Masse gardent leurs visuels Roblox construits en pièces.

Les exports locaux ont reçu une seconde passe de couleurs : les 16 lames utilisent un accent saturé propre à l'arme sur toute leur silhouette, avec un cœur plus clair. Après le round-trip Blender 5.2.3, la même palette a été appliquée aux 16 modèles Studio existants et à leurs prototypes disponibles : 116 pièces recolorées, 16 teintes d'accent distinctes. Sauvegarde réversible dans `ServerStorage.BeforeWeaponPalette_20261029`. En Play, les 16 modèles sont répliqués au client avec saturation d'accent supérieure à 0,65 ; la capture de l'armurerie montre notamment la Trancheuse bleue et le Glaive violet. Archive des FBX précédents : `assets/Modeles_a_importer/Armes_pre_palette_20261029.zip`.

TEST-WEAPON-MODELS-001, trois sessions Play arrêtées ensuite : les 16 ViewportFrames de l'armurerie ont chacun une caméra et 17 à 22 MeshParts ; aucun libellé « À modéliser ». Avec un grant admin temporaire Studio, Hook a été équipé côté serveur : 17/17 MeshParts soudés à la main droite, aucun ancré, centre de prise à (0, -0,5, -0,15). En première personne, le viewmodel Hook contenait 17 MeshParts devant la caméra, entre 1,54 et 2,31 studs. Aucun achat, dégât, animation de frappe, mobile/multijoueur, sauvegarde `.rbxl` ou publication n'a été effectué. La capture d'écran automatisée a expiré ; ces preuves sont des mesures et instances en Play, pas une capture inspectée. Résultat détaillé : [`studio/qa/weapon-model-integration-result.json`](../../studio/qa/weapon-model-integration-result.json).

Les sections ci-dessous décrivent les caractéristiques et le statut au moment où chaque arme a été ajoutée ; les mentions `ModelPending` et « modèle à créer » ont été supersédées par l'intégration ci-dessus.

## Lame du coeur

Ajoutée avec le palier du Cratère : 760 000 pièces, niveau 90, 420 dégâts, portée 9,5 studs et délai de 0,98 s. Elle passe par l'achat d'arme existant, reste disponible depuis l'UI à distance et prend sa place après la Pique dans le prochain palier conseillé. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Hache de verre

Ajoutée avec la Mer de verre : 1 100 000 pièces, niveau 110, 490 dégâts, portée 9,5 studs et délai de 0,88 s. Elle suit le catalogue et les vérifications d'achat existants ; la recommandation d'arsenal la propose après la Lame du coeur. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Lance du relais

Ajoutée avec la Cité des antennes : 1 650 000 pièces, niveau 130, 625 dégâts, portée 11 studs et délai de 0,86 s. L'achat reste dans le catalogue, passe par les validations serveur existantes et apparaît après la Hache de verre dans le prochain palier. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Lance orbitale

Ajoutée avec la Station orbitale : 2 400 000 pièces, niveau 150, 740 dégâts, portée 13 studs et délai de 1,02 s. Elle suit le même catalogue et la même validation d'achat serveur ; elle devient le palier conseillé après la Lance du relais. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Fendoir des abysses

Ajouté avec le Bunker des profondeurs : 3 300 000 pièces, niveau 170, 850 dégâts, portée 13,5 studs et délai de 0,98 s. Il suit le catalogue et la validation d'achat serveur ; il devient le prochain palier conseillé après la Lance orbitale. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Maillet du dernier jour

Ajouté avec la Fonderie du dernier jour : 4 400 000 pièces, niveau 190, 980 dégâts, portée 14 studs et délai de 1,08 s. Il suit le catalogue et la validation d'achat serveur ; il devient le prochain palier conseillé après le Fendoir des abysses. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Lame du dernier convoi

Ajoutée avec le Terminus du dernier convoi : 6 000 000 pièces, niveau 210, 1 120 dégâts, portée 15 studs et délai de 1,04 s. Elle suit le catalogue et la validation d'achat serveur ; elle devient le prochain palier conseillé après le Maillet du dernier jour. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Pique de la grille

Ajoutée avec la Grille déchue : 8 200 000 pièces, niveau 230, 1 300 dégâts, portée 16 studs et délai 0,98 s. Elle suit le catalogue et la validation d'achat serveur ; elle devient le prochain palier conseillé après la Lame du dernier convoi. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Trancheuse du blackout

Ajoutée avec le Noyau d'arrêt : 11 000 000 pièces, niveau 250, 1 550 dégâts, portée 17 studs et délai 1,12 s. Elle suit le catalogue et la validation d'achat serveur ; elle devient le prochain palier conseillé après la Pique de la grille. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

## Glaive de l'éclipse

Ajouté avec la Voûte de l’Éclipse : 15 000 000 pièces, niveau 270, 1 850 dégâts, portée 17,5 studs et délai 1,06 s. Il suit le catalogue et la validation d'achat serveur ; il devient le prochain palier conseillé après la Trancheuse du blackout. Son FBX est intégré dans `ReplicatedStorage.WeaponModels`.

Depuis le lot du 27 octobre, la carabine mène au **Fusil du guetteur** niveau 28 / 32 000 pièces. La progression des armes à feu culmine à la [Mitrailleuse de barrage](MITRAILLEUSE.md) niveau 35 ; la progression de mêlée continue jusqu'au Glaive de l'éclipse niveau 270. Les chiffres de test ci-dessous restent ceux du lot historique Carbine. Voir [GUETTEUR.md](GUETTEUR.md).

Lot du 26 octobre 2026, en réponse à la demande de rendre la progression plus plaisante. La carabine offre un objectif après le port (niveau 20). La nouvelle carte d'armurerie explique le prochain achat plutôt que demander au joueur de comparer toute la liste : arme cible, niveau actuel/requis, solde/prix, pièces manquantes et achat direct quand tout est réuni.

## Règle de recommandation

`GameplayConfig.NextWeapon(owned)` prend le dernier palier normal possédé dans WeaponOrder et propose le suivant. Les armes premium ne font pas sauter cette progression. Exemple : Poings → Tuyau ; Fusil à pompe → Carabine. Dans le lot historique Carabine seul, la carte indiquait « Dernier palier atteint » sans affirmer que toutes les armes sont collectionnées. Les autres achats restent accessibles.

## Deux armes de mêlée ajoutées

La Machette de secours (niveau 9, 5 200 pièces, 62 dégâts, portée 8 studs, 0,55 s par coup) et la Masse de démolition (niveau 19, 16 500 pièces, 170 dégâts, portée 8,5 studs, 0,95 s par coup) sont achetables depuis l'armurerie. Le serveur réutilise ses validations existantes de niveau, solde, possession et combat. Les poses de frappe sont distinctes. Les visuels Roblox sont reconstruits en pièces à partir des modèles Blender : les FBX de `assets/new_weapons/` ne sont pas importés dans Studio, car l'API de création d'asset n'était pas disponible. Les animations Roblox sont adaptées aux contrôleurs existants, pas des clips Blender importés.

C'est un parcours de catalogue, pas un classement universel de DPS ou de portée. La barre mesure uniquement le solde de pièces divisé par le prix cible, borné à 100 % ; elle ne représente pas l'XP. Les nombres de niveaux manquants sont séparés. Aucun nouveau multiplicateur, prix d'arme existante, reçu ou champ de profil n'est ajouté.

## Carabine des cendres

| Paramètre | Valeur |
| --- | --- |
| Identifiant | Carbine |
| Niveau / prix | 22 / 18 000 pièces |
| Corps / tête | 38 / 57 dégâts |
| Portée | 175 studs |
| Intervalle / chargeur | 0,24 s / 18 balles |
| Rechargement | 2,4 s, réserve illimitée comme les autres armes |

Modèle distinct avec crosse, garde-main ventilé, poignée avant, rail, viseur décoratif et trois pièces mobiles (Magazine, MagazineBase, BoltHandle). Le viseur ne donne pas de mode zoom. Les deux vues partagent les calculs de mécanismes ; la première personne garde sa réponse immédiate à l'entrée. ReducedMotion limite les déplacements mécaniques à un quart. Les sons réutilisent l'asset métal existant : rapport plus grave, claquement de culasse, trois étapes de recharge ; aucun enregistrement externe ajouté.

Les poses et cycles courts sur le personnage commencent désormais à la réception du ShotFX accepté, pour éviter que la réplication tardive de SwingAt fasse sauter l'animation. Un premier relevé arrivait à environ 0,196 s alors que le cycle de culasse durait 0,13 s. Seule la présentation change : cadence, munitions, raycast, dégâts et récompenses restent serveur. La première personne continue de démarrer localement, sans attendre le réseau.

## Preuves et limites

`studio/qa/carbine-result.json` contient 27 contrôles de combat/progression, dix de présentation et 33 régressions des mécanismes existants réussis, en SessionStudio. Achat refusé au niveau 21/sans budget/sans possession, achat niveau 22 à 18 000 depuis une arène éloignée, doublon non facturé ; chargeur 18 ; 38 dégâts à 160 studs, 57 sur la tête, refus au-delà de 175, derrière un mur et pour un vecteur invalide ; spam limité à une balle, recharge serveur et annulation sans balles gratuites au changement d'arme.

Deux vrais clics ont été acceptés pour la présentation, dont un en mode muet/réduit. Mesures finales : course de chargeur 0,62796 stud, culasse monde observée à 0,12750 stud après réception, course relative de culasse première personne réduite à 0,04443 stud. Une instance GunShot, une CarbineBolt, trois ReloadClick pendant la recharge ; aucun nouveau son de tir pour le clic muet. Cela prouve les instances et mouvements, pas une écoute physique.

UI testée : au niveau 21 avec 9 000 pièces, carte Carbine verrouillée et barre à 50 %. Au niveau 22 avec 22 000 pièces, clic réel sur OBTENIR : Carbine équipée côté serveur et solde 4 000, puis reconnaissance du dernier palier. Captures inspectées de la carte et du modèle catalogue sur PC 1447×824, portrait 401×778 et paysage 750×381 ; titres/descriptions tiennent. Bouton portrait 333,02×48,17 ; paysage 113,66×45,17. Ces contrôles concernent l'armurerie, pas toutes les pages.

Les tentatives sont distinguées dans le rapport : première session avec timeout CorePackages et HUD absent, puis sessions neuves avec HUD présent ; premier cycle monde manqué avant correction de la réception ; premier sampler FPS trop tardif, déplacé avant le clic pour observer la réponse locale. Les régressions ont ensuite passé et la dernière console contrôlée est vide. La condition de démarrage lent n'est pas couverte par une garantie de robustesse générale.

Fichiers actifs : GameplayConfig, WeaponVisuals, WeaponMotion, FistsClient, CharacterCombat, FirearmsClient et GameHub. Backup des sept dans ServerStorage.BeforeCarbine ; sources locales/instances Edit comparées. Aucun nouveau script actif, manifeste toujours 46. Les QA restaurent le profil, les statistiques et la position avant Stop. Simulateur default/LandscapeLeft rétabli. Aucun DataStore de production, paiement Robux, publication ou sauvegarde .rbxl.

Non vérifiés : périphériques physiques, multijoueur, reconnexion DataStore, rendu R6 de toutes les poses ou équilibre par essais de joueurs. Une garde de présence du personnage et de la tête au moment du son de culasse différé a été ajoutée puis compilée après les tests ; la mort dans cette fenêtre de 80 ms n'a pas de test dédié. Graphify a servi au repérage du snapshot puis les sources actuelles ont été relues ; Context7 a confirmé les contrôles de tirs côté serveur. Ponytail réutilise services, catalogue, modèles et animations existants ; ECC guide les contrôles ciblés. [Référence officielle de validation des tirs](https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/intermediate-scripting/hit-detection-with-lasers).


## Six armes ajoutées après la Mitrailleuse

Le 28 octobre 2026, six armes de mêlée complètent la progression après la Mitrailleuse de barrage. Elles sont achetables en pièces depuis l'armurerie, même à distance : Crochet de quarantaine (niv. 40, 68 000), Kris du veilleur (48, 92 000), Lance de rupture (56, 145 000), Couperet des digues (64, 230 000), Marteau de siège (72, 360 000) et Pique des remparts (80, 560 000). Chacune a ses dégâts, portée, cadence et pose de frappe dans GameplayConfig/WeaponMotion, ainsi qu'un modèle FBX intégré.

Cette description remplace la note historique qui disait que les modèles restaient à créer : les six FBX sont inclus parmi les 16 modèles Hook à EclipseGlaive décrits plus haut. Le catalogue Studio vérifié ne marque aucune arme `ModelPending`.


Vérification de reprise du 29 octobre : session Play neuve, `GameplayConfig` client chargé sans aucun `ModelPending`, dossier `ReplicatedStorage.WeaponModels` présent avec les 16 modèles et 17 à 22 MeshParts chacun. La session a perdu sa connexion Studio avant l'ouverture effective de l'onglet ARMES : le nombre de lignes, le texte rendu et les ViewportFrames n'ont donc pas été recontrôlés dans cette passe. La preuve complète précédente demeure dans `weapon-model-integration-result.json`.

## Retest Play du signalement utilisateur — 29 octobre 2026

Dans une session Play fraîche, le client charge 31 définitions sans `ModelPending`. `ReplicatedStorage.WeaponModels` contient 30 modèles avec 335 MeshParts ; `WeaponVisuals.Build` produit une géométrie non vide pour chacune des 30 armes hors poings. La recherche Studio ne trouve ni `ModelPending` ni « à modéliser » dans les scripts. Aucun libellé correspondant n'est présent dans le PlayerGui à l'état initial du menu. Console vide, Play arrêté, retour Edit. Rapport [`weapon-models-play-user-retest-20261029.json`](../../studio/qa/weapon-models-play-user-retest-20261029.json).

Limite : cette session n'a pas ouvert l'onglet ARMES. Le viewport client était à 1×1, le clic automatisé a expiré et la revue automatique a refusé la création d'un Script QA temporaire en Edit. Ce test confirme la géométrie/runtime et l'absence du libellé dans les sources, mais pas les cartes rendues à l'écran. Le contrôle Play précédent avait, lui, observé 31 aperçus remplis et zéro libellé en ouvrant l'armurerie. Si le texte reste visible en jeu, il faut une capture et le nom de l'arme afin de retrouver l'autre interface ou un client déjà chargé.

## Contraste des armes à feu de départ — 29 octobre 2026

L’audit couleur a repéré deux armes réellement ternes : Pistolet et Revolver avaient un corps et un canon gris clair identiques. En Edit, le Pistolet reçoit un corps ambre `255,190,66` et un canon bleu pétrole `43,113,128` ; le Revolver reçoit un corps cuivre `233,151,86` et un canon ardoise `78,86,112`. Les poignées cuir restent intactes. Sauvegarde réversible des deux modèles : `ServerStorage.BeforeStarterFirearmAccent_20261029`. Le contrôle Play confirme que les deux couleurs sont répliquées, chaque arme ayant trois couleurs distinctes ; l’arsenal reste 30/30 géométries non vides et 0 `ModelPending`. Voir [`le rapport`](../../studio/qa/starter-firearm-accents-play-check-20261029.json) et [`la recette Edit`](../../studio/qa/EnhanceStarterFirearmAccents.edit.luau).

La cour a également été contrôlée en Play : 19 portails/prompts actifs, 6 allées d’au moins 8 studs et 18 connecteurs d’au moins 8,5 studs, sans pièces de chemin collidables. La capture d’écran Studio et la capture Windows n’ont pas répondu ; ces mesures valident la structure et le passage libre, pas l’esthétique à l’écran. Aucun achat, sauvegarde de place ou publication.
