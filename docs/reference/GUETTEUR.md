# Fusil du guetteur — 27 octobre 2026

Le palier suivant est désormais la [Mitrailleuse de barrage](MITRAILLEUSE.md), niveau35. Les preuves ci-dessous décrivent le lot historique où Marksman terminait l’arsenal.

Nouveau palier normal après la Carabine : Marksman, niveau 28, 32 000 pièces. Six cartouches, 140 dégâts corps / 210 tête, portée 260 studs, intervalle 1,05 s, recharge 3,1 s. Les contrôles de prix, possession, niveau, cadence, chargeur et dégâts restent serveur. Pas de nouveau champ de progression ni de reçu ; les possessions existantes sont préservées. Achat direct depuis l’armurerie, loin des stands, comme les autres armes.

Modèle distinct construit avec les primitives existantes : long canon, frein de bouche, crosse/appui-joue, dioptre, bipied décoratif, chargeur et levier de verrou. Le dioptre ne donne pas de zoom. Quatre mécanismes Magazine/MagazineBase/BoltHandle/BoltStem ; pièces sans masse, ancrage ou collision. Culasse retardée après le tir, extraction/insertion du chargeur et fermeture de verrou pendant la recharge ; soutien gauche et recul dédiés. Les couches corporelles existantes prennent en charge Motor6D et AnimationConstraint. ReducedMotion réduit le mouvement à un quart.

Sons existants réutilisés avec timbres distincts : tir grave et claquement de verrou différé, trois étapes de recharge programmées. Aucune nouvelle bande audio importée. Gardes présence/vie/arme pour le son différé. Les instances de sons de tir/verrou ont été observées ; pas d’écoute physique ni de preuve des trois clics de recharge dans cette session sans RenderStepped.

## Preuves

- `studio/qa/marksman-recovered-result.json` : 28 contrôles serveur retrouvés à la reprise, tous réussis, données restaurées. Seuil27/28, budget, doublon, six balles, corps140 à240studs/tête210, spam, mur, portée270, vecteurs invalides, blocage recharge, annulation sans balles gratuites, mécanismes et règles pures finies. Ce rapport retrouvé ne constitue pas une nouvelle exécution de ces28 tests pendant le lot de reprise.
- `studio/qa/carbine-marksman-regression-result.json` : 28 régressions réexécutées avec vrais messages Shoot/ReloadGun depuis le pont client. Ancienne carabine inchangée et progression Carbine→Marksman→dernier palier.
- `studio/qa/marksman-motion-result.json` : 18 contrôles exécutés sur les Motor6D du modèle porté, après vrais tirs/recharge acceptés. Culasse normale0,33990stud/réduite0,08498stud, chargeur0,73996stud, culasse pendant recharge0,33999stud ; retour au repos, trois balles consommées puis recharge6. Un GunShot et un MarksmanBolt par tir observé ; aucun son en muet. Caméra temporairement rapprochée par le harnais puis restaurée. Échantillonnage Heartbeat des Transform écrits par CharacterCombat.PreSimulation, sans preuve de rendu FPS.
- Propriétés UI : carte verrouillée NIVEAU28 au niveau27, active à28/40000pièces, dernier palier reconnu après BuyWeapon envoyé par le vrai remote client. Pas de clic natif. Lecture séparée du solde postachat non confirmée : require depuis execute_luau a un cache distinct, puis l’observateur ordinaire a rencontré une erreur de transport. Le prix exact reste couvert par le premier rapport serveur, pas par cet essai UI.

Deux premières tentatives du harnais de mouvement échouées sur critères de mesure : nombre d’échantillons minimum20 malgré un maximum de culasse observé, puis pic de recharge manqué entre des frames (0,295 observé). Les critères actuels exigent plusieurs échantillons, mouvement de verrou >0,25 et retour au repos ; la dernière exécution retrouve aussi le pic complet0,340. Aucun changement produit pour contourner ces observations.

## Reprise et limites

Six sources runtime déjà installées avant reprise : GameplayConfig, WeaponVisuals, WeaponMotion, FistsClient, CharacterCombat, FirearmsClient ; backup ServerStorage.BeforeMarksman. Aucun nouveau script actif. Harnais QA uniquement Play SessionStudio, jamais Edit/public. Meta/position/ancrage/flags de fixtures et caméra/options client restaurés, puis Stop. Pas de publication ni de sauvegarde .rbxl.

Rendu Play indisponible (viewport1×1, RenderStepped0 ; PreSimulation/PreAnimation/Heartbeat actifs). Reste à inspecter : modèle et poses FPS à l’écran, cadrage PC/mobile, écoute/recharge sonore, mort pendant délai du son de verrou, R6, multijoueur, équilibrage et reconnexion DataStore. Les anciennes captures d’autres armes ne prouvent pas ces points.
