# Bunker des profondeurs

La quatorzième zone, accessible au niveau 180, prolonge la Station orbitale. Le blockout montre un sas de décontamination, une porte de pression, des colonnes de soutien, des drains lumineux et des cloisons effondrées. Ce décor est une base géométrique temporaire, pas un modèle final.

| Espèce | PV | Vitesse | Dégâts | Pièces | XP | Familier et bonus |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Gardien du sas / VaultWarden | 62 000 | 10 | 270 | 54 000 | 70 000 | Sasou : +90 % pièces, +90 % XP, +7 % vitesse |
| Sirène des profondeurs / SirenRunner | 49 000 | 25 | 230 | 50 000 | 72 000 | Sireneau : +60 % pièces, +100 % XP, +27 % vitesse |
| Goliath de confinement / ContainmentGoliath | 78 000 | 6 | 320 | 68 000 | 88 000 | Bunkerours : +105 % pièces, +100 % XP, +6 % vitesse |

Le contrat rapide de cette zone a un multiplicateur x52. Le dossier paie 160 000/72 000, 240 000/108 000, puis 320 000/144 000 pièces/XP. Les primes de niveau 170 et 180 rapportent 200 000 et 225 000 pièces. Le [Fendoir des abysses](PROGRESSION_ARMES.md) se débloque au niveau 170 pour 3 300 000 pièces.

Les fragments de chaque espèce réutilisent le taux de 1/3 et la fusion de trois copies existante. Les trois nouveaux familiers réutilisent les formes Robot, Bat et Bear ; aucun mécanisme de progression ni achat Robux n'a été ajouté.

`studio/BuildDepthsExpansion.luau` est un constructeur ponctuel, jamais un script de démarrage. Le blocout a été construit dans Edit ; les fichiers locaux seuls ne reconstruisent pas ses objets. Le portail d'entrée se trouve dans l'alignement du refuge et le retour renvoie au Camp. Le backup des quatre configurations Studio est `ServerStorage.BeforeDepthsConfiguration`.

## Limites de vérification

Les contrôles des modules, récompenses, contrats et conservation des reçus ont été faits en Edit à partir de clones temporaires des configurations. En Play SessionStudio, 45 assertions communes aux zones 180/200 ont vérifié deux ennemis vivants par espèce, leurs rigs/santés, les sept surfaces d'arrivée/spawn, et les seuils 179/180/199/200. Le niveau du joueur a été restauré et Play arrêté. Aucun combat, achat, paiement par kill, fusion, déplacement autour des obstacles, audio, interface mobile ou DataStore de production n'a été testé. Le blockout reste à remplacer par des modèles finaux.
