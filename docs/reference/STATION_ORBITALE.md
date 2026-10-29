# Station orbitale

Treizième zone, accessible à partir du niveau 160 après la Cité des antennes. Elle réutilise les services génériques de voyage, apparition, combat, récompenses, fragments, familiers, contrats et dossiers. Les contrôles d'accès, prix et récompenses restent côté serveur.

| Zombie | PV | Vitesse | Dégâts | Pièces | XP | Familier de fusion |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Mécano du vide | 41 000 | 10 | 190 | 31 000 | 44 000 | Vaculet |
| Coureur stellaire | 34 000 | 24 | 170 | 28 000 | 42 000 | Cometou |
| Titan de capsule | 52 000 | 6 | 255 | 48 000 | 62 000 | Capsulours |

Six apparitions utilisent les rigs de la zone précédente avec les attributs et couleurs de `WorldConfig`. Les fragments et la fusion restent compatibles. Le dossier permanent verse 120 000/55 000, 180 000/82 500 et 240 000/110 000 pièces/XP. Le contrat express monte à x50.

La Lance orbitale est proposée au niveau 150 pour 2 400 000 pièces, 740 dégâts, portée 13 studs et délai de 1,02 s. Son modèle Blender est intégré dans `ReplicatedStorage.WeaponModels` parmi les 16 FBX visibles en Play ; voir [la vérification de l'arsenal](PROGRESSION_ARMES.md).

Le constructeur ponctuel `studio/BuildOrbitalWreckExpansion.luau` crée un blockout géométrique temporaire, le portail refuge à (192, 4,5, 252), le retour à (7442, 4,5, -100) et les trois templates à partir de rigs existants. Il n'est pas un script de démarrage et refuse les doublons.

En Studio/Edit, des clones temporaires des modules ont passé des assertions sur les 13 zones, les six apparitions dans les limites, les trois templates/familiers, le prochain palier d'arme, les primes 150/160, le contrat x50 et les trois récompenses d'expédition. Le blockout et les deux portails sont présents dans la scène. Aucun test Play, combat, achat, accès au niveau 159/160, vue mobile ou collision en déplacement n'a encore été effectué ; aucun fichier `.rbxl` sauvegardé ni expérience publiée.
