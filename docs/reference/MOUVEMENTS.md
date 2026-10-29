# Déplacements — travail en cours

Le contrôleur SprintServer gère désormais l'accélération et partage son endurance avec AdvancedMovement et le dash existant. Aucune publication.

## Commandes

- Maj / L3 : sprint.
- C / R1 : bascule accroupi ; en course au sol à au moins 18 studs/s, déclenche une glissade si disponible.
- V / Y : franchissement d'un obstacle bas devant soi.
- Ctrl / B manette : dash existant.
- O / Select manette, bouton de vue ou Options : première/troisième personne. Voir [le lot de jouabilité et ses preuves](IDEES_IMPLEMENTEES.md).
- En troisième personne, le pointeur reste centré et masqué ; clic droit/glisser tourne la caméra. M libère le pointeur pour l'interface, puis M le reverrouille.
- Boutons tactiles GLISSE et FRANCHIR ajoutés au groupe existant.

## Règles actuelles

Contrôle caméra du 26 octobre, en troisième personne sur téléphone simulé paysage : distance tête/caméra 8,2855 studs sans obstacle, 3,0185 avec un mur temporaire placé derrière le joueur, puis 8,3131 après retrait. Cela vérifie un cas d'occlusion du contrôleur natif, pas toutes les collisions de la carte ; la rotation au clic droit n'était alors pas testée.

Le 27 octobre, une session Play PC a vérifié le verrouillage du pointeur en troisième personne, son déverrouillage/reverrouillage par M et le retour au verrouillage après fermeture des options et de l'atelier. Un glisser clic droit simulé a changé l'orientation de la caméra ; aucune souris physique n'a été testée.

- Accroupi : vitesse cible 8, hauteur et caméra abaissées. Cela ne garantit pas le passage sous toutes les ouvertures : les collisions du corps Roblox restent actives.
- Marche : 18 ; sprint : 32 studs/s avant améliorations et pets. Accélération 14, freinage 18. Endurance et délais conservés.
- Glissade : coût 15, durée 0,7 s, délai 1,5 s, vitesse horizontale décroissante 40 → 18. Arrêt au contact d'un obstacle ; contraintes nettoyées à la fin, à la mort ou lors d'un menu.
- Franchissement : coût 12, délai 1 s. Obstacle ancré entre 0,6 et 3,2 studs de haut ; contrôle du dégagement et d'une surface de réception. Impulsion verticale et assistance horizontale temporaire, sans téléportation.
- Dash refusé pendant glissade/franchissement ou accroupissement. Actions refusées avant Jouer, dans un menu, à terre ou assis.
- Configuration : studio/MovementConfig.luau.

## Vérification du 22 octobre 2026

Accroupissement via le vrai RemoteEvent : état actif, vitesse observée 8,04 puis 15,55 après retour debout. Harnais Studio isolé studio/qa/Movement.server.luau : 10 contrôles réussis (glissade, déplacement physique, consommation, nettoyage, franchissement bas, impulsion, absence d'obstacle, mur haut, endurance insuffisante, menu). Console vide lors du contrôle final. Les objets temporaires sont retirés à la fin du harnais puis par arrêt de Play.

Le harnais a ensuite été étendu : passage réel au-delà de l'obstacle et atterrissage contrôlés, soit 12 contrôles réussis. Les poses des hanches, genoux, taille et épaules sont maintenant ajoutées par CharacterCombat pour accroupissement, glissade et franchissement, avec transitions. Sons de tissu et réception réutilisés depuis les assets existants ; déclenchement vérifié et console vide. Ces tests ne remplacent pas les essais de fluidité avec entrée clavier soutenue, les collisions sur toute la carte, le multijoueur ni les commandes tactiles/manette. Le système complet inspiré d'Evade reste donc en cours.

Sauvegarde des scripts précédents : ServerStorage.BeforeAdvancedMovement.

## Réglage actuel après l'extension du port

L'assistance de franchissement dure maintenant 0,38 s (au lieu de 0,3). La distance de dégagement et de réception contrôlée serveur est dérivée de VaultForwardSpeed × VaultDuration + 0,5, pour couvrir cette assistance. Un essai sans entrée de marche maintenue avait révélé un arrêt sur les sacs de sable de la ville ; cette correction permet de passer entièrement cet obstacle. Le coût reste 12.

Huit obstacles contrôlés via FireServer client : sacs de sable, quatre obstacles Usine/Labo, trois caisses du port ; tous déclenchés, franchis, avec atterrissage et coût vérifiés. Douze régressions Movement réussies. Parcours clavier réel sprint/glissade/dash au port : déplacement ~72,84 studs, pointe ~65,08, aucun dash pendant la glissade. Les premiers essais perturbés et le résultat final sont distingués dans studio/qa/harbor-result.json. Le sampler TerrainLocomotion utilise désormais le niveau requis de sa zone ; TerrainVaults ajoute les obstacles du port si cette scène existe.

## Parcours sur la carte — 22 octobre, passe suivante

Quatre obstacles permanents ajoutés dans workspace.TraversalCover : FactoryCrate, FactoryPipeRack, LabConsole et LabBarrier. Chaque modèle ne comporte qu'un noyau de collision ; ses détails décoratifs ne gênent pas les raycasts. BuildTraversalCover.luau est un constructeur ponctuel Edit, jamais un script de démarrage.

Le franchissement pouvait perdre son impulsion verticale sur un personnage possédé par le client. AdvancedMovement confirme désormais un franchissement validé via MovementAction ; MovementClient applique l'impulsion au personnage encore au sol, après réception de cette confirmation. Les contrôles de géométrie, délai et endurance restent serveur. Backup BeforeOwnedVaultLaunch.

TerrainVaults, via un véritable FireServer client : cinq obstacles franchis puis atterrissage confirmé, dont les sacs de sable de la ville et les quatre nouveaux modèles. Élévation mesurée environ 3,3–3,4 studs ; avant correction, les sacs de sable et la console échouaient. Les 12 contrôles Movement ont aussi été rejoués avec succès.

Entrées clavier réelles Maj/W/C/Ctrl : sprint, glissade puis dash observés sur les avenues de Ville, Usine et Labo ; aucun dash pendant la glissade. Résultats terrain-vault-result.json, movement-owner-fix-regression.json et terrain-locomotion-result.json dans studio/qa. Cela ne couvre pas tous les reliefs, une forte latence, le multijoueur ou des commandes tactiles physiques.
