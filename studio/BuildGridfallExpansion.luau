-- One-shot Edit builder for a replaceable level-240 blockout. Never install at startup.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before building Gridfall")
local root=workspace:WaitForChild("ProgressionZones") local portals=root:WaitForChild("RefugePortals") local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
assert(not root:FindFirstChild("Gridfall"),"Gridfall already exists; inspect before rebuilding") assert(not portals:FindFirstChild("Travel_Gridfall"),"Gridfall portal already exists; inspect before rebuilding")
for _,id in {"GridWarden","FlashHound","BreakerTitan"} do assert(not templates:FindFirstChild(id),"Zombie template already exists: "..id) end
local stage=Instance.new("Folder") stage.Name="GridfallBuildStage" stage.Parent=game.ServerStorage
local world=game.ReplicatedStorage.WorldConfig:Clone() world.Parent=stage
local factory=game.ServerScriptService.ZombieFactory:Clone()
assert(factory.Source:find('local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))',1,true),"ZombieFactory changed; inspect before building")
factory.Source=factory.Source:gsub('local Config=require%(game.ReplicatedStorage:WaitForChild%("WorldConfig"%)%)','local Config=require(script.Parent.WorldConfig)',1)
factory.Parent=stage local Factory=require(factory) local templateStage=Instance.new("Folder") templateStage.Name="ZombieTemplates" templateStage.Parent=stage
local center=Vector3.new(9920,0,-120) local zone=Instance.new("Model") zone.Name="Gridfall" zone:SetAttribute("RequiredLevel",240)
local asphalt=Color3.fromRGB(54,59,55) local steel=Color3.fromRGB(94,98,82) local olive=Color3.fromRGB(123,116,72) local warning=Color3.fromRGB(229,196,92)
local function part(parent,name,size,pos,color,material,collide,className)
 local p=Instance.new(className or "Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Material=material p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.CanQuery=collide~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
part(zone,"SubstationApron",Vector3.new(290,4,300),center+Vector3.new(0,-2,0),asphalt,Enum.Material.Asphalt)
part(zone,"EntryCauseway",Vector3.new(36,.2,106),center+Vector3.new(0,.1,102),steel,Enum.Material.Metal,false)
for _,x in {-137,137} do part(zone,"BrokenPerimeterFence",Vector3.new(16,20,300),center+Vector3.new(x,10,0),steel,Enum.Material.CorrodedMetal) end
for _,z in {-142,142} do part(zone,"BrokenPerimeterFence",Vector3.new(258,20,16),center+Vector3.new(0,10,z),steel,Enum.Material.CorrodedMetal) end
for _,x in {-88,88} do
 local transformer=part(zone,"RuinedTransformer",Vector3.new(34,20,30),center+Vector3.new(x,10,-42),olive,Enum.Material.CorrodedMetal)
 for _,side in {-1,1} do part(zone,"CoolingRadiator",Vector3.new(4,15,24),transformer.Position+Vector3.new(side*19,0,0),steel,Enum.Material.DiamondPlate) end
 part(zone,"InsulatorBank",Vector3.new(24,2,5),transformer.Position+Vector3.new(0,12,0),Color3.fromRGB(179,169,130),Enum.Material.SmoothPlastic)
end
-- Leaning poles and slack crossarms sell the collapsed grid while leaving lanes open.
for i,x in {-112,-38,38,112} do
 local z=-118-(i-1)*8
 local pole=part(zone,"LeaningPowerPole",Vector3.new(3,28,3),center+Vector3.new(x,14,z),steel,Enum.Material.Wood)
 pole.CFrame=CFrame.new(pole.Position)*CFrame.Angles(0,0,math.rad(i%2==0 and 8 or -8))
 local cross=part(zone,"Crossarm",Vector3.new(18,2,3),pole.Position+Vector3.new(0,12,0),olive,Enum.Material.Wood,false)
 cross.CFrame=CFrame.new(cross.Position)*CFrame.Angles(0,0,math.rad(i%2==0 and 8 or -8))
 for _,offset in {-6,0,6} do local insulator=part(zone,"CeramicInsulator",Vector3.new(1.7,4,1.7),cross.Position+Vector3.new(offset,3,0),Color3.fromRGB(177,169,131),Enum.Material.SmoothPlastic,false); insulator.Shape=Enum.PartType.Ball end
end
for i=1,8 do
 local x=i%2==0 and 74 or -74 local z=-208+math.floor((i-1)/2)*38
 local breaker=part(zone,"FallenBreakerCabinet",Vector3.new(18,7,14),center+Vector3.new(x,3.5,z),i%2==0 and olive or steel,Enum.Material.Metal)
 breaker.CFrame=CFrame.new(breaker.Position)*CFrame.Angles(0,math.rad(i%2==0 and 12 or -12),math.rad(i%3==0 and 9 or 0))
end
for i=1,6 do local x=i%2==0 and 42 or -42 local z=-190+(i-1)*28; part(zone,"WarningStripe",Vector3.new(2,.15,18),center+Vector3.new(x,.12,z),warning,Enum.Material.Neon,false) end
local ret=root:WaitForChild("LastConvoy"):WaitForChild("Return_LastConvoy"):Clone() ret.Name="Return_Gridfall"
local back=ret:FindFirstChild("Field",true) assert(back and back:IsA("BasePart"),"LastConvoy return Field missing") back:SetAttribute("Destination","Camp")
ret:PivotTo(CFrame.new(center+Vector3.new(0,4.5,20))*CFrame.new(-back.Position)*ret:GetPivot()) ret.Parent=zone
for _,id in {"GridWarden","FlashHound","BreakerTitan"} do Factory.Build(templateStage,id) end
local entry=portals:WaitForChild("Travel_LastConvoy"):Clone() entry.Name="Travel_Gridfall"
local portalPrompt=entry:FindFirstChild("ZoneTravel",true) assert(portalPrompt and portalPrompt:IsA("ProximityPrompt"),"Missing travel prompt: Gridfall")
portalPrompt.ObjectText="GRILLE DECHUE - NIV. 240"
local portalSign=entry:FindFirstChild("ZoneSign",true) assert(portalSign and portalSign:IsA("BasePart"),"LastConvoy portal sign missing")
portalSign.Size=Vector3.new(22,2.8,.5)
for _,label in ipairs(portalSign:GetDescendants()) do if label:IsA("TextLabel") then label.Text="GRILLE DECHUE\nNIVEAU 240" end end
local field=entry:FindFirstChild("Field",true) assert(field and field:IsA("BasePart"),"LastConvoy entry Field missing") field:SetAttribute("Destination","Gridfall")
entry:PivotTo(CFrame.new(320,4.5,252)*CFrame.new(-field.Position)*entry:GetPivot())
for _,template in templateStage:GetChildren() do template.Parent=templates end
zone.Parent=root entry.Parent=portals stage:Destroy()
return {zone="Workspace.ProgressionZones.Gridfall",entry="Workspace.ProgressionZones.RefugePortals.Travel_Gridfall",returnGate="Workspace.ProgressionZones.Gridfall.Return_Gridfall",species=3,descendants=#zone:GetDescendants()+#entry:GetDescendants()}
