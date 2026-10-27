# Amélioration Souffle

L'ATELIER propose une troisième amélioration permanente, Souffle, achetable en pièces depuis l'interface où que l'on soit. Elle augmente le réservoir d'endurance de 20 par achat, de 100 à 200. Elle profite à tous les usages de la même réserve : sprint, dash, déplacements avancés et capacités. Aucun coût, délai, vitesse ou taux de régénération n'est modifié.

| Achat | Prix | Maximum obtenu |
| --- | --- | --- |
| 1 | 250 | 120 |
| 2 | 475 | 140 |
| 3 | 902 | 160 |
| 4 | 1 714 | 180 |
| 5 | 3 258 | 200 |

À réserve pleine, les règles de sprint autorisent donc 10 secondes de consommation continue au dernier palier au lieu de 5 : 20 points/seconde. Régénération inchangée à 18 points/seconde après 1,25 seconde de repos ; récupération d'épuisement au seuil fixe existant de 25. Les contraintes de mouvement/menu/état du personnage restent appliquées par le serveur.

Un achat ajoute uniquement les 20 nouveaux points au stock courant. Par exemple 95/120 devient 115/140 ; rafraîchir le profil ne remplit pas le réservoir. Une réapparition restitue le maximum acheté ; une réduction de capacité de test borne le stock au nouveau maximum.

## Repère d’achat

Le raccourci vers l’atelier affiche « ATELIER ! » lorsqu’au moins une amélioration Vie, Vitesse ou Souffle est achetable avec les pièces du joueur. Il reprend son libellé ordinaire quand aucune ne l’est. Le `+N` sur le raccourci tactile continue à compter les cadeaux disponibles. Le repère utilise l’état transmis au client ; le serveur reste responsable du prix et de l’achat.

En SessionStudio : 99 pièces sans repère, 100 avec ; une requête d’achat Vie depuis le client a donné 120 PV et zéro pièce, puis retiré le repère. Souffle seul à 250 a activé le repère ; tous les paliers au maximum l’ont masqué. TextFits et captures iPhone simulé portrait/paysage ; aucun clic d’achat natif ni tactile physique dans cette passe. Fixture et rapport `studio/qa/AffordableUpgradeHint.server.luau` et `affordable-upgrade-hint-result.json`. Source GameHub synchronisée, backup `BeforeAffordableUpgradeHint`.

## Sources et données

- GameplayConfig : Upgrades.Stamina, cinq paliers, prix floor(250×1,9^niveau).
- EconomyService : Meta.StaminaLevel normalisé entre 0 et 5, défaut 0 pour les profils anciens. Même requête Upgrade et contrôles serveur que Vie/Vitesse, débit au prix calculé, refus au maximum. StaminaCapacity est publié par le serveur ; GameState contient StaminaLevel. L'attribution des clés existantes reste HealthLevel/SpeedLevel.
- SprintState : maxStamina appartient à l'état de chaque joueur, régénération bornée par ce maximum ; fallback standard 100 pour les anciens états de test.
- SprintServer : applique la capacité serveur avant la mise à jour de mouvement ; ajoute la différence positive uniquement quand le maximum change et borne les diminutions. Publie MaxStamina sur le personnage. Ne pas utiliser une capacité fournie par une requête client.
- GameHub : troisième carte avec image de cristal existante, barre du palier, coût/maximum, signature incluant StaminaLevel. Le client Sprint existant lit déjà MaxStamina et affiche la bonne fraction, aucun changement de son/animation requis.

Le champ est inclus dans le payload Meta existant de ProgressionService, sans réinitialisation de données ni des reçus. Reconnexion DataStore non testée : seule la sérialisation JSON a été vérifiée dans cette passe.

## Preuves du 27 octobre

26 contrôles serveur réussis par scripts ordinaires SessionStudio : anciens profils à zéro, réserve initiale, fonds insuffisants, cinq prix exacts, achat loin du stand, maximum, entrées falsifiées, régressions Vie/Vitesse, reçus JSON, nouveau jour, règles pures de drain/régénération, réapparition réelle et diminution de capacité. Un dash transmis par le vrai remote consomme 25 de 120 ; l'achat suivant donne 115/140 et les rafraîchissements suivants ne rechargent pas.

Un clic natif PC achète Souffle : 1 000→750 pièces, palier 1, maximum/HUD 120/120, prochain prix 475. Trois snapshots UI réussis PC 1447×824, portrait 401×778, paysage 750×381 : trois cartes, TextFits, actions contenues et cibles tactiles >=44 px. Captures PC/portrait inspectées ; pas de capture paysage inspectée ni de tactile physique. Console finale vide. Pas d'essai multijoueur, réseau dégradé ou écoute audio. Les tests remplacent une fois le personnage de la session ; métadonnées, statistiques et position sont restaurées avant Stop.

QA : créer StaminaUpgradeQABridge (RemoteFunction) en Play, installer StaminaUpgradeBridge.client.luau, puis StaminaUpgrade.server.luau comme Script temporaire ordinaire. Lire ServerStorage.StaminaUpgradeQAResult. Pour les essais UI : PrepareStaminaUpgradeUI, ReadStaminaUpgradeQA, puis RestoreStaminaUpgradeQA obligatoirement. Restaurer default/LandscapeLeft et arrêter Play. Aucun QA en Edit. Rapport stamina-upgrade-result.json ; sauvegarde avant modification ServerStorage.BeforeStaminaUpgrade, cinq scripts.
