# Interfaces portrait — état de vérification

Dernier changement Pets : troisième action Évoluer, colonnes séparées, carte PC104, image26 dans le titre ; [règles et limites](EVOLUTION_PETS.md).42 assertions locales passent, mais aucun nouveau relevé mobile/TextFits/capture : les preuves anciennes ci-dessous ne couvrent pas cette disposition.

## États critiques et changement de périphérique

Le titre de vie critique est rouge ; le titre et la valeur d’endurance deviennent orange lorsqu’elle est épuisée ou inférieure à 25 %, puis retrouvent leurs couleurs normales. Le texte reste présent pour ne pas dépendre uniquement de la couleur. Les trois raccourcis du menu sont regroupés sur tactile, y compris lors d’un changement PC → téléphone ; ils reviennent au passage téléphone → PC.

`HUDController`/`SprintClient` comparés/synchronisés (backup `BeforeCriticalHUDColors`), puis `GameHub` (backup `BeforeResponsiveShortcuts`). Six contrôles locaux de capacités maximales et couleurs/titres passent ; les états d’endurance ont été simulés côté client. Les valeurs 300/300 et 200/200 passent TextFits en portrait 401×778 et paysage 750×381. Quatre snapshots PC→paysage→portrait→PC passent 23 contrôles de visibilité, TextFits et chevauchement ciblé ; capture portrait inspectée. Fixture serveur `MaximumHUD.server` restaure Meta/stats/santé/position/flags ; console vide, Stop et simulateur default/LandscapeLeft. Pas de test d’épuisement réel, tactile physique ni tous appareils. Rapport `studio/qa/critical-responsive-hud-result.json`.

## Jauges téléphone plus lisibles

Les cartes vie/endurance/pièces utilisent une échelle minimale de 0,8 sur tactile au lieu de 0,68 ; elles passent de 158 à 186 pixels de large dans les formats testés. Elles commencent à Y88, et l’étiquette décorative sous les cartes est masquée sur tactile. Sur PC la taille et l’aide clavier sont conservées. Le sélecteur de capacité ignore la position d’un groupe tactile masqué et utilise une position de repli, adaptée au portrait.

Sources `HUDController`, `InterfaceV2`, `PulseClient` comparées puis synchronisées ; backups `BeforeReadableMobileHUD` (2) et `BeforeAbilityHiddenAnchor`. Quatre snapshots iPhone 17 Pro simulé (portrait 401×778, paysage 750×381, groupe de boutons natifs visible et masqué) passent 74 assertions : échelle, TextFits des valeurs, non-chevauchement avec capacités, raccourcis et boutons natifs visibles ; le bouton ADMIN est également comparé aux capacités. Captures portrait et paysage inspectées. PC : échelle 1, aide clavier visible, valeurs TextFits. Console vide, Stop et simulateur remis default/LandscapeLeft. Ces preuves ne couvrent ni tous les appareils, ni les très grandes valeurs, ni les actions tactiles physiques ou l’activation d’une capacité. Rapport `studio/qa/readable-mobile-hud-result.json`.

## Vie : animation et changement de maximum

La traînée des dégâts est synchronisée quand la vie maximale change. Avec l’option mouvements réduits, la jauge et la traînée passent directement à la valeur actuelle ; activer cette option interrompt une animation en cours. Les calculs de santé restent inchangés. Sources InterfaceV2 et HUDController comparées et synchronisées en Edit ; sauvegarde `ServerStorage.BeforeHUDHealthMotion` (2).

En Play SessionStudio, `HUDHealthMotion.client.luau` a passé quatre contrôles de propriétés : changement de maximum, dégâts en mode réduit, traînée en mode normal, interruption lors de l’activation de l’option. Santé/max/option restaurées ; console vide puis Stop. Une capture PC montre les jauges ordinaires ; elle ne valide pas l’animation en combat réel ni les formats mobiles, et aucun achat de vitalité ou respawn n’a été testé dans ce lot. Rapport `studio/qa/hud-health-motion-result.json`.

## Lot du 27 octobre — seconde passe compacte et images

HUD 232×114 au lieu de 256×132 (−14 % hauteur), carte XP 320×58 au lieu de 360×64. Jauges épaissies, coins moins arrondis et ombres de 3 px ; icône XP ajoutée. GameHub : accueil PC .80, catalogue PC .84, espacement 8 unités, coins de cartes 12 unités et dégradé papier chaud. Cibles tactiles et règles serveur conservées. Images de l’atlas CartoonArt ajoutées aux missions/dossiers, options, offres Robux et prochain palier d’arme ; aucun nouvel asset importé. rowIcon réutilise une image déjà présente pour éviter les doublons.

Deux sources comparées puis synchronisées en Edit, backup ServerStorage.BeforeCompactIllustratedUI. QA IllustratedUI.server/client uniquement Play SessionStudio : 266 assertions structurelles sur huit pages, 54 images de catalogue sans doublons, actions contenues et Robux désactivé. Rapport illustrated-ui-result.json. Flags de session restaurés puis Play arrêté. Le viewport vaut 1×1 et RenderStepped reste à zéro : aucune nouvelle preuve visuelle, TextFits de catalogue, réactivité des animations, dimensions mobiles ou clic natif. Les anciennes preuves ci-dessous concernent les anciennes dimensions et doivent être renouvelées pour ce lot.


## Lot du 27 octobre — quatre pages restantes et retour PC

Missions, Robux, Options et Caisses passent les snapshots portrait 401×778 et paysage 750×381, soit 252 assertions supplémentaires. Les onglets ont été ouverts par clic natif sur PC, puis le simulateur changé : cela ne prouve pas leur ouverture au doigt sur un appareil physique. TextFits, actions contenues, hauteur tactile >=44 px et images HUD chargées. Capture Caisses portrait inspectée ; pas de revue visuelle exhaustive des huit snapshots. Rapport `studio/qa/remaining-mobile-ui-result.json`. Avec la passe précédente, les huit pages ont donc une preuve de snapshot dans les deux orientations ; les états avancés de progression et les interactions physiques restent à vérifier.

Défaut observé : après passage tactile → PC, le raccourci boutique conservait MENU (+cadeaux). GameHub rétablit désormais BOUTIQUES [B] dans la même boucle de rafraîchissement. Source comparée, backup `ServerStorage.BeforeShopDeviceLabel`, un seul script de jeu modifié. Régression du snapshot enrichi : PC → portrait → PC, 41 assertions (13/15/13). Aucun changement d'économie, d'achats ou de profil, aucun achat réalisé dans cette passe. Play arrêté et simulateur restauré default/LandscapeLeft.

## Lot du 26 octobre — HUD compact et images cartoon

GameHub et InterfaceV2 utilisent FredokaOne, plus ronde et épaisse, avec les bordures et animations existantes. HUD vie/endurance/pièces : 256×132 au lieu de 296×170 (−22 % de hauteur), images de cœur/chaussure/pièce issues de CartoonArt. L'ancien logo géométrique reste présent mais masqué. L'indication de maintien du sprint est masquée dans cette version compacte ; les commandes restent dans les aides et les boutons tactiles. Accueil PC à échelle .86, fenêtres PC .9 ; le tactile conserve son facteur adapté à l'écran.

Cartes portrait : armes 260 unités au lieu de 320, autres cartes empilées 250 au lieu de 300, sans réduire la cible d'action sous 44 pixels. Aperçus armes 96×96 au lieu de 128×128 en portrait. Images ajoutées aux raccourcis, aux cartes pets et caisses, réutilisant l'atlas publié existant ; aucune nouvelle image importée. Les animations existantes des boutons et les aperçus respectent toujours ReducedMotion.

Preuves : 752 assertions de snapshots dans `studio/qa/compact-cartoon-ui-result.json`. Huit pages PC ouvertes par clic natif (1447×824). Atelier, armurerie, pets et cadeaux contrôlés en portrait (401×778) et paysage (750×381) : TextFits, actions contenues dans leurs cartes, hauteur tactile au moins 44 pixels, trois images HUD chargées. Captures inspectées PC, portrait et paysage ; elles ne sont pas sauvegardées comme fichiers locaux. Le premier snapshot cadeaux portrait a rencontré un menu fermé par G : réouverture et nouvelle sonde réussie. L'essai de sélection/activation avec ButtonA n'a pas changé la page ; pas de validation de navigation physique manette.

Deux sources comparées à Studio avant écriture, backup `ServerStorage.BeforeCompactCartoonUI`. Contrôle Edit final 46/46 sources/classes synchronisées et compilables, Robux désactivé. QA locale rejouable : `CompactCartoonUI.client.luau`, après ouverture d'un onglet et stabilisation du format, uniquement en Play. Aucun achat ou test de persistance dans ce lot, aucun changement de règles serveur. Quatre autres pages restent à revalider sur mobile ; aucun test tactile physique, multijoueur ou écoute audio.

## Lot du 26 octobre — changement de périphérique et démarrage

Le HUD des capacités et plusieurs layouts pouvaient rester en attente sur `ContextActionService:GetButton` quand le tactile devenait actif sans ContextActionGui. Une sonde a constaté les frames de rendu en cours alors que le texte restait ancien. Deux sondes ordinaires isolent la condition : sur PC sans conteneur l'appel retourne ; avec TouchEnabled=true, SurvivalVault encore lié et le conteneur absent, il n'est toujours pas revenu après 0,6 s. Cette dernière condition a été préparée uniquement en Play en désactivant les owners de boutons avant le changement de périphérique ; le thread de sonde a été annulé puis Play arrêté. La correction protège les recherches par l'existence du conteneur et recrée les sept actions tactiles quand TouchEnabled change. Les boutons remplacés sont vérifiés avant de lire leur Parent : la première passe avait révélé une erreur sur un ancien bouton retiré.

PulseClient rafraîchit le HUD sur Heartbeat à 10 Hz, en dehors de la boucle de rendu ; le sélecteur mesure désormais 44×56. Les autres interfaces concernées (GameHub, InterfaceV2, ZoneGuide) évitent aussi l'attente d'un conteneur absent. Les owners de sprint, coups, lampe, recharge, accroupissement/franchissement et dash réenregistrent leurs propres callbacks, sans nouveau script actif ni changement de touches. Les sept boutons natifs sont le maximum utilisé ici ; ajouter d'autres actions tactiles demande de conserver le sélecteur personnalisé plutôt que multiplier les boutons CAS.

Le menu accepte Entrée, A et la liaison Start. Il laisse passer l'entrée quand la partie est déjà démarrée, quand un texte est saisi ou quand un autre bouton est sélectionné. L'indication « ENTREE / A : JOUER » est sous le conseil de démarrage. Entrée et A ont réellement démarré le jeu dans les tests. Une sonde ordinaire a reçu A et Entrée, mais pas ButtonStart de l'outil : cette dernière liaison reste non validée. Une sonde de priorité inférieure a reçu A après démarrage : le menu ne le consomme plus en jeu. Cela ne constitue pas un essai physique du saut à la manette.

Preuves Play SessionStudio : huit contrôles de bindings passent ; six contrôles de snapshot HUD passent en paysage. Une séquence PC → portrait → paysage → PC → portrait conserve le HUD actif, les textes correspondant au format et exactement sept boutons tactiles sans duplication. Mesures : PC 1447×824, bouton 190×48 ; portrait 401×778 et paysage 750×381, bouton 56×56, sélecteur visible 44×56. Dernière console contrôlée vide après la séquence corrigée. Rapport `studio/qa/responsive-hud-result.json`, snapshot rejouable `ResponsiveHUD.client.luau`.

La capture WelcomeStartHintLandscape a été inspectée : menu et indication tiennent dans le format paysage. Le clic automatique Jouer reste non validé : une demande (375,210) a produit un Touch en (313,112,5), visant WelcomeIllustration ; les essais suivants n'ont pas produit de nouvelle activation enregistrée. C'est une limite de calibration de l'outil, pas une preuve de panne du bouton ; ne pas agrandir ou déplacer la zone cliquable du produit pour compenser cette mesure.

Sources locales et Edit synchronisées : PulseClient, GameHub, SprintClient, FistsClient, PresentationClient, FirearmsClient, MovementClient, InterfaceV2 et ZoneGuide. Backup BeforeResponsiveStart (neuf scripts). Toujours 46 scripts actifs. Les sondes ont été installées seulement dans Play, puis retirées par Stop ; simulateur default/LandscapeLeft rétabli. Aucun profil persistant, reçu, prix, dégât, coût ou paiement modifié. Pas de sauvegarde .rbxl ni publication.

Limites : pas de téléphone/manette physique, multijoueur ou validation de toutes les pages du catalogue. L'adaptation globale à PreferredInput sur PC à écran tactile ou appareils hybrides reste distincte : le comportement existant utilise toujours TouchEnabled pour le layout. Graphify a aidé au repérage puis les sources actuelles ont été comparées ; Context7 a fourni les références d'entrée et de boutons CAS ; Ponytail réutilise les callbacks et ECC encadre les contrôles. [Référence officielle des boutons ContextActionService](https://create.roblox.com/docs/reference/engine/classes/ContextActionService).

Lot du 23 octobre 2026 : **sources installées, validation complète en attente**. Ne pas présenter les sept pages comme visuellement validées. Preuve partielle et diagnostics : studio/qa/portrait-catalog-result.json.

## Implémentation

Un seul script actif modifié : studio/GameHub.client.luau → StarterPlayer.StarterPlayerScripts.GameHub. Copie initiale dans ServerStorage.BeforePortraitCatalog.GameHub. Pas de changement serveur, profil, reçus ou paiements.

portraitCatalog active la fenêtre haute pour les sept pages tactiles lorsque la hauteur dépasse la largeur. La largeur logique reste 720 ; le facteur dépend de la vue réelle. Les catégories sont réparties en deux lignes (quatre puis trois), les actions et la fermeture sont arrondies au pixel logique supérieur pour rester à au moins 44 unités UI après UIScale. Les dimensions inférieures à 100×100 sont ignorées en attendant la première vraie taille de caméra.

Armurerie : cartes 320 de haut, aperçu 128×128, titre et caractéristiques à droite, achat/équipement pleine largeur en bas. Atelier, cadeaux, options et Robux : cartes empilées 300, actions pleine largeur. Pets : fusion et équipement côte à côte. Missions : cartes compactes 190 conservées, dans la nouvelle fenêtre/les nouveaux onglets. Hauteur de carte ajustée si le minimum d'action exige plus de place sur un petit écran. Les mesures minimales annoncées sont des unités de décalage Roblox, pas une mesure physique au doigt.

Lignes et textes plus grands ; icônes décoratives déplacées, barres de progression étendues. Le pied de page portrait utilise une taille de texte fixe et un espace accru. Sa contrainte minimale précédente de 18 empêchait la réduction sous UIScale : minimum ramené à 9, sans changer le texte principal des cartes. Les actions désactivées ne sont ni actives ni sélectionnables ; aucune autorité économique déplacée vers le client.

Le changement de page remet le défilement en haut. Un rafraîchissement de la même page garde sa position, bornée au contenu. Un numéro de rendu empêche une restauration différée d'un ancien rendu de s'appliquer au nouveau. À tester en achat/rotation réels. Hors portrait, les dimensions larges, les icônes d'onglets et les colonnes sont restaurées par layoutWindow.

## Preuves et limites

Retour utilisateur du 23 octobre : la carte s’affiche normalement en cliquant Jouer dans Studio. L’ancien fond noir des captures n’est donc pas un défaut du jeu confirmé chez l’utilisateur. Aucune modification d’éclairage réalisée ; les sept pages et les animations restent à contrôler visuellement.

Parcours Jouer activé à la souris sur une vraie session client : HasStarted false → true / InGameMenu false, sans fixture serveur modifiant le démarrage. Le dernier essai de ce parcours précède uniquement les corrections finales du pied de page et de la garde 1×1. L'essai initial avait cliqué Options en utilisant une correction d'origine inadaptée ; fermeture puis centre absolu brut ont réellement déclenché Jouer. Ne pas généraliser une formule de coordonnées à tous les états de l'outil.

Atelier : titres/descriptions/boutons et onglets mesurés dans une vraie vue iPhone 17 Pro 401×778 ; les contrôles passaient après correction temporaire de la taille minimale du pied de page, persistée ensuite. Les premiers échecs fermeture <44 et footer ont conduit aux corrections. Cela ne valide pas les autres pages ni toutes les versions finales.

La capture ancienne des Options a été inspectée avant la disposition finale des onglets ; aucune nouvelle capture finale n'a abouti. Plusieurs démarrages de client ont ensuite montré une caméra 1×1 et un PlayerGui 800×600/504. Ne pas compter ces mesures comme un échec de géométrie du produit. Les demandes de capture et une entrée souris en attente n'ont pas donné de résultat ; attentes annulées après vérification indépendante de l'état vivant Play et du viewport, sans succès présumé. La tentative Set3dRenderingEnabled était interdite par la capacité RobloxScript et n'a rien changé. Aucun contournement de permission.

Correctif des preuves précédentes : la sélection de preset par `iphone%s*(%d+)` ignorait les espaces insécables des noms localisés et choisissait iphone_7. Les mesures 666×374 / 374×666 du fusil étaient donc sur iPhone 7, pas 17 Pro. docs/reference/ARMES_A_FEU.md, RELAIS_IA.md et shotgun-result.json sont corrigés. Pour sélectionner à nouveau : rechercher iphone dans le nom puis extraire le premier nombre séparément ; lire GetDeviceAsync après sélection et le noter dans le rapport. Ne pas modifier les autres rapports historiques sans leur propre preuve de preset.

## Ajout suivant à inclure dans les captures

Le lot tirs de tête a ajouté le rappel « Armes a feu : tete x1.5 » dans la note d'armurerie, sans changer le layout. Ses dégâts/protocoles ont passé 93 contrôles, mais cette note et la bulle TETE!/ReducedMotion restent visuellement non vérifiées. Le client était toujours 1×1. Voir docs/reference/TIRS_A_LA_TETE.md.

## Disponibilité du rendu au 26 octobre

Le correctif d’orientation des armes a été mesuré avec une vraie caméra PC 1447×801 et iPhone 17 Pro 750×381 / 401×778, puis une capture portrait à l’impact enregistrée. L’ancien blocage 1×1 n’était pas présent dans ce lot. Les sept pages UI restent à reprendre : ces tests ne les couvrent pas.

## Reprise de la validation

1. Redécouvrir Studio, vérifier Edit/Play et que le client a un vrai ViewportSize (>100×100). Vérifier que l'onglet client est visible. Ne pas réinitialiser Play sur le seul dépassement d'une attente.
2. Simuler le vrai iPhone récent avec GetDeviceListAsync et GetDeviceInfoAsync ; noter GetDeviceAsync. Portrait puis paysage et PC ; une seconde largeur portrait 320 est à contrôler. Toujours attendre après les setters et remettre default/LandscapeLeft à la fin.
3. En Play SessionStudio, installer temporairement studio/qa/CatalogLayout.client.luau dans PlayerScripts côté Client. Le BindableFunction PlayerGui.InspectCatalogQA retourne les rectangles/textes/erreurs de la page courante. Il refuse une vue 1×1. Aucun script QA en Edit.
4. Ouvrir chaque page par vrais clics. Lire InspectCatalogQA:Invoke(false) après stabilisation. Pour le bas du catalogue, demander Invoke(true), laisser la disposition se stabiliser puis mesurer à nouveau ; vérifier que la dernière action est atteignable et hors du pied de page. Ne pas attendre RenderStepped à l'intérieur d'une invocation MCP si le client ne rend pas.
5. Préparer seulement le profil de test temporaire via un Script serveur ordinaire : pièces/niveaux/fragments/récompense prête. Acheter vie/vitesse/arme depuis l'UI loin des stands ; fusionner/équiper un pet ; réclamer un cadeau ; basculer une option. Lire les vrais résultats serveur. Contrôler achat verrouillé et Robux désactivés sans lancer un paiement.
6. Contrôler retour paysage/PC, position conservée au rafraîchissement, remise en haut au changement de page, textes longs et ReducedMotion. Capturer les pages finales, puis arrêter Play et auditer 43 scripts.

Références Context7 consultées : [adaptation des interfaces](https://github.com/roblox/creator-docs/blob/main/content/en-us/production/publishing/adaptive-design.md), [ScrollingFrame](https://github.com/roblox/creator-docs/blob/main/content/en-us/ui/scrolling-frames.md), [ViewportSize](https://create.roblox.com/docs/reference/engine/classes/Camera). Codex on Crack doctor : workflow-ready, sans rôle délégué ; travail direct. Panel : state_unreadable, aucune approbation revendiquée.
