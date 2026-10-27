# Weapon Evolution — contexte et analyse

Analyse du 21 octobre 2026. Intention du créateur : le joueur commence avec ses poings, puis progresse pour obtenir une arme. Conserver le système existant comme point de départ.

## Sources examinées

- Le dossier local contenait uniquement docs/historique/context.txt, qui décrit la vision du jeu.
- Scripts et objets lus dans Roblox Studio, expérience placeId 76184777294422, pendant une session Play, côté serveur. Cette analyse décrit les objets accessibles pendant le test ; elle ne remplace pas une vérification du modèle Edit avant modification.
- Aucun script du jeu modifié, aucun test de gameplay déclenché.

## Système existant

- ReplicatedStorage.FistsConfig : dégâts 10, multiplicateur lourd 2,5 (25 dégâts), cooldown client 0,4 s, portée 6,5 studs, rayon 1,6 ; combo de 3 coups, fenêtre 1,1 s ; recul normal 22, lourd 55 ; listes de sons.
- ReplicatedStorage.Remotes.Punch : demande de frappe client vers serveur avec direction de caméra.
- ReplicatedStorage.Remotes.PunchHit : confirmation serveur vers client avec indicateurs heavy et killed.
- ServerScriptService.FistsServer : valide direction, personnage vivant et cooldown (0,32 s côté serveur), calcule le combo, Spherecast depuis la tête, accepte uniquement les modèles tagués Zombie. Applique dégâts, attribut LastAttacker sur le Humanoid, recul, flash rouge et son 3D. Récompenses encore en TODO.
- StarterPlayer.StarterPlayerScripts.FistsClient : bras et poings construits par code devant la caméra ; alternance droite/gauche, anticipation/frappe/retour, balancement, sons, viseur, secousse et variation de FOV (base 75). Clic gauche maintenu, gâchette R2 et bouton tactile. Demande envoyée 0,17 s après le début du coup.
- ServerStorage.TrainingDummyTemplate : modèle tagué Zombie.
- Workspace.TrainingDummy : cible taguée Zombie.
- ServerScriptService.TrainingDummyService : à la mort du mannequin, attend 2 s, détruit, attend 1,5 s puis clone le modèle et réinstalle la surveillance.
- Scripts de caméra, déplacement et sons Roblox également présents dans StarterPlayer ; ne pas les confondre avec les scripts métier du jeu.

## Pas encore implémenté dans les scripts examinés

Coins/Gems, leaderstats, sauvegarde DataStore, achat/amélioration/équipement d'armes, inventaire, vagues et IA zombies, zones, œufs et pets. StarterPack et StarterGui vides pendant l'inspection ; le viseur est créé par code.

## Points à traiter lors de la progression vers les armes

- Ajouter un état d'équipement autoritaire côté serveur : les poings sont actuellement toujours disponibles, le client capture le clic et affiche ses bras tant que le personnage vit. Prévoir désactivation des poings à l'équipement d'une arme.
- Relier LastAttacker à une attribution de récompense unique, puis à une monnaie et à une sauvegarde avant les achats.
- Client et serveur calculent leur combo séparément ; vérifier la synchronisation après frappes refusées, mort et respawn.
- Une frappe différée côté client vérifie un personnage vivant mais ne vérifie pas qu'il s'agit du même personnage qu'au début du coup.
- La couleur des bras est lue à la construction du viewmodel ; pas de reconstruction explicite au respawn.
- Le serveur ne vérifie pas l'orientation du personnage ni l'arme équipée. Définir les règles attendues avant d'étendre le combat.

## Ordre de travail cohérent

1. Conserver et fiabiliser les poings comme équipement initial.
2. Récompenses de combat et monnaie sauvegardée.
3. Première arme achetable et équipement exclusif poings/arme.
4. Améliorations et déblocages, puis autres systèmes décrits dans docs/historique/context.txt.

Cet ordre est une proposition technique ; les prix, armes et conditions de déblocage restent à définir avec le créateur.

## Map apocalyptique ajoutée le 21 octobre 2026

- Workspace.SurvivorCamp : camp procédural généré (tentes, véhicules militaires, murs, barricades), recentré en (0, 120) sur le plan XZ.
- Workspace.ApocalypseDistrict : ville en ruine, 12 bâtiments de 2 à 5 étages avec ouvertures, sols, toits cassés, gravats et armatures ; avenue, carrefour, passages piétons, voitures abandonnées, deux foyers avec fumée, éclairage et entrée de quarantaine. Silhouettes au fond de la ville.
- SpawnLocation déplacé en (0, 1, 175), invisible ; mannequin et modèle de réapparition déplacés ensemble en (0, 4, 160).
- Lighting : fin de journée, brume et correction colorimétrique. Anciennes valeurs et effets copiés dans ServerStorage.BeforeApocalypseLighting avant modification.
- Scripts de poings conservés. Aucun système de vagues ou d'IA zombie ajouté avec le décor.
- Source de construction complémentaire : studio/BuildApocalypseDistrict.luau. Ce script suppose le camp procédural initial présent et ne doit pas être relancé tel quel sur la map déjà construite (il créerait un doublon).
- Vérification visuelle effectuée depuis la rue et en vue d'ensemble ; contrôle du sol par raycasts le long de l'avenue.

## Interface vie et pièces ajoutée le 21 octobre 2026

- StarterGui.SurvivalHUD : deux panneaux sombres en bas à gauche sur ordinateur ; placement haut gauche sur petit écran tactile pour éviter le joystick. Barre de vie, valeur actuelle/maximale, compteur de pièces avec séparateurs de milliers.
- HUDController (LocalScript) écoute HealthChanged, MaxHealth et leaderstats.Coins ; raccordement automatique après respawn et adaptation à la taille de fenêtre. Masque la barre de vie Roblox intégrée.
- ReplicatedStorage.CoinIcon : logo doré avec Z, dessiné avec des objets GUI Roblox, réutilisable sans asset externe. Version vectorielle disponible dans assets/coin-logo.svg.
- ServerScriptService.PlayerCurrency : crée leaderstats.Coins à 0 côté serveur sans écraser une valeur déjà présente. Valeur de session uniquement : aucune sauvegarde ni récompense de combat ajoutée.
- Sources locales dans studio/CoinIcon.luau, studio/PlayerCurrency.server.luau, studio/SurvivalHUD.client.luau et studio/CreateSurvivalHUD.luau. Le script de création refuse les doublons ; les sources des contrôleurs doivent être installées séparément comme dans Studio.
- Vérifié en Play : affichage initial 100/100 et 0 pièce ; changement côté serveur à MaxHealth=150, Health=55 et Coins=12345 répercuté ; après respawn, un seul HUD, vie 100/100 et solde de test remis à 0.

## Sprint et endurance ajoutés le 21 octobre 2026

- SprintConfig dans ReplicatedStorage : vitesse de sprint 26 (marche initiale 16 conservée par personnage), endurance 100, consommation 20/s, récupération 18/s après 1,25 s de repos. Déblocage après épuisement à partir de 25 points et relâchement du bouton.
- SprintServer et SprintState dans ServerScriptService : intent reçu via Remotes.Sprint, endurance et vitesse gérées côté serveur, publication des attributs Stamina, MaxStamina, Sprinting et SprintExhausted sur le personnage. Pas de consommation immobile ; arrêt à la mort, en position assise, en nage ou escalade.
- SprintClient : Maj gauche/droite, L3 ou bouton tactile maintenu ; remise à zéro de la commande au respawn, à la perte de focus ou à l'ouverture d'un champ texte. Animation de course R15 (507767714) ou R6 (180426354), pas accélérés et respiration progressive quand l'endurance baisse.
- Audio respiration : asset gratuit Creator Store 101395573137763 ; pas intégrés Roblox action_footsteps_plastic.mp3. Chargement des deux sons confirmé en Play.
- FistsClient : mouvement alterné des bras pendant le sprint et transition FOV 75 vers 82, compatible avec les impulsions de FOV des coups. Source précédente conservée dans ServerStorage.BeforeSprint.
- SurvivalHUD.StatusPanel.StaminaCard : jauge cyan entre vie et pièces, valeurs actuelle/maximale, passage orange à faible endurance et indication EPUISE.
- Sources locales : studio/SprintConfig.luau, SprintState.luau, Sprint.server.luau, Sprint.client.luau et FistsClient.client.luau. InstallSprint.luau documente l'installation complète et ne doit pas être relancé sur les objets existants.
- Vérifications : règles de consommation/récupération/épuisement, absence de consommation immobile, mort ; essai clavier Maj+W ; vitesse 26 et baisse de jauge ; animation R15 chargée et jouée à 1,45 ; son de pas actif ; retour vitesse 16 et FOV 75 au relâchement ; respawn avec endurance 100 et un seul HUD. R6 et commandes tactiles/manette implémentés mais non testés sur appareil.

## État actuel après zombies et refonte de présentation

Les sections précédentes décrivent des étapes historiques. L'état installé comprend maintenant trois zones (ville niveau 1, usine niveau 5, laboratoire niveau 12), trois variantes de zombies par zone, six zombies actifs par zone, récompenses en pièces et XP, niveaux et accès contrôlés côté serveur. Le départ se trouve en (0, 1, 220), devant les portails. Les valeurs de progression restent de session dans les tests Studio.

La refonte visuelle, sonore, d'animation et d'interface est décrite dans docs/historique/REFONTE_VISUELLE.md. Ses principaux contrôleurs actifs sont les fichiers canoniques dans studio/ ; les anciennes versions remplacées sont archivées dans studio/archive/presentation-v1 et des copies sont conservées dans ServerStorage.BeforePresentationV2.

Nouveautés : mode lumineux Realistic, trois matériaux PBR, dix assets de mesh texturés, décors enrichis, zombies à animation fluide et chutes physiques, nouveau viewmodel de poings, ambiances spatiales, météo, torche, HUD compact et menu de réglages. Les contrôles tactiles ont été vérifiés dans le simulateur iPhone 17 Pro en paysage, puis la vue normale a été rétablie.

Voir assets/presentation-v2-manifest.json pour les IDs des assets. Les scripts de construction sont des préparations uniques : ne pas les relancer sans vérifier leurs préconditions. Les personnages restent partiellement stylisés ; ne pas présenter la version comme photoréaliste ou comme un classement des meilleurs graphismes.
