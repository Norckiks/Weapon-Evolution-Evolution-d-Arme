# Tirs dans la tête — contrat de gameplay

## Règles installées

Les quatre armes à feu ont un multiplicateur de tête de 1,5, configuré par C.HeadshotMultiplier. Le serveur calcule chaque impact à partir de son propre raycast. Le client envoie toujours uniquement la direction ; ses montants et indicateurs de critique supplémentaires sont ignorés.

| Arme | Corps | Tête | Cartouche |
|---|---:|---:|---|
| Pistolet | 24 | 36 | 1 balle |
| SMG | 14 | 21 | 1 balle |
| Revolver | 72 | 108 | 1 balle |
| Fusil à pompe | 20 par plomb | 30 par plomb | 7 plombs / 1 cartouche |

Maximum du fusil : 140 si sept impacts corps, 210 si sept impacts tête. Un tir peut mélanger les deux : les dégâts de tous les plombs sont regroupés par cible avant une seule application TakeDamage et une seule confirmation. Une cible recevant au moins un plomb de tête est signalée comme critique, même si le total comprend des impacts corps. La portée, la cadence, les cartouches et les contrôles de zone/mur restent identiques.

Seuls Head directement sous le modèle cible et le VisualHead canonique de ce modèle qualifient. Les accessoires, pièces de bras ou objets d'un autre modèle ne qualifient pas. Les douze rigs actuels ont un Head invisible non interrogeable et un VisualHead interrogeable : la tête visible est donc la cible réelle. Aucun agrandissement de hitbox ni visée automatique. Les casques/accessoires ne reçoivent pas un bonus sur leur seul nom.

Les pièces, l'XP, les fragments et les objectifs de mort gardent leurs règles ordinaires. Aucun multiplicateur économique de tête et aucun champ de sauvegarde nouveau.

## Code et présentation

- GameplayConfig : HeadshotMultiplier=1.5.
- FirearmBallistics.HitDamage : classification de la partie et montant arrondi ; multiplicateur borné entre 1 et 3.
- FirearmsServer : accumulation par cible de Amount/Critical/Position, puis validation de zone et récompense existante.
- PunchHit : un cinquième argument facultatif Kind="Headshot". Les anciennes frappes restent compatibles avec quatre arguments.
- GameHub : rappel tête ×1,5 dans la note de l’armurerie (ajout compilé après les tests de combat ; mise en page finale à vérifier).
- FistsClient : titre TETE!, teinte de coup fort et montant total existant. La création d'effet est ignorée si la vue est trop petite pour ses bornes ; cela ne supprime pas les dégâts serveur.

L'option ReducedMotion supprime la rotation, le grossissement élastique et le mouvement ascendant de la bulle ; quatre traits fixes au lieu de huit, puis fondu. Cette correction concerne aussi les coups ordinaires. Aucun nouvel asset audio ajouté.

## Vérification

studio/qa/headshots-result.json contient **93 contrôles réussis : 30 dédiés aux tirs de tête, 33 régressions Firearms et 30 régressions Shotgun corps**. Les services réels sont testés par un Script temporaire en Server Play, avec HeadshotsBridge.client.luau côté Client et FirearmsQABridge (RemoteFunction) côté serveur. Le pont émet de vrais Shoot:FireServer et enregistre les confirmations PunchHit, sans dépendre d'une caméra rendue.

Les 30 contrôles dédiés incluent les confirmations exactes 36/21/108/210, un tir mixte à 70, faux montant/critique client ignorés, murs, zone, douze têtes de vrais templates 3D et la mort d’un vrai Civilian de 35 PV. Cette mort par un seul pistolet à 36 dégâts a attribué +8 pièces/+20 XP une seule fois. Les douze autres modèles sont des clones ancrés, sans IA de directeur. Le pont a enregistré de vraies confirmations PunchHit ; cela ne prouve pas le rendu de la bulle. Console finale Play vide.

Les fixtures restaurent le profil puis sont retirées par arrêt de Play. Cinq scripts modifiés, copies dans ServerStorage.BeforeHeadshots. 41 scripts actifs, aucun constructeur de scène exécuté. Le volume de corps du harnais Shotgun, historiquement nommé Head malgré sa taille 4×4, est désormais nommé Torso pour tester les 140 dégâts corps ; les impacts anatomiques sont couverts séparément par Headshots.server.luau. Ne pas confondre les anciennes preuves du fusil sans critiques avec ces nouvelles règles.

La validation visuelle finale des bulles/menus reste dépendante d'un vrai viewport client ; pas de capture revendiquée tant que la caméra est 1×1. Pas de test tactile/manette physique, multijoueur, audition, équilibre long ou persistance de production. Ne jamais installer les QA en Edit.
