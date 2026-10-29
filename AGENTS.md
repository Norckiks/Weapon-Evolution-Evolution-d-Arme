# Weapon Evolution — consignes de reprise

Lire README.md puis RELAIS_IA.md avant de modifier le jeu. Les guides fonctionnels sont dans docs/reference/. Les notes de docs/historique/ décrivent des intentions anciennes et ne prouvent pas une fonctionnalité. Voir docs/README.md pour choisir les documents utiles.

- Projet Roblox/Luau. Les sources locales sont dans studio/. La documentation est organisée dans docs/reference/ et docs/historique/ ; commencer par docs/README.md. Le mapping des 47 scripts actifs est studio/runtime-manifest.json. Ce dépôt seul ne reconstruit pas la scène Studio.
- Redécouvrir l'instance Studio et vérifier son état. Les changements persistants de scripts vont dans Edit, après arrêt de Play. Modifier les fichiers locaux et leurs instances correspondantes ; ne pas écraser les changements Studio sans comparaison préalable.
- Ne pas installer studio/qa, studio/archive, Build*, Install*, Upgrade*, CreateSurvivalHUD ou AddAmbientWorldDetails comme scripts de démarrage. Ce sont des tests, archives ou constructeurs ponctuels, susceptibles de dupliquer/remplacer la scène.
- Conserver les achats en pièces depuis l'UI, même loin des stands. Les contrôles de prix, niveau, possession, dégâts et récompenses restent côté serveur.
- Achats Robux désactivés à la demande de l'utilisateur : MonetizationEnabled=false et identifiants produits à zéro jusqu'à configuration explicite.
- Préserver la progression existante et ses reçus. Ne pas réinitialiser DataStore, activer des paiements ou publier l'expérience sans autorisation correspondante.
- Les tests QA modifient temporairement le personnage et ses données : uniquement en Play de test, puis arrêter Play. Ne jamais les installer en Edit ni dans une expérience publique.
- Une commande execute_luau peut avoir un cache require distinct des scripts du jeu : pour tester leurs services, créer un Script temporaire dans le serveur Play et lire son résultat.
- Vérifier clavier, mobile paysage/portrait et interfaces à différentes tailles. Les poses doivent prendre en charge AnimationConstraint et Motor6D, et respecter les options de réduction des mouvements.
- Dire ce qui est réellement vérifié. Compilation, mesures géométriques et capture visuelle sont des preuves différentes. Ne pas annoncer un test multijoueur, tactile physique ou DataStore sans l'avoir fait.
- Mettre à jour RELAIS_IA.md après un lot, avec fichiers modifiés, preuves, limites et prochaine étape. Ne pas marquer l'objectif général terminé pour une seule amélioration.

