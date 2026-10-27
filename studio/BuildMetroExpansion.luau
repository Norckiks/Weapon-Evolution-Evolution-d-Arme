-- One-shot Edit builder. Never install as a startup script.
assert(not game.RunService:IsRunning(),"Stop Play before building")
local root=workspace:WaitForChild("ProgressionZones") local ids={"Conductor","TunnelRunner","RailTitan"}
local existing=root:FindFirstChild("Metro")
if existing then
 assert(existing:GetAttribute("MetroBuildComplete")==true,"Inspect incomplete Metro before retrying")
 assert(root.RefugePortals:FindFirstChild("Travel_Metro") and root:FindFirstChild("MetroExpeditionPad"))
 for _,id in ids do assert(game.ServerStorage.ZombieTemplates:FindFirstChild(id),id) end
 return "Metro already built; no mutation"
end
assert(not root.RefugePortals:FindFirstChild("Travel_Metro") and not root:FindFirstChild("MetroExpeditionPad"))
for _,id in ids do assert(not game.ServerStorage.ZombieTemplates:FindFirstChild(id),id) end
local staging=Instance.new("Folder",game.ServerStorage) staging.Name="MetroBuildModules"
local config=game.ReplicatedStorage.WorldConfig:Clone() config.Parent=staging
local factory=game.ServerScriptService.ZombieFactory:Clone()
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1) factory.Parent=staging
local W=require(config) local F=require(factory) local zone
for _,z in W.Zones do if z.Id=="Metro" then zone=z break end end assert(zone)
local group=Instance.new("Model",root) group.Name="Metro" local x=zone.Center.X
local ink=Color3.fromRGB(37,47,46) local stone=Color3.fromRGB(99,110,104) local rust=Color3.fromRGB(133,99,69) local green=zone.Color
local function part(parent,name,size,pos,color,material,solid)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material or Enum.Material.Concrete p.Anchored=true p.CanCollide=solid~=false p.CanTouch=false p.CanQuery=solid~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local function chunk(name,fn)
 local model=Instance.new("Model") model.Name=name fn(model) model.Parent=group task.wait() return model
end
local function sign(parent,pos,size,message)
 local p=part(parent,"MetroSign",size,pos,ink,Enum.Material.Metal)
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
  local g=Instance.new("SurfaceGui",p) g.Face=face g.PixelsPerStud=24 g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
  local t=Instance.new("TextLabel",g) t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Font=Enum.Font.FredokaOne t.TextColor3=Color3.fromRGB(225,243,203) t.TextScaled=true t.Text=message
 end
end
chunk("Station",function(m)
 part(m,"Ground",Vector3.new(290,2,320),Vector3.new(x,-1,-120),stone)
 part(m,"CentralConcourse",Vector3.new(64,.18,300),Vector3.new(x,.09,-120),Color3.fromRGB(128,135,121))
 for _,side in {-1,1} do
  part(m,"TunnelWall",Vector3.new(3,26,320),Vector3.new(x+side*145,13,-120),ink)
  for _,z in {-50,-110,-170,-230} do
   part(m,"SupportPillar",Vector3.new(3,24,3),Vector3.new(x+side*48,12,z),stone)
   part(m,"WarningBand",Vector3.new(3.1,1,3.1),Vector3.new(x+side*48,3,z),green,Enum.Material.SmoothPlastic,false)
  end
 end
 part(m,"EndWall",Vector3.new(290,26,3),Vector3.new(x,13,-280),ink)
 sign(m,Vector3.new(x,15,-269),Vector3.new(58,6,1),"METRO OUBLIE\nDERNIER DEPART")
end)
for _,z in {-80,-195} do chunk("Canopy"..z,function(m)
 part(m,"Roof",Vector3.new(286,1.2,100),Vector3.new(x,25,z),ink,Enum.Material.Metal)
 for _,side in {-1,1} do
  local glow=part(m,"EmergencyLight",Vector3.new(14,.25,1.2),Vector3.new(x+side*24,23.5,z),green,Enum.Material.Neon,false)
  local l=Instance.new("PointLight",glow) l.Color=green l.Range=32 l.Brightness=1.3
 end
end) end
for _,side in {-1,1} do chunk("Track"..side,function(m)
 for _,dx in {-5,5} do part(m,"Rail",Vector3.new(.5,.35,285),Vector3.new(x+side*76+dx,.3,-120),rust,Enum.Material.CorrodedMetal) end
 for z=-250,10,12 do part(m,"Sleeper",Vector3.new(14,.16,1),Vector3.new(x+side*76,.08,z),ink,Enum.Material.Wood,false) end
end) end
for _,spec in {{-1,-105},{-1,-169},{1,-156},{1,-220}} do chunk("Carriage"..spec[1]..spec[2],function(m)
 local cx,z=x+spec[1]*76,spec[2]
 part(m,"CarriageBody",Vector3.new(16,9,56),Vector3.new(cx,5.5,z),Color3.fromRGB(62,116,98),Enum.Material.Metal)
 part(m,"TrainRoof",Vector3.new(17,1,58),Vector3.new(cx,10.5,z),ink,Enum.Material.Metal)
 for _,side in {-1,1} do for offset=-20,20,10 do
  part(m,"DarkWindow",Vector3.new(.1,3.5,6),Vector3.new(cx+side*8.08,7,z+offset),Color3.fromRGB(34,57,57),Enum.Material.Glass,false)
  part(m,"DoorFrame",Vector3.new(.16,7,1),Vector3.new(cx+side*8.12,4.5,z+offset+4),stone,Enum.Material.Metal,false)
 end end
 for _,dz in {-19,19} do for _,side in {-1,1} do
  local wheel=part(m,"TrainWheel",Vector3.new(1,2.8,2.8),Vector3.new(cx+side*7,1.5,z+dz),ink,Enum.Material.Metal) wheel.Shape=Enum.PartType.Cylinder
 end end
end) end
chunk("ConcourseDetails",function(m)
 sign(m,Vector3.new(x,17,-20),Vector3.new(48,4,.6),"LIGNE 06  /  AUCUN SERVICE")
 for _,side in {-1,1} do for _,z in {-62,-143,-220} do
  part(m,"Bench",Vector3.new(3,2,8),Vector3.new(x+side*39,1,z),rust,Enum.Material.Wood)
  part(m,"BenchBack",Vector3.new(.4,2,8),Vector3.new(x+side*40.4,3,z),ink,Enum.Material.Metal)
  part(m,"PlatformLine",Vector3.new(.6,.04,15),Vector3.new(x+side*32,.22,z),Color3.fromRGB(237,208,114),Enum.Material.SmoothPlastic,false)
 end end
 for _,spec in {{-13,-45},{15,-104},{-12,-180}} do
  local barrier=part(m,"Turnstile",Vector3.new(7,2,1.3),Vector3.new(x+spec[1],1,spec[2]),stone,Enum.Material.Metal) barrier:SetAttribute("VaultObstacle",true)
  part(m,"TurnstileStripe",Vector3.new(7.02,.2,1.32),barrier.Position+Vector3.new(0,.5,0),green,Enum.Material.SmoothPlastic,false)
 end
end)
local function portal(parent,pos,returning)
 local m=Instance.new("Model") m.Name=returning and "Return_Metro" or "Travel_Metro"
 part(m,"Platform",Vector3.new(12,.5,8),pos+Vector3.new(0,.25,0),ink,Enum.Material.DiamondPlate)
 for _,side in {-1,1} do part(m,"Pillar",Vector3.new(.7,10,.7),pos+Vector3.new(side*5,5,0),green,Enum.Material.Neon) end
 local field=part(m,"Field",Vector3.new(9.5,8.5,.3),pos+Vector3.new(0,4.5,0),green,Enum.Material.ForceField,false)
 field.Transparency=.65 field.CanQuery=true field:SetAttribute("Destination",returning and "Camp" or "Metro")
 local prompt=Instance.new("ProximityPrompt",field) prompt.Name="ZoneTravel" prompt.ActionText=returning and "Retour au refuge" or "Entrer" prompt.ObjectText=returning and "REFUGE" or "METRO - NIV. 35" prompt.HoldDuration=.35 prompt.MaxActivationDistance=10 prompt.RequiresLineOfSight=false
 sign(m,pos+Vector3.new(0,11,0),Vector3.new(19,2.8,.5),returning and "RETOUR REFUGE" or "METRO OUBLIE\nNIVEAU 35") m.Parent=parent
end
portal(group,Vector3.new(x+22,0,20),true)
part(root,"MetroExpeditionPad",Vector3.new(40,.3,22),Vector3.new(114,.15,215),ink,Enum.Material.Asphalt)
portal(root.RefugePortals,Vector3.new(128,0,208),false)
for _,id in ids do F.Build(game.ServerStorage.ZombieTemplates,id) task.wait() end
staging:Destroy() group:SetAttribute("MetroBuildComplete",true)
return {Zone=group:GetFullName(),Descendants=#group:GetDescendants(),Templates=ids}
