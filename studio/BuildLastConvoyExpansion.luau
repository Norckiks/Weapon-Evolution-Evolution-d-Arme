-- One-shot Edit builder for a replaceable level-220 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building LastConvoy")
local root=workspace:WaitForChild("ProgressionZones") local portals=root:WaitForChild("RefugePortals")
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("LastConvoy"),"LastConvoy already exists; inspect before rebuilding")
assert(not portals:FindFirstChild("Travel_LastConvoy"),"LastConvoy portal already exists; inspect before rebuilding")
for _,id in {"ConvoyMarshal","AshHound","SiegeBehemoth"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="LastConvoyBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage local Factory=require(factory)
local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(9300,0,-120) local zone=Instance.new("Model") zone.Name="LastConvoy" zone:SetAttribute("RequiredLevel",220)
local concrete=Color3.fromRGB(53,63,69) local steel=Color3.fromRGB(88,103,111) local rust=Color3.fromRGB(142,82,60) local signal=Color3.fromRGB(239,176,83)
local function part(parent,name,size,pos,color,material,collide,className)
 local p=Instance.new(className or "Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(zone,"TerminalSlab",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),concrete,Enum.Material.Concrete)
part(zone,"EntryCauseway",Vector3.new(36,.2,106),center+Vector3.new(0,.1,102),steel,Enum.Material.Asphalt,false)
for _,x in {-137,137} do part(zone,"PerimeterBarrier",Vector3.new(16,22,300),center+Vector3.new(x,11,0),steel,Enum.Material.CorrodedMetal) end
for _,z in {-142,142} do part(zone,"PerimeterBarrier",Vector3.new(258,22,16),center+Vector3.new(0,11,z),steel,Enum.Material.CorrodedMetal) end
-- A collapsed departure hall frames the route without blocking zombie paths.
for _,x in {-92,-46,46,92} do
 part(zone,"HangarPillar",Vector3.new(5,30,5),center+Vector3.new(x,15,-24),rust,Enum.Material.CorrodedMetal)
 local beam=part(zone,"BentRoofTruss",Vector3.new(48,3,5),center+Vector3.new(x/2,29,-36),steel,Enum.Material.Metal,false)
 beam.CFrame=CFrame.new(beam.Position)*CFrame.Angles(0,0,math.rad(x<0 and -7 or 7))
end
part(zone,"DepartureCanopy",Vector3.new(178,3,12),center+Vector3.new(0,29,-44),rust,Enum.Material.CorrodedMetal,false)
-- Broken convoy cars and freight crates act as readable cover silhouettes.
for i=1,5 do
 local x=(i%2==0 and 1 or -1)*(48+math.floor((i-1)/2)*15) local z=-198+(i-1)*29
 local car=part(zone,"WreckedConvoyCar",Vector3.new(27,8,13),center+Vector3.new(x,4,z),i%2==0 and steel or rust,Enum.Material.CorrodedMetal)
 car.CFrame=CFrame.new(car.Position)*CFrame.Angles(0,math.rad(i%2==0 and 9 or -11),math.rad(i%3==0 and 7 or 0))
 part(zone,"CargoCrate",Vector3.new(12,9,12),center+Vector3.new(-x*.65,4.5,z-12),Color3.fromRGB(76,88,91),Enum.Material.Metal)
end
-- Signal pylons mark the three combat lanes; lights are visual and non-colliding.
for i,x in {-110,0,110} do
 local z=-92-(i-1)*44
 part(zone,"SignalMast",Vector3.new(2,24,2),center+Vector3.new(x,12,z),steel,Enum.Material.Metal)
 part(zone,"AmberSignal",Vector3.new(5,2,2),center+Vector3.new(x,23,z),signal,Enum.Material.Neon,false)
end
local ret=root:WaitForChild("IronSanctum"):WaitForChild("Return_IronSanctum"):Clone() ret.Name="Return_LastConvoy"
local back=ret:FindFirstChild("Field",true) assert(back and back:IsA("BasePart"),"IronSanctum return Field missing") back:SetAttribute("Destination","Camp")
ret:PivotTo(CFrame.new(center+Vector3.new(0,4.5,20))*CFrame.new(-back.Position)*ret:GetPivot()) ret.Parent=zone
for _,id in {"ConvoyMarshal","AshHound","SiegeBehemoth"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_IronSanctum"):Clone() entry.Name="Travel_LastConvoy"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: LastConvoy")
portalPrompt.ObjectText="TERMINUS DU DERNIER CONVOI - NIV. 220"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"IronSanctum portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="TERMINUS DU DERNIER CONVOI\nNIVEAU 220" end end
local field=entry:FindFirstChild("Field",true) assert(field and field:IsA("BasePart"),"IronSanctum entry Field missing") field:SetAttribute("Destination","LastConvoy")
entry:PivotTo(CFrame.new(288,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
zone.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.LastConvoy",entry="Workspace.ProgressionZones.RefugePortals.Travel_LastConvoy",returnGate="Workspace.ProgressionZones.LastConvoy.Return_LastConvoy",species=3,descendants=#zone:GetDescendants()+#entry:GetDescendants()}
