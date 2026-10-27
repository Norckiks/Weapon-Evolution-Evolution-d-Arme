# Idées à faire — lot du 26 octobre 2026

Le fichier utilisateur à la racine `idéé a faire.txt` contient cinq demandes. L'ancien `docs/historique/idees-a-faire.txt` est vide ; il ne remplace pas cette nouvelle liste.

## Changements installés

| Demande | Réalisation |
| --- | --- |
| Améliorer l'UI | Carte cartoon indiquant état et vitesse, bouton de vue, option dans le menu. En mobile paysage, boutiques/pets/cadeaux passent sur une ligne de boutons de 44 pixels de haut pour dégager les jauges. |
| Mouvements plus rapides | Marche 18 au lieu de 16 ; sprint 32 au lieu de 26 studs/s. Accélération 14, freinage 18 ; glissade 40 → 18 ; assistance horizontale de franchissement 22. Coûts d'endurance et délais conservés. |
| Comparer aux jeux tendance | Comparaison documentaire ci-dessous, avec observations séparées des choix de conception. |
| Améliorer la course | Cadence de l'animation liée à la vitesse physique ; entrée plus rapide, inclinaison progressive du torse et du corps en virage. ReducedMotion atténue cette couche. |
| Ajouter la troisième personne | O, bouton de vue ou option « Vue du personnage ». Caméra native Roblox, zoom 8–14, décalage épaule. Première personne conservée par défaut. |

En troisième personne, clic droit maintenu pour tourner sur PC et gestes de caméra Roblox sur mobile. Les bras subjectifs ne s'affichent que lorsque la caméra est réellement près de la tête ; l'arme du personnage reste visible à distance. La visée converge depuis la tête vers la cible sous le viseur. Origine des tirs, obstacles et dégâts restent contrôlés par le serveur. La préférence de vue reste pendant une réapparition, uniquement pour la session.

Les bonus de vitesse des améliorations et pets utilisent les mêmes bases que SprintConfig. Les achats en pièces restent accessibles depuis l'UI, loin des stands. Aucun produit Robux activé.

## Comparaison documentaire

Les [classements Roblox](https://www.roblox.com/charts?SortFilter=default&TimeFilter=0&nl=true) ont été consultés pendant ce lot. Leur ordre évolue ; aucun nombre de joueurs ni rang permanent n'est revendiqué. Ce travail n'est pas un essai personnel de ces jeux.

| Référence officielle | Ce que la source permet d'observer | Choix pour Weapon Evolution |
| --- | --- | --- |
| [Evade](https://www.roblox.com/games/9872472334/Evade) | La description met en avant action, parkour, déplacements, boutiques et réglages. | Donner davantage de réponse aux accélérations, conserver glissade/franchissement et proposer une vue plus large. Ce sont nos choix, pas une reproduction de ses paramètres physiques. |
| [Forsaken](https://www.roblox.com/games/18687417158/ALPHA-Forsaken) | La présentation décrit survie, objectifs et coopération. | Rendre plus lisibles l'état du joueur et les objectifs déjà présents. Une nouvelle boucle de manches ou de coopération demanderait un lot distinct. |
| [RIVALS, sélection FPS Roblox](https://www.roblox.com/spotlight/first-person-shooters) | Roblox le présente comme un FPS multijoueur à rythme rapide. | Préserver la première personne et la réactivité, tout en validant la visée et les obstacles pour la nouvelle vue. Aucune prétention de qualité ou performance équivalente. |

Priorités de suite déduites de cette comparaison : observer de vrais parcours et combats, mesurer l'usage des raccourcis sur téléphone, puis améliorer l'accès aux objectifs existants. Aucun mécanisme payant supplémentaire ni dépendance installé.

## Preuves et limites

Tests en Play Studio SessionStudio : cinq assertions de configuration/endurance/bonus, 33 régressions d'économie et 12 régressions de glissade/franchissement passent. Le parcours clavier W/Maj mesure 32 studs/s, environ 50,33 studs parcourus et une cadence d'animation de 2 ; l'endurance baisse de 98 à 65,2. Un second parcours ReducedMotion passe également (55,07 studs, 97,7 → 65). La mesure d'angle total inclut Animator : elle ne prouve pas à elle seule le facteur de réduction de la couche ajoutée.

O bascule réellement entre LockFirstPerson (distance tête/caméra environ 0,69) et Classic (environ 8,34). Le menu Options bloque O et masque le bouton de vue. Après réapparition, Classic et le zoom 8–14 sont conservés. Un clic réel en troisième personne au pistolet inflige 24 dégâts à une cible isolée ; le clic suivant, avec mur interposé, consomme une balle sans blesser cette cible.

Captures inspectées : PC 1447×801, iPhone 17 Pro simulé en portrait 401×778 et paysage 750×381. Le bouton de vue portrait répond à un clic explicite après correction des coordonnées du simulateur ; le ciblage par instance_path seul n'avait pas activé le bouton. Les trois raccourcis paysage mesurent 92×44 et ne recouvrent plus les jauges. Cela ne valide pas toutes les pages de boutique ni un écran tactile physique.

Un premier essai de course dite réduite a échoué : le setter ReducedMotion n'avait pas été exécuté après une erreur d'outil, et la cible de tir obstruait le parcours. La cible a été retirée, le réglage confirmé, le personnage repositionné et le test rejoué avec succès. Aucun de ces essais n'utilise de données de production.

La rotation au clic droit n'a pas été confirmée par l'outil de déplacement de souris : le vecteur caméra est resté identique. Elle utilise le contrôleur Roblox natif ; un essai physique reste nécessaire. Le cadrage troisième personne est visible sur le personnage actuel, mais la qualité de toutes les attaques et du rendu R6 n'a pas été revue visuellement. Pas de test multijoueur, manette physique, collision caméra sur toute la carte, reconnexion DataStore, publication ou sauvegarde .rbxl.

Sources actives modifiées : SprintConfig, MovementConfig, EconomyService, SprintClient, CharacterCombat, FistsClient, MovementClient, InterfaceV2 et GameHub. Backup initial dans `ServerStorage.BeforeIdeasMovementCamera`. Un écart sans effet d'exécution (commentaire local absent de PlayerCurrency dans Studio) a été aligné côté fichier local, sans remplacer le script Studio. Contrôle final Edit : les 46 sources du manifeste correspondent aux instances (empreintes normalisées et classes), les 46 compilent, aucun QA installé dans les conteneurs de démarrage. Harnais et résultats sous `studio/qa`, jamais installés en Edit.

Graphify a servi au repérage des dépendances (graphe distant pouvant précéder les derniers fichiers), puis les sources locales et Studio ont été comparées directement. Context7 a fourni la référence de caméra native Roblox ; ECC a guidé la lisibilité et les zones cliquables ; Ponytail a conduit à réutiliser les contrôleurs existants. [Référence caméra officielle](https://create.roblox.com/docs/workspace/camera).
