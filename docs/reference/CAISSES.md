# Caisses d'armes et de pets

Ajout du 26 octobre 2026. Accès : BOUTIQUES / MENU, onglet CAISSES, DETAILS, puis CONFIRMER. Le résultat est attribué côté serveur avant toute animation. Pas d'ouverture automatique ni d'achat Robux.

## Contenu et probabilités

| Caisse | Niveau | Prix | Résultats |
|---|---:|---:|---|
| Récupération | 5 | 450 pièces | Tuyau 50 %, batte 30 %, pistolet 15 %, hache 5 % |
| Arsenal | 16 | 3 500 pièces | SMG 45 %, revolver 30 %, katana 20 %, fusil à pompe 5 % |
| Compagnons | 1 | 800 pièces | Mini Rôdeur 45 %, Zippy 30 %, Mini Colosse 15 %, Boulon 8 %, Buddy 2 % |

Toutes les probabilités sont fixes et totalisent 100 % par caisse. Aucune suppression/repondération des objets possédés. Une arme déjà possédée est recyclée en 25 % de son prix direct, arrondi à l'entier inférieur ; le montant exact est affiché avant confirmation. Un pet en double ajoute une copie dans l'inventaire. Les copies ne cumulent pas leurs bonus : un seul pet équipé. Si un objet du pool de pets atteint 100 000 copies, la caisse entière est refusée avant paiement pour ne pas produire de résultat perdu.

Les objets restent achetables/équipables par les systèmes existants. Les nouvelles récompenses ne remplacent pas automatiquement l'équipement. Pas de nouvel ID d'arme/pet, champ de profil, reçu ou migration DataStore.

## Autorité et restrictions

EconomyService reçoit uniquement OpenCrate + identifiant de caisse via GameAction. Le client ne choisit ni résultat, ni prix, ni rareté. Vérifications serveur : démarrage, identifiant, accès PolicyService, délai de quatre secondes par joueur, niveau, fonds et capacité d'inventaire. Débit, tirage et attribution ne cèdent pas l'exécution entre eux ; sauvegarde via ProgressionService.Save existant, puis CrateResult et état courant. Le résultat est déjà acquis si le joueur ferme ou passe l'animation.

PolicyService:GetPolicyInfoForPlayerAsync est interrogé côté serveur à l'arrivée. Seul ArePaidRandomItemsRestricted == false autorise les caisses. Restriction, réponse absente/invalide ou erreur => refus. Les achats directs restent disponibles. La réponse est mémorisée pour la session ; après une erreur de service, il faut rejoindre une nouvelle session pour réessayer. Aucun attribut fourni par le client n'autorise l'achat.

Ce contrôle est conservé même avec les Robux désactivés : les pièces pourront être achetées avec Robux une fois les produits explicitement configurés. Ne pas supprimer cette protection lors de l'activation future. Lire les [règles officielles Roblox sur les objets aléatoires](https://create.roblox.com/docs/production/monetization/paid-random-items) ; lors d'une future publication avec monnaie payante, renseigner aussi le questionnaire de conformité applicable. Aucun échange, retrait de valeur réelle ou lot Robux.

## Animation et fichiers

- studio/CrateCatalog.luau → ReplicatedStorage.CrateCatalog : pools, probabilités, raretés, recyclage et tirage pondéré. Les assertions de chargement refusent les pools invalides.
- studio/CrateReveal.luau → ReplicatedStorage.CrateReveal : confirmation, coffre 3D, vibration, couvercle, éclats et présentation de l'objet.
- studio/EconomyService.luau : validation et attribution, PolicyService, messages CrateResult/CrateError.
- studio/GameHub.client.luau : huitième onglet, grille portrait 4+4, verrouillage menus/combat pendant la fenêtre, branche de réception et réemploi du constructeur de pets existant via CrateReveal.PetModel.

Le constructeur de pets est réutilisé, pas dupliqué ; cette affectation dans GameHub doit rester faite avant une ouverture. Les armes utilisent WeaponVisuals.Build. ReducedMotion donne une révélation immédiate sans secousse/rotation/éclats ; SFXEnabled=false supprime le son de récompense. PASSER révèle le résultat déjà acquis, CONTINUER ferme. Le panneau passe sur deux colonnes en paysage bas, avec actions visant au moins 44 unités UI après mise à l'échelle.

Deux anciens scripts sauvegardés dans ServerStorage.BeforeCrates : EconomyService et GameHub. Deux nouveaux modules ; total 45 scripts actifs, mapping dans studio/runtime-manifest.json. Aucun script QA en Edit.

## Preuves

studio/qa/crates-result.json : 39 contrôles sur les vrais services serveur, avec vrai remote client. Couverture exhaustive des 100 tickets de chaque pool (13 résultats), prix/niveaux/fonds/démarrage, requêtes invalides et récompense falsifiée ignorée, un débit/une attribution, délai anti-rejeu, équipement conservé, doublons/recyclage, bonus du pet équipé et saturation de l'inventaire. PolicyService réel a autorisé ce compte de test ; deux gardes supplémentaires ont refusé les politiques restreinte et inconnue dans des copies isolées du module, sans initialiser leurs connexions réseau. Ce dernier test ne simule pas la géolocalisation réelle de deux comptes.

Vraies confirmations à la souris : PC 20 000 → 19 550, nouveau tuyau ; portrait 19 550 → 18 750, Mini Rôdeur ; paysage 18 750 → 18 337, tuyau déjà possédé et recyclage +37. Les profils temporaires ont été restaurés avant arrêt Play.

Animation finale mesurée sur 79 images : couvercle relatif au corps Y≈0,94 → 1,694, rotation jusqu'à 115°, puis modèle de récompense. Premier prototype descendait dans le coffre ; signe corrigé avant validation finale. Présence d'un son observée, pas d'audition revendiquée. ReducedMotion/muet : zéro image de coffre animé, récompense affichée, aucun son créé. PASSER observé vers 0,736 s ; résultat visible vers 0,784 s, avant la révélation automatique à 1,3 s.

PC 1447×801 ; iPhone 17 Pro simulé portrait 401×778 et paysage 750×381. TextFits des titres/probabilités vrai, boutons confirmés ≈44,22 / 44,12 unités. Les offsets des entrées natives différaient des coordonnées GUI : un observateur InputBegan a permis de mesurer les positions réelles, puis les activations ont été vérifiées. Ne pas copier un offset de ce rapport dans le produit.

Captures inspectées dans studio/qa/screenshots : crate-reward-pc.png, crate-odds-portrait.png, crate-pet-portrait.png, crate-odds-landscape.png. La page des caisses est vérifiée ; les sept anciennes pages ne sont pas intégralement revalidées par ce lot.

Limites : pas de téléphone/manette physiques, multijoueur, audition, sauvegarde/reconnexion de production, benchmark ou équilibrage long. Une première fixture QA a échoué en tentant de lire Source depuis un Script ordinaire ; les copies de modules ont ensuite été préparées via MCP en Server Play. Les erreurs restantes de console de cette passe viennent de cette fixture ou de sondes GUI trop précoces ; pas d'erreur produit observée lors des ouvertures finales. Ne pas annoncer une console intégralement vide pour ce lot.

## Refaire les tests sans toucher à la production

En Play SessionStudio uniquement : créer RemoteFunction ReplicatedStorage.CrateQABridge via MCP, installer temporairement CratesBridge.client.luau dans Client PlayerScripts, attendre un état avec CratesAllowed=true, puis Crates.server.luau dans le serveur. Lire ServerStorage.CratesQAResult. Le harnais laisse un profil temporaire financé pour les essais UI ; appeler ServerStorage.RestoreCratesQA:Invoke() puis arrêter Play.

CrateAnimation.client.luau observe une vraie ouverture confirmée nativement. Pour les gardes de politique : préparer avec MCP deux ModuleScripts temporaires sous ServerScriptService, copiés de EconomyService, en remplaçant uniquement la table locale cratePolicy par {[joueur]=false} ou {}. Les nommer CratePolicyRestrictedQA et CratePolicyUnknownQA ; ne jamais appeler Init sur ces copies. Le Script temporaire CratePolicyGuard.server.luau les requiert, vérifie les refus sans débit, les détruit et réémet l'état du vrai service. Ne jamais lire/écrire Source depuis un Script ordinaire ; cette capacité est réservée à l'outillage.

État final : Edit, Play arrêté, default/LandscapeLeft, 45/45 sources synchronisées et compilantes, aucune publication ni sauvegarde .rbxl confirmée. Relire RELAIS_IA.md avant le prochain lot.
