# Fonderie du dernier jour

La quinzième zone se débloque au niveau 200, après le Bunker des profondeurs. Son blockout comprend deux hauts-fourneaux, une bande transporteuse, des coulées lumineuses et des poutres tombées. Les objets servent de base remplaçable ; aucun modèle final Blender n'est inclus.

| Espèce | PV | Vitesse | Dégâts | Pièces | XP | Familier et bonus |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Garde du creuset / CrucibleGuard | 76 000 | 10 | 310 | 66 000 | 90 000 | Creusetou : +100 % pièces, +95 % XP, +8 % vitesse |
| Sprinteur incandescent / CinderRunner | 61 000 | 26 | 275 | 62 000 | 92 000 | Braizip : +65 % pièces, +105 % XP, +29 % vitesse |
| Titan de la forge / ForgeTitan | 96 000 | 6 | 370 | 82 000 | 112 000 | Forgerours : +110 % pièces, +105 % XP, +7 % vitesse |

Le contrat rapide applique x54. Le dossier paie 180 000/80 000, 270 000/120 000, puis 360 000/160 000 pièces/XP. Les primes des niveaux 190 et 200 sont de 250 000 et 280 000 pièces. Le [Maillet du dernier jour](PROGRESSION_ARMES.md) se débloque au niveau 190 pour 4 400 000 pièces.

Les fragments de chaque espèce utilisent le taux de 1/3 et la fusion existante de trois fragments identiques. Les familiers réemploient les formes Robot, Bat et Bear.

`studio/BuildIronSanctumExpansion.luau` est un constructeur ponctuel en Edit, jamais un script de démarrage. Le portail d'entrée prolonge l'alignement du refuge ; le portail de retour vise Camp. La sauvegarde des quatre modules concernés est `ServerStorage.BeforeIronSanctumConfiguration`.

## Limites de vérification

Les modules sont contrôlés avec des clones temporaires. Play SessionStudio a vérifié le verrou 199/200 et le refus à 179/180, deux ennemis réels de chaque espèce avec leurs PV/rigs, les sept points d'apparition sur des surfaces collidables et les portails entrée/retour. Le niveau a été restauré puis Play arrêté. Le combat, les achats, gains de kill, fragments/fusion, parcours des collisions, interface mobile et DataStore de production restent à tester. Le jeu n'a pas été sauvegardé en `.rbxl` ni publié.
