# Carabine et prochain palier d'arsenal

Depuis le lot du 27 octobre, la carabine mène au **Fusil du guetteur** niveau 28 / 32 000 pièces. Le dernier palier normal est maintenant la [Mitrailleuse de barrage](MITRAILLEUSE.md), après Marksman ; les chiffres de test ci-dessous restent ceux du lot historique Carbine. Voir [GUETTEUR.md](GUETTEUR.md).

Lot du 26 octobre 2026, en réponse à la demande de rendre la progression plus plaisante. La carabine offre un objectif après le port (niveau 20). La nouvelle carte d'armurerie explique le prochain achat plutôt que demander au joueur de comparer toute la liste : arme cible, niveau actuel/requis, solde/prix, pièces manquantes et achat direct quand tout est réuni.

## Règle de recommandation

`GameplayConfig.NextWeapon(owned)` prend le dernier palier normal possédé dans WeaponOrder et propose le suivant. Les armes premium ne font pas sauter cette progression. Exemple : Poings → Tuyau ; Fusil à pompe → Carabine. Dans le lot historique Carabine seul, la carte indiquait « Dernier palier atteint » sans affirmer que toutes les armes sont collectionnées. Les autres achats restent accessibles.

C'est un parcours de catalogue, pas un classement universel de DPS ou de portée. La barre mesure uniquement le solde de pièces divisé par le prix cible, borné à 100 % ; elle ne représente pas l'XP. Les nombres de niveaux manquants sont séparés. Aucun nouveau multiplicateur, prix d'arme existante, reçu ou champ de profil n'est ajouté.

## Carabine des cendres

| Paramètre | Valeur |
| --- | --- |
| Identifiant | Carbine |
| Niveau / prix | 22 / 18 000 pièces |
| Corps / tête | 38 / 57 dégâts |
| Portée | 175 studs |
| Intervalle / chargeur | 0,24 s / 18 balles |
| Rechargement | 2,4 s, réserve illimitée comme les autres armes |

Modèle distinct avec crosse, garde-main ventilé, poignée avant, rail, viseur décoratif et trois pièces mobiles (Magazine, MagazineBase, BoltHandle). Le viseur ne donne pas de mode zoom. Les deux vues partagent les calculs de mécanismes ; la première personne garde sa réponse immédiate à l'entrée. ReducedMotion limite les déplacements mécaniques à un quart. Les sons réutilisent l'asset métal existant : rapport plus grave, claquement de culasse, trois étapes de recharge ; aucun enregistrement externe ajouté.

Les poses et cycles courts sur le personnage commencent désormais à la réception du ShotFX accepté, pour éviter que la réplication tardive de SwingAt fasse sauter l'animation. Un premier relevé arrivait à environ 0,196 s alors que le cycle de culasse durait 0,13 s. Seule la présentation change : cadence, munitions, raycast, dégâts et récompenses restent serveur. La première personne continue de démarrer localement, sans attendre le réseau.

## Preuves et limites

`studio/qa/carbine-result.json` contient 27 contrôles de combat/progression, dix de présentation et 33 régressions des mécanismes existants réussis, en SessionStudio. Achat refusé au niveau 21/sans budget/sans possession, achat niveau 22 à 18 000 depuis une arène éloignée, doublon non facturé ; chargeur 18 ; 38 dégâts à 160 studs, 57 sur la tête, refus au-delà de 175, derrière un mur et pour un vecteur invalide ; spam limité à une balle, recharge serveur et annulation sans balles gratuites au changement d'arme.

Deux vrais clics ont été acceptés pour la présentation, dont un en mode muet/réduit. Mesures finales : course de chargeur 0,62796 stud, culasse monde observée à 0,12750 stud après réception, course relative de culasse première personne réduite à 0,04443 stud. Une instance GunShot, une CarbineBolt, trois ReloadClick pendant la recharge ; aucun nouveau son de tir pour le clic muet. Cela prouve les instances et mouvements, pas une écoute physique.

UI testée : au niveau 21 avec 9 000 pièces, carte Carbine verrouillée et barre à 50 %. Au niveau 22 avec 22 000 pièces, clic réel sur OBTENIR : Carbine équipée côté serveur et solde 4 000, puis reconnaissance du dernier palier. Captures inspectées de la carte et du modèle catalogue sur PC 1447×824, portrait 401×778 et paysage 750×381 ; titres/descriptions tiennent. Bouton portrait 333,02×48,17 ; paysage 113,66×45,17. Ces contrôles concernent l'armurerie, pas toutes les pages.

Les tentatives sont distinguées dans le rapport : première session avec timeout CorePackages et HUD absent, puis sessions neuves avec HUD présent ; premier cycle monde manqué avant correction de la réception ; premier sampler FPS trop tardif, déplacé avant le clic pour observer la réponse locale. Les régressions ont ensuite passé et la dernière console contrôlée est vide. La condition de démarrage lent n'est pas couverte par une garantie de robustesse générale.

Fichiers actifs : GameplayConfig, WeaponVisuals, WeaponMotion, FistsClient, CharacterCombat, FirearmsClient et GameHub. Backup des sept dans ServerStorage.BeforeCarbine ; sources locales/instances Edit comparées. Aucun nouveau script actif, manifeste toujours 46. Les QA restaurent le profil, les statistiques et la position avant Stop. Simulateur default/LandscapeLeft rétabli. Aucun DataStore de production, paiement Robux, publication ou sauvegarde .rbxl.

Non vérifiés : périphériques physiques, multijoueur, reconnexion DataStore, rendu R6 de toutes les poses ou équilibre par essais de joueurs. Une garde de présence du personnage et de la tête au moment du son de culasse différé a été ajoutée puis compilée après les tests ; la mort dans cette fenêtre de 80 ms n'a pas de test dédié. Graphify a servi au repérage du snapshot puis les sources actuelles ont été relues ; Context7 a confirmé les contrôles de tirs côté serveur. Ponytail réutilise services, catalogue, modèles et animations existants ; ECC guide les contrôles ciblés. [Référence officielle de validation des tirs](https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/intermediate-scripting/hit-detection-with-lasers).
