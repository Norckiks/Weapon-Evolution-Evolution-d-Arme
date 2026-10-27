# Première chasse du jour

La première carte de MISSIONS propose un objectif court : éliminer un zombie dans la journée, puis récupérer 100 pièces et 50 XP. Les gains habituels du zombie ne changent pas. La prime est fixe, sans multiplicateur de pet ou boost, récupérable une fois par jour UTC à partir du compteur quotidien existant. Elle nécessite une action de récupération dans l'UI : aucune attribution automatique supplémentaire lors du décès.

Après la première élimination du jour, le message de progression signale la prime disponible dans MISSIONS. Si un ancien profil a déjà des éliminations aujourd'hui et ne possède pas le nouveau reçu, il peut également réclamer la prime ; les anciens kills antérieurs au compteur quotidien ne sont pas reconstruits.

## Autorité et sauvegarde

- GameplayConfig.FirstHunt contient 100 pièces / 50 XP.
- EconomyService normalise Daily.FirstHuntClaimed en booléen sans changer les autres champs. Le nouvel identifiant de réclamation est ClaimDailyHunt / FirstHunt.
- Le serveur exige ProgressReady, partie démarrée, identifiant exact, Daily.Kills >=1, reçu non réclamé et place suffisante pour 100 pièces sous le plafond de deux milliards. Le client ne fournit ni nombre d'éliminations ni montant.
- Le reçu est posé avant AddRewards, sans yield ; il est retiré si l'attribution refuse. Le circuit existant sauvegarde Meta, pièces et XP ensemble. Aucun nouveau DataStore, changement de clé ou reçu Robux.
- La remise à zéro quotidienne existante, à 00:00 UTC, remet aussi ce reçu à faux et exige une nouvelle élimination. Les dossiers et primes de niveau permanents ne sont pas réinitialisés.
- Le bouton indique 1 ZOMBIE REQUIS, RECUPERER, RECUPERE ou DEPENSE D'ABORD selon les conditions. La signature de rafraîchissement Missions inclut le reçu. Aucun nouveau raccourci ou bouton tactile natif.

## Preuves du 27 octobre 2026

21 checks serveur réussis, via les vrais GameAction:FireServer : ancien profil, absence d'élimination, tentative de fausse élimination client, un décès du vrai directeur attribué par le harnais, conservation des 8 pièces/20 XP de base, partie non démarrée, paiement exact, doublons, identifiants invalides, trois frontières du plafond, boosts sans effet sur la prime, JSON des reçus, changement de jour et nouvelle chasse. Le second jour utilise un callback serveur synthétique ; ce n'est pas un deuxième tir de joueur.

Quatre états client vérifiés par lecture de Text, Active et Fill.Size.X.Scale. Pas de nouvelle preuve visuelle, TextFits, interaction au doigt ou clic natif : la sonde compte 31 Heartbeat et zéro RenderStepped. Les portails/visuels de la Centrale restent donc en attente. Console finale vide avant Stop. Données/statistiques/attributs restaurés ; pas de reconnexion DataStore ni multijoueur.

QA : créer LevelRewardsQABridge (RemoteFunction) dans Play SessionStudio, installer le pont générique existant LevelRewardsBridge.client.luau, puis FirstDailyHunt.server.luau comme Script temporaire ordinaire. Lire ServerStorage.FirstDailyHuntQAResult. Les bindables PrepareFirstHuntUI (Locked/Ready/Claimed/Full) et RestoreFirstHuntQA permettent les essais UI ; restauration impérative avant Stop. Ne jamais installer ces scripts en Edit. Rapport first-daily-hunt-result.json.

Trois sources produit : GameplayConfig, EconomyService et GameHub ; backup ServerStorage.BeforeFirstDailyHunt. Aucun nouveau script actif.
