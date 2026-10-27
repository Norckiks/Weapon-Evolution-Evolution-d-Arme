# Cadence des états du HUD

GameHub conserve GameHubCursor sur BindToRenderStep pour la caméra et le pointeur des menus. La mise à jour des textes, disponibilités et placements du HUD a été séparée sur Heartbeat, avec une cadence cible de 10 Hz. Les compteurs de cadeaux, états du dash, visibilité des raccourcis/contrat, contrôles tactiles et placements de toast ne s'exécutent donc plus à chaque rendu caméra. Les boosts gardent leur cadence cible de 4 Hz mais sont également sur Heartbeat.

Les interactions des boutons, animations Tween, aperçus d'armes et déplacements des compagnons ne sont pas changés. Les poses/visées de combat restent dans leurs scripts de présentation. Aucun contrôle serveur, coût, profil ou reçu n'est modifié. Les gardes ContextActionGui et Parent des anciens boutons tactiles ont été conservées.

La séparation suit la distinction entre boucle de rendu et simulation décrite par [RunService](https://create.roblox.com/docs/reference/engine/classes/RunService). Elle réduit la fréquence de cette boucle de statut par construction ; aucun gain FPS, CPU ou GPU chiffré n'a été mesuré.

## Preuves du 27 octobre

Baseline sans rendu : menu ouvert, mais raccourcis encore visibles et compteur cadeaux resté sans nombre. Après correction, six checks passent : raccourcis masqués dans le menu, compteur à deux cadeaux (un de temps et un de niveau), texte du boost XP actualisé, cadence du compte à rebours bornée. Mesure courte : 13 changements de texte du dash en 1,269 s, premier changement à 16 ms et plus grand intervalle 102 ms, avec zéro RenderStepped et 117 Heartbeat sur la durée du test. Ces valeurs décrivent cette exécution, pas une garantie de latence de l'interface affichée.

Trois états logiques supplémentaires sont relevés : fermeture du menu via la transition HasStarted (raccourcis/boost visibles), OptionsOpen=true (masqués), puis restauration (visibles). Les essais G/P natifs n'ont pas produit la transition attendue dans la session sans rendu ; ils ne sont pas déclarés validés. La fixture initiale de boost 60 s avait expiré lors d'essais ultérieurs ; la fixture finale dure 600 s, sans changement de règle produit.

Diagnostic de pipeline : les callbacks First/Last, PreRender et RenderStepped restent tous à zéro, tandis que Heartbeat avance. L'essai temporaire Set3dRenderingEnabled(true) est refusé par la capacité RobloxScript ; aucun contournement de sécurité n'est tenté. Les vérifications visuelles de Centrale, ses portails et les dispositions mobiles restent en attente d'une fenêtre Play rendue.

QA : HubStatus.server.luau comme Script temporaire en Play SessionStudio, puis HubStatus.client.luau. Lire PlayerGui.HubStatusQAResult et appeler ServerStorage.RestoreHubStatusQA:Invoke() avant Stop. La fixture change temporairement niveau, primes/cadeaux et boost XP et restaure le Meta original. La sonde client restaure DashReadyAt. Rapport hub-status-result.json. Backup Edit de GameHub : ServerStorage.BeforeHubStatusHeartbeat. Aucun QA dans le manifeste.
