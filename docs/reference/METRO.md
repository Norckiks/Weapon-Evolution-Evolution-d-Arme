# Métro oublié

Sixième zone, identifiant Metro, niveau35. Centre(3100,0,-120), demi-emprise(145,100,150), arrivée(3100,4,10). Six spawns, deux zombies de chaque espèce ; réapparition commune10s. Entrée au refuge(128,0,208), pad relié à celui de la Centrale ; retour dans la station(3122,0,20). Le serveur refuse l’accès avant35 et renvoie une entrée directe non autorisée au refuge. La flèche de progression existante cible Travel_Metro lors du passage34→35.

| Espèce | PV | Vitesse | Dégâts | Pièces | XP | Silhouette |
| --- | --- | --- | --- | --- | --- | --- |
| Contrôleur déchu / Conductor | 1700 | 10 | 42 | 2000 | 2600 | Casquette, épaulettes, manteau, badge et lanterne |
| Coureur des tunnels / TunnelRunner | 2100 | 18 | 45 | 2500 | 3200 | Casque à lampe, masque/filtres, harnais, sac, genouillères et griffes |
| Titan des rails / RailTitan | 3200 | 7 | 60 | 3600 | 4600 | Grande carrure, plaque faciale, armure, traverses dorsales et marteau |

Trois rigs améliorés réutilisés (Civilian/Runner/Brute), six MeshParts et six Motor6D chacun, avec équipements distincts soudés au squelette. Ils ne remplacent aucun template antérieur. Les accessoires lumineux sont décoratifs ; les ennemis utilisent la mêlée et la navigation existantes, sans nouvelle attaque de lanterne/marteau.

La scène contient238 descendants : sol continu, rails/traverses, quatre rames fermées, quais, murs et auvents à25studs, lumière de secours verte, panneaux, bancs et trois tourniquets franchissables. Les trains sont des obstacles fermés, pas des véhicules pilotables ou intérieurs accessibles. Les spawns et le chemin central restent dégagés. Aucun asset externe téléchargé/importé.

## Correction des apparitions

Les anciens contrôles de sol utilisaient un rayon court : ils ne prouvaient pas la hauteur des zombies réellement créés. En Play, les six ennemis apparaissaient sur les auvents, à environ 28,84–31,60 studs. Le directeur lance désormais son rayon depuis six studs au-dessus du point configuré, avec `RespectCanCollide`, en excluant les joueurs et les zombies vivants. Après correction, les racines observées au Métro sont à 3,42 (coureur), 3,60 (contrôleur) et 6,18 (titan) ; les 36 ennemis des six zones observés étaient sous 15 studs. Le test Metro mis à jour passe 55 contrôles, dont six sur les racines réelles : `studio/qa/metro-spawn-fix-result.json`.

## Progression

Chance de fragment serveur1/3 par élimination, fusion de trois identiques. Les pets réutilisent les formes existantes avec ces couleurs/bonus :

| Pet | Forme | Pièces | XP | Vitesse |
| --- | --- | --- | --- | --- |
| Ticketou / Conductor | Robot vert | +80% | +40% | +4% |
| Lampin / TunnelRunner | Lapin jaune | +35% | +65% | +25% |
| Railours / RailTitan | Ours gris vert | +90% | +75% | +10% |

Un seul actif ; multiplicateurs composés avec les boosts existants. Ils ne sont pas ajoutés aux caisses. Trois dossiers uniques :6 éliminations,3 espèces,18 éliminations, avec10 000/4500,15 000/6750,20 000/9000 pièces/XP. Contrats express Metro×14, avec le palier minimum des éliminations contributrices ; normalisation du multiplicateur élargie1..14, anciennes valeurs préservées. Prime permanente de niveau35 :9 000pièces, onzième prime, mêmes contrôles serveur de reçu/capacité. Aucun ancien prix/récompense modifié, aucun profil effacé ; Meta.Expeditions.Metro et possessions/pets utilisent les tables existantes.

## Preuves du27 octobre2026

Sept sources locales/instances comparées et synchronisées Edit : WorldConfig, ZombieFactory, GameplayConfig, Expeditions, QuickContracts, GameHub, ZoneGuide. Backup ServerStorage.BeforeMetroExpansion(7). Constructeur ponctuel BuildMetroExpansion.luau exécuté en Edit, jamais installé en démarrage ; second appel idempotent confirme aucune mutation. Les templates neufs sont construits via copies temporaires de config/fabrique pour éviter le cache require Edit, puis staging retiré. Manifeste toujours46 scripts.

Rapport `studio/qa/metro-result.json` :

-49 assertions zone : sols libres sous arrivée/spawns, rigs complets non ancrés, six ennemis actifs, refus34/accès35 et éjection, attribut de flèche Metro, chemin Pathfinding pour grand gabarit, vraie poursuite, trois vrais callbacks de mort,8 100pièces/10 400XP de base (niveau35→41, reste1160XP), aucun double crédit, fragments observés, refus2/fusion3 et bonus des trois pets, dossiers/doublons, respawn et JSON.
-55 régressions contrats :18 paliers/contrats exacts et remises à zéro, mélanges de zones, anciennes sauvegardes, bornes1..14, faux messages client et vraie mort Lineman avec récompense de contrat distincte. Ancien harnais ContractZones mis à jour pour le maximum14.
-35 régressions primes de niveau, incluant le nouveau niveau35/9000 et la capacité du portefeuille, doublons/forgery/JSON/reçus. 
-3 vrais tirs de carabine (38 dégâts corps, une balle chacun) sur les trois nouveaux rigs via Shoot client. Ces tirs ne sont pas les morts utilisées pour les récompenses.
-3 fiches pets client : présence/image, noms et descriptions de bonus constatés. Pas de TextFits ou capture.

QA Metro.server/MetroBridge.client, MetroCombat.server/client, ContractZones et LevelRewards uniquement Play SessionStudio, données Meta/statistiques/position/flags restaurées puis Stop. Les zombies visés gardent temporairement leurs dégâts dans le Play de test ; Stop retire cet état. Console contrôlée vide.

Capture Edit MetroEditOverview en attente sans image : attente d’orchestration terminée manuellement, aucune capture réussie à revendiquer. Pas de nouvel essai de capture relancé. État Studio redécouvert Edit ensuite. Le rendu Play antérieur reste indisponible ; ni cadrage, modèles/poses à l’écran, textures, écoute, UI mobile, manette/tactile physique, interaction native des nouveaux portails, R6, multijoueur ni reconnexion DataStore ne sont validés. Pas de publication ou sauvegarde.rbxl. L’équilibrage final nécessite des joueurs ; les tests prouvent les règles et géométries ciblées.
