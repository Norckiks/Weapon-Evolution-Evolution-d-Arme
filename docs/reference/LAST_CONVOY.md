# Terminus du dernier convoi

Seizième zone, déverrouillée au niveau 220, centrée en (9300, -120). Six apparitions couvrent trois espèces : Maréchal du convoi, Limier des cendres et Behemoth de siège. Ils réutilisent trois rigs de référence déjà présents (`CrucibleGuard`, `CinderRunner`, `ForgeTitan`) avec statistiques, teintes, fragments et familiers dédiés. Les modèles définitifs restent à fabriquer.

La scène est un blockout remplaçable : dalle de terminal, chaussée d'arrivée, hall d'embarquement effondré, voitures de convoi brisées, caisses de couverture, pylônes-balises, entrée depuis le refuge et retour au Camp. Le portail du refuge est placé à (288, 4.5, 252). Le constructeur ponctuel est `studio/BuildLastConvoyExpansion.luau` ; ne pas l'installer comme script de démarrage ni le rejouer sans inspection, car il refuse les doublons.

La Lame du dernier convoi est ajoutée au catalogue au niveau 210 : 6 000 000 pièces, 1 120 dégâts, portée 15 et délai 1,04 s. Son modèle Blender est intégré dans `ReplicatedStorage.WeaponModels` parmi les 16 FBX visibles en Play ; voir [la vérification de l'arsenal](PROGRESSION_ARMES.md).

Le contrat express de la zone est x56. Son dossier permanent offre trois étapes de 220 000 / 100 000, 330 000 / 150 000, puis 440 000 pièces / XP. Deux primes de niveau s'ajoutent : 310 000 pièces au niveau 210 et 340 000 au niveau 220. MonetizationEnabled reste à false et les IDs de produits à zéro.

## Vérification de ce lot

La scène a été construite en Edit dans l'instance Studio `Évolution des armes` (placeId 89391796839094) : 56 descendants déclarés pour la zone et son portail, trois gabarits créés par ZombieFactory, avec porte de retour et destination `LastConvoy`. Les quatre modules Studio disposent d'une sauvegarde antérieure `ServerStorage.BeforeLastConvoyConfiguration`.

Les copies isolées des modules confirment 16 zones, 48 espèces uniques, six apparitions dans chaque limite, un zombie/familier/gabarit correspondant par espèce, 36 primes et le rang suivant `ConvoyEdge`. Calcul des dossiers : 4 338 315 pièces et 1 973 025 XP au total ; contrat de première sortie x56 : 2 240 pièces / 1 120 XP.

En Play SessionStudio, le verrou refuse le niveau 219 et accepte 220 ; le directeur fait apparaître six zombies du Terminus, deux de chaque espèce, avec rig Humanoid, et les six points touchent le sol. Portails et destinations sont contrôlés par attribut, pas par interaction utilisateur. Niveau, position et attributs de session du joueur ont été restaurés puis Play arrêté. Pas de capture visuelle, d'essai d'achat/de combat/de récompense, de tactile, de multijoueur ni de DataStore ; aucune sauvegarde `.rbxl` ni publication n'a été faite.
