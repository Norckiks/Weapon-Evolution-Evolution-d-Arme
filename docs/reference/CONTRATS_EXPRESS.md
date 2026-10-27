# Contrats express par zone

Depuis le lot Métro, Metro vaut×14 et la borne sauvegardée est1..14 ; les cinq anciens paliers restent inchangés. Voir [METRO.md](METRO.md).

Le cycle existant continue sans attente : 3 éliminations, 2 espèces distinctes, 7 éliminations. Les primes sont maintenant adaptées aux zones des éliminations qui ont effectivement fait avancer le contrat.

| Zone | Multiplicateur | 3 éliminations pièces/XP | 2 espèces pièces/XP | 7 éliminations pièces/XP |
| --- | --- | --- | --- | --- |
| Ville | x1 | 40/20 | 60/30 | 100/60 |
| Usine | x2 | 80/40 | 120/60 | 200/120 |
| Labo | x4 | 160/80 | 240/120 | 400/240 |
| Port | x7 | 280/140 | 420/210 | 700/420 |
| Centrale | x10 | 400/200 | 600/300 | 1000/600 |

Le palier le plus bas des éliminations contributrices fixe la prime. Deux éliminations en Ville puis la dernière à la Centrale donnent x1 ; Labo/Port/Centrale donne x4. Une répétition de la même espèce dans l'objectif de variété ne fait pas avancer le contrat et ne change pas son palier. Le serveur déduit la zone de l'espèce réelle, jamais d'un identifiant envoyé par le client.

Les bonus pet/temps continuent de modifier les gains habituels des zombies. La prime express calculée n'est pas multipliée une seconde fois. Le plafond existant de deux milliards de pièces demeure applicable : les contrats restent payés automatiquement et ne mettent pas de prime en attente au plafond. Les protections des primes de niveau/première chasse ne sont pas étendues à ce circuit.

Le suivi rapide PC affiche les deux gains : par exemple `0 / 3 · +40 P / +20 XP (base)`. Ces montants viennent de `Q.Reward` comme dans Missions ; aucune attribution n’a changé. Capture PC inspectée et TextFits vérifié au refuge puis en Ville avec dossier 0/6. Gros multiplicateurs, dossier prêt et mobile non vérifiés pour cette modification ; le suivi rapide est masqué sur tactile. Source GameHub comparée puis synchronisée en Edit, sauvegarde `ServerStorage.BeforeContractXPText`.

## Attente réduite en Ville

La Ville conserve six zombies simultanés, mais leur délai de réapparition passe de 10 à 7 secondes. Les autres zones gardent 10 secondes ; le contrat « Nettoyage express » reste à sept éliminations pour 100 pièces et 60 XP de base. Les profils partiellement avancés, prix et récompenses ne sont pas modifiés. Le directeur applique le délai de la zone aussi bien après une mort qu’après la disparition d’un modèle.

En Play SessionStudio, les réapparitions observées étaient de 7,23 s en Ville après mort et suppression, et de 10,47 s en Usine. Un test de sept morts de vrais zombies attribuées par harnais vérifie le contrat à 6/7 puis sa complétion et les gains exacts ; ce ne sont pas des coups utilisateur. Six contrôles de délai et quatre de contrat passent, profil/statistiques/santé restaurés, console vide puis Stop. Rapport `studio/qa/city-respawn-result.json` ; scripts temporaires `CityRespawn.server` et `CityContractPacing.server`. `WorldConfig` et `ZombieDirector` comparés/synchronisés, sauvegarde `BeforeCityRespawn`. Équilibrage ressenti et multijoueur restent à tester.

## Sources et données

- QuickContracts.ZoneMultipliers définit les cinq facteurs. Q.Ensure normalise QuickContract.Multiplier entre 1 et 10, Q.OnKill garde le minimum et Q.Reward calcule les montants, sans modifier les définitions de base.
- Un ancien contrat partiellement avancé sans multiplicateur reste à x1 pour sa fin de cycle ; le cycle suivant suit ses nouvelles éliminations. Aucun compteur existant ni reçu n'est réinitialisé. Une zone inconnue ou un appel ancien sans zone utilise x1.
- La complétion avance l'index, remet Count/Seen/Multiplier à zéro/vide/x1 avant l'attribution, comme l'ancien circuit. Le changement de jour n'efface pas le contrat partiel. Meta et son bail/sauvegarde sont ceux de ProgressionService ; pas de nouveau DataStore.
- EconomyService transmet l'identifiant de zone calculé par Expeditions.ZoneForSpecies. Aucun nouveau remote, argument de récompense ou commande client de progression.
- GameHub utilise le même Q.Reward pour Missions et le suivi PC. Un contrat vide affiche BASE ; un contrat en cours affiche son facteur suivi xN. Il ne prédit pas la zone du prochain ennemi.

Pour une future zone : ajouter son facteur et garder cohérente la borne de normalisation (10 actuellement), conserver des identifiants d'espèces propres à chaque zone.

## Preuves du 27 octobre

49 checks réussis : trois contrats pour chacune des cinq zones, fin de cycle/remise à zéro, zones mixtes, variété/duplicata, migration d'un ancien contrat, valeurs sauvegardées malformées, zone inconnue, aperçu vide, tentative client de faux kill, complétion réelle du directeur et JSON/changement de jour. Sept contrôles historiques Ville passent également, sans changement de leurs montants.

Le décès d'un Lineman réellement apparu a été attribué au joueur par le harnais : gains normaux avec pet/boosts de 1870 pièces et 2520 XP, plus précisément 400 pièces/200 XP de contrat, puis cycle suivant. Ce test n'est pas un tir de joueur. Trois cas client vérifient les textes x10 (400/200), x4 (160/80) et BASE (40/20), dans la carte et le suivi. Aucune nouvelle capture, géométrie mobile ou interaction physique ; les visuels/portails Centrale restent à revalider. Console contrôlée vide. Données/statistiques/attributs restaurés avant Stop, pas de test DataStore de reconnexion ou multijoueur.

QA : en Play SessionStudio, créer LevelRewardsQABridge et installer le pont générique LevelRewardsBridge.client.luau, puis ContractZones.server.luau comme Script temporaire ordinaire. Lire ContractZonesQAResult. PrepareContractZoneUI:Invoke(multiplier,count) prépare les textes ; RestoreContractZoneQA:Invoke() est obligatoire après les essais UI. Contracts.server.luau couvre la régression Ville. Rapport contract-zones-result.json ; backup BeforeContractZoneRewards, trois sources. Aucun nouveau script actif.
