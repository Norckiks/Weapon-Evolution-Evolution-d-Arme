# Mer de verre

La Mer de verre prolonge la Citadelle, le Cratère et la progression d'armes sans ajouter de modèle final : accès niveau 120, arrivée en (6200, 4, 10), six emplacements et trois espèces. ZoneService, ZombieDirector, fragments, familiers, contrats et dossiers d'expédition s'appuient sur les systèmes partagés.

| Espèce | PV | Vitesse | Dégâts | Pièces | XP | Familier de fusion |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Gardien prismatique | 19 000 | 10 | 118 | 19 500 | 27 000 | Prismignon |
| Éclat fulgurant | 15 000 | 22 | 105 | 18 000 | 27 000 | Eclatin |
| Titan de silice | 24 000 | 6 | 178 | 28 000 | 36 000 | Silicorne |

Chaque élimination suit la chance existante d'un fragment sur trois ; trois fragments de la même espèce se fusionnent en familier. L'expédition dédiée récompense les trois étapes existantes en pièces et XP. Le contrat express monte jusqu'au multiplicateur x38 dans cette zone.

La Hache de verre est le palier d'arme suivant après la Lame du coeur : niveau 110, 1 100 000 pièces, 490 dégâts, portée 9,5 studs, délai 0,88 s. Le niveau et le solde sont contrôlés par le serveur à l'achat. Son modèle Blender est intégré dans `ReplicatedStorage.WeaponModels` parmi les 16 FBX visibles en Play ; voir [la vérification de l'arsenal](PROGRESSION_ARMES.md).

Le constructeur ponctuel `studio/BuildGlassSeaExpansion.luau` ajoute en Edit un blockout géométrique simple, l'entrée à (128, 4,5, 252), le retour vers le refuge à (6202, 4,5, -100) et les trois gabarits dérivés des rigs Soldier, Runner et RailTitan. Il ne remplace aucun script de démarrage et s'arrête si la zone, le portail ou les gabarits existent déjà.

Le contrôle de cohérence dans Studio/Edit confirme les six apparitions dans les limites de zone, les trois gabarits et familiers, le palier d'arme, les primes de niveau 110/120, le dossier `GlassSea:1` et les deux destinations de prompt. Aucun test Play de combat, d'achat, de verrou de niveau, de récompense ou de collision n'a été fait ; la scène n'a pas été enregistrée dans un `.rbxl` et l'expérience n'a pas été publiée. Les rendus de nuit, les collisions du blocout et l'équilibrage restent à vérifier.
