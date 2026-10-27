# Mitrailleuse de barrage

Nouvel objectif d’armurerie après le Fusil du guetteur : LMG, niveau35,54 000pièces. 28 dégâts corps /42 tête, portée160studs, intervalle0,12s, chargeur48, recharge3,8s. Réserve illimitée comme les autres armes ; grand chargeur destiné aux groupes, sans dégâts de zone ni pénétration de mur. Pas de nouveau zoom. Prix, niveau, possession, cadence, munitions, dégâts et récompenses restent serveur ; achat direct depuis l’UI loin des stands. Possessions et reçus existants conservés, aucune nouvelle DataStore.

Modèle lourd distinct : boîtier, couvercle articulé, levier, canon ventilé, bipied décoratif, poignée avant et poignée de transport latérale. Quatre mécanismes (Magazine/MagazineBase/FeedCover/BoltHandle), pièces sans masse et sans collision. Boîtier descendant0,82stud pendant recharge ; couvercle tournant autour d’une charnière arrière à1,1rad, puis fermeture ; levier de0,16stud. Pose de soutien gauche, petit recul répété et recharge dédiés. ReducedMotion ramène les mécanismes au quart, avec couches corporelles Motor6D/AnimationConstraint existantes. La poignée de transport a été déportée de0,48stud pour laisser0,14stud de dégagement latéral au couvercle sur son axe de rotation.

Tir réutilisant l’asset métal avec timbre distinct ; quatre étapes de recharge programmées (ouverture/boîtier/fermeture/armement). SFXEnabled=false supprime les sons ; aucun enregistrement externe ajouté. Les instances de tir ont été constatées, sans écoute revendiquée. Les sons de recharge dépendent encore de RenderStepped et n’ont pas été observés dans cette session sans rendu.

## Preuves du27 octobre2026

Six sources comparées et synchronisées Edit : GameplayConfig, WeaponVisuals, WeaponMotion, FistsClient, CharacterCombat, FirearmsClient. Backup ServerStorage.BeforeLMG(6), manifeste46 scripts ; aucun nouveau script actif ni modification serveur de dégâts.

`studio/qa/lmg-result.json` :30 contrôles LMG,19 contrôles des moteurs portés et28 régressions Carbine passés. Tests LMG : handler ordinaire EconomyService pour les achats (niveau34/35, budget54000, refus doublon/équipement non possédé), vrais Shoot/ReloadGun par pont client pour28corps à140studs/42tête, spam limité à une balle, portée/mur/vecteurs invalides, huit requêtes successives (pas un chronométrage du débit maximal), recharge48 et annulation sans balle gratuite. Échantillons mathématiques finis et charnière fermée en fin de cycle ; progression Carbine→Marksman→LMG, premium ignoré.

Modèle porté réellement mesuré via Heartbeat après tirs/recharges acceptés : levier0,15993stud normal /0,03892 réduit, boîtier0,81998, couvercle1,09997rad, retour au repos ; une instance GunShot par tir, aucune en muet. Caméra rapprochée temporairement par le harnais puis restaurée. Cela prouve les Transform appliqués en PreSimulation, sans preuve de pose FPS ou capture. La correction de poignée a suivi ces essais ; le modèle construit hors scène à partir des sources courantes confirme le dégagement X de0,14stud, pas une absence universelle de tout croisement entre pièces.

Catalogue : niveau34 verrouillé NIVEAU35, niveau35/60000 prêt ; BuyWeapon/LMG envoyé par le vrai remote client, lecture du service ordinaire confirme6000pièces/possession/équipementLMG, puis DERNIER PALIER ATTEINT. Pas de clic natif. Fixture LMGCatalog.server avec Prepare/Read/RestoreLMGCatalog. Meta/statistiques/flags/position/ancrage et options/caméra des harnais restaurés, puis Stop ; chargeurs privés de test retirés avec Stop. Console contrôlée vide.

Carbine.server et Marksman.server ont été mis à jour pour le nouveau dernier palier. Seule la régression Carbine a été réexécutée dans ce lot ; les anciennes preuves Marksman restent historiques. QA LMG.server, LMGMotion.server/client et LMGCatalog.server temporaires uniquement Play SessionStudio, jamais Edit/public.

Reste à vérifier : rendu du modèle et poses FPS/corps, cadrage UI PC/mobile, maintien natif du tir, écoute/recharge sonore, R6, multijoueur et équilibrage par joueurs. Viewport1×1/RenderStepped0 persiste ; aucune capture relancée après le blocage du lot Métro. Pas de reconnexion DataStore, publication ou sauvegarde.rbxl.
