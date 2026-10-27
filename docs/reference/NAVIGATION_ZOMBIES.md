# Navigation zombies — contrat et reprise

Module serveur ZombieNavigation ajouté le 23 octobre 2026. ZombieDirector utilise un contrôleur par zombie ; aucun calcul de chemin côté client, aucune téléportation de rattrapage ni modification des récompenses/profils. Les mesures détaillées sont dans studio/qa/zombie-navigation-result.json.

## Déplacements

En vue dégagée, MoveTo va directement à la destination sans calcul de chemin. Sinon, le contrôleur suit les points renvoyés par le vrai PathfindingService avec les dimensions d'agent précédentes (rayon 1,6×échelle, hauteur 5,2×échelle, saut autorisé). La progression compare la distance horizontale et une tolérance verticale adaptée : les points sont sur le sol, pas au centre du HumanoidRootPart.

Le contrôle 3D précédent avec seuil 3 causait des pauses sur les grands rigs : le colosse restait environ 4,05 studs au-dessus du point même après arrivée horizontale. Une arène physique temporaire a mesuré ce cas avant/après sur le vrai directeur, pas seulement un tableau de points.

Une absence de progrès horizontal pendant 1,2 s force un trajet calculé, y compris si la tête voit par-dessus une barrière qui bloque le corps. Les points de saut déclenchent le vrai Humanoid.Jumping. Le trajet forcé reste suivi jusqu'à la fin ; on ne le supprime pas simplement parce que la tête retrouve une vue directe. Path.Blocked est connecté seulement pour les points à venir ; un blocage physique sert de repli si cet événement n'arrive pas. Un trajet impossible arrête le déplacement et temporise les nouvelles tentatives (1,4 s après échec), sans marcher indéfiniment dans le mur.

## File et annulation

Deux calculs ComputeAsync au maximum à la fois dans ce module, une file de 64 au plus et un calcul par contrôleur à la fois. Les demandes en file utilisent la dernière destination sans doublon. Une cible déplacée d'au moins 6 studs invalide le résultat précédent. Les calculs natifs déjà démarrés ne sont pas prétendus annulés : ils terminent, puis leur révision est refusée s'ils sont obsolètes.

Pause pendant étourdissement, préparation/récupération de mêlée, arrivée au refuge d'origine ou attente invalide les chemins et leur callback. Mort/retrait détruit le contrôleur et arrête la commande MoveTo déjà donnée si le personnage est encore vivant. Les attentes de calcul ne sont pas traitées comme un blocage physique. Les références de Path.Blocked sont déconnectées et les Path détruits lors du remplacement, de la pause ou de la destruction. Le budget de travail est libéré après un résultat refusé ou une erreur native.

API : new(model,definition), Move(destination,direct), Pause(), Destroy(), Stats(). Stats retourne les compteurs de ce module, pas le nombre global de toutes les requêtes moteur d'un serveur. Les attributs NavigationState/NavigationRevision servent au diagnostic sans ajouter de panneau au joueur.

## Arrêt d’un contrôleur vivant

Un test distinct a reproduit une commande directe encore active après Destroy : 5,60 studs parcourus en 0,8 s. La destruction annule désormais aussi le MoveTo courant, sans effacer une poussée physique extérieure. La passe finale mesure environ 0,122 stud de décélération après Pause et après Destroy. Les callbacks de chemin obsolètes sont également rejetés. Cela couvre le retrait d'un zombie encore vivant de LiveZombies, pas seulement une mort où Humanoid s'arrête naturellement.

## Validation finale

23 contrôles de navigation + 47 régressions de mêlée + 29 régressions Pulse ont passé sur la version finale, soit 99. Les deux contrôles du parcours comparatif sont documentés séparément : ils précèdent seulement le correctif final de Destroy, qui ne change pas le suivi du trajet. Ne pas additionner les anciennes passes de diagnostic au total final.

La file a réellement eu deux travaux simultanés et quatre en attente. Trois résultats devenus obsolètes ont été refusés ; à la fin du harnais navigation, zéro travail actif/en attente. Le compteur Failed=1 correspond au NoPath volontaire, pas à une erreur de test. Le cap de 64 est une règle configurée, pas une charge de 64 agents mesurée.

Une lecture require directe via execute_luau a retourné une autre instance de cache à zéro : elle n'est pas retenue comme état du directeur. Utiliser toujours un Script serveur ordinaire temporaire pour Stats et les services, comme les harnais fournis. Le module calcule des chemins avec ComputeAsync qui cède ; une attente de calcul n'est pas un échec terminal et ne doit pas justifier une relance aveugle.

## Tests et limites

Le harnais temporaire NavigationDirector.server.luau place le vrai colosse sur un plancher supérieur isolé, avec mur et joueur cible immobile, dans son rayon de poursuite d'origine. Il vérifie d'abord un chemin moteur valide, mesure positions/vitesse et restaure le joueur/NPC/la scène. La version avant a atteint la distance d'approche en 12,03 s, dont 4,25 s de pauses associées au décalage vertical. Après : 7,76 s et 0,43 s de pauses, même géométrie. Une mesure de parcours n'est ni un benchmark FPS ni une garantie dans toutes les zones.

ZombieNavigation.server.luau teste la vraie file moteur et le déplacement de clones physiques : route directe sans calcul, deux travaux simultanés, remplacement en file/en cours, pause/mort, non-reprise d'un vieux trajet, saut au-dessus d'une barrière basse, obstruction ajoutée et trajet impossible. Pendant la passe initiale, la barrière a été franchie en 7,11 s avec un saut réel, hauteur racine maximale ~130,11 sur sol Y120. Le premier mur ajouté a été contourné en 14,10 s, trois révisions, deux reprises après immobilité. La passe finale l’a contourné en 12,02 s, deux révisions et une reprise. **Path.Blocked n'a pas été observé sur ce montage (compteur 0)** ; seul son repli par détection physique est prouvé pour ce cas. Une observation ciblée de huit secondes, sans mise à jour de déplacement qui aurait déclenché le repli, n’a pas non plus reçu ce signal. Il reste non validé en exécution ; ne pas annoncer la connexion du signal comme une preuve qu’il s’est déclenché.

Tous les QA sont des Scripts ordinaires temporaires en Server Play SessionStudio, jamais en Edit/public. Ils créent de la géométrie de test et des modèles temporaires ; il faut arrêter Play après les essais même en cas d'échec. Un étage ou un objectif inaccessible peut légitimement retourner NoPath : pas de téléportation ou passage à travers le décor. Les formes étroites, multi-étages, tous les reliefs, interactions de foule, latence, saisie physique et multijoueur restent à explorer.

La caméra client reste un problème d'outillage séparé : une pose ou capture n'est pas prouvée par des coordonnées serveur. La validation des boutiques/poses reste celle de docs/reference/UI_MOBILE.md. Aucun MaterialVariant, scène permanente, paiement, DataStore ou publication ajouté.

Référence Context7 : [Roblox pathfinding et chemins bloqués](https://github.com/roblox/creator-docs/blob/main/content/en-us/characters/pathfinding.md).

État final : sources synchronisées/compilantes, 43 scripts actifs. Un Script précédent dans ServerStorage.BeforeZombieNavigation ; nouveau ModuleScript ZombieNavigation. Play arrêté, default/LandscapeLeft, aucun QA en Edit, console finale Play vide. Aucun achat Robux ni publication activé.
