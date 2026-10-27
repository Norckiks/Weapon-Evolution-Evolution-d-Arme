# Attaques de zombies — contrat de gameplay

Lot du 23 octobre 2026. Les règles serveur sont installées et ont passé 47 contrôles dédiés + 29 régressions de l’onde de choc. Résultats : studio/qa/zombie-melee-result.json. Aucun nouveau prix, bonus économique, schéma de sauvegarde ou produit Robux.

## Préparation et esquive

Chaque attaque comprend une préparation, un impact unique puis une récupération. Le zombie s'arrête et verrouille sa direction au début : passer derrière lui ou sortir de sa portée pendant la préparation permet d'éviter le coup. Arc total 100° (±50°), portée habituelle 4,4 studs au départ / 4,7 à l'impact. Deux attaques ne peuvent pas se superposer. Le délai entre débuts reste au moins 1,5 s et au moins préparation + récupération.

| Type | Préparation | Récupération |
|---|---:|---:|
| Civilian | 0,45 s | 0,35 s |
| Runner | 0,32 | 0,30 |
| Brute | 0,70 | 0,45 |
| Worker | 0,48 | 0,35 |
| Soldier | 0,42 | 0,35 |
| Scrapper | 0,80 | 0,45 |
| Hazmat | 0,50 | 0,35 |
| Stalker | 0,28 | 0,30 |
| Abomination | 0,90 | 0,50 |
| Drowned | 0,50 | 0,40 |
| Raider | 0,34 | 0,30 |
| AnchorTitan | 1,00 | 0,50 |

Une mise à jour de StunnedUntil annule la préparation immédiatement. Un jeton invalide les callbacks déjà planifiés : même si l'étourdissement court expire avant l'ancien impact, ce coup ne revient pas. La mort/retrait du zombie, le remplacement du personnage, le changement de zone, le niveau insuffisant, l'éloignement et les murs sont revérifiés. Un joueur avant Jouer n'est pas ciblé. Les menus ouverts pendant la partie ne mettent pas le monde en pause.

## Occlusion

Un mur solide bloque même s'il est transparent. Les volumes décoratifs sans collision sont traversés sous une limite de 32 raycasts. Les accessoires et outils de la victime sont exclus de la ligne de vue : une boîte de collision de cheveux dépassant devant un mur ne doit pas faire croire que le corps est exposé. Les véritables parties du personnage restent des cibles. Cela corrige un cas observé avec Pink Hair.Handle de l'avatar de test. La même vérification est utilisée pour la poursuite directe du directeur.

## Code et présentation

ServerScriptService.ZombieMelee (studio/ZombieMelee.luau) possède le contrôleur, les délais, le cône, les validations et annulations. API : new(model,definition,zone), TryAttack(character), CanHit, IsBusy, Cancel, Destroy ; HasSight pour la poursuite. Aucun remote de dégâts ennemi accepté du client. Le directeur crée/détruit un contrôleur par zombie et suspend marche/rotation pendant préparation/récupération. Les slots/rewards/respawn restent dans ZombieDirector.

Attributs AttackPhase (Idle/Windup/Recovery), AttackAt, AttackWindup, AttackRecovery, AttackFacing et AttackOutcome servent à synchroniser/diagnostiquer l'animation. Un Highlight AttackWarning orange/or, avec profondeur Occluded, est activé seulement pendant la préparation. Un son de tissu existant marque le début puis un autre le geste final, y compris un coup manqué ; annulation avant impact supprime le son de préparation et empêche le geste final. Les sons utilisent WorldFoley et sont détruits à Ended avec filet Debris. Aucun nouvel enregistrement sonore.

PresentationClient lit ces durées pour la préparation, le geste final et le retour. Détection des articulations Motor6D et AnimationConstraint, noms R6/R15 normalisés. ReducedMotion atténue les transformations à 25 %. Les anciennes animations de marche/recul sont conservées. Ces poses et le contour sont implémentés mais leur rendu final reste à inspecter quand le client dispose d'une vraie vue ; caméra 1×1 pendant la passe serveur. Ne pas appeler un Highlight.Enabled une preuve visuelle.

## Résultats

La passe complète de 47 contrôles a réussi après correction : douze vrais rigs/délais/dégâts, avertissement activé et arrêt, impacts uniques, récupération/cooldown, esquives préparées derrière/hors portée, mur transparent solide et accessoire cosmétique, déclencheur sans collision, annulation même après expiration d'un étourdissement court, mort/retrait, accès/niveau, vrai directeur et vraie réapparition. Le sous-ensemble ciblé de 23 avait passé avant la passe complète ; il ne s'ajoute pas au total de validation.

Les 29 contrôles Pulse précédents ont aussi passé : vrai remote, endurance/délai, mort d'un vrai Civilian à récompense ordinaire, arrêt/reprise du Runner, poussée physique ~2,58 studs, respawn et limite de cibles. Leurs intitulés historiques « renders » désignent ici les instances créées : 12/6 traits et 1/0 son, pas une image rendue. PoseDistance était 0, caméra 1×1. Aucun mouvement de pose n'est donc prouvé par cette passe.

Les impacts mesurés n'ont jamais précédé le délai configuré. Ce n'est pas une garantie de délai maximal : le Stalker a été observé vers 0,439 s pour 0,28 configuré pendant la passe finale. task.delay reprend sur une étape de planification suivante ; charge/latence et ressenti restent à mesurer. Aucun benchmark FPS revendiqué.

Quatre scripts précédents dans ServerStorage.BeforeZombieWindups ; nouveau module ZombieMelee. Sources/instances synchronisées dans Edit, 42 scripts actifs, QA absents des démarrages. Aucun changement de scène persistent, constructeur ou publication. Console finale Play vide, profils temporaires restaurés, Play arrêté et simulateur default/LandscapeLeft.

## Vérification et reprise

Le harnais studio/qa/ZombieMelee.server.luau s'installe seulement comme Script temporaire dans Server Play SessionStudio. Il teste les vrais contrôleurs sur les douze rigs, chaque délai/dégât, les annulations/obstacles, puis deux attaques d'un vrai zombie du directeur et une réapparition réelle du joueur. Les racines sont temporairement ancrées ; l'esquive est préparée par déplacement serveur contrôlé, pas par clavier/tactile physique. Profil/niveau/santé/position restaurés à la fin puis Play doit être arrêté. SkipRigPass=true permet un diagnostic du reste sans rejouer les douze rigs ; ne pas compter ce sous-ensemble comme une passe complète.

Le premier test du mur a révélé les cheveux cosmétiques touchés avant le mur. Après correction, le montage synthétique a dû isoler l'accessoire dans un dossier du personnage et placer le mur plus près du zombie pour éviter de couper le corps ; cela stabilise la preuve sur les avatars différents. Le rayon brut doit toucher l'accessoire, la vérification filtrée doit ensuite trouver le mur. Les erreurs de montage et la correction produit sont distinctes.

À terminer côté rendu : contour/pose/sons audibles sur PC et mobile, ReducedMotion sur les deux classes d'articulation, ressenti d'esquive au clavier et sous latence, multijoueur et équilibrage long. Ces points ne sont pas prouvés par une mesure de délai serveur. La validation des boutiques de docs/reference/UI_MOBILE.md reste aussi en attente.

Références Context7 consultées : [task.delay/task.cancel](https://github.com/roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/task.yaml) et [validation de tirs serveur](https://github.com/roblox/creator-docs/blob/main/content/en-us/tutorials/use-case-tutorials/scripting/intermediate-scripting/hit-detection-with-lasers.md). Les annulations utilisent ici un jeton de contrôleur plutôt que la suppression du thread.

Lot suivant : le directeur utilise ZombieNavigation pour les trajets et Pause pendant la préparation/récupération/étourdissement ; les 47 régressions de mêlée et 29 Pulse ont repassé. Le jeu compte désormais 43 scripts. Voir docs/reference/NAVIGATION_ZOMBIES.md pour les parcours physiques et les limites.
