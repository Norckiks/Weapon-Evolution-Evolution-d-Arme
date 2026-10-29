# Documentation

## Pour reprendre le projet

1. Lire `../AGENTS.md`, puis `../RELAIS_IA.md` : règles de travail et état actuel.
2. Utiliser `../studio/runtime-manifest.json` pour relier les 47 scripts actifs aux instances Roblox Studio.
3. Ouvrir uniquement le guide de référence utile au changement. Les guides ci-dessous décrivent l'état fonctionnel et les preuves disponibles ; vérifier leur portée et leurs limites.

Le registre de propagation des régressions est dans [`../REGRESSION.md`](../REGRESSION.md).

## Guides de référence

- Monde : `reference/AMBIANCE_NUIT.md`, `reference/REFUGE.md`, `reference/ZONES.md`, `reference/ECLIPSE_VAULT.md`, `reference/BLACKOUT_CORE.md`, `reference/GRIDFALL.md`, `reference/LAST_CONVOY.md`, `reference/CRATERE.md`, `reference/MER_DE_VERRE.md`, `reference/CITE_ANTENNES.md`, `reference/STATION_ORBITALE.md`, `reference/DEPTHS.md`, `reference/IRON_SANCTUM.md`, `reference/CENTRALE.md`, `reference/METRO.md`, `reference/NAVIGATION_ZOMBIES.md`, `reference/ELITES.md`
- Combat : `reference/PVP.md`, `reference/ZOMBIES_COMBAT.md`, `reference/CAPACITES.md`, `reference/DECHARGE.md`, `reference/TIRS_A_LA_TETE.md`
- Déplacements : `reference/MOUVEMENTS.md`, `reference/ENDURANCE.md`, `reference/IDEES_IMPLEMENTEES.md` (nouvelle vue, UI, course et comparaison documentaire)
- Économie et progression : `reference/PROGRESSION_ARMES.md`, `reference/PRIMES_DE_NIVEAU.md`, `reference/CONNEXION.md`, `reference/EVOLUTION_PETS.md`, `reference/PREMIERE_CHASSE.md`, `reference/CONTRATS_EXPRESS.md`, `reference/EXPEDITIONS.md`, `reference/CAISSES.md`, `reference/ADMIN_PANEL.md`
- Armes : `reference/ARMES_A_FEU.md`, `reference/GUETTEUR.md`, `reference/MITRAILLEUSE.md`, `reference/ANIMATIONS_ARMES.md` (mécanismes sur le personnage et tests)
- Interface : `reference/UI_MOBILE.md`, `reference/HUD_CADENCE.md`, `reference/MENU_ACCUEIL.md`

## Concepts à transmettre à la modélisation

- `ideas/REFONTE_REFUGE_ET_PREMIERE_ZONE.md` : brief historique pour le refuge et la Ville niveau 1 ; la place actuelle à 19 portails est décrite et testée dans `reference/REFUGE.md`.

## Notes historiques

`historique/` contient des analyses, idées et plans anciens, ainsi que `RELAIS_IA_avant_synthese_2026-10-27.md`, copie intégrale du relais avant synthèse. Ils aident à comprendre l'intention, mais ne prouvent pas qu'une fonctionnalité existe aujourd'hui. Pour l'état réel, privilégier `RELAIS_IA.md`, les guides de référence et les sources `studio/` comparées à Studio.

## Sources du jeu

`../studio/` contient les sources Luau, `runtime-manifest.json`, les archives et les harnais QA. Les constructeurs ponctuels, archives et tests ne sont pas des scripts de démarrage. `../assets/` contient les ressources graphiques.
