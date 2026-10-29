-- One-shot Edit builder for a replaceable level-200 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building IronSanctum")
local root=workspace:WaitForChild("ProgressionZones") local portals=root:WaitForChild("RefugePortals")
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("IronSanctum"),"IronSanctum already exists; inspect before rebuilding")
assert(not portals:FindFirstChild("Travel_IronSanctum"),"IronSanctum portal already exists; inspect before rebuilding")
for _,id in {"CrucibleGuard","CinderRunner","ForgeTitan"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="IronSanctumBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage local Factory=require(factory)
local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(8680,0,-120) local zone=Instance.new("Model") zone.Name="IronSanctum" zone:SetAttribute("RequiredLevel",200)
local floor=Color3.fromRGB(58,54,53) local steel=Color3.fromRGB(91,78,73) local ember=Color3.fromRGB(241,110,69)
local function part(parent,name,size,pos,color,material,collide,className)
 local p=Instance.new(className or "Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(zone,"FoundryFloor",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),floor,Enum.Material.Concrete)
part(zone,"EntryCauseway",Vector3.new(36,.2,106),center+Vector3.new(0,.1,102),steel,Enum.Material.Metal,false)
for _,x in {-137,137} do part(zone,"FoundryWall",Vector3.new(16,24,300),center+Vector3.new(x,12,0),steel,Enum.Material.CorrodedMetal) end
for _,z in {-142,142} do part(zone,"FoundryWall",Vector3.new(258,24,16),center+Vector3.new(0,12,z),steel,Enum.Material.CorrodedMetal) end
for _,x in {-86,86} do
 local furnace=part(zone,"BlastFurnace",Vector3.new(34,32,34),center+Vector3.new(x,16,-34),Color3.fromRGB(68,61,59),Enum.Material.CorrodedMetal)
 part(zone,"FurnaceWindow",Vector3.new(19,8,1),furnace.Position+Vector3.new(0,0,-17.6),ember,Enum.Material.Neon,false)
 part(zone,"SmokeStack",Vector3.new(8,18,8),furnace.Position+Vector3.new(0,24,0),steel,Enum.Material.Metal)
end
part(zone,"Conveyor",Vector3.new(26,2,148),center+Vector3.new(0,1,-132),Color3.fromRGB(72,69,65),Enum.Material.DiamondPlate)
for _,x in {-12,12} do part(zone,"ConveyorRail",Vector3.new(1,3,148),center+Vector3.new(x,2,-132),steel,Enum.Material.Metal) end
for i=1,8 do
 local x=i%2==0 and 108 or -108 local z=-208+math.floor((i-1)/2)*42
 local beam=part(zone,"FallenIBeam",Vector3.new(18,3,9),center+Vector3.new(x,2,z),i%2==0 and steel or Color3.fromRGB(112,72,59),Enum.Material.CorrodedMetal)
 beam.CFrame=CFrame.new(beam.Position)*CFrame.Angles(0,(i%4)*math.pi/8,math.rad(i%2==0 and 10 or -12))
end
for i=1,6 do
 local x=i%2==0 and 38 or -38 local z=-205+(i-1)*34
 part(zone,"MoltenRunoff",Vector3.new(3,.4,26),center+Vector3.new(x,.4,z),Color3.fromRGB(218,83,53),Enum.Material.Neon,false)
end
local ret=root:WaitForChild("Depths"):WaitForChild("Return_Depths"):Clone() ret.Name="Return_IronSanctum"
local back=ret:FindFirstChild("Field",true) assert(back and back:IsA("BasePart"),"Depths return Field missing") back:SetAttribute("Destination","Camp")
ret:PivotTo(CFrame.new(center+Vector3.new(0,4.5,20))*CFrame.new(-back.Position)*ret:GetPivot()) ret.Parent=zone
for _,id in {"CrucibleGuard","CinderRunner","ForgeTitan"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_Depths"):Clone() entry.Name="Travel_IronSanctum"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: IronSanctum")
portalPrompt.ObjectText="FONDERIE DU DERNIER JOUR - NIV. 200"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"Depths portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="FONDERIE DU DERNIER JOUR\nNIVEAU 200" end end
local field=entry:FindFirstChild("Field",true) assert(field and field:IsA("BasePart"),"Depths entry Field missing") field:SetAttribute("Destination","IronSanctum")
entry:PivotTo(CFrame.new(256,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
zone.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.IronSanctum",entry="Workspace.ProgressionZones.RefugePortals.Travel_IronSanctum",returnGate="Workspace.ProgressionZones.IronSanctum.Return_IronSanctum",species=3,descendants=#zone:GetDescendants()+#entry:GetDescendants()}
