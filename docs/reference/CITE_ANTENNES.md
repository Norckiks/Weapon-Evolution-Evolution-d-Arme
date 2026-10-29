# Cité des antennes

Douzième zone, débloquée au niveau 140 après la Mer de verre. La progression, le portail, les apparitions, les contrats, les primes et les dossiers réutilisent les services existants ; prix, niveau d'accès, dégâts et récompenses restent contrôlés côté serveur.

| Zombie | PV | Vitesse | Dégâts | Pièces | XP | Familier de fusion |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Gardien du relais | 28 000 | 9 | 155 | 26 000 | 36 000 | Relayin |
| Sprinteur statique | 23 000 | 22 | 136 | 23 500 | 35 000 | Voltibat |
| Goliath des tours | 36 000 | 6 | 220 | 40 000 | 52 000 | Toursaurus |

Six points d'apparition utilisent les rigs Sentry, Glitch et Colossus déjà présents, avec les variantes de statistiques et de couleur définies dans `WorldConfig`. Les fragments et la fusion suivent le système partagé. Les dossiers rapportent 90 000/43 000, 135 000/64 500 et 180 000/86 000 pièces/XP ; le contrat express atteint x44.

La Lance du relais est proposée au niveau 130 pour 1 650 000 pièces, 625 dégâts, portée 11 studs et cadence de 0,86 s. Son modèle Blender est intégré dans `ReplicatedStorage.WeaponModels` parmi les 16 FBX visibles en Play ; voir [la vérification de l'arsenal](PROGRESSION_ARMES.md).

Le constructeur ponctuel `studio/BuildSkylineExpansion.luau` crée un blockout géométrique simple, l'entrée au refuge (160, 4,5, 252), le retour (6822, 4,5, -100) et les gabarits à partir des rigs existants. Il n'est pas un script de démarrage et refuse de dupliquer la zone, le portail ou les templates.

En Studio/Edit, les configurations clonées et requises ont passé des assertions de présence, limites des six apparitions, templates/familiers, prochain palier, primes 130/140, contrat x44 et trois paiements d'expédition. Le blockout et les deux portails existent dans la scène. Aucune partie Play, capture visuelle, collision en mouvement, achat réel, contrôle du verrou niveau 139/140 ou test mobile n'a encore été effectué ; aucun `.rbxl` sauvegardé ni publication confirmée.
