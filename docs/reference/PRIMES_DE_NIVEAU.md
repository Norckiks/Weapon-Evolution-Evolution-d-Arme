# Primes de niveau

Depuis l'ajout de la Voûte de l’Éclipse, le catalogue comporte 42 primes, des niveaux 2 à 280 ; les paliers 270 et 280 ajoutent respectivement 520 000 et 560 000 pièces. Les reçus serveur existants restent utilisés. Voir [ECLIPSE_VAULT.md](ECLIPSE_VAULT.md).

Dans CADEAUX & PALIERS (raccourci G), une carte présente le premier palier non récupéré. Atteindre le niveau requis permet de récupérer des pièces, puis la carte passe au suivant ; elle disparaît après les 42 primes. Le compteur Cadeaux inclut ces primes disponibles, en plus des cadeaux de temps. Aucun XP n'est accordé par ces primes : elles n'entraînent pas une boucle de niveaux gratuits.

| Niveau | Pièces |
| --- | --- |
| 2 | 150 |
| 3 | 250 |
| 5 | 500 |
| 7 | 750 |
| 10 | 1 200 |
| 12 | 1 600 |
| 16 | 2 400 |
| 20 | 3 500 |
| 22 | 4 000 |
| 28 | 6 000 |
| 35 | 9 000 |
| 40 | 11 000 |
| 45 | 12 500 |
| 48 | 14 000 |
| 50 | 15 500 |
| 55 | 18 000 |
| 60 | 22 000 |
| 64 | 25 000 |
| 65 | 27 000 |
| 70 | 32 000 |
| 72 | 35 000 |
| 80 | 45 000 |
| 90 | 55 000 |
| 100 | 70 000 |
| 110 | 85 000 |
| 120 | 100 000 |
| 130 | 120 000 |
| 140 | 140 000 |
| 150 | 160 000 |
| 160 | 180 000 |
| 170 | 200 000 |
| 180 | 225 000 |
| 190 | 250 000 |
| 200 | 280 000 |
| 210 | 310 000 |
| 220 | 340 000 |
| 230 | 370 000 |
| 240 | 400 000 |
| 250 | 440 000 |
| 260 | 480 000 |
| 270 | 520 000 |
| 280 | 560 000 |

Les anciens joueurs peuvent récupérer les paliers déjà atteints. Une prime est unique par profil, sans remise à zéro quotidienne ; ce sont des récompenses fixes, non multipliées par les pets ou bonus temporaires. Le plafond de pièces de deux milliards est conservé : ClaimLevel refuse désormais avant tout reçu si la prime entière ne tient pas dans le solde disponible. Elle reste à récupérer après une dépense. Une place exactement suffisante est acceptée. L'UI affiche DEPENSE D'ABORD et exclut cette prime du nombre de primes de niveau prêtes. Cette garde concerne uniquement les primes de niveau ; le comportement des autres sources de récompenses n'a pas été modifié.

## Sources et autorité

- GameplayConfig : LevelRewardOrder et LevelRewards. Garder les niveaux stables : ils servent d'identifiants permanents, pas les positions dans la liste.
- EconomyService : initialise Meta.LevelRewards sans remplacer le reste du profil, inclut la table dans GameState, traite ClaimLevel. Le serveur choisit le montant, vérifie la partie démarrée, le niveau réel et le reçu, puis ajoute les pièces via ProgressionService. Le reçu canonique est posé avant l'attribution sans yield et retiré si AddRewards refuse.
- GameHub : carte et image de pièce, progression de niveau (pas un pourcentage d'XP), état verrouillé/prêt, compteur et signature de rafraîchissement incluant les reçus.

Meta.LevelRewards contient des clés de niveau en chaîne (`"2"`, `"22"`), valeur true. Le payload Meta existant les sérialise avec les autres données ; les reçus Robux et les anciens cadeaux ne sont pas réinitialisés. Les identifiants numériques alternatifs sont canonicalisés avant la vérification de doublon. Les requêtes ne déterminent jamais le montant attribué.

## Preuves du 27 octobre 2026

Lot niveau 28/plafond : 34 contrôles serveur réussis via les vrais remotes (les cas précédents, la dixième prime et trois frontières : solde plein, place insuffisante d'une pièce, place exactement suffisante). Deux assertions d'état client : bouton désactivé/DEPENSE D'ABORD à deux milliards, réactivation/RECUPERER à deux milliards moins 150. **Ce ne sont pas des preuves visuelles** : la sonde compte 43 Heartbeat et zéro RenderStepped ; aucune capture ni nouvelle géométrie mobile n'a été validée. Rapport `studio/qa/level-rewards-capacity-result.json`, backup de trois sources `ServerStorage.BeforeLevelRewardCapacity`. Restauration des données et Stop confirmés. Aucun test DataStore de reconnexion.

Lot initial, avant ajout du niveau 28 :

Trente contrôles serveur passent : demandes via vrais RemoteEvents, niveau requis, partie non démarrée, montants exacts, XP inchangé, doublons/canonicalisation, entrées invalides, tous les paliers, rafale répétée, conservation JSON des reçus et absence de remise à zéro quotidienne. Les données utilisées sont SessionStudio, restaurées après les tests. Aucun test de reconnexion ou d'écriture DataStore de production.

Six snapshots UI (PC 1447×824, portrait 401×778 et paysage 750×381 avant/après finition du titre et footer) vérifient textes, actions contenues, images et cibles tactiles >=44 px. Deux clics natifs PC : 500→650 au niveau 2 puis prochain niveau 3 verrouillé ; 500→4500 au dernier palier, puis disparition de la carte avec tous les reçus présents dans la fixture. Captures inspectées PC/portrait, pas de fichiers locaux. Console finale vide. Pas de tactile physique, multijoueur, écoute audio ou mesure de l'équilibre par joueurs.

QA : créer LevelRewardsQABridge (RemoteFunction) uniquement en Play, installer LevelRewardsBridge.client.luau puis LevelRewards.server.luau comme scripts temporaires ordinaires. Lire ServerStorage.LevelRewardsQAResult. Les bindables PrepareLevelRewardUI (niveau 1 ou n'importe quel niveau de prime), ReadLevelRewardQA et RestoreLevelRewardQA permettent de préparer et restaurer les essais UI. Le harnais utilise le dernier niveau du catalogue pour récupérer tous les paliers. Appeler la restauration après les essais, rétablir default/LandscapeLeft et arrêter Play. Ne jamais installer ces fichiers en Edit.

Rapport : studio/qa/level-rewards-result.json. Backup Edit : ServerStorage.BeforeLevelRewards, trois sources ; aucun nouveau script actif.
