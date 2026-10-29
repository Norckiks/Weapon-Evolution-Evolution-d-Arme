-- One-shot Edit builder for a replaceable gameplay blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building the Crater")
local root=workspace:WaitForChild("ProgressionZones")
local portals=root:WaitForChild("RefugePortals")
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("Crater"),"Crater already exists; inspect before rebuilding")
assert(not portals:FindFirstChild("Travel_Crater"),"Crater portal already exists; inspect before rebuilding")
for _,id in {"CinderHusk","AshWraith","CoreBehemoth"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="CraterBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory dependency changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage
local Factory=require(factory)
local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(5580,0,-120)
local zone=Instance.new("Model") zone.Name="Crater"
zone:SetAttribute("RequiredLevel",100)
local function part(parent,name,size,pos,color,material,collide)
	local p=Instance.new("Part")
	p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material
	p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false
	p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent
	return p
end
local basalt=Color3.fromRGB(43,38,41)
local wall=Color3.fromRGB(70,54,51)
local ember=Color3.fromRGB(255,104,67)
part(zone,"CraterFloor",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),basalt,Enum.Material.Basalt)
part(zone,"ApproachRoad",Vector3.new(18,.15,96),center+Vector3.new(0,.1,102),Color3.fromRGB(54,49,50),Enum.Material.Asphalt,false)
for _,x in {-68,-34,34,68} do
	part(zone,"RoadStripe",Vector3.new(.45,.08,7),center+Vector3.new(x,.23,100),Color3.fromRGB(176,133,89),Enum.Material.Metal,false)
end
for _,x in {-137,137} do
	part(zone,"PerimeterWall",Vector3.new(16,20,300),center+Vector3.new(x,10,0),wall,Enum.Material.Concrete)
end
for _,z in {-142,142} do
	part(zone,"PerimeterWall",Vector3.new(258,20,16),center+Vector3.new(0,10,z),wall,Enum.Material.Concrete)
end
part(zone,"ReactorBase",Vector3.new(54,2,54),center+Vector3.new(0,1,-18),Color3.fromRGB(68,48,46),Enum.Material.CorrodedMetal)
local core=part(zone,"InactiveCore",Vector3.new(26,1,26),center+Vector3.new(0,2.6,-18),ember,Enum.Material.Neon,false)
core.Transparency=.22
for i=0,7 do
	local angle=i*math.pi/4
	local rock=part(zone,"AshRidge",Vector3.new(16,9,10),center+Vector3.new(math.cos(angle)*39,4.5,-18+math.sin(angle)*39),Color3.fromRGB(68+i%2*9,52,48),Enum.Material.Rock)
	rock.CFrame=CFrame.new(rock.Position)*CFrame.Angles(0,-angle,math.rad((i%3-1)*8))
end
for _,z in {-220,-158,-98,-38} do
	for _,x in {-108,108} do
		local pillar=part(zone,"BrokenPylon",Vector3.new(7,14,7),center+Vector3.new(x,7,z),wall,Enum.Material.CorrodedMetal)
		part(zone,"SignalLamp",Vector3.new(2,1,2),pillar.Position+Vector3.new(0,7.6,0),ember,Enum.Material.Neon,false)
	end
end
for i=1,8 do
	local angle=i*math.pi/4
	local p=part(zone,"Debris",Vector3.new(9,5,7),center+Vector3.new(math.cos(angle)*90,2.5,-120+math.sin(angle)*90),Color3.fromRGB(79,69,66),Enum.Material.Rock)
	p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,-angle,math.rad(i%2==0 and 9 or -7))
end
local returnSource=root:WaitForChild("Citadel"):WaitForChild("Return_Citadel")
local returnGate=returnSource:Clone() returnGate.Name="Return_Crater"
local returnField=returnGate:FindFirstChild("Field",true)
assert(returnField and returnField:IsA("BasePart"),"Citadel return Field missing")
returnField:SetAttribute("Destination","Camp")
local returnTarget=center+Vector3.new(2,4.5,20)
returnGate:PivotTo(CFrame.new(returnTarget)*CFrame.new(-returnField.Position)*returnGate:GetPivot())
returnGate.Parent=zone
local entrySource=portals:WaitForChild("Travel_Citadel")
local entry=entrySource:Clone() entry.Name="Travel_Crater"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: Crater")
portalPrompt.ObjectText="CRATERE DU REACTEUR - NIV. 100"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"Citadel portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="CRATERE DU REACTEUR\nNIVEAU 100" end end
local entryField=entry:FindFirstChild("Field",true)
assert(entryField and entryField:IsA("BasePart"),"Citadel portal Field missing")
entryField:SetAttribute("Destination","Crater")
entry:PivotTo(CFrame.new(-127,4.5,252)*CFrame.new(-entryField.Position)*entry:GetPivot())
for _,id in {"CinderHusk","AshWraith","CoreBehemoth"} do Factory.Build(templateStage,id) end
for _,template in templateStage:GetChildren() do template.Parent=templates end
zone.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.Crater",entry="Workspace.ProgressionZones.RefugePortals.Travel_Crater",returnGate="Workspace.ProgressionZones.Crater.Return_Crater",species=3,descendants=#zone:GetDescendants()+#entry:GetDescendants()}
