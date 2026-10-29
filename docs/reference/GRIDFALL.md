# Grille déchue

Dix-septième zone, déverrouillée au niveau 240, centrée en (9920, -120). Six apparitions accueillent trois espèces : Gardien du réseau, Limier électrique et Titan disjoncteur. Chaque espèce possède ses statistiques, sa chance de fragment, son familier et son gabarit ; ces rigs réutilisent les silhouettes du Terminus. Les modèles finaux restent à créer.

Blockout remplaçable de sous-station : dalle d'asphalte, transformateurs ruinés, isolateurs, poteaux électriques penchés, armoires de disjoncteurs tombées, chaussée d'arrivée et balises de danger. Le portail du refuge est à (320, 4.5, 252), le retour renvoie au Camp. `studio/BuildGridfallExpansion.luau` est un constructeur ponctuel, jamais un script de démarrage ; il refuse toute construction doublon.

La Pique de la grille est ajoutée à l'armurerie au niveau 230 : 8 200 000 pièces, 1 300 dégâts, portée 16, délai 0,98 s. Son modèle Blender est intégré dans `ReplicatedStorage.WeaponModels` parmi les 16 FBX visibles en Play ; voir [la vérification de l'arsenal](PROGRESSION_ARMES.md).

Contrat express x58. Le dossier comporte trois étapes à 280 000 / 130 000, 420 000 / 195 000, puis 560 000 pièces / XP. Primes de niveau : 370 000 pièces au niveau 230 et 400 000 au niveau 240. MonetizationEnabled reste false, identifiants des produits à zéro.

## Vérification

En Studio/Edit, les modules clonés ont passé les assertions : 17 zones, 51 espèces uniques avec définitions zombies/pets/gabarits, six apparitions par zone et dans leurs limites, total des dossiers 5 598 315 pièces / 2 558 025 XP, 38 primes, Pique comme prochain palier après la Lame du dernier convoi, contrat x58 et achats Robux désactivés. Le blockout et les deux portails ont été construits ; 61 descendants dans la zone, 73 avec le portail.

En Play SessionStudio : accès refusé au niveau 239 et accepté au niveau 240 ; six zombies apparaissent, deux de chaque espèce, rigs Humanoid valides et rayons sol positifs aux six positions. Niveau, position et attributs du joueur ont été restaurés ; Stop confirmé. Pas d'interaction réelle aux portails, combat, achat/réclamation, capture visuelle, appareils mobiles, multijoueur ou test DataStore. Aucune sauvegarde `.rbxl` ni publication.
