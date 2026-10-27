# Évolution des pets

Les copies identiques servent désormais à améliorer leur espèce dans l’onglet **Pets**, avec le bouton **Évoluer**. Un seul pet reste actif ; ses copies ne cumulent pas directement les bonus. Tous les pets, y compris Buddy et ceux du Métro, ont trois rangs.

| Rang obtenu | Copies nécessaires avant évolution | Copies consommées | Multiplicateur des bonus du pet |
| --- | --- | --- | --- |
| 1 ★ | 3 | 2 | ×1,15 |
| 2 ★★ | 5 | 4 | ×1,30 |
| 3 ★★★ | 7 | 6 | ×1,45 |

Une copie reste toujours utilisable. Treize copies au total permettent donc d’atteindre le rang3 en en conservant une ; il n’y a pas de coût en pièces ni de tirage aléatoire. Exemple Railours : son bonus pièces de+90% devient+130,5% au rang3, soit gains×2,305 avant un boost temporaire. Son XP devient+108,75% et sa vitesse de marche/sprint+14,5%. Ce sont les bonus du pet qui augmentent, pas directement tous les gains de45%. Les pourcentages de la fiche sont arrondis, les calculs serveur gardent la précision puis les récompenses ordinaires arrondissent les montants entiers.

`GameplayConfig.PetRanks` définit Max3,Bonus.15,Copies{3,5,7}. `PetBonuses(id,rank)` partage les trois bonus pièces/XP/vitesse entre UI et serveur. `Meta.PetRanks[species]` est normalisé0..3, sans espèces inconnues, et sérialisé dans le Meta existant hors de Daily. Les anciens profils ont un dictionnaire vide et les19 bonus au rang0 restent identiques. Aucun pet, reçu ou dossier existant n’est réinitialisé.

`UpgradePet` accepte seulement l’identifiant d’espèce connu. Le routeur serveur conserve ses contrôles de démarrage/type/fréquence. Le serveur choisit rang et copies nécessaires, refuse le manque de copies ou le rang maximum, puis change copies/rang ensemble sans yield. E.Refresh applique immédiatement le rang du pet actif ; déséquiper retire ses bonus. Les boosts temporaires se composent ensuite comme avant. La fusion de fragments, le calendrier et les cadeaux de temps ajoutent des copies sans remettre le rang à zéro.

Protection d’inventaire : une fusion à100 000copies ne débite plus les fragments ; un cadeau de pet à inventaire plein reste non réclamé. Les contrôles existants des caisses/calendrier restent en place. Pas d’activation de paiement ou de nouvelle DataStore.

UI : rang/étoiles, copies nécessaires et bonus recalculés ; Évoluer/Fusionner/Équiper disposent de colonnes distinctes. Sur PC, image déplacée dans le titre pour dégager les actions, description réduite en largeur et carte104 unités au lieu de92. En portrait, trois actions204 unités côte à côte dans la carte250, en conservant la hauteur adaptée. Buddy garde Évoluer/Équiper et n’a pas de bouton de fragments. Le changement de rang est dans la signature du catalogue pour rafraîchir une fiche même sans autre changement de statut.

## Preuves du27 octobre2026

Trois sources comparées et synchronisées Edit : GameplayConfig, EconomyService, GameHub ; backup ServerStorage.BeforePetRanks(3), toujours46 scripts actifs. Aucun nouveau modèle de pet ou aura introduit ; les étoiles concernent la fiche, les modèles/animations existants restent utilisés.

`studio/qa/pet-ranks-result.json` :48 contrôles serveur et42 assertions de propriétés UI réussis. Bonus exacts des19 pets au rang0, trois rangs de Railours et conservation de copie/équipement, marche/sprint, refus2copies/non possédé/avantPlay/fauxID/max, rafale simultanée, Buddy/calendrier/fusion, capacités100000, déséquipement, normalisation, sauvegarde JSON/resetDaily/reçus et boosts. Une vraie mort Civilian via le directeur, avec crédit de test, paie18pièces/41XP au rang3 Railours ; pas un test de tir joueur.

UI Ready/RankOnly/Locked/Max : rang, bouton actif, étoiles, image, actions contenues et sans chevauchement dans leurs coordonnées locales. RankOnly est envoyé sans demande d’ouverture de page et confirme le rafraîchissement par signature. Ce ne sont ni des captures ni des mesures physiques tactiles. La fenêtre retourne1×1 ; TextFits et adaptation visuelle PC/portrait/paysage restent à renouveler après ces changements.

Premier test de rafale échoué : cinq InvokeClient successifs laissaient passer du temps entre messages, autorisant plusieurs évolutions légitimes. PetRanksBridge envoie désormais cinq FireServer depuis un seul callback, puis le test constate un seul rang et le coût correct. Aucun changement produit pour contourner le test.

QA PetRanks.server/PetRanksBridge.client/PetRanksUI.client uniquement Play SessionStudio. PreparePetRankUI(Ready/RankOnly/Locked/Max), puis RestorePetRanksQA avant Stop ; attribut client PetRanksQAPhase temporaire retiré. Meta/statistiques/flags restitués, console vide puis Stop. Pas de reconnexion DataStore, multijoueur, clic natif, tactile physique, capture ou nouvel effet3D vérifié. Aucune publication/sauvegarde.rbxl.
