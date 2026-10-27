# Refonte cartoon — progression

## Lot installé le 22 octobre 2026

- Achats de vitalité, agilité et armes en pièces depuis les menus, sans obligation de proximité des stands. Contrôles serveur de prix, niveau et possession conservés.
- Cinq modèles d'armes enrichis : tuyau à valve, batte renforcée, hache de secours avec rivets, katana gravé, lame Nova avec runes. Les poings conservent les gants existants.
- Module WeaponMotion : six profils de mouvements à la première personne, durées adaptées aux cadences, deuxième coupe inversée du katana, préparation et impact amplifiés au troisième coup.
- Annulation d'un impact différé après changement d'arme, mort ou ouverture d'un menu.
- Aperçus 3D animés des armes dans le catalogue, cartes différenciant l'arme équipée, niveau requis et boutons désactivés si solde insuffisant.
- Réactions au survol, au focus manette et à l'appui tactile/souris ; arrivée animée du panneau ; dégradés doux. Les animations d'interface respectent Camera douce.
- Rafraîchissement du catalogue seulement quand les données pertinentes changent, afin de préserver les boutons lors des mises à jour périodiques.
- Boutique Robux toujours désactivée.

## Vérification

Le harnais studio/qa/Expansion.server.luau a passé les contrôles d'achats à distance, doubles achats, niveau, équipement, fragments, pets, multiplicateurs et récompenses uniques. Construction des cinq modèles et échantillonnage des six animations vérifiés en Studio. Armurerie inspectée visuellement sur PC ; console sans erreur au contrôle. Les nouveaux changements mobiles et les animations en combat réel restent à vérifier.

Sauvegarde des scripts précédents dans ServerStorage.BeforeCartoonRefresh. Les modifications sont installées dans le DataModel Edit ; aucune publication effectuée.

## Suite de l'objectif actif

Neuvième lot : essais téléphone iPhone 17 Pro simulé, paysage 750 × 381. Les sept boutons dont recharge ont été observés ; taille 54 × 54. Détection puis correction du chevauchement des munitions avec le niveau : position finale mesurée (556,24), taille (170,42), niveau (195,14), taille (360,64), donc pas de chevauchement et contenu dans le viewport. Indication tactile/manette de recharge adaptée et bouton COUP devient TIR pour une arme à feu. La capture après correction est restée bloquée et a été annulée : validation finale géométrique uniquement, à compléter visuellement. Scripts compilés et installés ; test arrêté, données de test supprimées, simulateur remis à default. Portrait et interactions physiques restent à vérifier.

Huitième lot : contrats express renouvelables (3 zombies : 40 pièces/20 XP ; 2 espèces : 60/30 ; 7 zombies : 100/60). Récompenses automatiques, progression stockée dans Meta.QuickContract, prochain contrat immédiat sans compteur d'attente. Objectif affiché sur PC dans le HUD et dans Missions sur tous les appareils. Sept contrôles du harnais Contracts.server.luau réussis : seuil, sérialisation partielle, récompenses, variété, boucle et refus d'espèce inconnue. Sauvegarde DataStore en production non testée. Menu inspecté visuellement, console vide. Rafraîchissement Missions indépendant du compteur de temps, pour éviter de recréer les boutons toutes les deux secondes. Source finale compilée et installée en Edit. Backup BeforeQuickContracts.

Septième lot : deux images originales créées avec ImageGen et importées dans Roblox. Fond d'accueil illustré et atlas de huit icônes intégrés aux étapes, onglets, améliorations, missions et cadeaux. Texture atlas mesurée via EditableImage.Size ; rendu et correction d'espacement inspectés dans Studio sur PC. Sources et prompts dans assets/ui/README.md. Validation mobile des visuels et nouvelles activités rapides encore à poursuivre.

Sixième lot : poses corporelles et sons des déplacements, validation d'atterrissage, pistolet achetable avec munitions et rechargement (voir docs/reference/ARMES_A_FEU.md). Demandes ajoutées par l'utilisateur : images/illustrations pour les UI, rythme rapide et fonctionnalités de progression engageantes. À poursuivre avec visuels intégrés, objectifs courts, récompenses lisibles, et vérifications de performance ; ces points ne sont pas encore achevés.

Cinquième lot : première intégration des déplacements avancés, décrite dans docs/reference/MOUVEMENTS.md. Accélération, accroupissement, glissade, franchissement bas et contrôles serveur installés ; dix contrôles du harnais Studio réussis. Fluidité en situation, animations/SFX et tests tactiles restent à effectuer.

Quatrième lot : attaques à la troisième personne diffusées par les attributs serveur SwingWeapon/SwingCombo/SwingAt, uniquement après validation. CharacterCombat ajoute une couche procédurale aux épaules R6/R15 et prend en charge Motor6D ainsi que les AnimationConstraint réellement présentes dans le personnage Studio. Vérification en Play : attaque valide acceptée, direction nulle refusée, amplitude de l'épaule droite observée à 1,346 rad puis retour à 0,439 rad (pose Animator de repos). Vérification multijoueur et inspection visuelle de chaque arme à poursuivre ; ce test ne prouve pas à lui seul toutes les animations.

Objectif élargi par l'utilisateur : système de déplacement inspiré d'Evade. À intégrer dans SprintServer : accélération, accroupissement, glissade et franchissement d'obstacles, avec arbitrage des états, endurance partagée, collisions, retours visuels/sonores et commandes tactiles. Le sprint et le dash actuels sont le point de départ, pas une preuve de réalisation de cette nouvelle demande.

Troisième lot : textes de pièces et notifications corrigés pour rester contrastés sur les cartes claires ; indicateur VIE CRITIQUE sous 25 % ; regroupement des gains reçus à moins d'une seconde d'intervalle ; bannière de niveau ; nouvelle fiche de cible (nom, PV, distance) calculée à 10 Hz et masquée par les murs ou les menus. Vérifications en Play : cible factice à 65/100 correctement affichée, avertissement de vie, occultation par un mur, bannière NIVEAU 3 et regroupement +15 pièces/+30 XP. Ces événements de test n'accordent pas de récompenses réelles. Session de test arrêtée pour retirer les objets temporaires.

Deuxième lot : accueil en trois cartes colorées (combats, évolution, collection), état de chargement explicite, bouton Options agrandi, barres de progression pour les améliorations, missions et cadeaux. Accueil contrôlé visuellement sur PC et iPhone 17 Pro simulé en paysage (750 × 381) et portrait (401 × 778), ScreenOrientation Sensor. Tous les éléments restent visibles ; bouton Options porté à 60 pixels logiques après mesure de sa hauteur en portrait. Page cadeaux inspectée sur PC. Console vide. Simulateur remis à default, Studio laissé en Edit ; dernière source compilée et installée. Les autres pages en portrait et les interactions tactiles physiques restent à vérifier.

Refonte plus complète de l'accueil et du HUD, harmonisation de tous les menus, vérification tactile, animations de combat en situation et troisième personne, amélioration des modèles et effets. Ce lot ne constitue pas la fin de la demande d'amélioration générale.

Documentation Context7 utilisée : Roblox Creator Docs, TweenService et GuiButton.Activated. Codex on Crack : vérification de configuration effectuée, aucun worker configuré ; réalisation directe demandée par la continuation. Le projet est inscrit au panneau, mais son affichage reste bloqué par une erreur de lecture Windows.
