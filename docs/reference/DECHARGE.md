# Décharge électrique

Déblocage automatique au niveau 24, identifiant Arc. **K**, **L2** à la manette, ou sixième capacité du sélecteur mobile. 38 endurance et 20 secondes de récupération ; mêmes validations de vie, sol, menu, zone, mouvement et recharge que les autres capacités. Le serveur conserve le délai pendant la session et la réapparition. Une activation sans cible dépense aussi endurance/délai.

La première cible est le zombie visible le plus proche dans un cône devant le personnage (dot >=0,35), à 22 studs maximum. Les rebonds cherchent ensuite le zombie vivant et visible le plus proche à 12 studs maximum du précédent, jusqu’à quatre cibles distinctes au total, dans la même zone. La direction et la liste de victimes envoyées par le client ne servent pas à viser cette capacité. Pas de dégâts aux joueurs.

Dégâts par saut : 42, 32, 24, 18 (arrondi de42×0,75^rang). Chaque impact étourdit0,8s, attribue l’attaquant, utilise les récompenses de mort ordinaires et le chiffre de dégâts existant. Les obstacles solides, même transparents, bloquent chaque trajet ; le modèle de départ et le modèle visé sont exclus du raycast du rebond. Le rayon maximal n’est pas une explosion autour du joueur : un rebond peut atteindre plus loin que les22studs initiaux.

Le serveur transmet le trajet sélectionné via le cinquième argument existant AbilityFX (table de positions pour Arc, Vector3 inchangé pour Frost). Effets locaux : trois segments néon cassés par lien, texte ZZAP xN, teinte et marques de charge existantes, son d’impact réutilisé à timbre aigu. ReducedMotion remplace chaque lien par un segment fixe, plus fin et moins lumineux. SFXEnabled=false supprime le son. Toutes les pièces sont ancrées, sans collision/toucher/query et supprimées par Debris. Pose dédiée de lancement dans WeaponMotion, réutilisée par les contrôleurs des mains et du corps ; leur support Motor6D/AnimationConstraint reste en place.

## Preuves du 27 octobre 2026

Quatre sources locales/Studio comparées et synchronisées Edit : GameplayConfig, PulseAbility, PulseClient, WeaponMotion. Backup ServerStorage.BeforeArcAbility (4), manifeste toujours46 scripts. Pas de profil nouveau, de paiement, de publication ou de sauvegarde.rbxl.

`studio/qa/arc-result.json` :

- 19 contrôles de combat/présentation par le vrai remote UseAbility : refus niveau23/endurance37/menu/sol/busy/cooldown sans coût, quatre dégâts exacts42/32/24/18, cinquième cible intacte, zone/tag/direction initiale, attribution/étourdissement, consommation38 et délai20, conservation du délai sur Bind, mur entre deuxième/troisième cible, mêmes dégâts sous ReducedMotion. Effets observés par instances :12 segments/un son en normal,4 segments/aucun son en réduit+muet, sécurité des pièces et trajet de cinq positions. Les Vector3 apparaissent null dans le rapport JSON final ; le contrôle de longueur du trajet a lieu avant sérialisation et les dégâts prouvent les quatre cibles.
- 6 régressions module sur un Script serveur ordinaire : Frost30/Slam34/Pulse20 dégâts, Égide active et soin35% préservés ; tous les composants de61 échantillons de pose Arc finis et retour au repos. Ce sont des appels module partagés, pas cinq entrées utilisateur natives.
- 9 contrôles de bindings : K/L2 enregistrés et aucune collision parmi les actions Survival/Survivor/Fists. Pas de test physique de ces touches ou de la sélection tactile.

Harnais Arc.server + ArcBridge.client et ArcRegression.server uniquement en Play SessionStudio ; fixtures de personnage/niveau/flags/caméra/options restituées puis Stop. Endurance réelle et cooldowns privés restent naturellement affectés pendant la session de test ; Stop les retire, aucun profil de production modifié. Console contrôlée vide.

Rendu indisponible : viewport1×1, RenderStepped0. Les effets sont comptés sans capture ni revue visuelle. Poses FPS/corps, cadrage du cinquième bouton PC, sélecteur mobile, audition, R6, multijoueur et mort pendant lancement restent à inspecter. Le seuil exact d’un saut >12studs et l’activation sans cible ne sont pas testés spécifiquement dans ce lot ; les conditions correspondantes sont dans le serveur. Aucun équilibrage long par joueurs.
