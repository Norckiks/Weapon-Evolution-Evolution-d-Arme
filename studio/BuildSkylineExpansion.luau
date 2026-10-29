-- One-shot Edit builder for a replaceable level-140 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building the Cite des antennes")
local root=workspace:WaitForChild("ProgressionZones")
local portals=root:WaitForChild("RefugePortals")
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("Skyline"),"Skyline already exists; inspect before rebuilding")
assert(not portals:FindFirstChild("Travel_Skyline"),"Skyline portal already exists; inspect before rebuilding")
for _,id in {"RelayWarden","StaticRunner","TowerGoliath"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="SkylineBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage
local Factory=require(factory)
local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(6820,0,-120)
local district=Instance.new("Model") district.Name="Skyline" district:SetAttribute("RequiredLevel",140)
local asphalt=Color3.fromRGB(43,47,52)
local concrete=Color3.fromRGB(65,71,77)
local gold=Color3.fromRGB(244,190,92)
local function part(parent,name,size,pos,color,material,collide,className)
	local p=Instance.new(className or "Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material
	p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false
	p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(district,"SkylineFloor",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),asphalt,Enum.Material.Asphalt)
part(district,"RelayApproach",Vector3.new(20,.16,100),center+Vector3.new(0,.08,100),concrete,Enum.Material.Concrete,false)
for _,x in {-137,137} do part(district,"PerimeterBlock",Vector3.new(16,22,300),center+Vector3.new(x,11,0),concrete,Enum.Material.Concrete) end
for _,z in {-142,142} do part(district,"PerimeterBlock",Vector3.new(258,22,16),center+Vector3.new(0,11,z),concrete,Enum.Material.Concrete) end
local platform=part(district,"RelayPlatform",Vector3.new(54,2,54),center+Vector3.new(0,1,-28),Color3.fromRGB(76,72,61),Enum.Material.Metal)
local mast=part(district,"SignalMast",Vector3.new(4,54,4),platform.Position+Vector3.new(0,28,-4),Color3.fromRGB(81,91,95),Enum.Material.Metal,false,"Part")
local beacon=part(district,"Beacon",Vector3.new(8,3,8),mast.Position+Vector3.new(0,27,0),gold,Enum.Material.Neon,false)
beacon.Transparency=.15
for i=1,3 do
	local dish=part(district,"RelayDish",Vector3.new(15-i*2,.7,9-i),mast.Position+Vector3.new(0,17-i*10,0),Color3.fromRGB(116,126,127),Enum.Material.Metal,false,"Part")
	dish.CFrame=CFrame.new(dish.Position)*CFrame.Angles(math.rad(24+i*8),i*math.pi/3,0)
end
for i=0,7 do
	local a=i*math.pi/4 local x,z=math.cos(a)*72,math.sin(a)*72
	local tower=part(district,"RelayTower",Vector3.new(7,20,7),center+Vector3.new(x,10,z-20),Color3.fromRGB(73,82,88),Enum.Material.CorrodedMetal)
	part(district,"TowerLamp",Vector3.new(2,1,2),tower.Position+Vector3.new(0,10.6,0),i%2==0 and gold or Color3.fromRGB(167,132,211),Enum.Material.Neon,false)
end
for i=1,10 do
	local x=(i%2==0 and 94 or -94) local z=-220+math.floor((i-1)/2)*43
	local wreck=part(district,"SignalWreck",Vector3.new(12,5,8),center+Vector3.new(x,2.5,z),Color3.fromRGB(84,87,84),Enum.Material.Metal)
	wreck.CFrame=CFrame.new(wreck.Position)*CFrame.Angles(0,(i%4)*math.pi/8,math.rad(i%2==0 and 10 or -8))
end
local returnGate=root:WaitForChild("GlassSea"):WaitForChild("Return_GlassSea"):Clone()
returnGate.Name="Return_Skyline"
local backField=returnGate:FindFirstChild("Field",true)
assert(backField and backField:IsA("BasePart"),"GlassSea return Field missing")
backField:SetAttribute("Destination","Camp")
returnGate:PivotTo(CFrame.new(center+Vector3.new(2,4.5,20))*CFrame.new(-backField.Position)*returnGate:GetPivot())
returnGate.Parent=district
for _,id in {"RelayWarden","StaticRunner","TowerGoliath"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_GlassSea"):Clone()
entry.Name="Travel_Skyline"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: Skyline")
portalPrompt.ObjectText="CITE DES ANTENNES - NIV. 140"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"GlassSea portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="CITE DES ANTENNES\nNIVEAU 140" end end
local field=entry:FindFirstChild("Field",true)
assert(field and field:IsA("BasePart"),"GlassSea portal Field missing")
field:SetAttribute("Destination","Skyline")
entry:PivotTo(CFrame.new(160,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
district.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.Skyline",entry="Workspace.ProgressionZones.RefugePortals.Travel_Skyline",returnGate="Workspace.ProgressionZones.Skyline.Return_Skyline",species=3,descendants=#district:GetDescendants()+#entry:GetDescendants()}
