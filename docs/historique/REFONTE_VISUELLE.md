# Refonte de la présentation — 21 octobre 2026

## État livré dans Roblox Studio

La refonte est installée dans l'expérience existante. Elle conserve les trois zones, leurs niveaux d'accès, les dix-huit zombies actifs, les récompenses, les niveaux et le système d'endurance. Les essais ont lieu dans Studio ; ils ne publient pas une nouvelle version de l'expérience.

## Image et environnement

- LightingStyle **Realistic**, ombres globales et ombres de projecteurs proches, éclairage de fin d'après-midi, ciel couvert et atmosphère moins verte.
- Étalonnage discret, bloom contenu et profondeur de champ limitée au lointain ; changement progressif de teinte entre refuge, ville, usine et laboratoire.
- Trois matières PBR générées et appliquées : asphalte humide fissuré, béton usé et acier oxydé. Chacune possède ses cartes de couleur, normales, rugosité et métallicité.
- Dix assets de mesh générés et texturés : épave civile, végétation, gravats, trois bases de personnages articulables, gants, manche, tente et véhicule militaire.
- Façades, encadrements, fragments de vitres, rideaux, antennes, aérations, enseignes, drains, plaques d'égout, papiers et flaques.
- Cinq épaves civiles remplacées ; sept tentes et cinq véhicules du refuge remplacés ; végétation et gravats répartis dans les trois zones.
- Pluie légère locale qui s'interrompt sous un toit, poussière discrète, braises, frémissement de végétation et variation légère des lampes proches.
- Radio de refuge, caisses de matériel et traitement plus sobre des cuves du laboratoire.
- Torche personnelle sur **F**, **Y** sur manette ou bouton tactile.

Les instances ajoutées sont regroupées dans Workspace.PresentationV2. Les matériaux se trouvent sous MaterialService.AssistantMaterials ; les sources des meshes sous ReplicatedStorage.PresentationAssets.

## Personnages et animation

- Les neuf variantes de zombies conservent leurs statistiques et reçoivent des meshes texturés, avec tailles, proportions et équipements différents.
- Les animations des zombies sont calculées côté client pour éviter l'ancien mouvement d'articulations par saccades côté serveur. La simulation de déplacement, les attaques et les dégâts restent côté serveur.
- Marche, balancement du corps, respiration légère, préparation d'attaque et réaction à l'impact ; limitation de l'animation au voisinage du joueur.
- Les attaques des zombies appliquent leurs dégâts après une préparation de 0,18 seconde, avec nouvelle vérification de distance et de ligne de vue : le mouvement correspond mieux au coup et permet de s'écarter.
- Mort physique par cinq articulations BallSocket, contact des six meshes du corps avec le sol et suppression du cadavre après six secondes.
- Nouveau viewmodel avec gants et manches texturés, trois frappes distinctes, retour à la garde, balancement de course, inertie et impulsions de caméra plus contenues.
- Viseur discret, confirmation d'impact, marqueur de dernière frappe et petits chiffres de dégâts temporaires.
- Les frappes différées vérifient le personnage d'origine ; perte de focus, champ texte et menu empêchent de conserver une frappe maintenue.

## Son

Cinq groupes de mixage séparent ambiance, déplacements, impacts, interface et voix. Les sources spatiales utilisent une atténuation par distance ; la lecture des voix de zombies est limitée aux joueurs proches.

Bibliothèque de douze sons configurés, plus les impacts de poings existants et le pas métallique intégré Roblox :

- Vent et pluie, feux à proximité, grincements d'usine, bourdonnement électrique du laboratoire et radio du refuge.
- Pas individuels de marche/course avec variation de cadence et de hauteur, bruissement de vêtements et réception après une chute.
- Grognements espacés, bruits de préparation d'attaque, impacts et chute des corps.
- Respiration d'effort, battement discret à faible vie et confirmation des récompenses.
- Sons plus étouffés et légère réverbération sous couverture.

Les IDs et les noms des créateurs issus du Creator Store figurent dans assets/presentation-v2-manifest.json. Les sons de vent et de grincement sélectionnés sont de ProSoundEffects. Le bruit de radio est l'asset 8028069841, décrit par son créateur comme provenant de Freesound, « Static », numéro 171257.

## Interface et commandes

- Panneaux vie/endurance/pièces plus compacts ; chiffres plus lisibles, transition du compteur de pièces et indicateur retardé de perte de vie.
- Bandeau niveau/XP/zone plus discret ; notifications et barres de zombies allégées.
- Menu **P** ou bouton Options : qualité élevée/standard, pluie, sons et mouvements de caméra réduits.
- Le menu libère explicitement la souris et immobilise la caméra ; les boutons fonctionnent en vue à la première personne.
- Commandes tactiles rondes de 54 pixels, textes courts non coupés et placement séparé du saut : COUP, SPRINT et LAMPE.
- Profil élevé : pluie à 110 particules/s maximum et animation des zombies jusqu'à 120 studs ; profil standard : 40 particules/s et 75 studs. Les ombres détaillées restent limitées aux projecteurs proches.

## Vérifications effectuées

- Aucun échec de chargement dans la bibliothèque audio contrôlée ; les ambiances chargées sont également vérifiées par Sound.IsLoaded.
- Dix-huit zombies vivants, six par zone, neuf types présents, 108 meshes de personnage.
- Attaque réelle d'un zombie et perte de vie du joueur ; élimination via clic maintenu et nouveau viewmodel : +8 pièces, +20 XP, sans double récompense.
- Cadavre physique avec cinq articulations, six colliders de mesh et contact au sol observé.
- Sprint au clavier : vitesse 26 et consommation d'endurance. En mode mouvements réduits, le FOV reste à 75 pendant la course.
- Réglages testés au clic : pluie désactivée (taux 0), profil standard (taux 40), sons coupés (groupes à 0), mouvements réduits, fermeture du menu et retour du contrôle caméra.
- Torche testée par F.
- Interface et commandes tactiles examinées en simulation **iPhone 17 Pro, paysage**. Textes de boutons initialement coupés corrigés. Simulation arrêtée et vue Studio normale rétablie.
- Réapparition : un seul HUD, vie 100/100, endurance 100/100, contrôleurs reconnectés.
- Dernier contrôle : niveau 1, zéro pièce, zéro XP, qualité élevée, pluie et sons actifs. Valeurs d'essai effacées.
- Pas d'erreur liée aux scripts de présentation, de combat ou au chargement audio dans la console au contrôle final.

La mesure indicative de durée d'image dans la session Studio était autour de 16,6–16,7 ms. Ce n'est ni une mesure du temps CPU de chaque script, ni un benchmark sur un téléphone physique, ni une garantie de fréquence d'image sur toutes les machines.

## Sources et sauvegardes

Sources actives principales dans studio/ :

- FistsClient.client.luau, FistsServer.server.luau et Sprint.client.luau.
- ZombieDirector.server.luau et NPCPresentation.luau.
- PresentationConfig.luau, Presentation.client.luau et InterfaceV2.client.luau.

Scripts de préparation du décor et des assets : BuildPresentationV2.luau, BuildWeatheredFacades.luau, InstallDetailedEnvironment.luau, UpgradeCharacterVisuals.luau, UpgradeRefugeAssets.luau et AddAmbientWorldDetails.luau. Ils décrivent des opérations d'édition uniques et supposent les assets du manifeste disponibles. Ne pas les relancer sur une scène déjà équipée.

Les sources antérieures des quatre contrôleurs remplacés sont dans studio/archive/presentation-v1. Des copies des scripts, du HUD, des effets lumineux et des templates de zombies antérieurs sont aussi conservées dans ServerStorage.BeforePresentationV2. Les géométries simplifiées de véhicules et de tentes sont masquées dans leur ancien emplacement, avec leur transparence initiale enregistrée en attribut.

Le manifeste conserve les IDs des assets générés et les cartes des trois matériaux utilisés, pour faciliter leur récupération et leur inspection dans Studio.

## Passe UI cartoon

InterfaceV2.client.luau applique une palette crème, corail, turquoise et or aux cartes de vie, d'endurance, de pièces, d'XP et au menu. Les panneaux ont des coins ronds, un contour bleu encre épais, des ombres décalées et des jauges plus colorées. Les options ont des boutons colorés avec un retour visuel au survol ; les boutons tactiles reprennent le même code couleur. Les ombres suivent la visibilité des notifications pour ne pas laisser de cartes vides à l'écran.

FistsClient.client.luau affiche maintenant un éclat de style BD au point d'impact, avec « POW! », « BAM!! » ou « K.O.! » et le total de dégâts en points de vie. Le texte rebondit puis s'efface ; la taille et la couleur du viseur confirment aussi les coups lourds et les éliminations. Les dégâts restent calculés côté serveur.

## Limites à garder en tête

Le résultat vise un réalisme plus poussé mais certains personnages et accessoires restent stylisés. Il ne constitue pas un rendu photoréaliste, un classement face aux autres jeux, ni un système de ray tracing ajouté à Roblox. Les tentatives d'une seconde passe de retexturisation des personnages ont échoué côté service ; aucune amélioration de texture non installée n'est comptée dans ce document.

La qualité finale dépend aussi du niveau graphique Roblox du joueur. Les essais sur téléphone sont ceux du simulateur Studio ; une validation sur appareil physique et avec plusieurs joueurs reste nécessaire avant une publication large. Le chemin de sauvegarde DataStore n'a pas été modifié par cette refonte.
