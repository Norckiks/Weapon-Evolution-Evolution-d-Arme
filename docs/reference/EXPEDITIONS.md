# Dossiers d'expédition

Depuis le lot Métro :18 dossiers au total, avec trois nouveaux dossiers Metro. Voir [METRO.md](METRO.md).

Chaque zone possède un dossier permanent en trois étapes : six éliminations dans la zone, les trois espèces différentes éliminées, puis dix-huit éliminations. Les compteurs se cumulent dès l'installation du système ; récupérer une étape ne remet pas les compteurs à zéro. Les anciennes éliminations sans compteur ne sont pas reconstruites.

Les récompenses se récupèrent dans **Missions & dossiers**, depuis n'importe où. Le serveur exige le niveau de la zone et l'étape suivante exacte. Les récompenses sont fixes, sans multiplicateur de pet ou de boost ; les gains normaux des zombies ne changent pas.

| Zone | Étape 1 pièces / XP | Étape 2 pièces / XP | Étape 3 pièces / XP |
| --- | --- | --- | --- |
| Ville | 120 / 60 | 180 / 90 | 240 / 120 |
| Usine | 550 / 240 | 825 / 360 | 1100 / 480 |
| Laboratoire | 1400 / 650 | 2100 / 975 | 2800 / 1300 |
| Port | 3000 / 1300 | 4500 / 1950 | 6000 / 2600 |
| Centrale | 6000 / 2600 | 9000 / 3900 | 12000 / 5200 |

Quinze récompenses uniques, total 49 815 pièces et 21 825 XP. Les dossiers ne se renouvellent pas au changement de jour ; les missions quotidiennes et contrats express continuent séparément. Le lot Centrale a vérifié les trois paiements ajoutés ; sa présentation Play reste à inspecter (CENTRALE.md).

## Sources et sauvegarde

ReplicatedStorage.Expeditions (studio/Expeditions.luau) contient définitions et règles de profil partagées. EconomyService autorise les progrès et réclamations ; GameHub affiche la page et le suivi PC. Les deux anciens scripts sont dans ServerStorage.BeforeExpeditions. Le manifeste courant compte 46 scripts actifs.

Nouveau champ **Meta.Expeditions[zoneId] = {Kills, Seen, Claimed}** : Kills borné à 18, Seen limité aux trois identifiants d'espèces de la zone, Claimed égal à la dernière étape payée (0 à 3). Aucun champ existant ni reçu Robux n'est réinitialisé. Les zones futures inconnues déjà présentes dans cette table sont conservées. Le transport/sauvegarde utilise le Meta JSON existant dans ProgressionService et son bail de session ; aucun nouveau DataStore ou changement de clé.

E.OnZombieKill incrémente uniquement le dossier de l'espèce et si le niveau donne accès à sa zone. Le client ne possède aucune commande d'incrément. ClaimExpedition accepte seulement des identifiants canoniques comme City:1 ; la réception de l'étape est enregistrée avant le paiement, puis sauvegardée avec le profil par le circuit existant. Si AddRewards refuse l'attribution, l'étape est rétablie. Cette logique ne constitue pas une nouvelle transaction DataStore indépendante.

Pour ajouter une zone : ajouter ses récompenses dans Expeditions.Rewards et sa définition WorldConfig avec des identifiants d'espèces distincts. Ne pas rejouer les constructeurs de scène pour modifier des objectifs.

## Présentation

Le panneau OBJECTIFS affiche le dossier de la zone actuelle sur PC à partir de 1000×600, en plus du contrat express. Il se masque sur mobile et petits écrans ; la page Missions reste accessible. Une récompense prête est signalée dans le panneau et le bouton de sa ligne.

En portrait tactile, seule la page Missions utilise une disposition haute : textes agrandis, lignes plus hautes, onglets courts et boutons de récupération ~48 px. En paysage, la disposition large est restaurée (~45 px pour ces boutons sur le téléphone testé). Les autres pages conservent leur disposition antérieure.

## Preuves et limites

studio/qa/expeditions-result.json : 38 contrôles de dossiers, 27 contrôles de régression économique (nombre variable avec les fragments), douze paiements exacts et refus des doublons, identifiants falsifiés, niveau, compteurs et réinitialisation quotidienne. Les réclamations passent par de vrais GameAction:FireServer client. Un décès attribué par le harnais au directeur réel vérifie le lien avec la progression ; les autres éliminations du harnais sont des callbacks synthétiques.

Récupération par clic PC et portrait simulé : 1000 → 1120 pièces, +60 XP et passage immédiat à l'étape 2. Captures inspectées sur PC, iPhone 17 Pro simulé paysage 750×381 et portrait 401×778. Panneau visible sans chevauchement avec l'onde à 1200×720 ; volontairement masqué à 1200×539. Portrait : bouton ~81,7×48,2 au lieu de ~81,7×32,5, fenêtre ~377×754, descriptions mesurées sans débordement.

Le round trip JSON vérifie le format et les reçus en mémoire, pas une reconnexion ou écriture DataStore de production. Aucun test multijoueur, tactile/manette physique ni équilibrage sur une longue session. Play arrêté, simulateur default/LandscapeLeft ; aucune publication ni sauvegarde .rbxl confirmée.
