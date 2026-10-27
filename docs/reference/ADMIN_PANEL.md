# Panneau admin personnel

Compte autorisé : **Bruno_ban369**, UserId **10565455042** (identité lue dans Studio, puis nom résolu par Roblox).

Après JOUER, appuyer sur **F4**, ou **M** puis cliquer **ADMIN [F4]** sur PC. Sur mobile, bouton ADMIN au-dessus des commandes du bas. F4 ou X ferme le panneau. Le bouton bleu fait défiler les catégories : pièces, niveaux, XP, armes, pets, fragments. Entrer la quantité puis cliquer le bouton vert de l'objet voulu. Les listes se font défiler.

Les niveaux s'ajoutent sans effacer l'XP. Une arme est déverrouillée une fois ; les pets/fragments s'ajoutent à l'inventaire. L'équipement courant est conservé : utiliser ensuite ARMURERIE/PETS pour équiper. La Lame Nova est accessible pour les tests sans achat Robux. Les autres joueurs ne reçoivent rien.

Studio : profil SessionStudio, gains effacés à l'arrêt de Play. Jeu publié : gains conservés par l'autosauvegarde existante et la sauvegarde de sortie ; le panneau ne garantit pas une écriture immédiate. Attribution refusée si le chargement de sauvegarde est indisponible. Aucun nouveau DataStore, aucune remise à zéro, aucun reçu modifié, aucun paiement activé.

## Sécurité

AdminService, dans ServerScriptService, compare le UserId de l'appelant fourni par Roblox à l'unique identifiant autorisé à chaque requête. Aucun accès automatique aux créateurs de groupe, amis, autres comptes Studio ou serveurs privés. AdminAccess sert uniquement à afficher l'interface. Le client ne choisit pas de joueur cible. Catalogue, quantités entières finies, plafonds et délai de 0,3 seconde sont validés serveur.

Limites : quantité 1 à 1 000 000 ; pièces totales 2 milliards ; niveaux attribués jusqu'à 100 000 ; 100 000 copies par pet et 1 million de fragments par espèce. Une arme possédée reste possédée sans remboursement. Aucun outil d'effacement, de bannissement ou de modification des autres joueurs.

## Vérifications du 26 octobre 2026

29 assertions du harnais studio/qa/Admin.server.luau réussies dans un vrai Script serveur Play avec les services du jeu. Profil restauré. Identité étrangère synthétique refusée même avec AdminAccess=true ; ce n'est pas un test avec deux clients. Quantités invalides (NaN, infini, négatif, décimal, chaîne, table, hors plafond), catalogue invalide, délai, gains, plafonds, équipement et reçus contrôlés.

Client réel : F4 ouvre et ferme, GameMenuOpen=true à l'ouverture ; clic PC pièces 0→1000 ; navigation PC de catégorie jusqu'à ARMES. Appels client AdminAction acceptés pour niveaux, XP, pets, fragments, arme. Captures PC 1447×801, iPhone 17 Pro portrait 401×778 et paysage 750×381 inspectées. Panneau 560×580 / 377×580 / 560×299 ; liste paysage 528×59 ; boutons 44 minimum et lignes 48. Le bouton d'entrée a été descendu après observation d'un chevauchement du HUD ; placement final inspecté en portrait.

Limites : les tentatives de clic souris en émulation mobile n'ont pas activé les boutons et ne sont pas comptées comme réussies. Pas de tactile physique, clavier virtuel mobile, deuxième joueur ou reconnexion/DataStore de production vérifiés. La première fixture de test a échoué car un Script ordinaire ne peut pas créer un Player ; remplacée par une identité synthétique pour le refus d'accès, puis 29 assertions réussies. Une recherche de téléphone par nom ASCII a échoué à cause de l'espace insécable du nom ; sélection via l'identifiant inventorié ensuite réussie.

Scripts : nouveau AdminService, modifications EconomyService (initialisation) et GameHub (panneau et verrou de menus). 46 scripts dans le manifeste. Backups des deux anciens scripts : ServerStorage.BeforeAdminPanel. Le harnais QA ne doit jamais être installé en Edit. Aucun fichier .rbxl sauvegardé ni expérience publiée par cette intervention.

Audit final : 46 scripts compilants, aucun QA actif en Edit. Les trois sources modifiées concordent avec Studio ; seul le commentaire historique local de PlayerCurrency diffère du reste du manifeste.
