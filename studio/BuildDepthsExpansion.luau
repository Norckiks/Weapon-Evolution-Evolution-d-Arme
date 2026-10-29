-- One-shot Edit builder for a replaceable level-180 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building the Depths")
local root=workspace:WaitForChild("ProgressionZones")
local portals=root:WaitForChild("RefugePortals")
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("Depths"),"Depths already exists; inspect before rebuilding")
assert(not portals:FindFirstChild("Travel_Depths"),"Depths portal already exists; inspect before rebuilding")
for _,id in {"VaultWarden","SirenRunner","ContainmentGoliath"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="DepthsBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage
local Factory=require(factory)
local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(8060,0,-120)
local zone=Instance.new("Model") zone.Name="Depths" zone:SetAttribute("RequiredLevel",180)
local concrete=Color3.fromRGB(48,60,59) local steel=Color3.fromRGB(76,91,87) local glow=Color3.fromRGB(91,190,158)
local function part(parent,name,size,pos,color,material,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(zone,"VaultFloor",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),concrete,Enum.Material.Concrete)
part(zone,"EntryWalkway",Vector3.new(34,.2,104),center+Vector3.new(0,.1,102),steel,Enum.Material.Metal,false)
for _,x in {-137,137} do part(zone,"RetainingWall",Vector3.new(16,22,300),center+Vector3.new(x,11,0),steel,Enum.Material.CorrodedMetal) end
for _,z in {-142,142} do part(zone,"RetainingWall",Vector3.new(258,22,16),center+Vector3.new(0,11,z),steel,Enum.Material.CorrodedMetal) end
part(zone,"DecontaminationPad",Vector3.new(64,2,58),center+Vector3.new(0,1,-28),Color3.fromRGB(73,90,82),Enum.Material.DiamondPlate)
part(zone,"PressureDoor",Vector3.new(52,26,4),center+Vector3.new(0,13,-92),Color3.fromRGB(44,58,55),Enum.Material.Metal)
part(zone,"PressureDoorWarning",Vector3.new(24,2,.4),center+Vector3.new(0,19,-89.8),glow,Enum.Material.Neon,false)
for _,x in {-54,54} do
 for _,z in {-64,-144,-224} do
  local col=part(zone,"SupportColumn",Vector3.new(10,24,12),center+Vector3.new(x,12,z),steel,Enum.Material.CorrodedMetal)
  part(zone,"EmergencyLamp",Vector3.new(3,.6,2),col.Position+Vector3.new(0,12.4,0),glow,Enum.Material.Neon,false)
 end
end
for i=1,8 do
 local x=i%2==0 and 96 or -96 local z=-215+math.floor((i-1)/2)*46
 local debris=part(zone,"CollapsedBulkhead",Vector3.new(20,3,12),center+Vector3.new(x,2,z),i%2==0 and steel or Color3.fromRGB(92,75,61),Enum.Material.CorrodedMetal)
 debris.CFrame=CFrame.new(debris.Position)*CFrame.Angles(0,(i%4)*math.pi/8,math.rad(i%2==0 and 13 or -11))
end
for i=1,5 do
 local x=i%2==0 and 30 or -30 local z=-180-i*25
 part(zone,"DrainChannel",Vector3.new(2,.35,22),center+Vector3.new(x,.3,z),Color3.fromRGB(62,139,119),Enum.Material.Neon,false)
end
local returnGate=root:WaitForChild("OrbitalWreck"):WaitForChild("Return_OrbitalWreck"):Clone()
returnGate.Name="Return_Depths"
local backField=returnGate:FindFirstChild("Field",true) assert(backField and backField:IsA("BasePart"),"Orbital return Field missing")
backField:SetAttribute("Destination","Camp")
returnGate:PivotTo(CFrame.new(center+Vector3.new(0,4.5,20))*CFrame.new(-backField.Position)*returnGate:GetPivot())
returnGate.Parent=zone
for _,id in {"VaultWarden","SirenRunner","ContainmentGoliath"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_OrbitalWreck"):Clone()
entry.Name="Travel_Depths"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: Depths")
portalPrompt.ObjectText="BUNKER DES PROFONDEURS - NIV. 180"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"Orbital portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="BUNKER DES PROFONDEURS\nNIVEAU 180" end end
local field=entry:FindFirstChild("Field",true) assert(field and field:IsA("BasePart"),"Orbital entry Field missing")
field:SetAttribute("Destination","Depths")
entry:PivotTo(CFrame.new(224,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
zone.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.Depths",entry="Workspace.ProgressionZones.RefugePortals.Travel_Depths",returnGate="Workspace.ProgressionZones.Depths.Return_Depths",species=3,descendants=#zone:GetDescendants()+#entry:GetDescendants()}
