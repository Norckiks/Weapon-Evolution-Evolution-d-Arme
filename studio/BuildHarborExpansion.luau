-- One-shot Edit builder. Never install as a startup Script. Does not replace existing zones/templates.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building")
local root=workspace:WaitForChild("ProgressionZones")
local existing=root:FindFirstChild("Harbor")
if existing then
 assert(existing:GetAttribute("HarborBuildComplete")==true,"Incomplete Harbor: inspect before retrying")
 assert(root.RefugePortals:FindFirstChild("Travel_Harbor"),"Missing Harbor entry")
 for _,id in {"Drowned","Raider","AnchorTitan"} do assert(game.ServerStorage.ZombieTemplates:FindFirstChild(id),id) end
 return "Harbor already built; no mutation"
end
assert(not root.RefugePortals:FindFirstChild("Travel_Harbor"),"Entry exists without zone")
for _,id in {"Drowned","Raider","AnchorTitan"} do assert(not game.ServerStorage.ZombieTemplates:FindFirstChild(id),"Template already exists: "..id) end
-- Separate module instances avoid reusing an Edit command's older require cache.
local staging=Instance.new("Folder") staging.Name="HarborBuildModules" staging.Parent=game.ServerStorage
local config=game.ReplicatedStorage.WorldConfig:Clone() config.Parent=staging
local factory=game.ServerScriptService.ZombieFactory:Clone()
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=staging
local C=require(config) local F=require(factory) local zone
for _,z in C.Zones do if z.Id=="Harbor" then zone=z break end end assert(zone,"Install Harbor config first")
local group=Instance.new("Model") group.Name="Harbor" group:SetAttribute("HarborBuildVersion",1) group.Parent=root
local x=zone.Center.X local ink=Color3.fromRGB(45,58,63) local rust=Color3.fromRGB(127,83,58) local accent=zone.Color
local function p(parent,name,size,pos,color,material,solid)
 local v=Instance.new("Part") v.Name=name v.Size=size v.Position=pos v.Color=color v.Material=material or Enum.Material.Concrete
 v.Anchored=true v.CanCollide=solid~=false v.CanTouch=false v.CanQuery=solid~=false v.TopSurface=Enum.SurfaceType.Smooth v.BottomSurface=Enum.SurfaceType.Smooth v.Parent=parent return v
end
local function chunk(name,fn)
 local m=Instance.new("Model") m.Name=name fn(m) m.Parent=group task.wait() return m
end
local function sign(parent,pos,size,message)
 local v=p(parent,"HarborSign",size,pos,ink,Enum.Material.Metal)
 local g=Instance.new("SurfaceGui") g.Face=Enum.NormalId.Front g.PixelsPerStud=24 g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.Parent=v
 local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Font=Enum.Font.Cartoon t.TextColor3=Color3.fromRGB(247,226,174) t.TextScaled=true t.Text=message t.Parent=g return v
end
chunk("Quays",function(m)
 p(m,"Ground",Vector3.new(290,2,320),Vector3.new(x,-1,-120),Color3.fromRGB(73,80,80))
 p(m,"Avenue",Vector3.new(88,.2,294),Vector3.new(x,.1,-120),Color3.fromRGB(47,53,55),Enum.Material.Asphalt)
 -- Decorative water over a solid shallow bed: no hidden damaging or drowning volume.
 local water=p(m,"AshWater",Vector3.new(45,.2,283),Vector3.new(x+120,.15,-133),Color3.fromRGB(40,77,87),Enum.Material.Glass,false) water.Transparency=.3
 for z=-250,0,22 do p(m,"LaneMark",Vector3.new(.7,.04,8),Vector3.new(x,.23,z),Color3.fromRGB(197,166,91),Enum.Material.SmoothPlastic,false) end
 for _,side in {-1,1} do p(m,"PerimeterWall",Vector3.new(2,12,320),Vector3.new(x+side*145,6,-120),ink) end
 p(m,"BackWall",Vector3.new(290,14,2),Vector3.new(x,7,-280),ink)
 sign(m,Vector3.new(x,15,-265),Vector3.new(54,5,1),"PORT DES CENDRES\nLES QUAIS SONT PERDUS")
 for z=-250,-20,38 do
  p(m,"QuayEdge",Vector3.new(1.2,.5,34),Vector3.new(x+95,.45,z),rust,Enum.Material.CorrodedMetal)
  for _,dx in {-65,85} do
   p(m,"Bollard",Vector3.new(1,1.7,1),Vector3.new(x+dx,.85,z),ink,Enum.Material.Metal)
   p(m,"BollardCap",Vector3.new(2,.35,1.3),Vector3.new(x+dx,1.7,z),rust,Enum.Material.CorrodedMetal,false)
  end
 end
end)
for i,spec in {{-100,-50,Color3.fromRGB(121,83,60)},{-105,-115,Color3.fromRGB(55,100,111)},{-100,-195,Color3.fromRGB(116,114,73)},{-105,-115,Color3.fromRGB(112,72,62),10}} do
 chunk("BrokenContainer"..i,function(m)
  local cx,cz=x+spec[1],spec[2] local y=spec[4] or 0 local color=spec[3]
  p(m,"Floor",Vector3.new(48,.4,25),Vector3.new(cx,y+.2,cz),ink,Enum.Material.DiamondPlate)
  p(m,"RearWall",Vector3.new(48,9,.4),Vector3.new(cx,y+4.7,cz-12.3),color,Enum.Material.CorrodedMetal)
  p(m,"WestWall",Vector3.new(.4,9,25),Vector3.new(cx-23.8,y+4.7,cz),color,Enum.Material.CorrodedMetal)
  local roof=p(m,"BuckledRoof",Vector3.new(48,.4,25),Vector3.new(cx,y+9.4,cz),color,Enum.Material.CorrodedMetal) roof.CFrame*=CFrame.Angles(0,0,.035)
  for j=-3,3 do p(m,"CorrugatedRib",Vector3.new(.22,8.8,.2),Vector3.new(cx+j*6,y+4.7,cz+12.4),ink,Enum.Material.Metal,false) end
  for _,side in {-1,1} do
   local door=p(m,"TornDoor",Vector3.new(23,8.8,.3),Vector3.new(cx+side*12,y+4.7,cz+12.3+side*3),color,Enum.Material.CorrodedMetal)
   door.CFrame*=CFrame.Angles(0,side*.25,0)
  end
 end)
end
for i,z in {-85,-210} do
 chunk("CargoCrane"..i,function(m)
  p(m,"CraneFoot",Vector3.new(15,2,18),Vector3.new(x+112,1,z),ink,Enum.Material.Concrete)
  for _,offset in {-5,5} do p(m,"CraneLeg",Vector3.new(2.2,32,2.2),Vector3.new(x+112+offset,17,z),rust,Enum.Material.CorrodedMetal) end
  p(m,"CraneCab",Vector3.new(10,6,8),Vector3.new(x+109,30,z),Color3.fromRGB(158,127,63),Enum.Material.CorrodedMetal)
  p(m,"CraneGlass",Vector3.new(.12,3,5),Vector3.new(x+103.9,30,z),Color3.fromRGB(65,107,117),Enum.Material.Glass,false)
  p(m,"Boom",Vector3.new(105,2.5,3),Vector3.new(x+68,35,z),rust,Enum.Material.CorrodedMetal,false)
  for j=0,8 do
   local brace=p(m,"BoomBrace",Vector3.new(1,6,1),Vector3.new(x+19+j*12,34,z),ink,Enum.Material.Metal,false) brace.CFrame*=CFrame.Angles(0,0,.7)
  end
  p(m,"Cable",Vector3.new(.12,23,.12),Vector3.new(x+27,22,z),ink,Enum.Material.Metal,false)
  p(m,"CargoHook",Vector3.new(1.5,1.5,.4),Vector3.new(x+27,10,z),rust,Enum.Material.CorrodedMetal,false)
 end)
end
for i,z in {-135,-245} do
 chunk("GroundedWreck"..i,function(m)
  local hull=p(m,"Hull",Vector3.new(24,4,43),Vector3.new(x+118,2.5,z),rust,Enum.Material.CorrodedMetal) hull.CFrame*=CFrame.Angles(0,.08,.10)
  p(m,"Deck",Vector3.new(21,.4,38),Vector3.new(x+118,4.8,z),ink,Enum.Material.DiamondPlate)
  p(m,"Wheelhouse",Vector3.new(12,6,10),Vector3.new(x+119,8,z+8),Color3.fromRGB(142,148,134),Enum.Material.Metal)
  p(m,"CabWindow",Vector3.new(9,2,.15),Vector3.new(x+119,8.5,z+2.9),Color3.fromRGB(52,85,94),Enum.Material.Glass,false)
  p(m,"Mast",Vector3.new(.3,14,.3),Vector3.new(x+118,12,z-5),ink,Enum.Material.Metal,false)
  p(m,"MastCross",Vector3.new(10,.25,.25),Vector3.new(x+118,17,z-5),ink,Enum.Material.Metal,false)
 end)
end
chunk("RouteDetails",function(m)
 for _,z in {-25,-105,-185,-245} do
  for _,side in {-1,1} do
   p(m,"LampPole",Vector3.new(.4,13,.4),Vector3.new(x+side*54,6.5,z),ink,Enum.Material.Metal)
   local glow=p(m,"LampGlow",Vector3.new(1.8,.3,1.8),Vector3.new(x+side*54,13,z),accent,Enum.Material.Neon,false)
   local l=Instance.new("PointLight") l.Color=accent l.Range=26 l.Brightness=1.3 l.Parent=glow
  end
 end
 for _,spec in {{-18,-28,2.1},{22,-45,1.7},{-52,-162,2.4}} do
  local core=p(m,"CargoCover",Vector3.new(6,spec[3],1.2),Vector3.new(x+spec[1],.2+spec[3]/2,spec[2]),rust,Enum.Material.CorrodedMetal)
  core:SetAttribute("VaultObstacle",true)
  p(m,"CoverStripe",Vector3.new(6.03,.18,1.23),core.Position+Vector3.new(0,spec[3]*.25,0),Color3.fromRGB(213,168,71),Enum.Material.Metal,false)
 end
 sign(m,Vector3.new(x-52,6,0),Vector3.new(22,4,.4),"PORT DES CENDRES\nACCES NIVEAU 20")
end)
local function portal(parent,position,returning)
 local m=Instance.new("Model") m.Name=returning and "Return_Harbor" or "Travel_Harbor"
 p(m,"Platform",Vector3.new(12,.5,8),position+Vector3.new(0,.25,0),ink,Enum.Material.DiamondPlate)
 for _,side in {-1,1} do p(m,"Pillar",Vector3.new(.7,10,.7),position+Vector3.new(side*5,5,0),accent,Enum.Material.Neon) end
 local field=p(m,"Field",Vector3.new(9.5,8.5,.3),position+Vector3.new(0,4.5,0),accent,Enum.Material.ForceField,false)
 field.Transparency=.65 field.CanQuery=true field:SetAttribute("Destination",returning and "Camp" or "Harbor")
 local prompt=Instance.new("ProximityPrompt") prompt.Name="ZoneTravel" prompt.ActionText=returning and "Retour au refuge" or "Entrer" prompt.ObjectText=returning and "REFUGE" or "PORT DES CENDRES - NIV. 20" prompt.HoldDuration=.35 prompt.MaxActivationDistance=10 prompt.RequiresLineOfSight=false prompt.Parent=field
 sign(m,position+Vector3.new(0,11,0),Vector3.new(18,2.8,.5),returning and "RETOUR REFUGE" or "PORT DES CENDRES\nNIVEAU 20")
 m.Parent=parent return m
end
portal(group,Vector3.new(x+22,0,20),true)
-- New pad overlaps the old apron edge; no existing part is resized or removed.
local pad=p(root,"HarborExpeditionPad",Vector3.new(24,.3,22),Vector3.new(62,.15,215),Color3.fromRGB(57,63,63),Enum.Material.Asphalt)
portal(root.RefugePortals,Vector3.new(64,0,208),false)
for _,id in zone.Types do F.Build(game.ServerStorage.ZombieTemplates,id) task.wait() end
staging:Destroy()
group:SetAttribute("HarborBuildComplete",true)
return {Zone=group:GetFullName(),Descendants=#group:GetDescendants(),Templates=zone.Types,Entry="RefugePortals.Travel_Harbor",Version=1}
