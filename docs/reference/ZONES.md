# Zones et extensions

| Zone | Niveau | Centre X/Z | Arrivée X/Y/Z |
| --- | --- | --- | --- |
| Ville en ruine | 1 | 0 / -120 | 0 / 4 / 10 |
| Usine condamnée | 5 | 620 / -120 | 620 / 4 / 10 |
| Laboratoire toxique | 12 | 1240 / -120 | 1240 / 4 / 10 |
| Port des cendres | 20 | 1860 / -120 | 1860 / 4 / 10 |
| Centrale foudroyée | 28 | 2480 / -120 | 2480 / 4 / 10 |
| Métro oublié | 35 | 3100 / -120 | 3100 / 4 / 10 |
| Fosse de quarantaine | 45 | 3720 / -120 | 3720 / 4 / 10 |
| Barrage des noyés | 60 | 4340 / -120 | 4340 / 4 / 10 |
| Citadelle des cendres | 80 | 4960 / -120 | 4960 / 4 / 10 |
| Cratère du réacteur | 100 | 5580 / -120 | 5580 / 4 / 10 |
| Mer de verre | 120 | 6200 / -120 | 6200 / 4 / 10 |
| Cité des antennes | 140 | 6820 / -120 | 6820 / 4 / 10 |
| Station orbitale | 160 | 7440 / -120 | 7440 / 4 / 10 |
| Bunker des profondeurs | 180 | 8060 / -120 | 8060 / 4 / 10 |
| Fonderie du dernier jour | 200 | 8680 / -120 | 8680 / 4 / 10 |
| Terminus du dernier convoi | 220 | 9300 / -120 | 9300 / 4 / 10 |
| Grille déchue | 240 | 9920 / -120 | 9920 / 4 / 10 |
| Noyau d'arrêt | 260 | 10540 / -120 | 10540 / 4 / 10 |
| Voûte de l’Éclipse | 280 | 11160 / -120 | 11160 / 4 / 10 |

Le métro ajoute trois espèces/pets et dossiers : [règles et preuves](METRO.md). Treize extensions suivent : Fosse (45), Barrage (60), Citadelle (80), Cratère du réacteur (100), Mer de verre (120), Cité des antennes (140), Station orbitale (160), Bunker des profondeurs (180), Fonderie du dernier jour (200), [Terminus du dernier convoi (220)](LAST_CONVOY.md), [Grille déchue (240)](GRIDFALL.md), [Noyau d'arrêt (260)](BLACKOUT_CORE.md) et [Voûte de l’Éclipse (280)](ECLIPSE_VAULT.md), avec trois espèces, fragments/pets, six points de spawn et dossiers par zone. Ces secteurs utilisent des blockouts géométriques temporaires, en attente des modèles définitifs. Les zombies reprennent les rigs déjà présents avec leurs variantes de teinte et d’échelle. Les armes normales ajoutées après le niveau 35 utilisent les modèles décrits dans [la progression de l'arsenal](PROGRESSION_ARMES.md) ; les 16 FBX importés vont de Hook à EclipseGlaive.

La centrale ajoute trois espèces et familiers : [règles, scène, preuves serveur et validation Play restante](CENTRALE.md). Les preuves de port ci-dessous restent celles du lot historique et ne valent pas validation des nouveaux portails.

WorldConfig définit les limites, six emplacements et trois espèces dans chacune des dix-neuf zones. Le Bunker, la Fonderie, le Terminus, la Grille, le Noyau et la Voûte sont documentés dans [DEPTHS.md](DEPTHS.md), [IRON_SANCTUM.md](IRON_SANCTUM.md), [LAST_CONVOY.md](LAST_CONVOY.md), [GRIDFALL.md](GRIDFALL.md), [BLACKOUT_CORE.md](BLACKOUT_CORE.md) et [ECLIPSE_VAULT.md](ECLIPSE_VAULT.md). La Ville réapparaît après 7 s ; les autres zones conservent 10 s : voir [CONTRATS_EXPRESS.md](CONTRATS_EXPRESS.md). ZoneService contrôle niveau et distance au portail côté serveur, puis éjecte vers le refuge les entrées directes non autorisées. Le refuge reste hors des zones de combat.

## Zombies de la Ville

Les trois zombies possèdent de nouveaux corps texturés générés dans Studio : rôdeur vêtu d'une veste, affamé à capuche et côtes apparentes, colosse massif en armure. Six maillages sont soudés aux articulations de chaque rig ; `VisualHead` reste reconnu par les tirs à la tête. Chaque espèce a des poses procédurales propres de repos, marche et attaque dans PresentationClient ; ReducedMotion les atténue. Les dégâts et délais restent ceux de ZombieMelee et WorldConfig.

Le constructeur ponctuel `studio/BuildCityZombieRework.luau` a été exécuté une fois en Edit et ne doit pas être installé au démarrage ; les modèles précédents sont dans `ServerStorage.BeforeCityZombieRework`, et les sculptures sources dans `ServerStorage.CityZombieSculpts`. Les FBX et actions sous `assets/city_zombies/` sont des modèles Blender séparés, non importés dans le jeu et avec un rig différent. La capture statique a montré les nouveaux modèles ; en Play, six apparitions, les rayons de tête et calculs de dégâts, poses d'attaque et ReducedMotion ont été vérifiés par les fixtures temporaires `studio/qa/CityZombieRework.server.luau` et `CityZombiePresentation.client.luau`. Le rendu des déplacements et attaques en situation, l'import des clips Blender, AnimationConstraint et le mobile restent à vérifier.

## Départ et portails du refuge

Depuis l’apparition au refuge, Ville niveau 1 se trouve en face à (0,4.5,208), et Usine niveau 5 à gauche en (-32,4.5,208). Les modèles complets et leurs destinations ont été échangés en Edit ; sauvegarde `ServerStorage.BeforeStartingPortals` et opération ponctuelle `studio/MoveStartingPortals.luau`, à ne pas installer au démarrage. Les portails suivants n’ont pas été déplacés.

En Play PC, avancer depuis le départ et maintenir E 0,8 seconde a transféré le personnage dans la Ville. Le prompt demande 0,35 seconde ; un appui bref ne suffit pas. Le test ne couvre pas le retour, le verrouillage de l’Usine, le mobile ni le multijoueur. Le nom du panneau est maintenant visible en seconde ligne ; sa ligne de niveau reste partiellement masquée par l’UI.

Les onze prompts de voyage ont une portée de 14 studs et un maintien de 0,35 s. Le texte client indique « Maintenir pour entrer » lorsque la zone est accessible et « Verrouille » sinon ; les retours indiquent « Maintenir pour revenir ». La vérification serveur de proximité utilise la portée du prompt + 3 studs. Test PC : maintien E depuis le spawn vers Ville réussi ; en position de test devant Usine au niveau 1, accès refusé et message niveau 5. Le prompt Roblox standard était invisible sur capture ; ProgressionClient affiche maintenant une carte cartoon. Capture PC et capture portrait simulé lisibles ; le tactile physique et une activation portrait par clic restent à vérifier. Sauvegardes Edit `BeforePortalSigns` et `BeforePortalPromptText` ; `ImprovePortalSigns.luau` est ponctuel, jamais en démarrage.

## Parcours Usine au clavier

En Play SessionStudio PC, le personnage a marché du spawn vers le portail Usine déplacé. Au niveau 1 la carte affiche VERROUILLE et E maintenu laisse au refuge avec le message de niveau 5. Après préparation du niveau 5, la carte affiche MAINTIENS E et l’entrée conduit à (620, 3.82, 10). Depuis l’arrivée, déplacement clavier D puis S jusqu’au retour, maintien E et arrivée au refuge (0, 5.12, 220). La fixture temporaire restaure Meta/statistiques/santé/position/flags et retire son ForceField ; console vide puis Stop. `studio/qa/portal-walk-result.json`. Le niveau a été préparé artificiellement ; autres zones, tactile physique et multijoueur non vérifiés dans cette passe.

## Port des cendres

| Espèce | PV | Vitesse | Dégâts | Pièces | XP | Familier et bonus |
| --- | --- | --- | --- | --- | --- | --- |
| Matelot noyé / Drowned | 650 | 8 | 24 | 320 | 500 | Crabi : +45 % pièces, +20 % XP |
| Écumeur des cendres / Raider | 800 | 14 | 28 | 420 | 650 | Requinou : +15 % pièces, +30 % XP, +18 % vitesse |
| Titan de l'ancre / AnchorTitan | 1 200 | 5 | 38 | 650 | 1 000 | Krakenou : +50 % pièces, +45 % XP, +6 % vitesse |

Deux zombies par espèce, six au total, délai de réapparition commun de dix secondes. Chaque élimination utilise la chance serveur existante de fragment (1/3). Trois fragments de la même espèce fusionnent en un familier. Un seul familier actif ; ses multiplicateurs se composent avec les boosts temporels existants.

Les nouvelles espèces réutilisent les six maillages humains existants et leurs rigs : Civilian pour le matelot, Runner pour l'écumeur, Brute pour le titan. ZombieFactory clone le modèle, retire ses anciens accessoires et ajoute respectivement casquette/gilet/algues, masque/bouteilles/harpon, casque/épaulières/ancre. Les neuf modèles précédents ne sont pas modifiés. Les accessoires nouveaux ne bloquent pas les tirs ; les maillages du corps restent touchables. Les dimensions des modèles sont différentes.

## Scène persistante et reprise

- workspace.ProgressionZones.Harbor : quais, avenue, quatre conteneurs dont un empilé, deux grues, deux épaves, éclairage et trois obstacles bas.
- Entrée : workspace.ProgressionZones.RefugePortals.Travel_Harbor, Field à (64, 4.5, 208). HarborExpeditionPad prolonge le sol du refuge par recouvrement de l'ancien tablier.
- Retour : workspace.ProgressionZones.Harbor.Return_Harbor, Field à (1882, 4.5, 20).
- Templates : ServerStorage.ZombieTemplates.Drowned / Raider / AnchorTitan.
- Ambiance locale : teinte froide et vent renforcé ; aucune nouvelle piste audio. L'eau du décor est une surface visuelle au-dessus d'un fond solide, sans système de noyade.

BuildHarborExpansion.luau est un constructeur ponctuel Edit, **jamais un script de démarrage**. Il nécessite la scène existante, les templates humains améliorés et les scripts WorldConfig/ZombieFactory à jour. Il utilise des clones de modules isolés pour éviter un ancien cache require, puis retire ces clones. Une nouvelle exécution sur la scène complète confirme son existence sans mutation ; une scène partielle provoque un arrêt pour inspection. Ne pas relancer les anciens constructeurs de carte pour ajouter le port. Les sources seules ne reconstruisent pas les assets ni la scène complète.

Backup des huit scripts modifiés de ce lot : ServerStorage.BeforeHarbor. Aucun élément existant de la carte remplacé. L'ajout en Edit ne confirme ni sauvegarde .rbxl ni publication.

## Preuves et limites

studio/qa/harbor-result.json conserve les contrôles de services, récompenses, fusion, accès, portails et mouvements. Les décès du harnais Harbor.server sont attribués synthétiquement aux vrais zombies apparus ; le harnais HarborCombat.server utilise séparément de vrais Shoot:FireServer via son pont client. Ne pas confondre ces preuves.

Les passages de portail avec E partent d'approches préparées, sans parcours complet à pied. Les captures PC montrent l'arrivée et les trois modèles de près ; les captures iPhone simulé montrent la flèche PORT en paysage et portrait. Les familiers réellement équipés ont été clonés dans une prévisualisation temporaire pour inspection visuelle ; ce panneau QA ne fait pas partie du jeu. Le multijoueur, le tactile/manette physique, l'équilibrage sur une longue session et le DataStore de production restent hors de ces vérifications.
