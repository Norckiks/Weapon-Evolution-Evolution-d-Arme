# Noyau d'arrêt

Dix-huitième zone, déverrouillée au niveau 260, centrée en (10540, -120). Six apparitions accueillent le Gardien du noyau, l'Éventreur d'arc et le Titan du noyau. Ils ont leurs propres statistiques, fragments et familiers, mais leurs silhouettes techniques réutilisent les rigs du secteur précédent. Les modèles finaux restent à fabriquer.

Blockout de site de confinement : dalle de béton, pylônes de retenue, anneaux de confinement, générateur central éteint, armoires électriques et caniveaux de câbles. Le portail du refuge se trouve à (352, 4.5, 252), le retour de zone renvoie au Camp. Le constructeur ponctuel `studio/BuildBlackoutCoreExpansion.luau` refuse les doublons et ne doit pas être installé au démarrage.

La Trancheuse du blackout est achetable depuis l'armurerie au niveau 250 : 11 000 000 pièces, 1 550 dégâts, portée 17, délai 1,12 s. Son modèle Blender est intégré dans `ReplicatedStorage.WeaponModels` parmi les 16 FBX visibles en Play ; voir [la vérification de l'arsenal](PROGRESSION_ARMES.md).

Contrat express x60. Le dossier propose trois étapes à 350 000 / 170 000, 525 000 / 255 000, puis 700 000 pièces / XP. Les primes des niveaux 250 et 260 donnent respectivement 440 000 et 480 000 pièces. La monétisation Robux reste désactivée et les identifiants produits à zéro.

## Vérification

Les clones isolés des quatre modules confirment 18 zones, 54 espèces/gabarits/pets, six apparitions incluses dans les limites de chaque zone, un total des dossiers de 7 173 315 pièces / 3 323 025 XP, 40 primes et l'arme proposée après ArcPike. Le contrat x60 donne 2 400 pièces / 1 200 XP sur sa première étape.

Play SessionStudio : accès refusé au niveau 259, accepté au niveau 260 ; six zombies actifs, deux de chaque espèce, rigs Humanoid valides et rayons au sol vérifiés aux six apparitions. Niveau, position et attributs du joueur restaurés, puis Play arrêté. Console vide après l'essai. Pas de capture visuelle, interaction réelle des portails, combat, achat, réclamation, tactile, multijoueur ou test DataStore. Pas de sauvegarde `.rbxl` ni publication.
