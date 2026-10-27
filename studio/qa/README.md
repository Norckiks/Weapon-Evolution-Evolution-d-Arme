# Tests Studio uniquement

## HUD critique et raccourcis adaptatifs

En Play SessionStudio, installer MaximumHUD.server, appeler `PrepareMaximumHUD:Invoke(false)` ; CriticalHUD.client fournit six contrôles et restaure ses valeurs locales. ResponsiveShortcuts.client prend un snapshot PC, téléphone paysage, portrait et retour PC ; supprimer son résultat local avant chaque nouvelle sonde. `RestoreMaximumHUD:Invoke()` impératif avant Stop, puis simulateur default/LandscapeLeft. Rapport critical-responsive-hud-result.json et guide UI_MOBILE.md. Ne jamais installer en Edit.

## Réapparition et contrat Ville

En Play SessionStudio, exécuter CityRespawn.server comme Script temporaire et lire CityRespawnQAResult ; puis CityContractPacing.server et lire CityContractPacingQAResult. Le second restaure Meta/statistiques/flags/santé ; Stop efface les morts de zombies et les séries temporaires. Rapport city-respawn-result.json, guide CONTRATS_EXPRESS.md. Ne jamais installer en Edit.

## Parcours portail Usine

En Play SessionStudio après Jouer, installer PortalWalk.server comme Script temporaire. Parcourir l’entrée au niveau 1, puis `SetPortalWalkLevel:Invoke(5)` avant l’entrée et le retour au clavier. Appeler `RestorePortalWalkQA:Invoke()` avant Stop. Rapport portal-walk-result.json, guide ZONES.md. Ne pas installer en Edit.

## Repère d’achat de l’atelier

En Play SessionStudio, installer AffordableUpgradeHint.server comme Script temporaire. `SetAffordableUpgradeHint:Invoke("Low"/"Exact"/"Stamina"/"Maxed")` prépare les cas ; inspecter le raccourci client, puis impérativement `RestoreAffordableUpgradeHint:Invoke()` avant Stop. Rapport affordable-upgrade-hint-result.json, guide ENDURANCE.md. Jamais en Edit.

## Lisibilité du HUD téléphone

En Play SessionStudio après démarrage et stabilisation du simulateur, exécuter ReadableMobileHUD.client comme LocalScript temporaire ; lire PlayerGui.ReadableMobileHUDQAResult. Rejouer en portrait et paysage avec ContextButtonFrame visible et masqué. Quatre snapshots (14+14+23+23) : readable-mobile-hud-result.json. Stop et remise du simulateur à default/LandscapeLeft. Ne rien installer en Edit.

## Animation de vie

En Play SessionStudio, exécuter HUDHealthMotion.client comme LocalScript temporaire et lire PlayerGui.HUDHealthMotionQAResult. Quatre contrôles, restauration santé/max/option automatique puis Stop. Rapport hud-health-motion-result.json ; voir docs/reference/UI_MOBILE.md. Ne rien installer en Edit.

## Cour du refuge

En Play SessionStudio, exécuter RefugeCourtyard.server comme Script temporaire et lire ServerStorage.RefugeCourtyardQAResult. 14 contrôles, rapport refuge-courtyard-result.json. Le constructeur BuildRefugeCourtyard est ponctuel en Edit et ne doit jamais démarrer comme script. Voir docs/reference/REFUGE.md.

## Élites

En Play SessionStudio uniquement : RemoteFunction EliteQABridge, EliteBridge.client dans PlayerGui, puis Elites.server comme Script temporaire. Lire ServerStorage.ElitesQAResult : le harnais restaure ses données et sa caméra, puis arrêter Play pour effacer les compteurs temporaires de chasse. Les morts sont attribuées par le harnais, pas par des attaques utilisateur. 59 contrôles passés : elites-result.json.

## Rangs de pets

Play SessionStudio : LevelRewardsQABridge + PetRanksBridge.client (rafale dans un seul callback), puis Script ordinaire PetRanks.server. Lire PetRanksQAResult (48). PreparePetRankUI Ready/RankOnly/Locked/Max ; poser PetRanksQAPhase côté client pour PetRanksUI.client (42 assertions cumulées). RankOnly ne rouvre pas la page. Retirer l’attribut et appeler RestorePetRanksQA avant Stop. Rapport pet-ranks-result.json, guide EVOLUTION_PETS.md. Ne pas installer ces QA en Edit.


## Mitrailleuse

Play SessionStudio : FirearmsQABridge/FirearmsBridge.client, puis LMG.server (30). Pour moteurs : LMGMotionBridge + LMGMotion.client puis LMGMotion.server (19), restitutions automatiques. LMGCatalog.server prépare34/35, ReadLMGCatalog lit l’état par service ordinaire ; RestoreLMGCatalog impératif avant Stop après tests manuels. Carbine.server actualisé28 checks. Rapport lmg-result.json et guide MITRAILLEUSE.md. Aucun QA en Edit/démarrage.


## Métro

Play SessionStudio : MetroQABridge + MetroBridge.client puis Metro.server (55 checks, rapport metro-spawn-fix-result.json), restitution automatique et RestoreMetroQA après toute préparation manuelle. MetroCombatQABridge + MetroCombatBridge.client puis MetroCombat.server (3 vrais tirs) séparément. Régressions séquentielles : ContractZones (55) et LevelRewards (35), avec LevelRewardsQABridge/LevelRewardsBridge.client. Jamais ces QA en Edit. Constructeur BuildMetroExpansion ponctuel uniquement Edit, pas en démarrage. Rapport metro-result.json et guide METRO.md.


## Décharge

Play SessionStudio : créer ArcQABridge, installer ArcBridge.client puis Arc.server comme Script ordinaire. Respecte les vrais délais20s entre les trois activations (environ45s). Lire ArcQAResult ; restitution automatique. Ensuite ArcRegression.server (six contrôles module), AbilityBindings.client (neuf bindings/conflits). Rapport arc-result.json et guide DECHARGE.md. Ne pas installer en Edit.


## Calendrier de connexion

Play SessionStudio : LevelRewardsQABridge + LevelRewardsBridge.client, puis Script ordinaire LoginCalendar.server. Lire ServerStorage.LoginCalendarResult (41 checks). PrepareLoginCalendarUI(Ready/Claimed/Full), définir LoginCalendarQAPhase côté client puis exécuter LoginCalendarUI.client (5 assertions/cas), retirer l’attribut puis RestoreLoginCalendarQA impérativement avant Stop. Aucun test de reconnexion réelle ou de passage réel à minuit. Rapport login-calendar-result.json et guide CONNEXION.md.


## Guetteur et régression carabine

Play SessionStudio uniquement. FirearmsQABridge + FirearmsBridge.client puis Marksman.server ou Carbine.server comme Script ordinaire ; résultats MarksmanQAResult/CarbineQAResult. Marksman restaure automatiquement et laisse PrepareMarksmanUI(27/28) et RestoreMarksmanQA. Pour le modèle porté : RemoteFunction MarksmanMotionBridge, LocalScript MarksmanMotion.client puis Script MarksmanMotion.server ; lire MarksmanMotionResult, restitution automatique. Caméra temporaire et échantillonnage Heartbeat, pas de preuve FPS. Guides/preuves dans GUETTEUR.md ; ne jamais installer ces scripts en Edit.


## Primes express par zone

En Play SessionStudio : LevelRewardsQABridge et le pont générique LevelRewardsBridge.client.luau, puis ContractZones.server.luau comme Script temporaire ordinaire. Lire ContractZonesQAResult (49 checks). UI : PrepareContractZoneUI(multiplier,count), puis RestoreContractZoneQA avant Stop. Contrats Ville : Contracts.server.luau (sept régressions). Trois contenus de texte UI vérifiés ; pas de preuve visuelle ou mobile. Rapport contract-zones-result.json et guide CONTRATS_EXPRESS.md.

## Première chasse du jour

En Play SessionStudio : créer LevelRewardsQABridge, installer le pont générique LevelRewardsBridge.client.luau puis FirstDailyHunt.server.luau comme Script temporaire ordinaire. Lire ServerStorage.FirstDailyHuntQAResult (21 checks). Préparation UI : PrepareFirstHuntUI:Invoke(Locked/Ready/Claimed/Full), puis RestoreFirstHuntQA:Invoke() impérativement. Quatre propriétés de carte vérifiées, rendu nul : pas de preuve visuelle/clic. Rapport first-daily-hunt-result.json et guide PREMIERE_CHASSE.md. Ne rien installer en Edit.

## Cadence du HUD

En Play SessionStudio : HubStatus.server.luau comme Script temporaire, puis HubStatus.client.luau. Lire PlayerGui.HubStatusQAResult, appeler ServerStorage.RestoreHubStatusQA:Invoke(), puis Stop. Six checks de propriétés/cadence avec rendu nul ; rapport hub-status-result.json et guide HUD_CADENCE.md. Les transitions de menu/options enregistrées sont provoquées par attributs, pas des preuves d'interaction clavier ou de rendu. Ne pas installer en Edit.

## Centrale foudroyée

Voir docs/reference/CENTRALE.md avant reprise : rendu Play inactif lors de cette passe. QA uniquement en SessionStudio : RemoteFunction PowerQABridge, PowerBridge.client.luau puis Power.server.luau comme Script ordinaire. Résultat PowerQAResult (49 contrôles), bindables PreparePowerQA et RestorePowerQA pour les approches de portails. Tirs séparés : PowerCombatQABridge, PowerCombatBridge.client.luau puis PowerCombat.server.luau, résultat PowerCombatQAResult (trois vrais tirs). Métadonnées/statistiques/position restaurées, Stop après essais. Portails natifs, nouveaux pets/UI et captures rapprochées Play restent à vérifier quand RenderStepped reprend. Les scripts QA Harbor ont reçu un correctif de nombre minimum de zones et de vitesse SprintConfig au lieu d'une ancienne constante 16 ; leur harnais complet n'a pas été rejoué dans ce lot.

## Amélioration Souffle

En Play SessionStudio : créer RemoteFunction StaminaUpgradeQABridge, installer StaminaUpgradeBridge.client.luau, puis StaminaUpgrade.server.luau comme Script temporaire. Lire ServerStorage.StaminaUpgradeQAResult. Le test inclut une réapparition réelle ; profil/statistiques/position restaurés. Pour l'UI, PrepareStaminaUpgradeUI:Invoke(), ReadStaminaUpgradeQA:Invoke(), puis RestoreStaminaUpgradeQA:Invoke(). Réinitialiser simulateur et Stop. Résultats dans stamina-upgrade-result.json, règles dans docs/reference/ENDURANCE.md. Ne pas installer en Edit.

## Primes de niveau

Le harnais courant couvre dix primes jusqu'au niveau 28 et trois frontières du plafond de pièces (34 contrôles). `level-rewards-capacity-result.json` conserve cette passe et deux contrôles des propriétés du bouton client ; rendu inactif, aucune validation visuelle ajoutée. Le rapport initial à neuf primes reste historique.

Créer LevelRewardsQABridge (RemoteFunction) en Play, installer LevelRewardsBridge.client.luau et LevelRewards.server.luau comme scripts temporaires ordinaires. SessionStudio obligatoire. Lire ServerStorage.LevelRewardsQAResult ; 34 contrôles actuels, restauration automatique après le test serveur. Pour des essais UI, PrepareLevelRewardUI:Invoke(niveau 1 ou niveau de prime), ReadLevelRewardQA:Invoke(), puis impérativement RestoreLevelRewardQA:Invoke(). Réinitialiser simulateur et arrêter Play. Rapport courant level-rewards-capacity-result.json, rapport initial level-rewards-result.json ; détails PRIMES_DE_NIVEAU.md. Ne rien installer en Edit.

## HUD compact et images cartoon

`CompactCartoonUI.client.luau` : snapshot en lecture seule, uniquement en Play, après ouverture d'un onglet et stabilisation du simulateur. Contrôle dimensions, trois images chargées, TextFits et boutons contenus dans les cartes ; cible tactile minimale de 44 px. Pour changer de page, employer les vrais boutons ou B/N/G (réappuyer sur le raccourci de la page courante ferme le menu). Aucun ajout aux scripts actifs. Résultats et limites dans `compact-cartoon-ui-result.json` et `docs/reference/UI_MOBILE.md`.

## Carabine et objectif d'arsenal

Session Play neuve SessionStudio : créer FirearmsQABridge (RemoteFunction) côté serveur, installer FirearmsBridge.client.luau, puis Carbine.server.luau comme Script temporaire. Lire ServerStorage.CarbineQAResult (27 contrôles lors de la passe enregistrée). Le profil, les statistiques et la position sont restaurés après le pcall. Ne pas installer en Edit.

Pour la présentation, préparer une arène avec profil restaurable (IdeasMovement.server.luau), accorder/équiper Carbine et niveau 22 dans ce snapshot. Installer CarbinePresentation.client.luau ; à PlayerGui.CarbinePresentationQAResult == AwaitNativeShot, cliquer une fois ; à AwaitQuietNativeShot, cliquer une seconde fois. Le sampler FPS se connecte avant ce second clic pour ne pas manquer l'animation locale pendant la latence serveur. Lire le JSON final (dix contrôles). Appeler ServerStorage.RestoreIdeasQA:Invoke(), restaurer le simulateur et arrêter Play après les essais UI. WorldMechanisms.server/client couvre les 33 régressions de revolver/pompe avec le nouveau timing de réception. Résultat complet dans carbine-result.json ; guide PROGRESSION_ARMES.md pour les preuves et limites.

## Changements de format en cours de session

En Play SessionStudio après Jouer/Entrée/A et hors menus, installer temporairement `ResponsiveHUD.client.luau` dans PlayerScripts. Lire PlayerGui.ResponsiveHUDQAResult (six assertions en tactile, quatre en PC). Rejouer après chaque mode PC/portrait/paysage et attendre que le viewport ait changé ; les sept boutons CAS doivent exister sans duplication. `AbilityBindings.client.luau` vérifie aussi les huit conditions de raccourcis, y compris l'absence de collision avec SurvivalStart. Rapport `responsive-hud-result.json` ; arrêt de Play et simulateur default/LandscapeLeft à la fin.

Pour diagnostiquer les clics, une sonde ordinaire InputBegan doit accepter Touch et MouseButton1 : le simulateur téléphone convertit la souris en tactile. Comparer les coordonnées réellement reçues aux objets de GetGuiObjectsAtPosition avant de déclarer un bouton défectueux. Ne pas supposer qu'un `Success` de l'outil a activé le bouton. ButtonStart n'est pas arrivé dans la sonde de cette passe ; A et Entrée, oui.

## Commandes de capacités

Dans une session Play SessionStudio avec tous les contrôleurs chargés, installer temporairement `AbilityBindings.client.luau` dans PlayerScripts. Lire PlayerGui.AbilityBindingsQAResult : sept mappings clavier/manette et aucune collision parmi les actions Survival/Survivor/Fists. Cela vérifie les bindings, pas des périphériques physiques.

Le rapport `ability-controls-result.json` ajoute des entrées natives enregistrées par un observateur serveur et le clic mobile sur une Égide sélectionnée. Pour rejouer : préparer un personnage niveau 20 au sol en Ville dans une fixture SessionStudio restaurable, équiper un pistolet et retirer une balle ; observer les transitions GunReloading autour de R, puis AbilityId/ReadyAt autour de T, J et DPadLeft. Préparer la simulation mobile avant de démarrer Play pour tester le sélecteur ; trois clics depuis ONDE choisissent Égide. Confirmer GuardUntil/délai serveur après le clic principal. Restaurer profil/personnage et simulateur, puis arrêter Play. Ne jamais installer ces QA en Edit ou en public.

## Mécanismes en troisième personne

En Play neuf SessionStudio, cliquer Jouer puis installer `WorldMechanisms.server.luau` temporairement dans ServerScriptService. Installer `WorldMechanisms.client.luau` dans PlayerScripts ; attendre ClientReady côté Client sur ReplicatedStorage.WorldMechanismsQABridge. Côté serveur, définir l'attribut Run de cette RemoteFunction à true. Lire ServerStorage.WorldMechanismsQAResult jusqu'au résultat final (33 assertions lors de la passe enregistrée). Le harnais accorde des armes au profil temporaire, teste de vrais tirs et rechargements, échantillonne les mécanismes et isole la pose Slam côté client pour ReducedMotion. Il restaure le profil et enlève la plateforme même après une assertion en échec ; arrêter Play après lecture. Ne jamais installer en Edit ou en public.

Le repos après rechargement se contrôle sur LastPosition/LastAngle : les maxima peuvent inclure la première frame encore ancienne. L'essai de pompe demande une cadence de rendu suffisante pour observer son mouvement de .22 à .65 s après le tir. Résultat `world-mechanisms-result.json`, portée et limites dans `docs/reference/ANIMATIONS_ARMES.md`.

## Idées : vitesse, course et vue

En Play SessionStudio uniquement : installer `IdeasMovement.server.luau` comme Script serveur temporaire. Lire `ServerStorage.IdeasMovementQAResult` (cinq assertions) ; ce harnais laisse une arène et un profil préparé au pistolet. Installer `IdeasRun.client.luau` temporairement dans PlayerScripts puis maintenir W/Maj au moins 2 s pour échantillonner les vrais déplacements. Lire `PlayerGui.IdeasRunQAResult`. Pour un second passage, supprimer le résultat précédent ou définir l'attribut ResultName du script, replacer le personnage au départ et dégager la piste. Confirmer ReducedMotion avant un essai réduit. L'angle total inclut Animator et ne mesure pas isolément l'atténuation ajoutée.

À la fin, appeler `ServerStorage.RestoreIdeasQA:Invoke()` pour restaurer le profil et enlever l'arène, puis arrêter Play. Ne pas installer ces scripts en Edit. `Expansion.server.luau` vérifie les bonus avec la base SprintConfig ; `Movement.server.luau` couvre glissade/franchissement. Résultats du lot dans `ideas-result.json`, explications et limites dans `docs/reference/IDEES_IMPLEMENTEES.md`.

## Fusil à pompe

Dans une session Play neuve SessionStudio, créer FirearmsQABridge et installer FirearmsBridge.client.luau côté Client. Exécuter d'abord Firearms.server.luau (33 régressions), puis Shotgun.server.luau (30 contrôles, chargeur du fusil encore neuf), puis ShotgunKill.server.luau (cinq contrôles et vraie mort Civilian). Lire les StringValue FirearmsQAResult, ShotgunQAResult et ShotgunKillQAResult dans ServerStorage. Un seul harnais à la fois. Après préparation d'un personnage démarré/équipé avec un chargeur plein, ShotgunPresentation.client.luau attend un vrai clic de tir pendant 90 s, puis teste pompe, effets et deux recharges. Lire PlayerGui.ShotgunPresentationQAResult. Son compteur final comprend trois tirs (un natif, deux remotes de test), dont un muet ; ses assertions intermédiaires vérifient un événement/flash/son et sept traceurs pour le premier tir.

Fixtures temporaires uniquement, arrêter Play après tous les essais même en cas d'échec. Les achats des harnais passent par le service économique ; l'achat par clic PC et TIR simulé ont été vérifiés séparément. Rapport shotgun-result.json. Aucun test production ou tactile/manette physique.

## Dossiers d'expédition

Créer ExpeditionsQABridge (RemoteFunction) dans ReplicatedStorage serveur Play. Installer ExpeditionsBridge.client.luau dans PlayerScripts côté Client, puis Expeditions.server.luau comme Script serveur temporaire. Lire ServerStorage.ExpeditionsQAResult jusqu'au JSON final. Le harnais modifie le profil temporaire, attribue un décès à un vrai zombie et teste douze réclamations par le vrai remote client ; il restaure ensuite le profil. Arrêter Play même en cas d'échec. Résultats et captures inspectées décrits dans expeditions-result.json et docs/reference/EXPEDITIONS.md. La sérialisation JSON n'est pas un test de reconnexion DataStore.

Coordonnées d'entrée : la correction d'origine ci-dessous est spécifique au téléphone simulé testé. Sur PC, le centre absolu sans cette correction a fonctionné pour le bouton de dossier ; le centre corrigé n'a pas réclamé la récompense. Toujours vérifier le changement serveur, ne pas généraliser une seule formule à tous les simulateurs.

## Capacités et animations

Dans une session Play SessionStudio, installer temporairement Abilities.server.luau comme Script serveur. Attendre ReplicatedStorage.AbilitiesQAControl == "ReadyFrost", puis côté Client appeler UseAbility:FireServer("Frost", Vector3.new(0,0,-1)). Quand l'état passe à ReadyAegis, appeler UseAbility:FireServer("Aegis"). Le harnais mesure une cible à 58 studs, hors axe/hors portée, la garde pendant l'attaque et le retour des dégâts à son expiration. Lire ServerStorage.AbilitiesQAResult.

Pour le soin et la frappe, utiliser AbilityVisuals.server.luau, attendre ReadyHeal puis envoyer UseAbility:FireServer("SecondSouffle"); attendre ReadySlam, puis envoyer UseAbility:FireServer("Slam"). Lire ServerStorage.AbilityVisualsQAResult. Compter les instances d'effet dans Workspace.LocalPulseFX côté Client pendant leur courte durée : en rendu normal, le soin ajoute 12 étincelles et 8 segments de halo ; la frappe ajoute 12 fissures et 12 segments de vague. Ces deux harnais restaurent le niveau, les PV et le pivot ; arrêter Play après lecture des résultats. Ils ne doivent jamais être installés en Edit.

## Onde de choc et coordonnées du simulateur

Créer PulseQABridge (RemoteFunction) dans ReplicatedStorage côté serveur Play, puis installer PulseBridge.client.luau comme LocalScript temporaire dans PlayerScripts **côté Client**. Installer Pulse.server.luau comme Script serveur temporaire et lire ServerStorage.PulseQAResult jusqu'au JSON final. Ce harnais utilise une vraie réapparition, des cibles factices et de vrais zombies ; il respecte le délai privé existant au lieu de le réinitialiser. Restaurer les options, puis arrêter Play même en cas d'échec. Aucun de ces fichiers n'est installé en Edit.

Pour les clics automatiques sur un téléphone simulé, le centre AbsolutePosition + AbsoluteSize/2 peut inclure une origine de ScreenGui décalée (ici Y=-58). Le ciblage par instance_path n'a pas atteint le bouton pendant ces essais. Les coordonnées qui ont fonctionné sont : **centre absolu du bouton − AbsolutePosition du ScreenGui ancêtre**, envoyées explicitement à moveTo, avec attente puis mouseButtonDown/attente/mouseButtonUp. Confirmer Activated ou la transition serveur ; « Success » du seul outil ne prouve pas le clic.

Le verrouillage de souris de la vue subjective peut nécessiter, pour le test souris en émulation mobile, une libération temporaire après Camera. Cette fixture doit être retirée ; ne pas modifier les contrôles mobiles du jeu pour compenser l'outil. Le clic portrait ONDE a été confirmé avec FistsPunch d'origine. Le clic Jouer a été confirmé depuis un menu préparé, pas comme essai physique ou démarrage initial sans fixture. Résultats pulse-result.json.

## Extension du port

Harbor.server.luau est un Script serveur temporaire SessionStudio : contrôles de scène/spawns, accès 19/20, vrais callbacks de morts avec dégâts létaux attribués par le test, fragments et fusion, bonus et réapparition. HarborCombat.server.luau exige le pont Firearms côté Client et sa RemoteFunction : tirs réels dans le port, recharge et récompenses d'un matelot. Il ancre temporairement les racines des zombies du port et restaure leurs états ; arrêter Play après le test, y compris en cas d'échec. Résultats ServerStorage.HarborQAResult et HarborCombatQAResult. Consulter harbor-result.json pour les preuves obtenues et les limites.

Ne jamais installer ces fichiers en Edit ou les publier. Exécuter un seul harnais à la fois sur un joueur Studio chargé, avec PersistenceMode=SessionStudio. Ils modifient temporairement inventaire, monnaie, personnage et état de menu. Arrêter Play à la fin même en cas d'échec.

## Armes

Le harnais Firearms couvre maintenant Pistolet, SMG et Revolver (33 contrôles dans revolver-result.json). Après préparation d'un personnage démarré et équipé du revolver en SessionStudio, RevolverPresentation.client.luau peut être installé comme LocalScript temporaire dans PlayerScripts côté Client : il tire/recharge deux fois, échantillonne la pose réellement rendue et les étapes sonores, puis restaure ReducedMotion/SFXEnabled. Résultat PlayerGui.RevolverPresentationQAResult. Les munitions de session sont consommées puis rechargées ; arrêter Play après essai. Ne jamais installer ce sampler en Edit.

1. Partir d'une session Play neuve : les chargeurs sont propres à la session.

2. Créer en serveur Play une RemoteFunction nommée FirearmsQABridge dans ReplicatedStorage.

3. Installer temporairement FirearmsBridge.client.luau comme LocalScript dans PlayerScripts ; attendre sa liaison.

4. Installer Firearms.server.luau comme Script temporaire dans ServerScriptService.

5. Lire ServerStorage.FirearmsQAResult jusqu'à obtention du JSON final. Lire aussi la console si le résultat reste Running.

6. Arrêter Play pour supprimer le pont et les scripts temporaires. Le pont n'est pas un composant du jeu.

Le pont permet au harnais serveur de demander de vraies émissions client. RemoteEvent:FireServer ne fonctionne pas dans un Script serveur. La rafale est émise en un seul appel client, pour éviter que la latence des allers-retours transforme le test en tirs espacés.

## Autres harnais

Expansion.server.luau, Movement.server.luau et Contracts.server.luau s'exécutent en Script serveur temporaire. Leurs résultats sont respectivement ExpansionQAResult, MovementQAResult et ContractsQAResult dans ServerStorage. Attendre la fin et la restauration de chaque harnais avant de lancer le suivant.

Les résultats JSON sont datés et limités à leur scénario. Ils ne prouvent pas le rendu visuel, le multijoueur, la persistance réelle ni la fluidité sur toutes les cartes/appareils. Le nombre de contrôles Expansion peut varier avec les fragments aléatoires inspectés.

## Séries d'éliminations

Pour connaître les différences actuelles entre disque et Studio, lire handoff-audit-latest.json : les 40 scripts correspondent désormais aux fichiers locaux, y compris Expeditions. Les audits datés antérieurs sont historiques.

## Terrain et guide de zone

TerrainMovementBridge.client.luau se lie à une RemoteFunction temporaire TerrainMovementQABridge dans ReplicatedStorage. TerrainVaults.server.luau demande de vrais FireServer client sur cinq obstacles permanents, ou huit lorsque le port existe. Installer uniquement en Play de test et lire TerrainVaultsQAResult dans ServerStorage. Le pont est détruit à la fin du harnais : pour répéter, recréer la RemoteFunction et son LocalScript client. TerrainLocomotion.server.luau porte un attribut ZoneId (City/Factory/Lab/Harbor) ; après TerrainLocomotionReady, piloter immédiatement avec Maj+W, C puis Ctrl après la glissade. Lancer le sampler et les entrées dans une seule séquence d'outils pour éviter de dépasser sa fenêtre de mesure. Relâcher toutes les touches avant un autre harnais. Résultat TerrainLocomotionQA_<Zone>. Arrêter Play ensuite.

zone-guide-result.json conserve les états des guides et les mesures iPhone simulé paysage/portrait. Les captures montrent la flèche écran ; Enabled/Adornee du Billboard ne prouvent pas son rendu visible. Les niveaux de test sont réservés à SessionStudio. La console du dernier contrôle contenait seulement une assertion de fixture corrigée avant mutation, et ne doit pas être décrite comme vide.

KillChains.server.luau s'exécute en Script serveur temporaire après chargement du profil SessionStudio. Il attend les vraies échéances de huit secondes et tue/réapparaît le personnage de test. Lire ServerStorage.KillChainsQAResult. Il conserve puis restaure Meta, monnaie, XP, niveau, position et préférences de menu ; arrêter Play après lecture pour supprimer tous les effets temporaires. Les callbacks synthétiques vérifient le cycle du compteur, pas l'attribution d'une vraie élimination par ZombieDirector. Le résultat du 22 octobre est kill-chains-result.json. notification-layout-result.json couvre la passe UI ultérieure sur PC et téléphone simulé : gains/séries, fragments, boosts et munitions simultanés, avec mesures des rectangles et captures inspectées. pending-studio-sync.json est historique.

## Navigation souris M

mouse-navigation-result.json contient les 11 contrôles de la passe du 22 octobre. Pour reproduire les interactions, utiliser une session Studio PC neuve et les outils d'entrée utilisateur :

1. Cliquer JOUER, appuyer sur M ; vérifier MouseUnlocked=true, MouseUnlockButton.Modal=true, pointeur visible et MouseBehavior.Default pendant 30 images.

2. Cliquer Options : la fenêtre Options doit s'ouvrir, et non la boutique située plus bas. M reste inactif pendant ce menu ; sa fermeture remet le pointeur au centre.

3. En mode souris libre, maintenir le clic : aucun SwingAt serveur et aucune balle de pistolet ne doivent être consommés. Tester ensuite la reprise avec M.

4. Une sonde temporaire peut interrompre la préparation d'un coup par MouseUnlocked=true puis false après 20/30 ms ; vérifier que le son de préparation existe mais qu'aucune frappe différée n'arrive au serveur. Cette sonde est synthétique, distincte d'un essai humain de rapidité.

5. Réapparaître : le mode doit être réinitialisé. Configurer ensuite le téléphone simulé avant Play : bouton M masqué et modalité inactive, même après une touche M virtuelle.

Les profils utilisés doivent rester SessionStudio. L'armement temporaire du pistolet et la réapparition sont des fixtures ; arrêter Play après les contrôles. La libération du pointeur ne suspend pas le monde et ne change aucune validation serveur de combat.


## Panneau admin personnel
Dans une session Studio Play du compte autorisé, installer temporairement Admin.server.luau dans ServerScriptService. Lire ServerStorage.AdminQAResult ; le script restaure le profil même en cas d'échec. Arrêter Play après. Ne jamais installer en Edit. Résultat : admin-result.json ; limites et essais client dans docs/reference/ADMIN_PANEL.md.
