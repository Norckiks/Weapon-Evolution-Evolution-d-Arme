-- One-shot Edit builder for a replaceable level-280 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building EclipseVault")
local root=workspace:WaitForChild("ProgressionZones") local portals=root:WaitForChild("RefugePortals") local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("EclipseVault"),"EclipseVault already exists; inspect before rebuilding") assert(not portals:FindFirstChild("Travel_EclipseVault"),"EclipseVault portal already exists; inspect before rebuilding")
for _,id in {"EclipseWarden","NightStalker","VaultGoliath"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="EclipseVaultBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage local Factory=require(factory) local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(11160,0,-120) local zone=Instance.new("Model") zone.Name="EclipseVault" zone:SetAttribute("RequiredLevel",280)
local slate=Color3.fromRGB(49,46,62) local stone=Color3.fromRGB(84,76,99) local metal=Color3.fromRGB(102,99,121) local violet=Color3.fromRGB(176,133,231)
local function part(parent,name,size,pos,color,material,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(zone,"VaultForecourt",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),slate,Enum.Material.Slate)
part(zone,"EntryCauseway",Vector3.new(36,.2,106),center+Vector3.new(0,.1,102),metal,Enum.Material.Concrete,false)
for _,x in {-137,137} do part(zone,"VaultRetainingWall",Vector3.new(16,28,300),center+Vector3.new(x,14,0),stone,Enum.Material.Cobblestone) end
for _,z in {-142,142} do part(zone,"VaultRetainingWall",Vector3.new(258,28,16),center+Vector3.new(0,14,z),stone,Enum.Material.Cobblestone) end
-- Broken ribs frame the sealed door; their bases stay outside the combat lanes.
for i,x in {-112,-70,70,112} do
 local rib=part(zone,"VaultRib",Vector3.new(6,38,8),center+Vector3.new(x,19,-54),stone,Enum.Material.Cobblestone)
 rib.CFrame=CFrame.new(rib.Position)*CFrame.Angles(0,0,math.rad(x<0 and -8 or 8))
 part(zone,"RibFoot",Vector3.new(16,5,18),center+Vector3.new(x,2.5,-54),metal,Enum.Material.CorrodedMetal)
end
local door=part(zone,"SealedVaultDoor",Vector3.new(38,32,5),center+Vector3.new(0,16,-86),metal,Enum.Material.DiamondPlate)
for _,offset in {-12,-6,0,6,12} do part(zone,"DoorRivet",Vector3.new(1.4,27,1.4),door.Position+Vector3.new(offset,0,-3),violet,Enum.Material.Neon,false) end
part(zone,"VaultThreshold",Vector3.new(54,2,10),center+Vector3.new(0,1,-90),stone,Enum.Material.Cobblestone)
for i=1,8 do
 local x=i%2==0 and 94 or -94 local z=-190+math.floor((i-1)/2)*42
 local sarcophagus=part(zone,"CollapsedStoragePod",Vector3.new(22,8,17),center+Vector3.new(x,4,z),i%2==0 and metal or stone,Enum.Material.CorrodedMetal)
 sarcophagus.CFrame=CFrame.new(sarcophagus.Position)*CFrame.Angles(0,math.rad(i%2==0 and 11 or -11),math.rad(i%3==0 and 7 or 0))
 part(zone,"PodSeal",Vector3.new(16,1,1),sarcophagus.Position+Vector3.new(0,2,-9),violet,Enum.Material.Neon,false)
end
local ret=root:WaitForChild("BlackoutCore"):WaitForChild("Return_BlackoutCore"):Clone() ret.Name="Return_EclipseVault"
local back=ret:FindFirstChild("Field",true) assert(back and back:IsA("BasePart"),"BlackoutCore return Field missing") back:SetAttribute("Destination","Camp")
ret:PivotTo(CFrame.new(center+Vector3.new(0,4.5,20))*CFrame.new(-back.Position)*ret:GetPivot()) ret.Parent=zone
for _,id in {"EclipseWarden","NightStalker","VaultGoliath"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_BlackoutCore"):Clone() entry.Name="Travel_EclipseVault"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: EclipseVault")
portalPrompt.ObjectText="VOUTE DE L'ECLIPSE - NIV. 280"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"BlackoutCore portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="VOUTE DE L'ECLIPSE\nNIVEAU 280" end end
local field=entry:FindFirstChild("Field",true) assert(field and field:IsA("BasePart"),"BlackoutCore entry Field missing") field:SetAttribute("Destination","EclipseVault")
entry:PivotTo(CFrame.new(384,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
zone.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.EclipseVault",entry="Workspace.ProgressionZones.RefugePortals.Travel_EclipseVault",returnGate="Workspace.ProgressionZones.EclipseVault.Return_EclipseVault",species=3,descendants=#zone:GetDescendants()+#entry:GetDescendants()}
