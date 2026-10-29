-- One-shot Edit builder. Run via require only; never install as startup code.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
local RS=game:GetService("ReplicatedStorage")
local root=workspace:WaitForChild("ProgressionZones")
local portals=root:WaitForChild("RefugePortals")
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
local defs={
 {Id="Quarantine",X=3720,Level=45,Name="FOSSE DE QUARANTAINE",Color=Color3.fromRGB(220,166,86),Ground=Color3.fromRGB(71,76,60),Wall=Color3.fromRGB(83,82,64),Material=Enum.Material.Mud,EntryX=-27,Types={"Warden","MireRunner","QuakeBrute"},Sign="SECTEUR 09  /  CONFINEMENT"},
 {Id="Dam",X=4340,Level=60,Name="BARRAGE DES NOYES",Color=Color3.fromRGB(95,174,190),Ground=Color3.fromRGB(49,68,75),Wall=Color3.fromRGB(64,85,91),Material=Enum.Material.Asphalt,EntryX=-61,Types={"Flooded","Skirmisher","Leviathan"},Sign="BARRAGE  /  NIVEAU D'EAU CRITIQUE"},
 {Id="Citadel",X=4960,Level=80,Name="CITADELLE DES CENDRES",Color=Color3.fromRGB(180,143,214),Ground=Color3.fromRGB(69,62,76),Wall=Color3.fromRGB(86,72,89),Material=Enum.Material.Basalt,EntryX=-95,Types={"Sentry","Glitch","Colossus"},Sign="CITADELLE  /  DERNIER REFUGE"}
}
for _,d in defs do
 assert(not root:FindFirstChild(d.Id),"Zone exists: "..d.Id)
 assert(not portals:FindFirstChild("Travel_"..d.Id),"Portal exists: "..d.Id)
 for _,id in d.Types do assert(not templates:FindFirstChild(id),"Zombie template exists: "..id) end
end
local stage=Instance.new("Folder") stage.Name="FrontierBuildModules" stage.Parent=game.ServerStorage
local world=RS.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
local old='local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))'
assert(factory.Source:find(old,1,true),"ZombieFactory dependency changed; inspect first")
factory.Source=factory.Source:gsub("local Config=require%(game.ReplicatedStorage:WaitForChild%(\"WorldConfig\"%)%)","local Config=require(script.Parent.WorldConfig)",1)
factory.Parent=stage
local Factory=require(factory)
local function part(parent,name,size,pos,color,material,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material or Enum.Material.Concrete
 p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local function sign(parent,name,pos,text,color,size)
	local p=part(parent,name,size or Vector3.new(42,5,.8),pos,Color3.fromRGB(34,39,43),Enum.Material.Metal,false)
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
  local gui=Instance.new("SurfaceGui") gui.Face=face gui.PixelsPerStud=20 gui.Parent=p
  local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.Font=Enum.Font.FredokaOne label.TextScaled=true label.TextColor3=color label.Text=text label.Parent=gui
 end
end
local function portal(parent,name,pos,destination,label,color)
 local m=Instance.new("Model") m.Name=name
 part(m,"Platform",Vector3.new(13,.6,9),pos+Vector3.new(0,.3,0),Color3.fromRGB(39,46,47),Enum.Material.DiamondPlate)
 for _,side in {-1,1} do
  local p=part(m,"Pillar",Vector3.new(.8,10,.8),pos+Vector3.new(side*5,5,0),color,Enum.Material.Neon,false)
  local l=Instance.new("PointLight") l.Color=color l.Range=18 l.Brightness=.6 l.Parent=p
 end
 local field=part(m,"Field",Vector3.new(9.5,8.5,.3),pos+Vector3.new(0,4.5,0),color,Enum.Material.ForceField,false)
 field.Transparency=.68 field.CanQuery=true field:SetAttribute("Destination",destination)
 local prompt=Instance.new("ProximityPrompt") prompt.Name="ZoneTravel" prompt.ActionText="Entrer" prompt.ObjectText=label prompt.HoldDuration=.35 prompt.MaxActivationDistance=10 prompt.RequiresLineOfSight=false prompt.Parent=field
	 sign(m,"ZoneSign",pos+Vector3.new(0,11,0),label,color,Vector3.new(22,2.8,.5)) m.Parent=parent return m
end
for _,d in defs do
 local group=Instance.new("Model") group.Name=d.Id
 local x=d.X
 part(group,"Ground",Vector3.new(290,2,320),Vector3.new(x,-1,-120),d.Ground,d.Material)
 part(group,"MainPath",Vector3.new(34,.14,285),Vector3.new(x,.08,-120),Color3.fromRGB(104,102,91),Enum.Material.Concrete,false)
 for _,side in {-1,1} do
  part(group,"RetainingWall",Vector3.new(3,18,320),Vector3.new(x+side*145,9,-120),d.Wall,Enum.Material.Concrete)
  for _,z in {-238,-175,-112,-49} do
   part(group,"Barrier",Vector3.new(8,2.4,2),Vector3.new(x+side*45,1.2,z),Color3.fromRGB(43,48,48),Enum.Material.CorrodedMetal)
   local lamp=part(group,"Signal",Vector3.new(1.2,.25,1.2),Vector3.new(x+side*45,4,z),d.Color,Enum.Material.Neon,false)
   local light=Instance.new("PointLight") light.Color=d.Color light.Range=11 light.Brightness=.35 light.Parent=lamp
  end
 end
 for _,z in {-210,-135,-60} do
  part(group,"Cover",Vector3.new(20,6,5),Vector3.new(x-66,3,z),d.Wall,Enum.Material.CorrodedMetal)
  part(group,"CoverTop",Vector3.new(21,.6,6),Vector3.new(x-66,6.3,z),Color3.fromRGB(38,43,43),Enum.Material.Metal)
  part(group,"Crate",Vector3.new(5,5,5),Vector3.new(x+67,2.5,z+18),d.Wall,Enum.Material.WoodPlanks)
 end
 sign(group,"ZoneSign",Vector3.new(x,13,-272),d.Sign,d.Color)
 portal(group,"Return_"..d.Id,Vector3.new(x+22,0,20),"Camp","RETOUR AU REFUGE",d.Color)
 group:SetAttribute("FrontierBuildComplete",true) group.Parent=root
 portal(portals,"Travel_"..d.Id,Vector3.new(d.EntryX,0,252),d.Id,d.Name.." - NIV. "..d.Level,d.Color)
 for _,zid in d.Types do Factory.Build(templates,zid) end
 task.wait()
end
part(root,"QuarantineExpeditionPad",Vector3.new(38,.3,22),Vector3.new(26,.15,258),Color3.fromRGB(54,59,52),Enum.Material.Asphalt)
part(root,"DamExpeditionPad",Vector3.new(38,.3,22),Vector3.new(62,.15,258),Color3.fromRGB(48,63,69),Enum.Material.Asphalt)
part(root,"CitadelExpeditionPad",Vector3.new(38,.3,22),Vector3.new(98,.15,258),Color3.fromRGB(62,54,72),Enum.Material.Asphalt)
stage:Destroy()
return {Zones=3,Species=9,Portals=6,TemplateCount=#defs*3}

