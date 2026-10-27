# Zones et extensions

| Zone | Niveau | Centre X/Z | Arrivée X/Y/Z |
| --- | --- | --- | --- |
| Ville en ruine | 1 | 0 / -120 | 0 / 4 / 10 |
| Usine condamnée | 5 | 620 / -120 | 620 / 4 / 10 |
| Laboratoire toxique | 12 | 1240 / -120 | 1240 / 4 / 10 |
| Port des cendres | 20 | 1860 / -120 | 1860 / 4 / 10 |
| Centrale foudroyée | 28 | 2480 / -120 | 2480 / 4 / 10 |
| Métro oublié | 35 | 3100 / -120 | 3100 / 4 / 10 |

Le métro ajoute trois espèces/pets et dossiers : [règles et preuves](METRO.md).

La centrale ajoute trois espèces et familiers : [règles, scène, preuves serveur et validation Play restante](CENTRALE.md). Les preuves de port ci-dessous restent celles du lot historique et ne valent pas validation des nouveaux portails.

WorldConfig définit les limites, six emplacements et trois espèces de chaque zone. La Ville réapparaît après 7 s ; les autres zones conservent 10 s : voir [CONTRATS_EXPRESS.md](CONTRATS_EXPRESS.md). ZoneService contrôle niveau et distance au portail côté serveur, puis éjecte vers le refuge les entrées directes non autorisées. Le refuge reste hors des zones de combat.

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
