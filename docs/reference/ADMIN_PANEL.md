# Panneau admin personnel

**État au 27 octobre 2026 :** délégation installée dans les sources locales et l'instance Studio Edit. Test de chargement propriétaire et lecture DataStore réussis ; aucun accès n'a encore été attribué à une autre personne. Voir les limites de validation en fin de guide.

Propriétaire permanent : **Bruno_ban369**, UserId **10565455042** (identité lue dans Studio, puis nom résolu par Roblox). Depuis ADMINS, le propriétaire peut ajouter un nom d'utilisateur Roblox et retirer les identifiants délégués. Les délégations (maximum 50) sont conservées séparément dans le DataStore `AdminDelegates_v1` ; les profils et reçus des joueurs ne sont pas touchés. Seul le propriétaire peut gérer cette liste. Les admins délégués peuvent utiliser les commandes de test du panel, mais pas ajouter ou retirer d'admins.

Le serveur résout lui-même le nom en UserId, contrôle les droits pour chaque commande déléguée et relit la liste au démarrage puis périodiquement. Si la liste ne se charge pas, les commandes déléguées sont refusées. Les changements sont diffusés aux autres serveurs via MessagingService ; si la diffusion échoue ou qu'un serveur ne reçoit pas le message, un ancien accès peut y rester temporairement jusqu'à une relecture ou la reconnexion. L'ajout en jeu publié nécessite DataStores et messagerie interserveurs opérationnels. En Studio, autoriser l'accès API aux services pour les tester. Une erreur d'écriture peut laisser son résultat incertain ; reconnecte-toi et vérifie la liste avant de réessayer. L'interface de gestion ne prouve pas à elle seule une attribution en production.

Après JOUER, appuyer sur **F4**, ou **M** puis cliquer **ADMIN [F4]** sur PC. Sur mobile, bouton ADMIN au-dessus des commandes du bas. F4 ou X ferme le panneau. Le bouton bleu fait défiler les catégories : pièces, niveaux, XP, armes, pets et fragments. Entrer la quantité puis cliquer le bouton vert de l'objet voulu. La catégorie ADMINS du propriétaire sert à ajouter ou retirer des accès.

Les niveaux s'ajoutent sans effacer l'XP. Une arme est déverrouillée une fois ; les pets/fragments s'ajoutent à l'inventaire. L'équipement courant est conservé : utiliser ensuite ARMURERIE/PETS pour équiper. La Lame Nova est accessible pour les tests sans achat Robux. Seuls le propriétaire et les comptes auxquels il délègue ces fonctions peuvent utiliser les commandes.

Studio : profil SessionStudio, gains effacés à l'arrêt de Play. Jeu publié : gains conservés par l'autosauvegarde existante et la sauvegarde de sortie ; le panneau ne garantit pas une écriture immédiate. Attribution refusée si le chargement de sauvegarde est indisponible. Le seul nouveau stockage est la liste séparée des UserIds admin délégués ; aucun profil joueur, reçu ou paiement Robux n'est modifié par cette fonctionnalité.

## Sécurité

AdminService, dans ServerScriptService, contrôle le UserId fourni par Roblox à chaque requête : propriétaire permanent ou compte présent dans la liste déléguée. Aucun accès automatique aux créateurs de groupe, amis, autres comptes Studio ou serveurs privés. AdminAccess/AdminCanDelegate servent uniquement à afficher l'interface ; ils n'accordent aucun droit serveur. Seul le propriétaire peut déléguer ou retirer ces fonctions. Le client ne choisit pas de joueur cible pour les commandes de gains. Catalogue, quantités entières finies, plafonds et délai de 0,3 seconde sont validés serveur.

Limites : quantité 1 à 1 000 000 ; pièces totales 2 milliards ; niveaux attribués jusqu'à 100 000 ; 100 000 copies par pet et 1 million de fragments par espèce. Une arme possédée reste possédée sans remboursement. Aucun outil d'effacement, de bannissement ou d'attribution de progression à un joueur cible ; seul le propriétaire peut gérer l'accès admin d'un autre compte.

## Vérifications du 26 octobre 2026

29 assertions du harnais studio/qa/Admin.server.luau réussies dans un vrai Script serveur Play avec les services du jeu. Profil restauré. Identité étrangère synthétique refusée même avec AdminAccess=true ; ce n'est pas un test avec deux clients. Quantités invalides (NaN, infini, négatif, décimal, chaîne, table, hors plafond), catalogue invalide, délai, gains, plafonds, équipement et reçus contrôlés.

Client réel : F4 ouvre et ferme, GameMenuOpen=true à l'ouverture ; clic PC pièces 0→1000 ; navigation PC de catégorie jusqu'à ARMES. Appels client AdminAction acceptés pour niveaux, XP, pets, fragments, arme. Captures PC 1447×801, iPhone 17 Pro portrait 401×778 et paysage 750×381 inspectées. Panneau 560×580 / 377×580 / 560×299 ; liste paysage 528×59 ; boutons 44 minimum et lignes 48. Le bouton d'entrée a été descendu après observation d'un chevauchement du HUD ; placement final inspecté en portrait.

Limites : les tentatives de clic souris en émulation mobile n'ont pas activé les boutons et ne sont pas comptées comme réussies. Pas de tactile physique, clavier virtuel mobile, deuxième joueur ou reconnexion/DataStore de production vérifiés. La première fixture de test a échoué car un Script ordinaire ne peut pas créer un Player ; remplacée par une identité synthétique pour le refus d'accès, puis 29 assertions réussies. Une recherche de téléphone par nom ASCII a échoué à cause de l'espace insécable du nom ; sélection via l'identifiant inventorié ensuite réussie.

Scripts : nouveau AdminService, modifications EconomyService (initialisation) et GameHub (panneau et verrou de menus). 46 scripts dans le manifeste. Backups des deux anciens scripts : ServerStorage.BeforeAdminPanel. Le harnais QA ne doit jamais être installé en Edit. Aucun fichier .rbxl sauvegardé ni expérience publiée par cette intervention.

Audit final : 46 scripts compilants, aucun QA actif en Edit. Les trois sources modifiées concordent avec Studio ; seul le commentaire historique local de PlayerCurrency diffère du reste du manifeste.

## Délégation installée — 27 octobre 2026

Les sources locales ajoutent la catégorie ADMINS au panel propriétaire : saisie d'un nom Roblox, ajout et révocation par UserId. `AdminService` garde le UserId propriétaire fixe, vérifie les droits côté serveur, recharge les délégations au démarrage et met à jour les joueurs présents. Les changements passent par `MessagingService` pour actualiser les autres serveurs ; l'interface signale un échec de diffusion. Les actions de gestion sont interdites aux admins délégués. Le stockage est isolé dans `AdminDelegates_v1`, avec échec fermé et plafond de 50 comptes vérifié dans `UpdateAsync`. `GameHub` ferme le panel d'un joueur quand son accès est révoqué. Le harnais ajoute les refus d'auto-délégation.

Tu avais raison : le Studio `Évolution des armes` est le bon jeu. Le placeId actif est `89391796839094` ; les deux scripts de base (`AdminService`, `GameHub`) correspondaient exactement à leurs sources locales avant édition. Sauvegardes créées dans `ServerStorage.BeforeAdminDelegation`. Les deux scripts ont ensuite été synchronisés avec les sources locales.

En Play SessionStudio, le panel propriétaire s'est chargé pour UserId 10565455042, `AdminCanDelegate=true`, avec le champ de nom Roblox. L'appel serveur `ListAdmins` a réussi via le DataStore et renvoyé une liste vide ; aucun ajout ni retrait n'a été fait. Console Studio vide après démarrage, puis Play arrêté et Studio rendu à Edit. Les sources Studio et locales sont identiques après édition. Rapport `studio/qa/admin-delegation-result.json`.

Limites : le clic réel sur le nouvel onglet et les actions d'ajout/retrait n'ont pas été exercés ; aucun second joueur/serveur n'était présent. La lecture DataStore est confirmée, mais pas l'écriture, la résolution d'un vrai nom, ni la diffusion `MessagingService`. Le harnais comprend deux nouvelles assertions de refus, pas encore exécutées. Aucun `.rbxl` sauvegardé ou expérience publiée.
