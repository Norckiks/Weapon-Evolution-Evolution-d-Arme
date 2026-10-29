# Évolution des pets

Les copies identiques servent à améliorer leur espèce dans l’onglet **Pets**, avec le bouton **Évoluer**. Un seul pet reste actif ; ses copies ne cumulent pas directement les bonus. Les rangs continuent après les trois premiers, pour Buddy comme pour les autres espèces.

| Rang obtenu | Copies nécessaires avant évolution | Copies consommées | Multiplicateur des bonus du pet |
| --- | --- | --- | --- |
| 1 | 3 | 2 | ×1,15 |
| 2 | 5 | 4 | ×1,30 |
| 3 | 7 | 6 | ×1,45 |
| 4 | 9 | 8 | ×1,60 |

Une copie reste toujours utilisable. Treize copies permettent d’atteindre le rang 3 en conservant une ; il n’y a pas de coût en pièces ni de tirage aléatoire. Le besoin continue selon `min(100 000, 3 + 2 × rang actuel)` copies, avec un plafond de coût égal à l’inventaire maximal déjà autorisé. Les bonus restent linéaires jusqu'au rang 5, puis suivent des rendements décroissants. Exemple Railours : son bonus pièces de +90 % devient +130,5 % au rang 3, soit des gains ×2,305 avant un boost temporaire. Son XP devient +108,75 % et sa vitesse de marche/sprint +14,5 %. Les pourcentages de la fiche sont arrondis, les calculs serveur gardent la précision puis les récompenses ordinaires arrondissent les montants entiers.

`GameplayConfig.PetRanks` garde le bonus .15 et les trois prix initiaux {3,5,7} ; `PetRankCost` les prolonge au-delà. `PetBonuses(id,rank)` partage les bonus pièces/XP/vitesse entre UI et serveur. `Meta.PetRanks[species]` est normalisé de 0 à 1 000 000 000, sans espèces inconnues, et sérialisé dans le Meta existant hors de Daily. Les anciens profils et les bonus au rang 0 restent identiques. Aucun pet, reçu ou dossier existant n’est réinitialisé.

`UpgradePet` accepte seulement l’identifiant d’espèce connu. Le routeur serveur conserve ses contrôles de démarrage/type/fréquence. Le serveur choisit le rang et le nombre de copies, refuse le manque de copies ou la limite technique, puis change copies/rang ensemble sans yield. `E.Refresh` applique immédiatement le rang du pet actif ; déséquiper retire ses bonus. Les boosts temporaires se composent ensuite comme avant. La fusion de fragments, le calendrier et les cadeaux de temps ajoutent des copies sans remettre le rang à zéro.

Protection d’inventaire : une fusion à100 000copies ne débite plus les fragments ; un cadeau de pet à inventaire plein reste non réclamé. Les contrôles existants des caisses/calendrier restent en place. Pas d’activation de paiement ou de nouvelle DataStore.

UI : rang numérique compact, copies nécessaires et bonus recalculés ; Évoluer/Fusionner/Équiper gardent leurs colonnes distinctes. L'interface évite de fabriquer une étoile par rang, ce qui rend l'affichage prévisible aux niveaux élevés. La carte conserve son image et ses actions. Buddy garde Évoluer/Équiper et n’a pas de bouton de fragments. Le changement de rang est dans la signature du catalogue pour rafraîchir une fiche même sans autre changement de statut.

## Preuves du27 octobre2026

Trois sources comparées et synchronisées Edit : GameplayConfig, EconomyService, GameHub ; backup ServerStorage.BeforePetRanks(3), toujours46 scripts actifs. Aucun nouveau modèle de pet ou aura introduit ; les étoiles concernent la fiche, les modèles/animations existants restent utilisés.

Le rapport `studio/qa/pet-ranks-result.json` est une preuve historique de l'ancienne version à trois rangs ; il ne valide pas la progression actuelle. Les harnais `studio/qa/PetRanks.server.luau` et `PetRanksUI.client.luau` couvrent maintenant le rang 4 et la limite technique, mais ils n'ont pas été exécutés dans ce lot.

Preuve historique de l'ancienne UI Ready/RankOnly/Locked/Max : rang, étoiles, image et actions dans leurs coordonnées locales. Cette passe ne valide pas l'UI numérique actuelle. TextFits et adaptation visuelle PC/portrait/paysage restent à vérifier.

Premier test de rafale échoué : cinq InvokeClient successifs laissaient passer du temps entre messages, autorisant plusieurs évolutions légitimes. PetRanksBridge envoie désormais cinq FireServer depuis un seul callback, puis le test constate un seul rang et le coût correct. Aucun changement produit pour contourner le test.

QA PetRanks.server/PetRanksBridge.client/PetRanksUI.client uniquement Play SessionStudio. PreparePetRankUI(Ready/RankOnly/Locked/BeyondCap/TechnicalLimit), puis RestorePetRanksQA avant Stop ; attribut client PetRanksQAPhase temporaire retiré. Meta/statistiques/flags restitués, console vide puis Stop. Pas de reconnexion DataStore, multijoueur, clic natif, tactile physique, capture ou nouvel effet 3D vérifié. Aucune publication/sauvegarde `.rbxl`.
