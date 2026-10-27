# Variantes élites

Dans les zones de niveau requis 5 ou supérieur, huit éliminations attribuées au joueur alimentent un compteur commun au serveur et à la zone. La huitième prépare un élite, puis le prochain emplacement qui réapparaît consomme cette demande. La Ville reste sans élites. Un élite tué contribue à la prochaine série ; une mort sans attribution ne contribue pas. Compteur et demande sont temporaires et disparaissent à l’arrêt du serveur.

L’élite conserve l’identifiant de son espèce pour les fragments, dossiers et contrats. Il reçoit 1,8 fois les PV, 1,2 fois les dégâts, 2,5 fois les pièces et XP et 1,1 fois la taille, avec arrondi pour les valeurs entières. Couronne et nom dorés, contour et fiche de cible le distinguent. Un message annonce la prochaine apparition au joueur qui a crédité la huitième élimination.

Sources : WorldConfig, ZombieDirector et TargetHUD. Leurs copies antérieures sont dans ServerStorage.BeforeEliteSpawns. La QA temporaire `studio/qa/Elites.server.luau` utilise un pont client et des morts attribuées artificiellement ; elle ne prouve pas un combat au clavier, le rendu mobile ou un test multijoueur. En SessionStudio, 59 contrôles ont réussi, avec restitution du profil et de la caméra : `studio/qa/elites-result.json`. Aucun combat à la main, test de dégâts reçus, rendu mobile ou multijoueur n’est prouvé.
