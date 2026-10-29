# Arène PvP

La cour du refuge contient une arène rouge balisée et éclairée. Le combat s'active automatiquement quand deux personnes entrent dans le périmètre : aucune invitation ou progression n'est requise. L'arène est sur l'aile droite, à environ `(130, 326)` sur le plan X/Z ; son sol mesure 44×32 studs et le périmètre de combat 40×28 studs. Une allée pavée de 110×10 studs la relie au chemin central. Elle reste ouverte même si les joueurs désactivent le PvP hors arène.

Hors de l'arène, le PvP est désactivé par défaut à chaque nouvelle session. Dans l'onglet Options, « PVP HORS ARENE » permet à chacun d'accepter le combat partout ailleurs ; l'attaquant et la cible doivent tous les deux l'activer. Un joueur dans l'arène ne peut pas attaquer une cible dehors, ni l'inverse. Le réglage est tenu côté serveur pour la session et n'est pas sauvegardé dans le profil.

Les poings, les armes à feu et les capacités offensives existantes peuvent atteindre un personnage adverse. Le serveur exige que l'attaquant et sa cible soient deux joueurs différents, vivants, démarrés et hors menu. Dans l'arène, les deux racines doivent rester dans `Workspace.SurvivorArena.FightBounds` ; ailleurs, les deux doivent être hors de ce périmètre et avoir `PvPEnabled=true`. Le ForceField de réapparition et le bouclier Aegis protègent aussi les cibles. Les capacités gardent leur forme, leur portée, leur ligne de vue, leurs coûts et leurs délais.

Les zombies ne changent pas de règles : zones, dégâts, récompenses, pièces, XP et fragments gardent leurs validations actuelles. Les joueurs ne portent pas le tag `Zombie` et un décès PvP ne déclenche donc pas de récompense de zombie.

## Scripts et retour arrière

- `studio/PvPService.luau` centralise le périmètre et l'autorisation serveur.
- `studio/FistsServer.server.luau`, `studio/Firearms.server.luau` et `studio/PulseAbility.luau` ajoutent la cible joueur aux attaques existantes.
- `studio/BuildPvPArena.luau` est un constructeur ponctuel à exécuter en Edit une fois ; ne jamais le placer dans un service de démarrage.
- `studio/runtime-manifest.json` relie le nouveau module à `ServerScriptService.PvPService`.

Le dossier `ServerStorage.BeforePvPArena` garde les trois scripts d'origine. Pour revenir en arrière dans Studio Edit, restaurer leurs sources depuis ce dossier, supprimer `ServerScriptService.PvPService` et `Workspace.SurvivorArena`, puis remettre les trois sources locales depuis le même backup. Le constructeur refuse de recréer une arène déjà présente.

## Preuves et limites

`studio/qa/pvp-arena-result.json` consigne la comparaison locale/Studio, la compilation, l'absence d'obstacle superposé, et le test Play solo des limites et refus d'auto-dégâts. `studio/qa/PvPArena.server.luau` vérifie aussi l'arène toujours ouverte, le défaut désactivé hors arène, l'accord des deux joueurs et le refus de franchissement de périmètre. Aucun profil ou inventaire n'est modifié par le réglage. Le test à un joueur ne prouve pas la perte de santé, le recul, les coups de tête ou les dégâts entre deux clients ; le multijoueur et le tactile physique restent à contrôler dans une session Studio à plusieurs joueurs. La scène est installée en Edit, sans sauvegarde `.rbxl` ni publication.

Le contrôle des attaques suit les recommandations Roblox de validation serveur et de vérification du trajet par raycast : [Hit detection with lasers](https://github.com/Roblox/creator-docs/blob/main/content/en-us/tutorials/use-case-tutorials/scripting/intermediate-scripting/hit-detection-with-lasers.md).
