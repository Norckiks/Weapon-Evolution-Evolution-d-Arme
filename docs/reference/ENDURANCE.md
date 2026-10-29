# Amélioration Souffle

L'ATELIER propose Souffle, achetable en pièces depuis l'interface où que l'on soit. Chaque rang augmente le réservoir et continue au-delà des cinq premiers achats présentés ci-dessous. Les bénéfices restent linéaires jusqu'au rang 25, puis croissent avec des rendements décroissants. Le prix suit `floor(250 × 1,9^rang)` et s'arrête au plafond sûr de 2 000 000 000 pièces, égal au portefeuille maximal existant. L'endurance améliorée sert au sprint, au dash, aux déplacements avancés et aux capacités ; le coût, le délai et le taux de régénération restent inchangés.

| Achat | Prix | Réserve après achat |
| --- | --- | --- |
| 1 | 250 | 120 |
| 2 | 475 | 140 |
| 3 | 902 | 160 |
| 4 | 1 714 | 180 |
| 5 | 3 258 | 200 |

À réserve pleine, les règles de sprint autorisent donc 10 secondes de consommation continue après le cinquième achat au lieu de 5 : 20 points/seconde. Régénération inchangée à 18 points/seconde après 1,25 seconde de repos ; récupération d'épuisement au seuil fixe existant de 25. Les contraintes de mouvement/menu/état du personnage restent appliquées par le serveur.

Un achat ajoute uniquement les 20 nouveaux points au stock courant. Par exemple 95/120 devient 115/140 ; rafraîchir le profil ne remplit pas le réservoir. Une réapparition restitue le maximum acheté ; une réduction de capacité de test borne le stock au nouveau maximum.

## Repère d’achat

Le raccourci vers l’atelier affiche « ATELIER ! » lorsqu’au moins une amélioration Vie, Vitesse, Souffle ou Puissance est achetable avec les pièces du joueur. Il reprend son libellé ordinaire quand aucune ne l’est. Le `+N` sur le raccourci tactile continue à compter les cadeaux disponibles. Le repère utilise l’état transmis au client ; le serveur reste responsable du prix et de l’achat.

Preuve historique de l'ancienne version : en SessionStudio, 99 pièces sans repère, 100 avec ; l'achat Vie donnait 120 PV et retirait le repère. Les captures et vérifications de cette passe précèdent les rangs sans plafond pratique et ne prouvent pas le comportement actuel. Fixture et rapport `studio/qa/AffordableUpgradeHint.server.luau` et `affordable-upgrade-hint-result.json`.

## Sources et données

- GameplayConfig : `Upgrades.Stamina`, `ProgressionSteps` et prix exponentiel borné au portefeuille maximal.
- EconomyService : `Meta.StaminaLevel` normalisé entre 0 et 1 000 000 000, défaut 0 pour les profils anciens. Même requête `Upgrade` et contrôles serveur que Vie/Vitesse/Puissance ; le serveur débite le prix et refuse uniquement la limite technique. `StaminaCapacity` est publié par le serveur ; `GameState` contient `StaminaLevel`. Les champs existants restent inchangés.
- SprintState : maxStamina appartient à l'état de chaque joueur, régénération bornée par ce maximum ; fallback standard 100 pour les anciens états de test.
- SprintServer : applique la capacité serveur avant la mise à jour de mouvement ; ajoute la différence positive uniquement quand le maximum change et borne les diminutions. Publie MaxStamina sur le personnage. Ne pas utiliser une capacité fournie par une requête client.
- GameHub : carte avec image de cristal existante, rang, coût et signature incluant StaminaLevel. La jauge d'endurance reste pilotée par `MaxStamina` ; aucun changement de son/animation requis.

Le champ est inclus dans le payload Meta existant de ProgressionService, sans réinitialisation de données ni des reçus. Reconnexion DataStore non testée : seule la sérialisation JSON a été vérifiée dans cette passe.

## Preuves du 27 octobre

Preuve historique : les 26 contrôles serveur de la version à cinq rangs vérifiaient profils anciens, prix, achats, reçus, drain/régénération et réapparition. Ces résultats ne valident pas la nouvelle progression ; le harnais a été actualisé mais n'a pas été exécuté dans ce lot.

Preuve historique d'avant cette modification : un clic natif PC achetait Souffle pour 250 pièces, passait au palier 1 et affichait 120/120. Les snapshots PC/portrait/paysage et TextFits ne valident pas la nouvelle UI ni les rangs continus. Aucun essai multijoueur, réseau dégradé, tactile physique ou DataStore n'est documenté pour cette passe.

QA : créer StaminaUpgradeQABridge (RemoteFunction) en Play, installer StaminaUpgradeBridge.client.luau, puis StaminaUpgrade.server.luau comme Script temporaire ordinaire. Lire ServerStorage.StaminaUpgradeQAResult. Pour les essais UI : PrepareStaminaUpgradeUI, ReadStaminaUpgradeQA, puis RestoreStaminaUpgradeQA obligatoirement. Restaurer default/LandscapeLeft et arrêter Play. Aucun QA en Edit. Rapport stamina-upgrade-result.json ; sauvegarde avant modification ServerStorage.BeforeStaminaUpgrade, cinq scripts.
