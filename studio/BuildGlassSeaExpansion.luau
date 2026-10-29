-- One-shot Edit builder for the replaceable level-120 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building the Mer de verre")
local root=workspace:WaitForChild("ProgressionZones")
local portals=root:WaitForChild("RefugePortals")
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("GlassSea"),"GlassSea already exists; inspect before rebuilding")
assert(not portals:FindFirstChild("Travel_GlassSea"),"GlassSea portal already exists; inspect before rebuilding")
for _,id in {"PrismGuard","GlassRunner","ShardTitan"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="GlassSeaBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage
local Factory=require(factory)
local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(6200,0,-120)
local sea=Instance.new("Model") sea.Name="GlassSea" sea:SetAttribute("RequiredLevel",120)
local slate=Color3.fromRGB(38,48,59)
local ridge=Color3.fromRGB(55,72,84)
local cyan=Color3.fromRGB(121,196,226)
local function part(parent,name,size,pos,color,material,collide,className)
	local p=Instance.new(className or "Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material
	p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false
	p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(sea,"GlassSeaFloor",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),slate,Enum.Material.Slate)
part(sea,"ArrivalCauseway",Vector3.new(20,.16,100),center+Vector3.new(0,.08,100),Color3.fromRGB(62,79,88),Enum.Material.Concrete,false)
for _,x in {-137,137} do part(sea,"PerimeterRidge",Vector3.new(16,18,300),center+Vector3.new(x,9,0),ridge,Enum.Material.Rock) end
for _,z in {-142,142} do part(sea,"PerimeterRidge",Vector3.new(258,18,16),center+Vector3.new(0,9,z),ridge,Enum.Material.Rock) end
local basin=part(sea,"MirrorBasin",Vector3.new(50,.4,50),center+Vector3.new(0,.22,-28),cyan,Enum.Material.Glass,false)
basin.Transparency=.3
for i=0,7 do
	local a=i*math.pi/4
	local x,z=math.cos(a)*48,-28+math.sin(a)*48
	local crystal=part(sea,"PrismShard",Vector3.new(7,20+(i%3)*5,7),center+Vector3.new(x,10+(i%3)*2.5,z),i%2==0 and cyan or Color3.fromRGB(158,133,215),Enum.Material.Glass,false,"WedgePart")
	crystal.CFrame=CFrame.new(crystal.Position)*CFrame.Angles(0,-a,math.rad(i%2==0 and 8 or -8))
end
for i=1,8 do
	local x=(i%2==0 and 82 or -82)
	local z=-225+math.floor((i-1)/2)*48
	local shard=part(sea,"LowShard",Vector3.new(12,4,8),center+Vector3.new(x,2,z),ridge,Enum.Material.Rock)
	shard.CFrame=CFrame.new(shard.Position)*CFrame.Angles(0,(i%4)*math.pi/8,math.rad(i%2==0 and 8 or -8))
end
local returnGate=root:WaitForChild("Citadel"):WaitForChild("Return_Citadel"):Clone()
returnGate.Name="Return_GlassSea"
local backField=returnGate:FindFirstChild("Field",true)
assert(backField and backField:IsA("BasePart"),"Citadel return Field missing")
backField:SetAttribute("Destination","Camp")
local backTarget=center+Vector3.new(2,4.5,20)
returnGate:PivotTo(CFrame.new(backTarget)*CFrame.new(-backField.Position)*returnGate:GetPivot())
returnGate.Parent=sea
for _,id in {"PrismGuard","GlassRunner","ShardTitan"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_Citadel"):Clone()
entry.Name="Travel_GlassSea"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: GlassSea")
portalPrompt.ObjectText="MER DE VERRE - NIV. 120"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"Citadel portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="MER DE VERRE\nNIVEAU 120" end end
local field=entry:FindFirstChild("Field",true)
assert(field and field:IsA("BasePart"),"Citadel portal Field missing")
field:SetAttribute("Destination","GlassSea")
entry:PivotTo(CFrame.new(128,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
sea.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.GlassSea",entry="Workspace.ProgressionZones.RefugePortals.Travel_GlassSea",returnGate="Workspace.ProgressionZones.GlassSea.Return_GlassSea",species=3,descendants=#sea:GetDescendants()+#entry:GetDescendants()}
