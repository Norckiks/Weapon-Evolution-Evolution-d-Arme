-- One-shot Edit builder for a replaceable level-260 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building BlackoutCore")
local root=workspace:WaitForChild("ProgressionZones") local portals=root:WaitForChild("RefugePortals") local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("BlackoutCore"),"BlackoutCore already exists; inspect before rebuilding") assert(not portals:FindFirstChild("Travel_BlackoutCore"),"BlackoutCore portal already exists; inspect before rebuilding")
for _,id in {"BlackoutWarden","ArcRipper","CoreTitan"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="BlackoutCoreBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage local Factory=require(factory) local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(10540,0,-120) local zone=Instance.new("Model") zone.Name="BlackoutCore" zone:SetAttribute("RequiredLevel",260)
local concrete=Color3.fromRGB(45,52,61) local alloy=Color3.fromRGB(81,96,111) local ceramic=Color3.fromRGB(119,129,139) local pulse=Color3.fromRGB(120,204,237)
local function part(parent,name,size,pos,color,material,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(zone,"ContainmentApron",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),concrete,Enum.Material.Concrete)
part(zone,"EntryCauseway",Vector3.new(36,.2,106),center+Vector3.new(0,.1,102),alloy,Enum.Material.Metal,false)
for _,x in {-137,137} do part(zone,"PerimeterRetainingWall",Vector3.new(16,24,300),center+Vector3.new(x,12,0),alloy,Enum.Material.CorrodedMetal) end
for _,z in {-142,142} do part(zone,"PerimeterRetainingWall",Vector3.new(258,24,16),center+Vector3.new(0,12,z),alloy,Enum.Material.CorrodedMetal) end
-- Four split containment pylons frame the dead reactor without closing its spawn lanes.
for _,x in {-78,78} do for _,z in {-84,-158} do
 part(zone,"ContainmentPylon",Vector3.new(18,42,18),center+Vector3.new(x,21,z),alloy,Enum.Material.CorrodedMetal)
 part(zone,"ColdArcStrip",Vector3.new(20,1.5,2),center+Vector3.new(x,32,z),pulse,Enum.Material.Neon,false)
end end
local core=part(zone,"DarkReactorHousing",Vector3.new(42,32,38),center+Vector3.new(0,16,-42),Color3.fromRGB(57,66,78),Enum.Material.Metal)
for _,y in {5,16,27} do part(zone,"ContainmentRing",Vector3.new(54,2,50),core.Position+Vector3.new(0,y-16,0),ceramic,Enum.Material.DiamondPlate,false) end
part(zone,"ReactorWarningLamp",Vector3.new(8,2,8),core.Position+Vector3.new(0,17,0),pulse,Enum.Material.Neon,false)
for i=1,6 do
 local x=i%2==0 and 106 or -106 local z=-208+math.floor((i-1)/2)*42
 local housing=part(zone,"EmergencyPowerCabinet",Vector3.new(20,9,16),center+Vector3.new(x,4.5,z),i%2==0 and ceramic or alloy,Enum.Material.CorrodedMetal)
 housing.CFrame=CFrame.new(housing.Position)*CFrame.Angles(0,math.rad(i%2==0 and 10 or -10),math.rad(i%3==0 and 8 or 0))
 part(zone,"CabinetIndicator",Vector3.new(5,1,1),housing.Position+Vector3.new(0,1,-8.6),pulse,Enum.Material.Neon,false)
end
for i=1,5 do local x=i%2==0 and 54 or -54;local z=-222+(i-1)*35;part(zone,"BrokenCableTrench",Vector3.new(3,.2,28),center+Vector3.new(x,.15,z),Color3.fromRGB(28,34,42),Enum.Material.Metal,false) end
local ret=root:WaitForChild("Gridfall"):WaitForChild("Return_Gridfall"):Clone() ret.Name="Return_BlackoutCore"
local back=ret:FindFirstChild("Field",true) assert(back and back:IsA("BasePart"),"Gridfall return Field missing") back:SetAttribute("Destination","Camp")
ret:PivotTo(CFrame.new(center+Vector3.new(0,4.5,20))*CFrame.new(-back.Position)*ret:GetPivot()) ret.Parent=zone
for _,id in {"BlackoutWarden","ArcRipper","CoreTitan"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_Gridfall"):Clone() entry.Name="Travel_BlackoutCore"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: BlackoutCore")
portalPrompt.ObjectText="NOYAU D'ARRET - NIV. 260"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"Gridfall portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="NOYAU D'ARRET\nNIVEAU 260" end end
local field=entry:FindFirstChild("Field",true) assert(field and field:IsA("BasePart"),"Gridfall entry Field missing") field:SetAttribute("Destination","BlackoutCore")
entry:PivotTo(CFrame.new(352,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
zone.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.BlackoutCore",entry="Workspace.ProgressionZones.RefugePortals.Travel_BlackoutCore",returnGate="Workspace.ProgressionZones.BlackoutCore.Return_BlackoutCore",species=3,descendants=#zone:GetDescendants()+#entry:GetDescendants()}
