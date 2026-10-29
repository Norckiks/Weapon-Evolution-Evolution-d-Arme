# Onde de choc

La `Lance cryo` a maintenant sa propre courbe de pose : elle arme lentement le geste, puis projette les deux mains vers l'avant avec une détente rapide. `WeaponMotion.Ability` alimente la vue subjective et `CharacterCombat` pour les poses du personnage ; `ReducedMotion` continue d'atténuer le mouvement au point d'application.

Le contrôle Play a repassé 13 052 échantillons sur les six capacités et les deux mains. Deux assertions contrôlent les valeurs exactes à mi-charge et mi-projection de Cryo ; la continuité, les poids, les poses finales et le rebond Slam passent aussi. Console vide, Play arrêté et Studio en Edit. Pas de capture d'image en jeu : la forme visuelle reste vérifiée par trajectoires numériques, pas par pixels.

## Frappe tellurique : geste et modèle d'impact

Le geste `Slam` prend une accélération d'impact plus vive, puis un rebond plus lourd et asymétrique des poignets et du torse. Il continue d'utiliser la timeline partagée entre les mains à la première personne et le corps à la troisième personne. L'effet fallback en jeu ajoute un noyau ambré et huit éclats de basalte animés ; `ReducedMotion` en réduit le nombre et coupe leurs tweens.

L'asset Blender `SlamImpactStudy.blend` contient 44 meshes (1 960 polygones après réimport FBX) et l'action `SlamImpact_PopAndSettle` sur 18 images. `SlamImpact.fbx` et son aperçu sont dans `assets/Modeles_a_importer/Capacites/SlamImpact/`. Après import, grouper les pièces dans `ReplicatedStorage.SlamImpactTemplate` ; `PulseClient` l'utilise automatiquement et l'anime par tweens Roblox. Tant que le modèle n'est pas importé dans la place, le fallback reste actif.

Vérification Studio : le contrôle `AbilityMotion.server.luau` passe 13 052 échantillons des six capacités et des deux mains, sans discontinuité hors seuil. Le déclenchement visuel temporaire du Slam crée 12 fissures, 12 segments d'onde, 8 éclats, un noyau et le libellé `IMPACT !`. La vérification ReducedMotion et l'apparence du FBX importé restent à faire.

## Égide : réaction à un blocage

`ZombieMelee` envoie maintenant `AbilityFX/AegisBlock` quand une frappe de zombie est refusée par `GuardUntil`. Le signal est limité à un par joueur toutes les 0,65 s ; il ne change ni dégâts, ni durée de garde, ni récompenses. `PulseClient` dessine une couronne frontale en segments néon violet/or, un flash lumineux et un texte cartoon « CLANG ! ». `ReducedMotion` réduit les segments à quatre et supprime leurs tweens.

Vérification Play temporaire `SessionStudio` : activation de l'Égide par le remote normal, attaque du zombie refusée avec santé inchangée, deux tentatives rapprochées produisent un seul retour client (8 segments et libellé). Console vide ; profil temporaire restauré et Play arrêté, Studio revenu en Edit. Le comptage client confirme la création des éléments, pas leur aspect pixel à l'écran ; mode Réduction des mouvements et multijoueur non vérifiés.

## Égide astrale : cristal multi-pièces

Le template runtime `ReplicatedStorage.AegisCrystalPrototype` remplace l'ancien cristal monobloc dans `Pulse.client.luau`, avec l'ancien template gardé en secours. Le modèle généré dans Studio contient quatre MeshParts texturés : cœur violet (PrimaryPart), coque améthyste, cage dorée et éclats flottants. Le cœur a un halo violet ; coque, cage et éclats reçoivent des teintes distinctes. Il est réduit à 0,68 en troisième personne et 0,45 en première personne ; le client anime le cœur et l'orbite existante. En mouvement normal, les six cristaux se révèlent en cascade : un fondu de 0,18 s par cristal, espacé de 0,045 s ; le dernier est visible vers 0,46 s. En réduction des mouvements, ils apparaissent immédiatement. L'asset Mesh Roblox est `92567541294150`.

La trajectoire ajoute maintenant une rotation axiale alternée d'environ un tour en deux secondes, avec un très léger roulis. Cette impulsion reprend l'action Blender `AegisCrystalRootAction` (images 1–49 : rotation, flottement de ±0,025 unité et pulsation d'échelle de ±3,5 %). La pulsation du cœur runtime reste inchangée. Si `ReducedMotion` est activé pendant l'orbite, l'animation s'arrête.

Play a compilé le `PulseClient` modifié sans erreur de console. La sonde `AbilityFX` lancée depuis l'outil Studio n'a pas déclenché l'écouteur client ; l'orbite et son arrêt en ReducedMotion ne sont donc pas validés en rendu/trajectoire réelle.

Play visuel seulement, via le RemoteEvent `AbilityFX` sans appel à la capacité serveur : les six cristaux ont chacun quatre MeshParts, le cœur comme PrimaryPart, une enveloppe verticale de 1,06 stud et collisions/touches/requêtes désactivées. Un relevé client confirme la cascade : à 0,02 s le premier est déjà visible et les cinq suivants restent masqués ; à 0,22 s le dernier est encore masqué ; à 0,46 s les six sont visibles. Un second Play avec `ReducedMotion=true` donne trois cristaux, quatre meshes chacun, tous visibles dès l'apparition, avec halo à 0,65. Pièces/niveau/PV restent à 0/1/100, console vide ; Play arrêté, retour en Edit. La capture de jeu restait masquée par l'écran de sélection de zone, donc elle ne valide pas la lisibilité finale à l'écran. Le FBX Blender détaillé reste un fichier séparé et n'a pas été importé.

## Égide : affichage en première personne

Dans `PulseClient`, les cristaux d'Égide sont réduits à 45 % en vue subjective, placés un peu plus loin et plus bas, avec un flottement et une inclinaison plus discrets pour dégager le centre de l'écran. En troisième personne, l'orbite garde sa taille et son amplitude habituelles. Les valeurs d'orbite sont partagées avec la boucle `PreRender`, donc le placement de départ et le mouvement restent alignés.

Un clone temporaire du template actuellement chargé dans Studio a confirmé une réduction géométrique de 0,900 à 0,405 stud en hauteur. En Play, la capture subjective montre les cristaux aux bords de l'écran ; les six modèles se déplacent d'environ 0,974 stud en 0,25 s. Le test a déclenché uniquement l'événement visuel, sans combat, dégâts ni récompense ; la position et les PV sont restés inchangés, puis Play a été arrêté. Le FBX détaillé dans `assets/Modeles_a_importer/Capacites/` n'est pas encore importé dans la place, donc l'apparence de ce modèle reste à vérifier.

Mise à jour du 28 octobre : les six capacités possèdent des poses procédurales distinctes pour chaque main et un mouvement de torse associé. Les études Blender dans `assets/ability_motion/` ont inspiré les gestes ; les clips du mannequin ne sont pas importés dans Studio. `WeaponMotion` et `CharacterCombat` sont synchronisés ; sauvegarde `BeforeAbilityMotion20261028`. 13 052 échantillons de pose passent en Play, et la réduction des mouvements a été mesurée sur une épaule AnimationConstraint pour les six capacités. Ce sont des contrôles synthétiques : rendu FPS, combat réel, Motor6D, mobile physique et multijoueur restent à vérifier.

Nouvelle capacité niveau24 : **K/L2 — Décharge**, quatre rebonds42/32/24/18 dégâts. Six capacités au total dans le sélecteur, cinq boutons PC supplémentaires. Voir [DECHARGE.md](DECHARGE.md) pour les règles et les limites vérifiées du nouveau lot. Les paragraphes de preuves antérieures ci-dessous conservent leur portée historique.

Déblocage automatique au niveau 5. **Q** au clavier, **L1** à la manette, bouton **ONDE** sur mobile. L'interface affiche le niveau requis, le manque d'endurance, l'indisponibilité ou le compte à rebours.

| Réglage | Valeur |
| --- | --- |
| Endurance | 30, partagée avec sprint/dash/glissade |
| Récupération | 14 secondes, conservée après réapparition pendant la session |
| Rayon | 14 studs, mesuré depuis la racine du joueur |
| Dégâts | 20 par cible |
| Interruption | 0,7 seconde |
| Limite | 12 zombies par activation, les plus proches en premier |
| Repousse | Vitesse radiale cible 38 / max(1, échelle du modèle), impulsion adaptée à la masse |

L'onde exige un personnage vivant, au sol, dans une zone de combat autorisée. Elle est refusée dans les menus, au refuge, assis, immobilisé, accroupi, pendant une glissade/franchissement/dash ou une recharge. Elle consomme son endurance et son délai même sans cible. Les surfaces solides, y compris transparentes, bloquent l'effet ; les volumes sans collision ne le bloquent pas. Pas de dégâts aux joueurs.

## Architecture

Les entrées des quatre capacités viennent maintenant de GameplayConfig (Key et Pad), utilisées à la fois pour les bindings et les indications du HUD. Les anciennes associations R/G/X/Y/A, encore mentionnées dans les résultats historiques, sont remplacées par les commandes actuelles ci-dessous.

- GameplayConfig contient les valeurs de l'onde et des quatre autres capacités.
- SprintServer crée UseAbility, PulseFX et AbilityFX, puis passe **son état d'endurance serveur** à PulseAbility.Handle. Le client envoie uniquement l'identifiant d'action.
- PulseAbility valide le niveau, la zone, l'état, l'endurance et le délai individuel de chaque action. Les délais sont gardés hors du personnage pendant la session et recopiés après réapparition ; aucun champ DataStore n'est ajouté.
- Le serveur choisit les cibles, vérifie les obstacles, borne la liste, attribue les dégâts et récompenses habituelles. La défense Égide est vérifiée dans ZombieMelee.CanHit ; le soin est plafonné aux PV max.
- ZombieDirector lit StunnedUntil, arrête la marche puis rétablit la vitesse configurée ; les dégâts d'attaque différés sont refusés tant que l'interruption est active.
- PulseClient affiche les effets acceptés localement. WeaponMotion.Ability alimente la vue subjective FistsClient et la pose CharacterCombat via Motor6D/AnimationConstraint.
- ZoneGuide évite les boutons de capacité. Aucune entrée runtime nouvelle : le manifeste conserve 46 scripts actifs.

## Quatre capacités supplémentaires

Les capacités se débloquent automatiquement aux niveaux 8, 12, 16 et 20. Sur clavier : **E** frappe le sol, **T** lance la cryo, **H** active l'égide et **J** déclenche le second souffle. **R** recharge l'arme, **G** ouvre les cadeaux et **F** reste la lampe. À la manette : croix gauche = frappe, croix droite = cryo, R3 = égide, croix bas = soin ; L1 garde l'onde. Les boutons X/Y/A restent disponibles pour recharger, franchir et sauter. Sur mobile, le chevron sélectionne une capacité et le bouton principal lance réellement cette sélection. Tous partagent l'endurance du sprint et un délai individuel côté serveur, conservé après réapparition pendant la session.

| Capacité | Niveau | Coût / délai | Effet serveur | Animation et couleur |
| --- | ---: | --- | --- | --- |
| Frappe tellurique (E) | 8 | 34 / 12 s | 34 dégâts, étourdissement 1,1 s et repousse forte dans un rayon de 10 studs, jusqu'à 8 zombies | Bras levés, la main droite mène la frappe au sol et la gauche suit légèrement ; le torse accompagne puis rebondit. Fissures orange-or et vague de pression circulaire |
| Lance cryo (T) | 12 | 32 / 18 s | Tir rectiligne jusqu'à 70 studs, ±4,5 studs autour de la visée (9 studs de large), 30 dégâts et gel/interruption 1,7 s ; une cible | Retrait puis estoc des bras, projectile blanc-cyan, double traînée, éclats et anneau givré à l'impact |
| Égide astrale (H) | 16 | 30 / 24 s | Bloque les coups de mêlée zombies pendant 3,2 s ; l'attaque est aussi refusée au moment de l'impact | Bras croisés, trois anneaux segmentés, six cristaux qui orbitent et pulsent autour du personnage, teinte astrale |
| Second souffle (J) | 20 | 30 / 28 s | Rend jusqu'à 35 % des PV max, sans dépasser le maximum | Geste ramené au torse, spirale verte et or et halo qui s'ouvre au sol |

Le contrôleur serveur (`PulseAbility`) vérifie l'état du joueur, la zone, le niveau, les délais, l'endurance et les obstacles ; aucun dégât ou soin n'est choisi par le client. La Lance cryo compare chaque zombie à l'axe horizontal visé, choisit le plus proche dans son couloir et arrête le rayon sur un mur solide. La protection est vérifiée dans `ZombieMelee.CanHit` au départ du coup et à son impact. `AbilityFX` ne sert qu'au rendu local. `WeaponMotion.Ability` anime les bras et le torse, consommé par `CharacterCombat` et la vue subjective de `FistsClient`; les poses prennent en charge Motor6D et AnimationConstraint. Après l'impact, un court rebond de poignet et d'avant-bras accompagne le retour progressif à la garde. La réduction des mouvements conserve des formes fixes et atténue flashes, poses et trajectoires.

Le HUD PC garde quatre boutons supplémentaires et leurs touches. Sur tactile, un seul bouton lance la capacité sélectionnée et le chevron fait défiler les cinq capacités, pour limiter l'espace pris sur les commandes de déplacement. Le manifeste reste à 46 scripts : aucun nouveau script de démarrage.

## Résultats du 26 octobre — tir distant, égide et effets

Le Sillage cryo devient **Lance cryo** : la touche R envoie la direction horizontale de la caméra, validée côté serveur comme vecteur unitaire. Le serveur limite l'attaque à 70 studs, ±4,5 studs autour de l'axe visé (9 studs de large), une cible, et garde la vérification de visibilité/collision. Dégâts, étourdissement, endurance et délai restent serveur. La pose a été recentrée sur un retrait puis un estoc. L'Égide conserve sa garde serveur de 3,2 s ; son retour visuel montre trois anneaux soudés, chacun composé de 12 segments (8 segments en réduction des mouvements). Frappe tellurique produit 12 fissures au sol ; Second souffle une spirale de 12 particules vert/or.

Play en SessionStudio, vrais appels UseAbility:FireServer côté Client : 16 assertions réussies dans studio/qa/abilities-result.json. Lance cryo : cible à 58 studs passée de 100 à 70 PV, cible hors axe de 9 studs et cible à 72 studs intactes, endurance débitée et délai présent. Égide : TryAttack a refusé le coup de mêlée Guarded sans dégâts ; après expiration, l'attaque a repris et infligé ses dégâts normaux. Second souffle a rendu 20 PV manquants jusqu'au maximum. Frappe tellurique a infligé 34 dégâts et son étourdissement. VFX locaux comptés : 2 faisceaux/traînées, projectile et 7 éclats cryo ; 36 pièces de halo égide, 8 en mouvement réduit ; 12 étincelles de soin et 12 fissures. Vingt échantillons de pose ont renvoyé un CFrame et un poids borné. Les harnais sont temporaires dans studio/qa et absents des scripts actifs en Edit ; le manifeste reste à 46 scripts.

Limites : le blocage cryo par un mur n'a pas eu de scénario de test dédié. La capture d'écran Studio a montré l'illustration de chargement ou un viewport noir, donc les nombres d'instances et mesures prouvent les effets créés, pas leur apparence finale à l'écran. Pas de manette ou tactile physique, format mobile, multijoueur ni DataStore de production. Console finale vide, Play arrêté, Edit confirmé. Aucun fichier rbxl sauvegardé ni jeu publié.

## Vérifications des quatre ajouts

Studio Play a lancé les scripts sans erreur dans la console après correction du placement des boutons ; contrôles finaux répétés après la dernière modification, puis Play arrêté et Edit confirmé. `WeaponMotion.Ability` a été appelé pour les cinq actions ; chaque timeline a renvoyé un CFrame et un poids borné. Le HUD PC a affiché les cinq boutons après préparation temporaire du statut de test, en viewport 1447×801 ; les quatre raccourcis étaient à des positions distinctes (48×48). ZoneGuide inclut maintenant ces quatre boutons et le sélecteur dans ses rectangles d'évitement.

Rendu synthétique en Play, déclenché par `AbilityFX` depuis le serveur, a affiché les quatre libellés attendus, y compris avec ReducedMotion activé. La bulle de l'Égide était soudée au personnage. Quatre demandes `UseAbility:FireServer` réelles au niveau 1, au refuge et avant démarrage n'ont rien modifié : endurance 100, PV 100 et délai Slam 0 avant/après. Cela vérifie le rendu accepté et le refus d'état verrouillé, pas une activation de gameplay par touche.

Limites : lors du lot initial, pas de personnage débloqué pour vérifier dégâts/soin/protection par activation réelle ; pas de touche clavier, manette, tactile physique, portrait/paysage mobile ni multijoueur. Aucun profil ou DataStore de production n'a été modifié ; aucune publication ni sauvegarde `.rbxl`.

Présentation actuelle : une teinte violette monte sur l'image pendant que des marques néon au sol se resserrent autour d'un noyau chargé. Après 0,42 s, une couronne violette explose vers l'extérieur, suivie d'un écho magenta ; « BOUM ! » et le son d'impact arrivent au déclenchement de l'explosion. Les poses des bras anticipent la charge, frappent avec un bref recul, puis récupèrent en douceur. La même séquence améliore l'onde, la Frappe tellurique, la Lance cryo, l'Égide et le Second souffle ; la pose reste réduite par l'option de réduction des mouvements. En réduction des mouvements, la charge de l'onde est raccourcie, les huit marques et les six éclats restent fixes, et la teinte reste plus douce. Tous les effets sont locaux, sans collision, et nettoyés par Debris ; dégâts et validation serveur sont inchangés.

## Vérifications

Mise à jour ultérieure du 26 octobre : le gel au changement PC/mobile décrit dans la passe commandes ci-dessous est corrigé et retesté ; voir le lot de changement de périphérique dans [UI_MOBILE.md](UI_MOBILE.md). Le sélecteur est maintenant large de 44 au lieu de 42. La limite de clic automatique Jouer est conservée, avec un décalage tactile observé ; Entrée et A permettent aussi de démarrer.

Lot commandes du 26 octobre : huit assertions `studio/qa/AbilityBindings.client.luau` passent (sept associations attendues et absence de collision entre les bindings Survival/Survivor/Fists). Entrées natives observées côté serveur : R recharge le pistolet de 11 à 12 sans lancer Frost ; T active Frost ; J active SecondSouffle ; croix gauche active Slam. G ouvre CADEAUX DE TEMPS. En session démarrée directement sur iPhone 17 Pro portrait simulé (401×778), trois clics sur le chevron sélectionnent Égide et le clic principal active Aegis, GuardUntil et son délai serveur ; capture SelectedMobileAegis inspectée. L'attribut Ready du bouton suit désormais la sélection tactile.

Paysage simulé 750×381 : bouton principal 56×56 en (380,151), chevron 42×56 en (325,151), tous deux visibles après démarrage par le remote normal Start. Le clic automatique Jouer en paysage n'a pas démarré le jeu ; ne pas le déclarer validé. Le changement de périphérique PC→mobile au milieu d'une première session a laissé ce HUD en disposition PC ; le test tactile réussi utilise une session neuve déjà configurée mobile. Ce changement à chaud reste à diagnostiquer. Pas de téléphone/manette physique ou de multijoueur testé.

La première lecture ponctuelle de GunReloading a manqué la courte transition : un observateur serveur a ensuite enregistré true, consommation/remplissage et false autour des vrais inputs. Le rapport `studio/qa/ability-controls-result.json` conserve ces événements. Prix, dégâts, coûts et délais ne changent pas. Backup des deux sources avant modification : ServerStorage.BeforeAbilityControls.

Animation installée en Studio Edit puis observée en Play le 26 octobre 2026. Capture écran inspectée pendant la charge : marques au sol visibles et teinte de l'image violette. Sonde temporelle déclenchée par `PulseFX` uniquement (aucun dégât, stamina, niveau ou profil modifié) : en mouvement normal, 16 marques et noyau à 0,2 s, teinte violette plus forte à 0,5 s (RGB normalisé 0,53/0,27/0,87), 42 éclats à 0,5 s, texte BOUM entièrement visible à cet instant puis en fondu à 0,7 s. En réduction des mouvements : 8 marques immobiles, 6 éclats immobiles, teinte légère (RGB 0,91/0,86/1 à 0,2 s) puis neutre à 0,32 s ; aucune accentuation violette au choc. Play arrêté ; Studio revenu en Edit. La capture n'a pas été enregistrée dans le dépôt.

Le 26 octobre, la timeline de pose partagée a été échantillonnée en Play sur quatre capacités, deux sens et les frontières de phase : 826 appels ont renvoyé des CFrame finis, poids entre 0 et 1 et angles de torse finis ; les transitions mesurées restent continues à moins de 0,01 stud. Cela valide les calculs du module, pas une inspection visuelle des bras animés en situation réelle.

Le 29 octobre, une nouvelle vérification Play a parcouru 13 052 échantillons des six capacités dans les deux sens : aucune valeur non finie, poids hors limites, rupture de plus de 0,08 stud/rad ou pose finale bloquée. Le geste de cryo garde deux poses de main distinctes ; le coup Slam montre un rebond mesurable après l'impact. Ces mesures ne remplacent pas une capture visuelle en combat.

En Play, les cristaux de l'Égide orbitent autour du personnage via `RunService.PreRender` et s'effacent avec l'effet après 3,25 s. Un cristal s'est déplacé de 0,869 stud en 0,25 s ; avec `ReducedMotion`, le déplacement mesuré est resté à 0,0000 stud. Une première sonde a cherché le cristal avant sa création ; la sonde suivante attendait son apparition et a réussi. L'erreur `AssistantCommand: crystal missing` de la console vient de cette sonde temporaire, pas du `PulseClient`.

Cette sonde ne constitue pas un déclenchement de la capacité par Q : le joueur de test était niveau 1 au refuge. Elle vérifie le rendu de l'événement accepté, pas l'équilibrage, les dégâts, un essai tactile, mobile physique ou multijoueur.

Mise à jour du 29 octobre : `ReplicatedStorage.AegisCrystalTemplate` fournit le cristal astral facetté utilisé par `PulseClient` à la place de la sphère de secours. La MeshPart fait 0,34 × 0,9 × 0,34 stud, conserve son mesh et sa texture (`105775109092546`, `90659257925959`), reçoit une teinte violette et une PointLight discrète (`Brightness=0.45`, `Range=4.5`). En Edit, le modèle contient une MeshPart primaire ; en Play, un clone client a conservé mesh, dimensions, matériau, couleur et lumière.

La capture Play en première personne montrait les cristaux éclairés sur les côtés et l'anneau horizontal sous le centre du viseur. La correction utilise un anneau unique plus bas et plus fin à moins de 2,5 studs de la caméra ; en vue éloignée, le code conserve les trois anneaux. La console était vide ; le personnage a été replacé à sa position initiale et Play arrêté. Une capture à la troisième personne est restée trop tardive pour observer l'effet de 3,25 s, et la trajectoire orbitale des modèles n'a pas été mesurée en images. Réduction des mouvements, mobile, manette et multijoueur restent non vérifiés.

Modèle détaillé créé avec Blender 5.2.3 : `assets/Modeles_a_importer/Capacites/AegisCrystal.fbx`, 19 meshes et 543 faces ; réimporté dans Blender, son volume mesure environ 0,353 × 0,353 × 0,9 unité. L'aperçu confirme le cœur violet visible derrière la coque facettée et sa cage dorée. `PulseClient` vise le mesh `Aegis_LightCore` pour son pulsation si présent, ce qui garde la cage alignée ; les anciens templates continuent de pulser via leur pièce primaire. La source `.blend` contient une action de rotation/flottement sur 49 images, mais le FBX exporté est statique : l'animation orbitale de combat reste pilotée par `PulseClient`. Le FBX n'est pas encore dans Studio, car le pont MCP n'offre pas d'import local de FBX ; le guide `assets/Modeles_a_importer/Capacites/README.md` explique son import manuel et le réglage du PrimaryPart.

Mesures de la version précédente :

studio/qa/pulse-result.json contient 29 contrôles réussis : refus serveur, coût réel, dégâts, mur transparent solide, exclusions, attribution d'une vraie mort de zombie, repousse physique, interruption et reprise d'un Affamé, limite de douze cibles, son/effets, récupération complète et véritable réapparition sans contournement du délai. Les refus utilisent un état serveur temporaire ; les activations passent par un véritable FireServer du client vers SprintServer.

Déplacement de cible mesuré ~2,57 studs. Déplacement de la pose rendue ~0,377 stud normalement contre ~0,094 en réduction des mouvements. Effets observés : 12 traits et un son, puis 6 traits et aucun son avec options correspondantes. Ce sont des mesures de rendu/instances, sans audition du son ni capture vidéo de l'animation.

Q réellement pressé a déclenché l'onde. Bouton inspecté sur iPhone 17 Pro simulé en 750×381 et 401×778, sans chevauchement avec les commandes/panneaux contrôlés. Clic souris simulé en portrait : Activated reçu et PulseAt attribué avec la liaison FistsPunch d'origine conservée. Un pointeur libéré temporairement par la fixture et des coordonnées corrigées ont servi à ce test ; ce n'est pas un essai tactile physique.

Jouer a aussi été activé depuis un menu portrait préparé pour le test : HasStarted false → true, menu fermé. Le premier état observé d'une autre session était déjà démarré ; il ne prouve pas un démarrage initial naturel. Voir la procédure de coordonnées dans studio/qa/README.md avant de diagnostiquer une panne d'interface à partir d'un clic automatique sans effet.

Multijoueur, manette/tactile physiques, attaque ennemie précisément interrompue pendant sa préparation, autres ratios et équilibrage de longue durée restent à vérifier. Aucun paiement activé, aucune publication ni écriture de profil de production.
# Amelioration des capacites

L'Atelier propose Puissance achetable en pièces depuis l'UI, sans plafond de jeu visible. Les 25 premiers rangs ajoutent chacun 8 % aux dégâts, soins, étourdissements et à la durée de l'Égide ; après, le rendement décroît logarithmiquement. Le prix exponentiel est plafonné à 2 000 000 000 pièces et le garde-fou technique s'arrête à 1 000 000 000 rangs. Le serveur dérive le multiplicateur du profil sauvegardé (`AbilityLevel` dans `Meta`), valide l'achat avec les règles communes d'amélioration, puis applique l'effet ; le client ne choisit jamais les valeurs de combat. Les achats Robux et l'ordre de sauvegarde n'ont pas changé.
