-- One-shot Edit builder for a replaceable level-160 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building the Station orbitale")
local root=workspace:WaitForChild("ProgressionZones")
local portals=root:WaitForChild("RefugePortals")
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("OrbitalWreck"),"OrbitalWreck already exists; inspect before rebuilding")
assert(not portals:FindFirstChild("Travel_OrbitalWreck"),"OrbitalWreck portal already exists; inspect before rebuilding")
for _,id in {"VoidMechanic","OrbitRunner","CapsuleTitan"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="OrbitalWreckBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage
local Factory=require(factory)
local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(7440,0,-120)
local wreck=Instance.new("Model") wreck.Name="OrbitalWreck" wreck:SetAttribute("RequiredLevel",160)
local hull=Color3.fromRGB(51,56,63)
local metal=Color3.fromRGB(89,96,103)
local amber=Color3.fromRGB(233,163,102)
local function part(parent,name,size,pos,color,material,collide,className)
	local p=Instance.new(className or "Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material
	p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false
	p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(wreck,"StationFloor",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),hull,Enum.Material.Metal)
part(wreck,"DockApproach",Vector3.new(20,.16,100),center+Vector3.new(0,.08,100),Color3.fromRGB(74,78,80),Enum.Material.Concrete,false)
for _,x in {-137,137} do part(wreck,"HullBarrier",Vector3.new(16,20,300),center+Vector3.new(x,10,0),metal,Enum.Material.CorrodedMetal) end
for _,z in {-142,142} do part(wreck,"HullBarrier",Vector3.new(258,20,16),center+Vector3.new(0,10,z),metal,Enum.Material.CorrodedMetal) end
part(wreck,"AirlockDeck",Vector3.new(60,2,54),center+Vector3.new(0,1,-28),Color3.fromRGB(80,83,84),Enum.Material.DiamondPlate)
local airlock=part(wreck,"Airlock",Vector3.new(28,1,28),center+Vector3.new(0,2.6,-28),amber,Enum.Material.Neon,false)
airlock.Transparency=.28
for i=0,7 do
	local a=i*math.pi/4 local x,z=math.cos(a)*78,math.sin(a)*78-18
	local pylon=part(wreck,"BrokenPylon",Vector3.new(8,18+(i%3)*3,8),center+Vector3.new(x,9+(i%3)*1.5,z),metal,Enum.Material.Metal)
	local lamp=part(wreck,"PylonLamp",Vector3.new(2,1,2),pylon.Position+Vector3.new(0,pylon.Size.Y/2+.6,0),i%2==0 and amber or Color3.fromRGB(148,173,212),Enum.Material.Neon,false)
	lamp.Transparency=.12
end
for i=1,10 do
	local x=(i%2==0 and 100 or -100) local z=-222+math.floor((i-1)/2)*44
	local panel=part(wreck,"TornPanel",Vector3.new(15,2,9),center+Vector3.new(x,2.5,z),i%2==0 and Color3.fromRGB(63,81,92) or Color3.fromRGB(90,77,75),Enum.Material.Metal)
	panel.CFrame=CFrame.new(panel.Position)*CFrame.Angles(0,(i%4)*math.pi/8,math.rad(i%2==0 and 12 or -10))
end
for i=1,6 do
	local z=-205+(i-1)*34
	local rail=part(wreck,"CableTrench",Vector3.new(3,.4,24),center+Vector3.new(i%2==0 and 34 or -34,.3,z),Color3.fromRGB(114,94,78),Enum.Material.CorrodedMetal,false)
	rail.CFrame=CFrame.new(rail.Position)*CFrame.Angles(0,math.rad(90),0)
end
local returnGate=root:WaitForChild("Skyline"):WaitForChild("Return_Skyline"):Clone()
returnGate.Name="Return_OrbitalWreck"
local backField=returnGate:FindFirstChild("Field",true)
assert(backField and backField:IsA("BasePart"),"Skyline return Field missing")
backField:SetAttribute("Destination","Camp")
returnGate:PivotTo(CFrame.new(center+Vector3.new(2,4.5,20))*CFrame.new(-backField.Position)*returnGate:GetPivot())
returnGate.Parent=wreck
for _,id in {"VoidMechanic","OrbitRunner","CapsuleTitan"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_Skyline"):Clone()
entry.Name="Travel_OrbitalWreck"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: OrbitalWreck")
portalPrompt.ObjectText="STATION ORBITALE - NIV. 160"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"Skyline portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="STATION ORBITALE\nNIVEAU 160" end end
local field=entry:FindFirstChild("Field",true)
assert(field and field:IsA("BasePart"),"Skyline portal Field missing")
field:SetAttribute("Destination","OrbitalWreck")
entry:PivotTo(CFrame.new(192,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
wreck.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.OrbitalWreck",entry="Workspace.ProgressionZones.RefugePortals.Travel_OrbitalWreck",returnGate="Workspace.ProgressionZones.OrbitalWreck.Return_OrbitalWreck",species=3,descendants=#wreck:GetDescendants()+#entry:GetDescendants()}
