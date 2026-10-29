# Menu d'accueil — refonte du 29 octobre 2026

L'accueil propose Jouer, Options et Voir le prologue dans une colonne à gauche sur PC. Le titre Creepster est sur deux lignes, ou une seule en paysage mobile. Les effets de survol et le mouvement lent de caméra respectent ReducedMotion. Le prologue existant reste optionnel.

## Modélisation et intégration

- Source reproductible : `assets/build_menu_quarantine.py`.
- Fichiers : `assets/horror_menu/quarantine/MenuQuarantine.blend`, `.fbx`, `.png`, `.parts.json`.
- 244 objets Blender : portail nervuré, piles béton, rivets, poignées, fenêtres encadrées et condamnées, barricades et bandes de danger, projecteurs, caisses, fûts et maçonnerie.
- Instance installée : `ReplicatedStorage.PresentationAssets.MenuQuarantine`, clonée uniquement dans le WorldModel du menu.
- `InstallMenuQuarantine.luau`, dans le même dossier d'assets, est un constructeur ponctuel Edit, jamais un script de démarrage. Il refuse une seconde installation.
- Le pont JSON reproduit les primitives, dimensions, rotations et couleurs. Les biseaux et normales pondérées restent dans le FBX/Blend : ce n'est pas un import MeshPart du FBX. La voiture, les plantes, les gravats et le zombie existants sont conservés ; le zombie a été repositionné, pas remodélisé.
- Le ViewportFrame utilise Ambient/LightColor/LightDirection ; les projecteurs visibles ne produisent pas d'éclairage local ou d'ombres réelles dans cette vue.

## Vérifications

En Play : menu PC 1433×824 et iPhone 17 Pro simulé paysage 750×381 / portrait 401×778. Captures inspectées, débordement paysage et titre corrigés. Les trois boutons restent dans la surface utile avec hauteur ≥44 px. Contrôle conservé dans `studio/qa/MenuRedesign.client.luau` : client Play uniquement, menu ouvert. Options, lancement du prologue, retour Espace et démarrage de partie vérifiés. Console finale vide.

Studio revenu en Edit et simulateur arrêté. Pas de test tactile physique, manette ou multijoueur. Pas de publication ni sauvegarde du fichier place. L'ancien GameHub est copié dans `ServerStorage.BeforeMenuRefonte_20261029`. Les modèles existants partagés avec le gameplay ne sont pas modifiés.

Graphify interrogé sur le snapshot aa5acca (27 octobre), sans résultat utile sur cette partie : le source local a été comparé au source Studio. Context7 a documenté le rendu ViewportFrame ; ECC frontend-design-direction a guidé la hiérarchie et les contrôles de mise en page.
