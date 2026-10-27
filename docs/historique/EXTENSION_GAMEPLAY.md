# Menu, refuge, dash et compagnons

Cette extension conserve les zones et le combat existants, et ajoute une progression annexe geree par le serveur. Les sources actives sont dans `studio/`. Les scripts anterieurs sont copies dans `ServerStorage.BeforeGameplayExpansion` dans Studio.

## Commandes et interface

- Accueil avec Jouer et Options, camera sur le refuge et mouvement bloque avant le depart.
- Ctrl : dash dans la direction du mouvement, ou vers la visee si le joueur est immobile. Cout : 25 endurance, recharge : 3,5 secondes. Pas d'invulnerabilite ; balayage contre les obstacles avant le mouvement.
- B : boutiques, N : pets, G : cadeaux. P reste le menu rapide d'options.
- Mobile : un bouton Menu, quatre commandes tactiles (coup, sprint, lampe, dash) et onglets agrandis dans les boutiques.

## Boutiques du refuge

Quatre stands avec interaction E : atelier, armurerie, fusion de pets et Robux. L'atelier et l'armurerie exigent une proximite physique pour acheter. Les catalogues restent consultables a distance.

L'atelier propose 10 ameliorations de vie (+20 PV chacune) et 8 ameliorations de vitesse (+0,8 sur la marche et le sprint). Les prix augmentent a chaque achat et sont indiques avant confirmation.

| Arme | Prix en pieces | Niveau | Degats de base |
|---|---:|---:|---:|
| Poings | Gratuit | 1 | 10 |
| Tuyau | 150 | 1 | 16 |
| Batte a pointes | 650 | 2 | 28 |
| Hache de secours | 2200 | 5 | 48 |
| Lame du survivant | 8500 | 12 | 80 |

Les armes ont un modele a la premiere personne, un modele visible par les autres joueurs et leurs propres portees/cadences. La troisieme frappe conserve le multiplicateur de combo existant. Les achats possedes peuvent etre equipes gratuitement depuis le menu.

## Fragments et pets

Chaque elimination creditee a exactement une chance sur trois de donner un fragment du type de zombie tue, independamment des tirages precedents. Il existe neuf familles de fragments. Trois fragments identiques sont consommes pour fabriquer le pet correspondant. Buddy est offert par le temps de jeu.

Un seul pet est actif. Les copies supplementaires sont conservees mais ne multiplient pas les bonus. Les bonus vont de +10 % pieces pour Mini Rodeur a +35 % pieces et XP pour Titanou ; Zippy et Spectre favorisent la vitesse. Les valeurs exactes figurent dans GameplayConfig et dans chaque fiche du menu. Les compagnons flottent derriere leur proprietaire avec un modele cartoon et un nom.

## Recompenses du jour

Le temps commence apres Jouer, se cumule sur la journee UTC et reprend apres reconnexion en partie publiee. Les cadeaux doivent etre recuperes et ne peuvent pas l'etre deux fois. Le jour suivant renouvelle les paliers.

| Temps | Cadeau |
|---|---|
| 5 min | XP x2 pendant 10 min |
| 10 min | 150 pieces |
| 15 min | 1 fragment de Rodeur |
| 20 min | Pieces x2 pendant 10 min |
| 30 min | Pet Buddy gratuit |
| 45 min | 3 fragments d'Affame |
| 60 min | 1000 pieces |
| 90 min | 2000 XP |
| 120 min | 3 fragments de Chercheur toxique |

Quatre missions quotidiennes donnent aussi des pieces et de l'XP a 10, 30, 75 et 150 eliminations. Les boosts temporaires expirent en temps reel, meme hors connexion. Ils multiplient les gains des zombies avec le bonus du pet ; les cadeaux, missions et packs achetes ne sont pas multiplies.

## Robux : volontairement desactive

`GameplayConfig.MonetizationEnabled` vaut false. Tous les identifiants valent zero et aucun bouton ne lance un achat. Les packs prepares sont de 1000 / 6000 pieces et 1000 / 6000 XP. La Lame Nova est une arme permanente d'edition limitee, de 55 degats, reservee a une future offre configuree.

Pour une activation ulterieure : creer les quatre produits developpeur, renseigner leurs ProductId, creer le game pass de la Lame Nova, renseigner GamePassId et une vraie date de fin SaleEndsAt (timestamp UTC), puis activer MonetizationEnabled. Il faut egalement gerer la mise en vente et son arret dans Creator Hub : le controle en jeu ne retire pas une offre de la page Roblox externe. Aucun prix fictif, stock fictif ou faux compte a rebours n'est affiche.

Le serveur utilise ProcessReceipt pour les produits consommables et conserve l'identifiant du recu avec les benefices dans le meme profil avant de l'acquitter. Le game pass est verifie via Roblox, y compris a la reconnexion. Documentation de reference : [produits developpeur Roblox](https://create.roblox.com/docs/production/monetization/developer-products).

## Sauvegarde et verification

Les ameliorations, armes, fragments, pets, boosts et reclamations sont dans le champ Meta du profil existant WeaponEvolution_Progress_v1. Le verrou de session et l'autosauvegarde restent utilises. Studio fonctionne toujours avec des profils de session ; aucun achat reel ni sauvegarde de production n'a ete teste.

Le harnais `studio/qa/Expansion.server.luau` est reserve a Studio et restaure les donnees initiales apres ses controles. Il n'est pas installe comme script permanent. Il couvre les prix, la proximite, les niveaux, la possession des armes, les fusions, les bonus, les paliers temporels, les missions et les refus d'achats Robux. Les controles d'integration ont aussi confirme 16 degats pour le tuyau, le gain de pieces et l'incrementation des eliminations a la mort d'un zombie, le modele du compagnon, le demarrage et le dash.

L'accueil, les pages et les commandes tactiles ont ete inspectes dans le simulateur iPhone 17 Pro en paysage, puis Studio a ete remis en vue ordinateur. La validation sur appareil physique, en portrait et avec plusieurs joueurs reste a faire avant publication.

## Fichiers principaux

- GameplayConfig : catalogues, prix, bonus, paliers, dash et champs Robux.
- EconomyService : achats, fragments, pets, cadeaux, missions, recus et etat du joueur.
- GameSystems : initialisation du service.
- GameHub.client : accueil, interfaces, commandes tactiles, effets de dash et compagnons locaux.
- WeaponVisuals : modeles des armes en vue joueur, en multijoueur et sur les stands.
- BuildRefugeShops : construction unique des quatre stands, a ne pas relancer sur le refuge deja equipe.
- ProgressionService, ZombieDirector, FistsServer/FistsClient, SprintServer/SprintClient et InterfaceV2 : raccordements aux systemes existants.
