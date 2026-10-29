# Nuit et lampe torche

Le monde est réglé à 00 h 45. Les rues et les zones sans source lumineuse sont très sombres ; la lampe révèle le sol et les obstacles dans un cône central. Les lampes du refuge, les enseignes et les portails restent des repères.

Commandes existantes : **F** au clavier, **DPad haut** à la manette et bouton **LAMPE** sur mobile.

## Réglages installés

`BuildNightLighting.luau` est une commande **ponctuelle en Edit**, jamais un script de démarrage. Elle modifie Lighting, son atmosphère, ses effets existants, les nuages et les éclairages locaux ; elle ne reconstruit aucune géométrie. Ne pas relancer `BuildPresentationV2`, qui recréerait la scène et rétablirait l'après-midi.

| Élément | Valeur |
|---|---|
| Éclairage Roblox | Realistic, PrioritizeLightingQuality=true |
| Heure / luminosité / exposition | 0.75 / 0.45 / -0.15 |
| Ambient / OutdoorAmbient | RGB 7,9,14 / 12,17,26 |
| Diffus / spéculaire environnement | 0.12 / 0.65 |
| Atmosphère | Density 0.35, Haze 1.5, teinte froide |
| Étalonnage | `ApocalypseGrade` saturation -0.05 / contraste 0.12 ; `SurvivalFilmGrade` saturation -0.05 / contraste 0.08 ; bloom discret, rayons de soleil désactivés |
| Torche principale | angle 44°, portée 72 studs, Brightness 8.5, blanc légèrement chaud |
| Halo de torche | angle 85°, portée 30, Brightness 0.9, sans ombres |

98 lumières ont été sauvegardées ; 87 ont reçu un changement de luminosité, de portée ou d'intention d'ombre. Les lampes du refuge éclairent sur 22 studs ; les lampes de zones ont une portée de 16 studs, les lumières d'urgence 18. Les lampadaires de Ville concentrent la lumière vers le sol. Les points lumineux décoratifs ne servent plus d'éclairage général.

`Presentation.client.luau` conserve l'intention d'ombre dans `NightShadow`, puis active au maximum quatre ombres de lumières fixes dans un rayon de 65 studs, choisies par distance à la caméra. La torche a sa propre ombre. Les ombres fixes sont désactivées dans la scène Edit pour éviter leur activation massive au chargement. En qualité standard, le faisceau reste identique mais ses ombres et celles des lampes sont désactivées. L'option ReducedMotion stabilise les lampes qui scintillent.

## Rehausse des couleurs des armes — 29 octobre 2026

Le premier correctif avait réglé `SurvivalFilmGrade` à `-0.05`, mais un second `ColorCorrectionEffect`, `ApocalypseGrade`, gardait `Saturation=-0.28` et continuait à ternir toute la scène. Les deux filtres sont maintenant à `-0.05`. L'original d'ApocalypseGrade est sauvegardé dans `ServerStorage.BeforeApocalypseGradeColorPass_20261029`; celui de SurvivalFilmGrade dans `ServerStorage.BeforeWeaponColorGrade_20261029`. Brightness, contraste, heure, exposition, ambient, ombres et éclairage local restent inchangés. Le constructeur ponctuel `studio/BuildNightLighting.luau` applique désormais aussi le réglage à ApocalypseGrade s'il existe.

En Play, les deux filtres se répliquent à `-0.05`, avec l'heure 0,75, la luminosité 0,45 et l'exposition -0,15 conservées. Un clone client des trois armes finales garde 19 / 19 / 17 MeshParts, cinq couleurs distinctes chacune et aucune pièce grise (saturation HSV <0,2) ; minima ArcPike, BlackoutEdge, EclipseGlaive : 0,519 / 0,580 / 0,622. Les 19 portails et leurs prompts étaient encore présents, console vide. Rapport [`apocalypse-color-grade-play-check-20261029.json`](../../studio/qa/apocalypse-color-grade-play-check-20261029.json). Capture pixel non obtenue : l'amélioration de saturation est prouvée par les propriétés, pas par un rendu inspecté.

## Preuves du 27 octobre 2026

- Comparaison exacte du script local avec `StarterPlayer.StarterPlayerScripts.PresentationClient` avant modification, puis après synchronisation. Compilation Luau finale réussie en Edit. Aucun nouveau script actif ; manifeste toujours 46 scripts.
- Calibration visuelle PC avec caméra temporairement fixe : Ville lampe éteinte/allumée, refuge éteint, qualité standard allumée. La touche F a réellement déclenché le callback ; cœur et halo suivent le même état. Les valeurs retenues ont ensuite été persistées en Edit.
- Dernier Play : iPhone 17 Pro simulé, paysage 750×381 en Ville et portrait 401×778 à l'Usine. Captures inspectées : texture du sol et obstacles visibles dans le faisceau, presque invisibles lampe éteinte. À l'Usine : quatre ombres fixes en qualité élevée, zéro en standard ; ombre de torche true/false, luminosité 8.5 conservée.
- La fixture `studio/qa/NightLighting.client.luau` masque le menu et fixe la caméra ; le personnage reste au refuge et HasStarted=false. Ce ne sont pas des déplacements ni des combats réels. Elle restaure caméra, menu et options avant Stop ; aucun profil, achat ou reçu modifié.
- Des essais intermédiaires ont rencontré des interruptions MCP et des timeouts de CoreScripts Roblox, suivis de HUD manquant. Leur cause n'a pas été isolée. Une copie Clouds dans la sauvegarde provoquait aussi un avertissement : remplacée par un Folder de propriétés. **Dernier essai : console vide, une seule instance Clouds.** Aucun gain FPS n'a été mesuré.
- Fin vérifiée : Studio Edit, simulateur default/LandscapeLeft, source synchronisée. Rapport `studio/qa/night-lighting-result.json`. Captures inspectées dans l'outil, non exportées sur disque. Pas de sauvegarde `.rbxl` ni publication.

Non vérifié : partie complète dans les six zones, combat en mouvement, tactile physique, vraie manette, performances sur téléphone réel et tous niveaux de qualité Roblox. L'aspect dépend de l'écran et du réglage graphique du joueur.

Graphify a été interrogé sur le snapshot `aa5acca` (656 nœuds, 871 liens). Il localise Presentation/PresentationConfig et les consommateurs de HighGraphics, mais ne fournit pas le corps du fichier Presentation : les changements sont fondés sur les sources et l'état Studio comparés. Aucun push ni réindexation de ce lot. Context7 a fourni les références officielles [Lighting](https://github.com/Roblox/creator-docs/blob/main/content/en-us/environment/lighting.md) et [Atmosphere](https://github.com/Roblox/creator-docs/blob/main/content/en-us/environment/atmosphere.md).

## Retour arrière

`ServerStorage.BeforeNightLighting` conserve les propriétés Lighting, ses enfants d'origine, les propriétés des nuages, les références/propriétés des 98 lumières et la source PresentationClient d'origine. Ne pas supprimer cette sauvegarde avant validation du rendu.

En Edit uniquement, le code suivant restaure cet état. Il **n'a pas été exécuté**, car il annulerait la nuit. Reporter ensuite la source restaurée de PresentationClient dans `studio/Presentation.client.luau`.

```lua
assert(not game:GetService("RunService"):IsRunning(),"Stop Play")
local b=assert(game.ServerStorage:FindFirstChild("BeforeNightLighting"))
local L=game.Lighting
for key,value in b:GetAttributes() do
 if key=="LightingStyle" then L[key]=Enum.LightingStyle[value]
 elseif key~="HadClouds" then L[key]=value end
end
for _,old in b.LightingChildren:GetChildren() do
 local current=L:FindFirstChild(old.Name) if current then current:Destroy() end
 old:Clone().Parent=L
end
local c=workspace.Terrain:FindFirstChildOfClass("Clouds")
if b:GetAttribute("HadClouds") then
 c=c or Instance.new("Clouds",workspace.Terrain)
 for key,value in b.TerrainClouds:GetAttributes() do c[key]=value end
elseif c then c:Destroy() end
for _,state in b.WorldLights:GetChildren() do
 local light=state.Value
 if light and light.Parent then
  for _,key in {"Brightness","Range","Shadows","Angle"} do
   local value=state:GetAttribute(key) if value~=nil then light[key]=value end
  end
  light:SetAttribute("FlickerBase",state:GetAttribute("FlickerBase"))
  light:SetAttribute("NightShadow",state:GetAttribute("NightShadow"))
 end
end
game.StarterPlayer.StarterPlayerScripts.PresentationClient.Source=b.PresentationClient.Source
```
