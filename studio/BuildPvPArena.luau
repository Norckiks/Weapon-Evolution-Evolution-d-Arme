-- One-shot Edit builder. Never install as a startup Script.
local RunService=game:GetService("RunService")
assert(not RunService:IsRunning(),"Stop Play before building the arena")
assert(workspace:FindFirstChild("RefugeCourtyard"),"The refuge courtyard is required")
assert(not workspace:FindFirstChild("SurvivorArena"),"Inspect the existing arena before rebuilding")
assert(not workspace.RefugeCourtyard:FindFirstChild("PVPAccessPath"),"Inspect existing PvP access path before rebuilding")
assert(not workspace.RefugeCourtyard:FindFirstChild("PVPPathGuide_L") and not workspace.RefugeCourtyard:FindFirstChild("PVPPathGuide_R"),"Inspect existing PvP path guides before rebuilding")
local center=Vector3.new(130,3,326)
local overlap=OverlapParams.new()
for _,object in workspace:GetPartBoundsInBox(CFrame.new(center+Vector3.new(0,2,0)),Vector3.new(44,8,32),overlap) do
	assert(not object.CanCollide or object.Name=="Baseplate" or object.Name=="CourtyardGround" or object.Name=="PathStripe","Arena site is occupied by "..object:GetFullName())
end

local arena=Instance.new("Model")
arena.Name="SurvivorArena"
arena:SetAttribute("ZoneName","ARENE PVP")
local function part(name,size,position,color,material,collide)
	local p=Instance.new("Part")
	p.Name=name p.Size=size p.CFrame=CFrame.new(position) p.Color=color p.Material=material
	p.Anchored=true p.CanCollide=collide~=false p.CanTouch=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=arena
	return p
end

part("ArenaFloor",Vector3.new(44,.35,32),center+Vector3.new(0,-2.63,0),Color3.fromRGB(52,54,57),Enum.Material.CorrodedMetal)
local bounds=part("FightBounds",Vector3.new(40,22,28),center+Vector3.new(0,8,0),Color3.new(),Enum.Material.SmoothPlastic,false)
bounds.Transparency=1 bounds.CanQuery=false
local red=Color3.fromRGB(255,91,61)
for _,z in {center.Z-15.8,center.Z+15.8} do
	local rail=part("ArenaMarking",Vector3.new(44,.16,.28),Vector3.new(center.X,.62,z),red,Enum.Material.Neon,false) rail.CanQuery=false
end
for _,x in {center.X-21.8,center.X+21.8} do
	local rail=part("ArenaMarking",Vector3.new(.28,.16,32),Vector3.new(x,.62,center.Z),red,Enum.Material.Neon,false) rail.CanQuery=false
end
for _,x in {center.X-20,center.X+20} do for _,z in {center.Z-14,center.Z+14} do
	part("FloodlightPost",Vector3.new(.8,7,.8),Vector3.new(x,3.7,z),Color3.fromRGB(69,74,78),Enum.Material.Metal)
	local lamp=part("Floodlight",Vector3.new(1.8,.5,1.1),Vector3.new(x,7.5,z),Color3.fromRGB(255,194,144),Enum.Material.Neon,false)
	local light=Instance.new("PointLight") light.Name="ArenaLight" light.Color=lamp.Color light.Brightness=1.4 light.Range=24 light.Shadows=false light.Parent=lamp
end end

local sign=part("ArenaSign",Vector3.new(.5,4,10),Vector3.new(center.X-29,5,center.Z),Color3.fromRGB(49,35,35),Enum.Material.Metal,false)
local surface=Instance.new("SurfaceGui") surface.Name="ArenaSignFace" surface.Face=Enum.NormalId.Left surface.CanvasSize=Vector2.new(800,320) surface.LightInfluence=0 surface.Parent=sign
local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.Font=Enum.Font.Cartoon label.TextScaled=true label.TextWrapped=true label.Text="ARENE PVP\nCOMBAT ACTIF" label.TextColor3=red label.Parent=surface

arena.Parent=workspace
local access=Instance.new("Part")
access.Name="PVPAccessPath" access.Size=Vector3.new(110,.08,10) access.Position=Vector3.new(55,.24,center.Z)
access.Anchored=true access.CanCollide=false access.CanTouch=false access.CanQuery=false
access.Material=Enum.Material.Slate access.Color=Color3.fromRGB(43,54,67) access.Parent=workspace.RefugeCourtyard
for _,z in {center.Z-5,center.Z+5} do
	local guide=Instance.new("Part") guide.Name=z<center.Z and "PVPPathGuide_L" or "PVPPathGuide_R"
	guide.Size=Vector3.new(90,.04,.14) guide.Position=Vector3.new(61,.31,z)
	guide.Anchored=true guide.CanCollide=false guide.CanTouch=false guide.CanQuery=false
	guide.Material=Enum.Material.Neon guide.Color=Color3.fromRGB(55,178,170) guide.Transparency=.2 guide.Parent=workspace.RefugeCourtyard
end
return {Name=arena.Name,Bounds=bounds.Size,Center=bounds.Position,Parts=#arena:GetDescendants(),AccessPath=access.Name}
