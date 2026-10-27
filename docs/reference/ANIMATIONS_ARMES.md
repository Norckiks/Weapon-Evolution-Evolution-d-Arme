# Mécanismes d'armes sur le personnage

Lot du 26 octobre 2026, après l'ajout de la troisième personne. La pompe du fusil et le barillet du revolver étaient animés seulement dans les bras subjectifs. Ils sont maintenant animés aussi sur l'arme portée par le personnage, à partir des mêmes fonctions `WeaponMotion.PartPose` et des attributs de tir/rechargement publiés par le serveur.

## Implémentation

`WeaponMotion.IsMechanism` identifie les six pièces de pompe (Foreend et cinq PumpRib) et les quatorze pièces du revolver (Cylinder, CylinderAxle, six ChamberRim, six ChamberPrimer). `EconomyService.weaponModel` leur donne un Motor6D nommé WeaponMechanism ; les autres pièces gardent leurs WeldConstraint. C0 contient la prise en main et C1 l'inverse de la position de construction : le Transform peut appliquer le mouvement autour du pivot prévu par le modèle. Les pièces restent sans collisions et sans masse ajoutée.

`CharacterCombat` applique les Transform en PreSimulation pour les personnages visibles à moins de 120 studs de la caméra. Il garde un cache par modèle ; l'attribut serveur MechanismCount permet de le compléter si les joints arrivent après le modèle. Les changements d'arme remplacent le modèle et ses joints. La première personne continue d'utiliser son contrôleur existant, avec la même timeline.

La pompe descend à un quart d'amplitude en ReducedMotion, comme en vue subjective. La rotation mécanique du barillet continue d'indiquer les munitions. L'inclinaison de torse des capacités respecte désormais également ReducedMotion, avec Waist ou RootJoint selon le rig ; les couches de corps existantes prennent toujours en charge Motor6D et AnimationConstraint.

`FirearmsClient` place aussi la carte de munitions sous la nouvelle carte de déplacement en portrait pour éviter leur chevauchement. Prix, dégâts, munitions, délais, contrôles d'achat et paiements n'ont pas été changés.

## Preuves

Play SessionStudio, scripts QA ordinaires utilisant les vrais services : 33 assertions réussies. Les quatorze joints de revolver et les six de pompe sont attachés et sans masse. Un vrai tir de revolver consomme une balle et tourne le barillet de 1,0472 radian ; un vrai rechargement l'ouvre, le tourne, remet six balles puis ramène ses joints au repos. Deux tirs du fusil donnent des courses de pompe de 0,21970 et 0,05500 stud en mode réduit ; les deux retombent à zéro. Les poses de torse Slam isolées mesurent 0,418879 et 0,104720 radian (24° et 6°). Changer d'arme retire bien l'ancien modèle.

Résultats : `studio/qa/world-mechanisms-result.json`. Les premiers essais ont révélé un échantillon de pompe nul et une assertion de repos prenant le maximum d'une frame encore ancienne ; garde de réplication ajoutée, contrôle de repos sur la dernière frame et passe complète rejouée. Ces tentatives restent distinguées du résultat final.

Capture inspectée WorldRevolverMechanismPreview : personnage et barillet en pose d'ouverture. C'est une prévisualisation figée côté client pour inspecter la géométrie ; les tirs/rechargements réels sont prouvés séparément par le harnais. Capture AmmoPortraitAfterMovement : iPhone 17 Pro simulé, viewport 401×778, carte munitions en (207,271), carte déplacement en (168,219), écart vertical vérifié de 8 pixels. Pas de tactile physique testé.

Fichiers actifs : WeaponMotion, EconomyService, CharacterCombat et FirearmsClient, synchronisés avec leurs instances Edit après comparaison. Backup `ServerStorage.BeforeThirdPersonMechanisms`. Contrôle final : les 46 sources et classes du manifeste correspondent à Studio, les 46 compilent et aucun QA n'est installé dans les conteneurs de démarrage. Profils de test restaurés, aperçu caméra retiré, simulateur default/LandscapeLeft et Play arrêté. MonetizationEnabled=false. Aucune transaction, écriture DataStore de production, publication ni sauvegarde .rbxl.

Limites : un seul joueur, rig actuel seulement, pas de revue physique R6, manette/tactile ou multijoueur. Les Transform sont locaux à chaque client ; le contrôleur parcourt les autres joueurs, mais leur rendu entre deux clients n'a pas été essayé. La rotation caméra au clic droit et les collisions de caméra sur toute la carte restent à vérifier dans un lot suivant.

Graphify a repéré les liens EconomyService/WeaponVisuals/FistsClient ; les sources actuelles ont ensuite été relues directement. Context7 a confirmé le passage PreSimulation et le caractère local de Transform dans la [documentation Motor6D officielle](https://create.roblox.com/docs/reference/engine/classes/Motor6D). Ponytail : réutilisation de PartPose et du contrôleur de personnage, sans nouveau script actif. ECC verification-loop : compilation, contrôles en Play, revue des dépendances et limites explicites ; les commandes web/TypeScript du guide ne s'appliquent pas à ce projet Luau.
