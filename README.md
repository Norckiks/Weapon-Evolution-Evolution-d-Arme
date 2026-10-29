# Weapon Evolution

Jeu Roblox de survie contre des zombies : progression en pièces/XP, armes, pets et zones à niveaux requis, avec interface cartoon.

Monde nocturne très sombre : la lampe torche révèle le sol et les obstacles, avec faisceau principal, halo et ombres proches. F / bouton LAMPE : [réglages et limites vérifiées](docs/reference/AMBIANCE_NUIT.md).

Une arène **PVP** éclairée et balisée dans la cour du refuge reste ouverte à tous ; hors de l’arène, le combat est possible si les deux joueurs l’activent dans Options. [Règles, preuves et limites](docs/reference/PVP.md).

Une [cour réorganisée agrandit le refuge](docs/reference/REFUGE.md) : portail Ville près du spawn, puis 18 zones en trois rangées lisibles, avec des cadres assortis, une allée centrale et des espaces de repos.

Des élites apparaissent après huit éliminations attribuées dans les zones avancées : [règles et preuves](docs/reference/ELITES.md).

Les copies de pets permettent désormais trois évolutions, avec une copie conservée et des bonus renforcés : [rangs et preuves](docs/reference/EVOLUTION_PETS.md).

Un calendrier de connexion offre sept cadeaux successifs, un par jour UTC sans perte lors des absences : [récompenses et preuves](docs/reference/CONNEXION.md).

Les contrats express adaptent leurs primes à la zone jusqu'à x62 dans la Voûte de l’Éclipse, avec le palier le plus bas du contrat retenu : [règles et preuves](docs/reference/CONTRATS_EXPRESS.md).

Première chasse du jour : un zombie éliminé débloque 100 pièces et 50 XP à récupérer dans Missions, une fois par jour UTC : [règles et tests](docs/reference/PREMIERE_CHASSE.md).

L'atelier vend aussi Souffle : cinq améliorations d'endurance, de 100 à 200 points, avec achat depuis l'UI : [règles et preuves](docs/reference/ENDURANCE.md).

Quarante-deux primes de niveau en pièces (niveaux 2 à 280), uniques par profil, dont 520 000 pièces au niveau 270 et 560 000 au niveau 280 : [règles et preuves](docs/reference/PRIMES_DE_NIVEAU.md).

Dix-neuf zones, cinquante-sept espèces : Ville (niv. 1), Usine (5), Laboratoire (12), Port des cendres (20), Centrale foudroyée (28), Métro oublié (35), Fosse de quarantaine (45), Barrage des noyés (60), Citadelle des cendres (80), Cratère du réacteur (100), Mer de verre (120), Cité des antennes (140), Station orbitale (160), Bunker des profondeurs (180), Fonderie du dernier jour (200), Terminus du dernier convoi (220), Grille déchue (240), Noyau d'arrêt (260) et Voûte de l’Éclipse (280). Voir [ZONES.md](docs/reference/ZONES.md), [la Voûte](docs/reference/ECLIPSE_VAULT.md), [le Noyau](docs/reference/BLACKOUT_CORE.md), [la Grille déchue](docs/reference/GRIDFALL.md), [le Terminus](docs/reference/LAST_CONVOY.md), [le Cratère](docs/reference/CRATERE.md), [la Mer de verre](docs/reference/MER_DE_VERRE.md), [la Cité des antennes](docs/reference/CITE_ANTENNES.md), [la Station orbitale](docs/reference/STATION_ORBITALE.md), [le Bunker](docs/reference/DEPTHS.md), [la Fonderie](docs/reference/IRON_SANCTUM.md) et [la centrale](docs/reference/CENTRALE.md).

Sur PC, M libère le pointeur pour cliquer sur l'interface ; M ou REPRENDRE ramène au combat. Les attaques sont suspendues tant que le pointeur est libre. Les menus et la réapparition réinitialisent ce mode.

Une flèche cartoon accompagne le déblocage d'une nouvelle zone : portail de destination au refuge, ou portail de retour si le joueur se trouve dans une autre zone. Elle disparaît à l'arrivée et se masque dans les menus.

Armes à feu achetables depuis l'interface : pistolet (niveau 3), SMG (7), revolver (12), fusil à pompe (16) carabine des cendres (22) fusil du guetteur (28) et [mitrailleuse de barrage (35)](docs/reference/MITRAILLEUSE.md). Leurs caractéristiques et limites vérifiées sont dans docs/reference/ARMES_A_FEU.md.

L'arsenal compte la Machette de secours (niveau 9), la Masse de démolition (19), six armes aux niveaux 40 à 80, puis dix armes jusqu'au Glaive de l'éclipse (270). Les 16 modèles Blender importés de Hook à EclipseGlaive sont maintenant visibles dans l'armurerie et en main ; voir [la progression des armes](docs/reference/PROGRESSION_ARMES.md).

L'armurerie affiche le prochain palier de l'arsenal, le niveau requis et les pièces manquantes, avec achat direct quand les conditions sont réunies. Voir [la progression des armes](docs/reference/PROGRESSION_ARMES.md).

Les tirs de tête font ×1,5 dégâts, avec calcul serveur et récompenses ordinaires : [règles et tests](docs/reference/TIRS_A_LA_TETE.md).

Les zombies préparent leurs coups : direction verrouillée, esquive possible et interruption par étourdissement. Voir [les règles de combat ennemi](docs/reference/ZOMBIES_COMBAT.md).

La poursuite contourne les obstacles et reprend les trajets bloqués : [navigation zombies et mesures](docs/reference/NAVIGATION_ZOMBIES.md).

À partir du niveau 5, six capacités sont débloquées par niveau : onde de choc, frappe tellurique, lance cryo (tir droit jusqu'à 70 studs), égide astrale, second souffle et [décharge électrique en chaîne](docs/reference/DECHARGE.md) au niveau24. Le serveur vérifie niveau, endurance, délai, cibles, protection et soin. Voir [docs/reference/CAPACITES.md](docs/reference/CAPACITES.md).

Missions & dossiers proposent trois objectifs permanents dans chacune des dix-neuf zones, avec cinquante-sept récompenses uniques en pièces et XP. Voir [docs/reference/EXPEDITIONS.md](docs/reference/EXPEDITIONS.md) pour les règles et le champ de profil.

Refonte portrait des sept pages installée, validation complète encore en attente : [état et reprise des tests UI](docs/reference/UI_MOBILE.md).

Caisses d’armes et de pets en pièces : onglet CAISSES, probabilités visibles et ouverture 3D cartoon. Voir [docs/reference/CAISSES.md](docs/reference/CAISSES.md) pour les prix, règles et preuves.

Panneau admin : F4 ou bouton ADMIN ; Bruno_ban369 peut déléguer et retirer cet accès depuis la catégorie ADMINS. Voir [les commandes et limites](docs/reference/ADMIN_PANEL.md).

Marche et sprint accélérés, course adaptée à la vitesse et vue à la troisième personne : O, bouton de vue ou Options. [Les cinq idées traitées, la comparaison et les tests](docs/reference/IDEES_IMPLEMENTEES.md).

La pompe du fusil et le barillet du revolver s'animent aussi sur le personnage : [fonctionnement et preuves](docs/reference/ANIMATIONS_ARMES.md).

Capacités : Q onde, E frappe, T cryo, H égide, J soin, K décharge. R recharge et G ouvre les cadeaux. Le sélecteur mobile lance la capacité choisie ; [commandes manette et tests](docs/reference/CAPACITES.md).

Le menu se démarre aussi avec Entrée ou A à la manette. Les commandes tactiles se recréent lors d'un changement de périphérique ; [preuves et limites UI](docs/reference/UI_MOBILE.md).

## Organisation du dépôt

- `studio/` : sources Luau et manifeste des scripts actifs.
- `docs/reference/` : guides fonctionnels et preuves.
- `docs/historique/` : anciennes analyses, idées et plans, sans preuve d’implémentation.
- `assets/` : ressources graphiques.
- [Index documentaire](docs/README.md) : chemin de reprise et choix du guide pertinent.

Pour reprendre le travail :

1. Lire [AGENTS.md](AGENTS.md), puis [RELAIS_IA.md](RELAIS_IA.md).

2. Utiliser [le mapping des scripts](studio/runtime-manifest.json) pour retrouver leurs instances Studio.

3. Consulter [les déplacements](docs/reference/MOUVEMENTS.md), [les armes à feu](docs/reference/ARMES_A_FEU.md) et [les images UI](assets/ui/README.md) selon le travail.

Prompt de relais :

> Lis AGENTS.md puis RELAIS_IA.md. Inspecte les sources locales et l'instance Roblox Studio avant de modifier quoi que ce soit. Continue les améliorations en priorité à partir des vérifications restantes. Garde les achats Robux désactivés et les achats en pièces disponibles depuis l'UI. Mets à jour les sources locales et le guide après tes changements, en séparant les tests effectués des limites restantes.

Les scripts seuls ne contiennent pas tous les modèles, terrains et objets GUI du fichier Roblox. Les modifications installées en Studio n'impliquent ni sauvegarde du fichier .rbxl ni publication.


