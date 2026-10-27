# Centrale foudroyée

Cinquième zone, niveau 28, identifiant stable Power. Centre (2480,0,-120), demi-emprise (145,100,150), arrivée (2480,4,10), six emplacements et deux zombies de chaque espèce, délai de réapparition commun de dix secondes. Les attaques utilisent le système de mêlée existant ; les composants lumineux sont décoratifs, sans dégâts électriques ou attaque à distance ajoutés.

| Espèce | PV | Vitesse | Dégâts | Pièces | XP | Silhouette |
| --- | --- | --- | --- | --- | --- | --- |
| Électricien brûlé / Lineman | 1100 | 9 | 32 | 850 | 1200 | Casque, visière, gants isolants, bobine et perche |
| Étincelle errante / SparkRunner | 1400 | 16 | 36 | 1100 | 1500 | Corps mince, visière lumineuse, condensateurs, ailettes et bottes |
| Golem bobiné / CoilGolem | 2100 | 6 | 48 | 1600 | 2100 | Grande carrure, transformateur dorsal, bobines de cuivre et noyau |

Les trois modèles réutilisent les rigs humains améliorés : six MeshParts et six Motor6D, avec équipements distincts. Ils ne remplacent aucun ancien template. Le champ historique HarborSpecies de la fabrique demeure un ancien indicateur de ce chemin de construction ; utiliser ZoneId/ZombieType pour identifier la zone réelle.

## Fragments, pets et dossiers

Même chance serveur de fragment, 1/3, puis fusion de trois fragments du même identifiant. Les nouveaux pets réutilisent les silhouettes 3D existantes, avec couleurs et bonus distincts :

| Familier | Forme | Pièces | XP | Vitesse |
| --- | --- | --- | --- | --- |
| Voltix / Lineman | Robot | +60 % | +25 % | — |
| Flashou / SparkRunner | Lapin | +25 % | +50 % | +22 % |
| Bobinours / CoilGolem | Ours | +65 % | +60 % | +7 % |

Trois dossiers uniques : 6 éliminations, 3 espèces, 18 éliminations. Récompenses respectives 6000/2600, 9000/3900, 12000/5200 pièces/XP. Contrôles et reçus serveur inchangés, Meta.Expeditions.Power ajouté sans réinitialiser les autres dossiers. Les familiers sont enregistrés dans les tables Pets/Fragments existantes ; ils n'ont pas été ajoutés aux caisses.

## Scène et dépendances

- workspace.ProgressionZones.Power : cour, quatre transformateurs, quatre pylônes, hall de refroidissement, éclairage violet et trois obstacles franchissables. Couloir principal dégagé. Les éléments lumineux ne sont pas des dangers cachés.
- Portail refuge : RefugePortals.Travel_Power.Field à (96,4.5,208). PowerExpeditionPad recouvre le bord du pad du port pour prolonger le sol sans modifier l'ancien décor.
- Retour : Power.Return_Power.Field à (2502,4.5,20), destination Camp.
- ServerStorage.ZombieTemplates : Lineman, SparkRunner, CoilGolem.
- Ambiance locale : teinte violette et piste machine déjà disponible, sans nouvel asset audio.

BuildPowerExpansion.luau est un constructeur ponctuel Edit, jamais un script actif. Il dépend de la scène existante, des trois rigs de base améliorés et des sources WorldConfig/ZombieFactory à jour. Des clones isolés de ces modules évitent les caches require Edit. Il s'arrête si la scène est partielle et ne modifie rien si PowerBuildComplete et les dépendances sont présentes. Les panneaux sont double face. Une exécution réussie ne confirme pas une sauvegarde .rbxl ou une publication ; les sources seules ne reconstruisent pas tout le jeu.

Sept scripts sauvegardés dans ServerStorage.BeforePowerExpansion : WorldConfig, ZombieFactory, GameplayConfig, Expeditions, GameHub, ZoneGuide, PresentationClient. Manifeste runtime inchangé à 46.

## Preuves et reprise des tests

Rapport studio/qa/power-result.json : 49 contrôles serveur réussis (sol de l'arrivée/six spawns, trois rigs distincts, six apparitions, niveau 27 refusé/28 accepté, éjection d'entrée directe, flèche d'unlock Power, navigation grande silhouette, poursuite réelle, vrais callbacks de décès attribués par le harnais, gains exacts 3550 pièces/4800 XP, refus du double paiement, fragments observés, fusions et bonus des trois pets, dossiers et doublons, respawns et JSON). Trois contrôles séparés PowerCombat passent par de vrais Shoot:FireServer : chaque rig reçoit 38 dégâts corporels de Carbine, une balle consommée.

Une vue d'ensemble a été inspectée en Edit. La validation visuelle Play et les portails clavier sont **en attente** : deux sessions client ont compté des Heartbeat mais zéro RenderStepped. La caméra est restée au refuge malgré un déplacement répliqué du personnage, et la capture Play n'a pas abouti. E n'a pas téléporté ; désactiver Slam temporairement n'a pas résolu l'essai, donc ne pas déclarer un conflit de touche prouvé. InputHoldBegin/End n'a pas davantage déclenché le portail sans rendu. Le code de touches n'a pas été modifié. Refaire ces essais avec la fenêtre Play visible au premier plan ; une question utilisateur a été envoyée à ce sujet.

Installer uniquement en Play SessionStudio : PowerQABridge (RemoteFunction), PowerBridge.client.luau, Power.server.luau comme Script ordinaire ; lire PowerQAResult. PreparePowerQA:Invoke("Entry"/"Return") prépare une approche de portail, RestorePowerQA:Invoke() restaure après essais. Pour les tirs : PowerCombatQABridge, PowerCombatBridge.client.luau, PowerCombat.server.luau ; lire PowerCombatQAResult, restauration automatique. Les données/statistiques/position ont été restaurées avant Stop ; aucun test DataStore, multijoueur, physique tactile ou équilibre longue session. La forme des pets, les nouveaux libellés UI et les deux portails restent à inspecter visuellement en Play.
