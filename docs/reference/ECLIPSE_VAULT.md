# Voûte de l'Éclipse

La dix-neuvième zone s'ouvre au niveau 280. Elle est centrée en `(11160, 0, -120)` et possède six points d'apparition, un portail d'entrée au refuge en `(384, 4.5, 252)` et un portail de retour vers le Camp. Le décor est une base géométrique provisoire.

Les trois espèces sont le Gardien de la voûte (`EclipseWarden`), le Traqueur nocturne (`NightStalker`) et le Goliath du caveau (`VaultGoliath`). Chacune a son fragment et son pet ; leurs gabarits réutilisent ceux de la zone précédente. Le Glaive de l'éclipse s'achète depuis l'interface au niveau 270 pour 15 000 000 pièces : 1 850 dégâts, portée 17,5 et délai 1,06 s. Son modèle reste en attente d'intégration.

Les contrats valent jusqu'à x62 dans cette zone. Les trois étapes du dossier ont pour bases 430 000 pièces et 210 000 XP, avec multiplicateurs 1, 1,5 et 2. Les primes uniques des niveaux 270 et 280 valent respectivement 520 000 et 560 000 pièces.

Dans Studio, les quatre modules de configuration ont une copie antérieure dans `ServerStorage.BeforeEclipseVaultConfiguration`. Le constructeur ponctuel est `studio/BuildEclipseVaultExpansion.luau` et ne doit pas devenir un script de démarrage.

Les assertions sur modules clonés ont vérifié 19 zones, 57 espèces, 42 primes, les récompenses et la progression d'armes, ainsi que la désactivation Robux. En Play de test, le niveau 279 a été refusé et le niveau 280 accepté ; six zombies, deux de chaque espèce, et six points avec sol ont été observés. Le joueur a été restauré puis Play arrêté. Aucune interaction réelle des portails, achat, combat, réclamation, validation mobile, multijoueur ou DataStore n'a été testée. Pas de sauvegarde `.rbxl` ni de publication.
