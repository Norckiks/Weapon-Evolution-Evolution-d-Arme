-- One-time edit-mode scene dressing. Original gameplay geometry is retained.
local Lighting=game:GetService("Lighting")
assert(not workspace:FindFirstChild("PresentationV2"),"Presentation V2 already exists")
local root=Instance.new("Folder") root.Name="PresentationV2" root.Parent=workspace
Lighting.LightingStyle=Enum.LightingStyle.Realistic
Lighting.PrioritizeLightingQuality=true
Lighting.ClockTime=16.45 Lighting.GeographicLatitude=41
Lighting.Brightness=2.5 Lighting.ExposureCompensation=-0.1
Lighting.GlobalShadows=true Lighting.ShadowSoftness=0.26
Lighting.Ambient=Color3.fromRGB(39,44,52)
Lighting.OutdoorAmbient=Color3.fromRGB(102,113,124)
Lighting.EnvironmentDiffuseScale=0.65 Lighting.EnvironmentSpecularScale=1
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",Lighting)
atmosphere.Density=0.24 atmosphere.Offset=0.05
atmosphere.Color=Color3.fromRGB(190,203,211) atmosphere.Decay=Color3.fromRGB(86,102,116)
atmosphere.Glare=0.13 atmosphere.Haze=1.65
for _,v in Lighting:GetChildren() do
 if v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then v.Enabled=false end
end
local grade=Instance.new("ColorCorrectionEffect") grade.Name="SurvivalFilmGrade"
grade.Contrast=0.09 grade.Saturation=-0.12 grade.TintColor=Color3.fromRGB(255,248,237) grade.Brightness=0 grade.Parent=Lighting
local bloom=Instance.new("BloomEffect") bloom.Name="RestrainedBloom" bloom.Intensity=0.12 bloom.Size=24 bloom.Threshold=1.4 bloom.Parent=Lighting
local rays=Instance.new("SunRaysEffect") rays.Name="LateAfternoonRays" rays.Intensity=0.025 rays.Spread=0.75 rays.Parent=Lighting
local dof=Instance.new("DepthOfFieldEffect") dof.Name="DistantFocus" dof.FocusDistance=80 dof.InFocusRadius=70 dof.NearIntensity=0 dof.FarIntensity=0.08 dof.Parent=Lighting
local sky=Lighting:FindFirstChildOfClass("Sky") if sky then sky.SunAngularSize=1.8 sky.MoonAngularSize=4 sky.StarCount=0 end
local clouds=workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds",workspace.Terrain)
clouds.Cover=0.72 clouds.Density=0.58 clouds.Color=Color3.fromRGB(176,185,189)
local count=0
for _,v in workspace:GetDescendants() do
 if v:IsA("BasePart") and not v:IsDescendantOf(workspace.TrainingDummy) then
  if v.Material==Enum.Material.Asphalt or v.Name=="Road" or v.Name=="MainAvenue" or v.Name=="CrossStreet" then
   v.Material=Enum.Material.Asphalt v.MaterialVariant="V2_WetBrokenAsphalt" v.Color=Color3.fromRGB(147,150,151)
  elseif v.Material==Enum.Material.Concrete then v.MaterialVariant="V2_AgedConcrete" v.Color=v.Color:Lerp(Color3.fromRGB(164,163,157),0.2)
  elseif v.Material==Enum.Material.CorrodedMetal then v.MaterialVariant="V2_OxidizedSteel" v.Color=Color3.fromRGB(170,155,141)
  end
  if v.Name=="Baseplate" then v.Color=Color3.fromRGB(67,75,70) v.Material=Enum.Material.Ground end
  count+=1 if count%500==0 then task.wait() end
 end
 if v:IsA("PointLight") then
  v.Brightness=math.min(v.Brightness,1.6)
  if v.Parent.Name=="SodiumLamp" then
   v.Color=Color3.fromRGB(255,207,145) v.Range=30 v:SetAttribute("FlickerBase",v.Brightness)
   local lamp=v.Parent
   local spot=Instance.new("SpotLight") spot.Name="StreetDownLight" spot.Face=Enum.NormalId.Bottom spot.Angle=105 spot.Range=26 spot.Brightness=2.1 spot.Color=v.Color spot.Shadows=true spot.Parent=lamp
   v.Shadows=false
  end
 end
end
for _,v in workspace.Baseplate:GetChildren() do if v:IsA("Texture") then v.Transparency=1 end end
local rng=Random.new(492)
local dark=Color3.fromRGB(42,49,49)
local function group(name)
 local g=Instance.new("Model") g.Name=name return g
end
local function part(g,name,size,cf,color,mat,collision)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Color=color or dark p.Material=mat or Enum.Material.Concrete
 p.Anchored=true p.CanCollide=collision==true p.CanQuery=collision==true p.CanTouch=false
 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=g return p
end
local function sign(g,cf,size,txt,color)
 local p=part(g,"WeatheredSign",size,cf,color,Enum.Material.CorrodedMetal)
 local s=Instance.new("SurfaceGui") s.Face=Enum.NormalId.Front s.PixelsPerStud=35 s.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud s.Parent=p
 local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Font=Enum.Font.Oswald t.Text=txt t.TextScaled=true t.TextColor3=Color3.fromRGB(218,215,195) t.TextTransparency=0.13 t.Parent=s
 return p
end
local details=group("StreetDetails")
-- Thin wet patches are cosmetic and never obstruct movement or casts.
for _,cx in {0,620,1240} do
 for i=1,15 do
  local z=rng:NextNumber(-245,0) local x=cx+rng:NextNumber(-17,17)
  local p=part(details,"RainPuddle",Vector3.new(rng:NextNumber(2,7),0.025,rng:NextNumber(3,10)),CFrame.new(x,0.355,z)*CFrame.Angles(0,rng:NextNumber(0,6),0),Color3.fromRGB(72,85,91),Enum.Material.Glass)
  p.Transparency=0.3 p.Reflectance=0.28
  for j=1,2 do
   local rim=part(details,"DampEdge",Vector3.new(p.Size.X+0.5,0.015,p.Size.Z+0.4),p.CFrame-Vector3.new(0,0.018,0),Color3.fromRGB(36,43,45),Enum.Material.Asphalt)
   rim.Transparency=0.25
  end
 end
 for _,z in {-40,-135,-225} do
  local manhole=part(details,"Manhole",Vector3.new(0.12,3.8,3.8),CFrame.new(cx+5,0.4,z)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(49,55,54),Enum.Material.DiamondPlate)
  manhole.Shape=Enum.PartType.Cylinder
  for j=-2,2 do part(details,"ManholeGroove",Vector3.new(2.7,0.018,0.08),CFrame.new(cx+5,0.47,z+j*0.4),Color3.fromRGB(21,27,27),Enum.Material.Metal) end
 end
end
for z=-240,0,35 do
 for _,x in {-21,21} do
  part(details,"Drain",Vector3.new(1.2,0.06,3.2),CFrame.new(x,0.49,z),dark,Enum.Material.Metal)
  for i=-3,3 do part(details,"DrainGrate",Vector3.new(1.15,0.03,0.13),CFrame.new(x,0.54,z+i*0.4),Color3.fromRGB(14,19,19),Enum.Material.Metal) end
 end
end
for i=1,30 do
 local x=rng:NextNumber(-17,17) local z=rng:NextNumber(-250,10)
 local p=part(details,"DiscardedPaper",Vector3.new(rng:NextNumber(0.4,0.9),0.025,rng:NextNumber(0.7,1.1)),CFrame.new(x,0.38,z)*CFrame.Angles(0,rng:NextNumber(0,6),0),Color3.fromRGB(151,146,124),Enum.Material.Fabric)
 p:SetAttribute("WindPaper",true)
end
details.Parent=root task.wait()
local facades=group("ArchitecturalDetails")
local district=workspace:FindFirstChild("ApocalypseDistrict")
if district then
 for _,building in district:GetChildren() do
  local foundation=building:FindFirstChild("Foundation")
  if foundation then
   local x,z=foundation.Position.X,foundation.Position.Z
   local w,d=foundation.Size.X-2,foundation.Size.Z-2
   local side=math.sign(x) local streetX=x-side*(w/2+0.25)
   local floors=0
   for _,v in building:GetChildren() do if v.Name=="ExposedFloor" then floors+=1 end end
   for fl=0,floors-1 do
    for bay=-1,1 do
     local bz=z+bay*(d/3)
     local y=fl*11+7.2
     for _,edge in {-1,1} do part(facades,"BrokenWindowFrame",Vector3.new(0.12,5.5,0.12),CFrame.new(streetX,y,bz+edge*d/7),dark,Enum.Material.Metal) end
     part(facades,"WindowRail",Vector3.new(0.12,0.1,d/3.5),CFrame.new(streetX,y+2.7,bz),dark,Enum.Material.Metal)
     if (fl+bay)%3==0 then
      local glass=part(facades,"GlassRemnant",Vector3.new(0.06,2.5,d/9),CFrame.new(streetX,y+1.1,bz-d/10)*CFrame.Angles(math.rad(8),0,0),Color3.fromRGB(111,139,144),Enum.Material.Glass)
      glass.Transparency=0.4 glass.Reflectance=0.12
     elseif fl>0 and bay==0 then
      part(facades,"TornCurtain",Vector3.new(0.1,4,d/11),CFrame.new(streetX+side*0.2,y,bz),Color3.fromRGB(103,99,86),Enum.Material.Fabric)
     end
    end
   end
   local roofY=floors*11+1
   for i=1,3 do
    local pipe=part(facades,"RoofVent",Vector3.new(0.6,3+i,0.6),CFrame.new(x-4+i*3,roofY+(3+i)/2,z),Color3.fromRGB(91,93,88),Enum.Material.CorrodedMetal)
    pipe.MaterialVariant="V2_OxidizedSteel"
   end
   part(facades,"RoofAntenna",Vector3.new(0.1,6,0.1),CFrame.new(x+8,roofY+3,z-6),dark,Enum.Material.Metal)
   part(facades,"AntennaCrossbar",Vector3.new(4,0.1,0.1),CFrame.new(x+8,roofY+4,z-6),dark,Enum.Material.Metal)
   if math.abs(x)<85 then
    local titles={"PHARMACIE","ATELIER 07","EVACUATION","MAGASIN FERME"}
    sign(facades,CFrame.new(streetX-side*0.15,5,z)*CFrame.Angles(0,side>0 and math.pi/2 or -math.pi/2,0),Vector3.new(14,2.5,0.22),titles[rng:NextInteger(1,#titles)],Color3.fromRGB(48,65,61))
   end
   task.wait()
  end
 end
end
facades.Parent=root
local camp=group("RefugeDetails")
for i=1,9 do
 local x=(i%2==0 and -1 or 1)*rng:NextNumber(20,25)
 local z=70+i*12
 local crate=part(camp,"SupplyCrate",Vector3.new(3,2.3,2.2),CFrame.new(x,1.4,z)*CFrame.Angles(0,rng:NextNumber(-0.3,0.3),0),Color3.fromRGB(85,83,57),Enum.Material.WoodPlanks,true)
 for _,sx in {-1,1} do part(camp,"CrateBand",Vector3.new(0.18,2.5,2.35),crate.CFrame*CFrame.new(sx*0.85,0,0),Color3.fromRGB(60,66,57),Enum.Material.Metal) end
end
sign(camp,CFrame.new(-22,6,182),Vector3.new(12,4,0.3),"POINT DE RALLIEMENT\nEAU / SOINS / REPOS",Color3.fromRGB(42,64,58))
local fireBarrel=part(camp,"RefugeFireBarrel",Vector3.new(3,2,2),CFrame.new(-17,1.5,185)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(100,78,58),Enum.Material.CorrodedMetal,true)
fireBarrel.Shape=Enum.PartType.Cylinder fireBarrel.MaterialVariant="V2_OxidizedSteel"
local attachment=Instance.new("Attachment") attachment.Position=Vector3.new(1.4,0,0) attachment.Parent=fireBarrel
local sparks=Instance.new("ParticleEmitter") sparks.Name="Embers" sparks.Texture="rbxasset://textures/particles/sparkles_main.dds" sparks.Rate=3 sparks.Lifetime=NumberRange.new(0.5,1.4) sparks.Speed=NumberRange.new(1,3)
sparks.Color=ColorSequence.new(Color3.fromRGB(255,152,65)) sparks.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.05),NumberSequenceKeypoint.new(1,0)}) sparks.LightEmission=1 sparks.SpreadAngle=Vector2.new(20,20) sparks.Parent=attachment
local fire=Instance.new("Fire") fire.Size=3.5 fire.Heat=4 fire.Parent=fireBarrel
local light=Instance.new("PointLight") light.Color=Color3.fromRGB(255,174,93) light.Range=19 light.Brightness=1.4 light:SetAttribute("FlickerBase",1.4) light.Parent=fireBarrel
camp.Parent=root task.wait()
-- Clearer, quieter portal visuals: replace forcefield shader with a restrained gate.
for _,v in workspace.ProgressionZones:GetDescendants() do
 if v:IsA("BasePart") and v.Name=="Field" then v.Material=Enum.Material.Glass v.Transparency=0.88 v.Reflectance=0.04
 elseif v:IsA("BasePart") and v.Name=="Pillar" then v.Material=Enum.Material.Metal end
end
return {dressingParts=#root:GetDescendants(),lighting=Lighting.LightingStyle.Name}
