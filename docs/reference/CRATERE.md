# Cratère du réacteur

Le Cratère prolonge la progression après la Citadelle : accès niveau 100, arrivée en (5580, 4, 10), six emplacements de zombies et trois espèces. Les lignes de vue, le crédit de mort, les pièces, l'XP, les élites, fragments et dossiers réutilisent les systèmes existants.

| Espèce | PV | Vitesse | Dégâts | Pièces | XP | Familier de fusion |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Carcasse des braises | 12 500 | 9 | 105 | 11 500 | 15 000 | Braiselet |
| Spectre de cendre | 10 000 | 20 | 92 | 10 500 | 15 500 | Fumelin |
| Behemoth du coeur | 17 000 | 7 | 140 | 18 000 | 22 000 | Coeur-de-pierre |

Les trois espèces réutilisent respectivement les rigs Soldier, Runner et RailTitan. Une chance sur trois de fragment et la fusion de trois copies en familier sont celles du système partagé. Le contrat rapide monte à un multiplicateur de zone x32. L'expédition du Cratère propose trois étapes comme les zones précédentes.

La Lame du coeur (niveau 90, 760 000 pièces) prolonge aussi les paliers d'armes. Ses paramètres sont 420 dégâts, 9,5 studs et 0,98 s. Son modèle Blender est intégré dans `ReplicatedStorage.WeaponModels` parmi les 16 FBX visibles en Play ; voir [la vérification de l'arsenal](PROGRESSION_ARMES.md).

Le secteur de remplacement est un gris géométrique simple destiné à être remplacé par les modèles de l'auteur. Le constructeur ponctuel est `studio/BuildCraterExpansion.luau` : l'exécuter une seule fois en Edit après avoir arrêté Play. Il ajoute le secteur et clone les portails existants pour préserver leur logique de voyage ; il ne remplace aucun script actif.

La configuration locale est raccordée. La présence des modèles, les imports, collisions, trajet, verrou de niveau, retour, combat, récompenses et rendu n'ont pas encore été vérifiés en Play ; aucune sauvegarde `.rbxl` ni publication n'est confirmée.
