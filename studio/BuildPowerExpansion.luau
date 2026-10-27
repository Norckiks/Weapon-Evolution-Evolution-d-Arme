-- One-shot Edit builder. Never install as a startup Script.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building")
local root=workspace:WaitForChild("ProgressionZones")
local ids={"Lineman","SparkRunner","CoilGolem"}
local existing=root:FindFirstChild("Power")
if existing then
 assert(existing:GetAttribute("PowerBuildComplete")==true,"Incomplete Power: inspect before retrying")
 assert(root.RefugePortals:FindFirstChild("Travel_Power") and root:FindFirstChild("PowerExpeditionPad"),"Missing Power entry/pad")
 for _,id in ids do assert(game.ServerStorage.ZombieTemplates:FindFirstChild(id),id) end
 return "Power already built; no mutation"
end
assert(not root.RefugePortals:FindFirstChild("Travel_Power") and not root:FindFirstChild("PowerExpeditionPad"),"Partial Power entry")
for _,id in ids do assert(not game.ServerStorage.ZombieTemplates:FindFirstChild(id),"Template exists: "..id) end
local staging=Instance.new("Folder") staging.Name="PowerBuildModules" staging.Parent=game.ServerStorage
local config=game.ReplicatedStorage.WorldConfig:Clone() config.Parent=staging
local factory=game.ServerScriptService.ZombieFactory:Clone()
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=staging
local C=require(config) local F=require(factory) local zone
for _,z in C.Zones do if z.Id=="Power" then zone=z break end end assert(zone,"Install Power config first")
local group=Instance.new("Model") group.Name="Power" group.Parent=root
local x=zone.Center.X local ink=Color3.fromRGB(43,43,60) local steel=Color3.fromRGB(85,87,104)
local copper=Color3.fromRGB(153,100,64) local accent=zone.Color
local function p(parent,name,size,pos,color,material,solid)
 local v=Instance.new("Part") v.Name=name v.Size=size v.Position=pos v.Color=color v.Material=material or Enum.Material.Concrete
 v.Anchored=true v.CanCollide=solid~=false v.CanTouch=false v.CanQuery=solid~=false v.TopSurface=Enum.SurfaceType.Smooth v.BottomSurface=Enum.SurfaceType.Smooth v.Parent=parent return v
end
local function chunk(name,fn)
 local m=Instance.new("Model") m.Name=name fn(m) m.Parent=group task.wait() return m
end
local function sign(parent,pos,size,message)
 local v=p(parent,"PowerSign",size,pos,ink,Enum.Material.Metal)
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
  local g=Instance.new("SurfaceGui") g.Face=face g.PixelsPerStud=24 g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.Parent=v
  local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Font=Enum.Font.FredokaOne t.TextColor3=Color3.fromRGB(246,226,164) t.TextScaled=true t.Text=message t.Parent=g
 end
end
chunk("Courtyard",function(m)
 p(m,"Ground",Vector3.new(290,2,320),Vector3.new(x,-1,-120),Color3.fromRGB(72,69,79))
 p(m,"ServiceRoad",Vector3.new(86,.2,294),Vector3.new(x,.1,-120),ink,Enum.Material.Asphalt)
 for z=-250,0,22 do p(m,"LaneMark",Vector3.new(.8,.04,8),Vector3.new(x,.23,z),Color3.fromRGB(218,185,95),Enum.Material.SmoothPlastic,false) end
 for _,side in {-1,1} do p(m,"PerimeterWall",Vector3.new(2,12,320),Vector3.new(x+side*145,6,-120),steel) end
 p(m,"BackWall",Vector3.new(290,14,2),Vector3.new(x,7,-280),steel)
 sign(m,Vector3.new(x,16,-270),Vector3.new(62,6,1),"CENTRALE FOUDROYEE\nLA DERNIERE ETINCELLE")
end)
for i,spec in {{-91,-65},{91,-100},{-91,-155},{91,-225}} do
 chunk("Transformer"..i,function(m)
  local cx,z=x+spec[1],spec[2]
  p(m,"Foundation",Vector3.new(38,1,35),Vector3.new(cx,.5,z),steel)
  p(m,"TransformerCore",Vector3.new(24,13,22),Vector3.new(cx,7.5,z),copper,Enum.Material.CorrodedMetal)
  for j=-4,4 do p(m,"CoolingFin",Vector3.new(.5,11,25),Vector3.new(cx+j*2.8,7.5,z),ink,Enum.Material.Metal) end
  for _,side in {-1,1} do
   p(m,"InsulatorStem",Vector3.new(.9,7,.9),Vector3.new(cx+side*7,17,z),steel,Enum.Material.Metal)
   for j=1,4 do
    local disc=p(m,"InsulatorDisc",Vector3.new(2.8,.5,2.8),Vector3.new(cx+side*7,14+j*1.2,z),accent,Enum.Material.SmoothPlastic,false)
    disc.Shape=Enum.PartType.Ball
   end
   local tip=p(m,"TerminalGlow",Vector3.new(1.2,1.2,1.2),Vector3.new(cx+side*7,21,z),accent,Enum.Material.Neon,false)
   local l=Instance.new("PointLight") l.Color=accent l.Range=18 l.Brightness=1.4 l.Parent=tip
  end
  sign(m,Vector3.new(cx,6,z+12.6),Vector3.new(14,3,.3),"HAUTE TENSION\nNE PAS TOUCHER")
 end)
end
for i,spec in {{-119,-35},{119,-35},{-119,-245},{119,-245}} do
 chunk("Pylon"..i,function(m)
  local cx,z=x+spec[1],spec[2]
  for _,side in {-1,1} do
   local leg=p(m,"PylonLeg",Vector3.new(1.1,33,1.1),Vector3.new(cx+side*5,16.5,z),steel,Enum.Material.Metal)
   leg.CFrame*=CFrame.Angles(0,0,side*.1)
  end
  for h=5,29,6 do
   local brace=p(m,"PylonBrace",Vector3.new(12,.5,.5),Vector3.new(cx,h,z),copper,Enum.Material.Metal,false)
   brace.CFrame*=CFrame.Angles(0,0,(h%2==0 and 1 or -1)*.45)
  end
  p(m,"Crossarm",Vector3.new(22,1,1),Vector3.new(cx,31,z),steel,Enum.Material.Metal,false)
  for _,offset in {-8,0,8} do p(m,"CableTerminal",Vector3.new(1,3,1),Vector3.new(cx+offset,33,z),accent,Enum.Material.Neon,false) end
 end)
end
chunk("CoolingHall",function(m)
 p(m,"HallWall",Vector3.new(72,19,3),Vector3.new(x-90,9.5,-251),steel)
 p(m,"HallRoof",Vector3.new(76,1,35),Vector3.new(x-90,20,-248),ink,Enum.Material.Metal)
 for _,dx in {-20,20} do
  local stack=p(m,"CoolingStack",Vector3.new(19,15,15),Vector3.new(x-90+dx,30,-248),steel,Enum.Material.CorrodedMetal)
  stack.Shape=Enum.PartType.Cylinder stack.CFrame*=CFrame.Angles(0,0,math.pi/2)
  p(m,"StackRim",Vector3.new(17,1,17),Vector3.new(x-90+dx,40,-248),ink,Enum.Material.Metal,false)
 end
end)
chunk("RouteDetails",function(m)
 for _,z in {-20,-105,-190} do
  for _,side in {-1,1} do
   p(m,"LampPole",Vector3.new(.4,12,.4),Vector3.new(x+side*51,6,z),steel,Enum.Material.Metal)
   local tip=p(m,"LampGlow",Vector3.new(2,.4,2),Vector3.new(x+side*51,12,z),accent,Enum.Material.Neon,false)
   local l=Instance.new("PointLight") l.Color=accent l.Range=24 l.Brightness=1.2 l.Parent=tip
  end
 end
 for _,spec in {{-16,-29,2},{20,-45,1.7},{-48,-166,2.3}} do
  local cover=p(m,"CableCover",Vector3.new(7,spec[3],1.2),Vector3.new(x+spec[1],spec[3]/2+.2,spec[2]),copper,Enum.Material.Metal)
  cover:SetAttribute("VaultObstacle",true)
  p(m,"WarningStripe",Vector3.new(7.02,.16,1.23),cover.Position+Vector3.new(0,spec[3]*.25,0),Color3.fromRGB(237,202,87),Enum.Material.SmoothPlastic,false)
 end
end)
local function portal(parent,position,returning)
 local m=Instance.new("Model") m.Name=returning and "Return_Power" or "Travel_Power"
 p(m,"Platform",Vector3.new(12,.5,8),position+Vector3.new(0,.25,0),ink,Enum.Material.DiamondPlate)
 for _,side in {-1,1} do p(m,"Pillar",Vector3.new(.7,10,.7),position+Vector3.new(side*5,5,0),accent,Enum.Material.Neon) end
 local field=p(m,"Field",Vector3.new(9.5,8.5,.3),position+Vector3.new(0,4.5,0),accent,Enum.Material.ForceField,false)
 field.Transparency=.65 field.CanQuery=true field:SetAttribute("Destination",returning and "Camp" or "Power")
 local prompt=Instance.new("ProximityPrompt") prompt.Name="ZoneTravel" prompt.ActionText=returning and "Retour au refuge" or "Entrer" prompt.ObjectText=returning and "REFUGE" or "CENTRALE - NIV. 28" prompt.HoldDuration=.35 prompt.MaxActivationDistance=10 prompt.RequiresLineOfSight=false prompt.Parent=field
 sign(m,position+Vector3.new(0,11,0),Vector3.new(19,2.8,.5),returning and "RETOUR REFUGE" or "CENTRALE FOUDROYEE\nNIVEAU 28")
 m.Parent=parent
end
portal(group,Vector3.new(x+22,0,20),true)
p(root,"PowerExpeditionPad",Vector3.new(40,.3,22),Vector3.new(82,.15,215),ink,Enum.Material.Asphalt)
portal(root.RefugePortals,Vector3.new(96,0,208),false)
for _,id in ids do F.Build(game.ServerStorage.ZombieTemplates,id) task.wait() end
staging:Destroy() group:SetAttribute("PowerBuildComplete",true)
return {Zone=group:GetFullName(),Descendants=#group:GetDescendants(),Templates=ids,Entry="RefugePortals.Travel_Power"}
