-- One-time Edit command only. Never install as a startup script.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before applying night lighting")
local L=game:GetService("Lighting")
local storage=game:GetService("ServerStorage")
assert(not storage:FindFirstChild("BeforeNightLighting"),"Night lighting already applied; use the existing backup")
local backup=Instance.new("Folder") backup.Name="BeforeNightLighting"
for _,key in {"Ambient","OutdoorAmbient","Brightness","ClockTime","ExposureCompensation","EnvironmentDiffuseScale","EnvironmentSpecularScale","GlobalShadows","ShadowSoftness","GeographicLatitude","ColorShift_Top","ColorShift_Bottom","PrioritizeLightingQuality"} do backup:SetAttribute(key,L[key]) end
backup:SetAttribute("LightingStyle",L.LightingStyle.Name)
local children=Instance.new("Folder") children.Name="LightingChildren" children.Parent=backup
for _,child in L:GetChildren() do child:Clone().Parent=children end
local clouds=workspace.Terrain:FindFirstChildOfClass("Clouds")
backup:SetAttribute("HadClouds",clouds~=nil)
if clouds then
 local state=Instance.new("Folder") state.Name="TerrainClouds"
 for _,key in {"Cover","Density","Color","Enabled"} do state:SetAttribute(key,clouds[key]) end
 state.Parent=backup
end
game.StarterPlayer.StarterPlayerScripts.PresentationClient:Clone().Parent=backup
local lightStates=Instance.new("Folder") lightStates.Name="WorldLights" lightStates.Parent=backup
local count=0
for _,light in workspace:GetDescendants() do
 if light:IsA("PointLight") or light:IsA("SpotLight") then
  count+=1
  local state=Instance.new("ObjectValue") state.Name="Light"..count state.Value=light
  for _,key in {"Brightness","Range","Shadows"} do state:SetAttribute(key,light[key]) end
  if light:IsA("SpotLight") then state:SetAttribute("Angle",light.Angle) end
  state:SetAttribute("HadFlickerBase",light:GetAttribute("FlickerBase")~=nil)
  state:SetAttribute("FlickerBase",light:GetAttribute("FlickerBase"))
  state:SetAttribute("NightShadow",light:GetAttribute("NightShadow"))
  state.Parent=lightStates
 end
end
backup.Parent=storage

L.LightingStyle=Enum.LightingStyle.Realistic L.PrioritizeLightingQuality=true
L.ClockTime=.75 L.GeographicLatitude=41
L.Brightness=.45 L.ExposureCompensation=-.15
L.Ambient=Color3.fromRGB(7,9,14) L.OutdoorAmbient=Color3.fromRGB(12,17,26)
L.EnvironmentDiffuseScale=.12 L.EnvironmentSpecularScale=.65
L.GlobalShadows=true L.ShadowSoftness=.2
L.ColorShift_Top=Color3.fromRGB(3,6,12) L.ColorShift_Bottom=Color3.new()
local atmosphere=L:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",L)
atmosphere.Density=.35 atmosphere.Offset=.1 atmosphere.Haze=1.5 atmosphere.Glare=0
atmosphere.Color=Color3.fromRGB(98,112,136) atmosphere.Decay=Color3.fromRGB(9,15,27)
local grade=L:FindFirstChild("SurvivalFilmGrade")
assert(grade and grade:IsA("ColorCorrectionEffect"),"Missing existing film grade")
grade.Brightness=0 grade.Contrast=.08 grade.Saturation=-.05 grade.TintColor=Color3.fromRGB(228,237,255)
local apocalypseGrade=L:FindFirstChild("ApocalypseGrade")
if apocalypseGrade then
 assert(apocalypseGrade:IsA("ColorCorrectionEffect"),"ApocalypseGrade is not a ColorCorrectionEffect")
 apocalypseGrade.Saturation=-.05
end
local bloom=L:FindFirstChild("RestrainedBloom")
if bloom then bloom.Intensity=.08 bloom.Size=20 bloom.Threshold=1.5 end
local rays=L:FindFirstChild("LateAfternoonRays") if rays then rays.Enabled=false end
local dof=L:FindFirstChild("DistantFocus") if dof then dof.FarIntensity=.03 dof.NearIntensity=0 end
local sky=L:FindFirstChildOfClass("Sky")
if sky then sky.CelestialBodiesShown=true sky.MoonAngularSize=3 sky.StarCount=150 end
clouds=clouds or Instance.new("Clouds",workspace.Terrain)
clouds.Color=Color3.fromRGB(35,42,55) clouds.Cover=.93 clouds.Density=.8

local modified=0
for _,state in lightStates:GetChildren() do
 local light=state.Value local parent=light.Parent
 if parent.Name=="SodiumLamp" then
  if light:IsA("SpotLight") then light.Brightness=1.7 light.Range=26 light.Angle=80 light.Shadows=true
  else light.Brightness=.25 light.Range=10 end
 elseif parent.Name=="LampGlow" then light.Brightness=.8 light.Range=16 light.Shadows=true
 elseif parent.Name=="EmergencyLight" then light.Brightness=.7 light.Range=18 light.Shadows=true
 elseif parent.Name=="TerminalGlow" then light.Brightness=.6 light.Range=12
 elseif parent.Name=="Lamp" and parent:IsDescendantOf(workspace.RefugeCourtyard) then light.Brightness=1.8 light.Range=22 light.Shadows=true
 elseif parent.Name=="BurntEngine" or parent.Name=="RefugeFireBarrel" then light.Shadows=true
 end
 if light:GetAttribute("FlickerBase")~=nil then light:SetAttribute("FlickerBase",light.Brightness) end
 if light.Brightness~=state:GetAttribute("Brightness") or light.Range~=state:GetAttribute("Range") or light.Shadows~=state:GetAttribute("Shadows") then modified+=1 end
 light:SetAttribute("NightShadow",light.Shadows)
 light.Shadows=false -- PresentationClient enables only nearby shadow maps after loading.
end
assert(L.ClockTime<2 and L.Brightness<.5 and L.OutdoorAmbient.R<.05,"Night settings not applied")
return {Backup=backup:GetFullName(),LightsBackedUp=count,LightsModified=modified,ClockTime=L.ClockTime}
