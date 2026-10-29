-- One-time Edit builder. Never install as a startup script.
assert(not workspace:FindFirstChild("RefugeCourtyard"),"Inspect existing courtyard before rebuilding")
local W=require(game.ReplicatedStorage.WorldConfig)
for _,p in {Vector3.new(-70,4,260),Vector3.new(0,4,300),Vector3.new(100,4,340)} do assert(W.ZoneAt(p)==nil,"Courtyard overlaps a combat zone") end
local root=Instance.new("Model") root.Name="RefugeCourtyard"
local function part(name,size,pos,color,material,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=CFrame.new(pos) p.Color=color p.Material=material
 p.Anchored=true p.CanCollide=collide~=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=root return p
end
local asphalt=Color3.fromRGB(55,65,65) local metal=Color3.fromRGB(65,75,75) local wood=Color3.fromRGB(114,91,65) local gold=Color3.fromRGB(236,188,71)
part("CourtyardGround",Vector3.new(380,.2,190),Vector3.new(16,.1,295),asphalt,Enum.Material.Asphalt)
part("CentralPath",Vector3.new(24,.08,170),Vector3.new(0,.24,290),Color3.fromRGB(43,54,67),Enum.Material.Slate,false)
local shopAccess=Instance.new("Folder") shopAccess.Name="ShopAccessWalkways" shopAccess.Parent=root
for _,side in ipairs({-1,1}) do
 local name=side<0 and "Left" or "Right" local x=side*125 local laneStart,laneEnd=234.5,274
 local laneLength=laneEnd-laneStart local laneCenter=(laneStart+laneEnd)/2
 local lane=part("SideAisle_"..name,Vector3.new(8,.08,laneLength),Vector3.new(x,.24,laneCenter),Color3.fromRGB(58,75,88),Enum.Material.Slate,false)
 lane.Parent=shopAccess lane.CanTouch=false lane.CanQuery=false
 for _,edgeSide in ipairs({-1,1}) do
  local edge=part("SideAisleEdge_"..name.."_"..(edgeSide<0 and "L" or "R"),Vector3.new(.14,.04,laneLength-8),Vector3.new(x+edgeSide*3.78,.31,laneCenter),Color3.fromRGB(55,178,170),Enum.Material.Neon,false)
  edge.Parent=shopAccess edge.Transparency=.22 edge.CanTouch=false edge.CanQuery=false
 end
 local startX,endX=side*10.5,x local linkLength=math.abs(endX-startX) local linkCenter=(startX+endX)/2
 local link=part("CentralConnector_"..name,Vector3.new(linkLength,.08,8),Vector3.new(linkCenter,.24,laneEnd),Color3.fromRGB(58,75,88),Enum.Material.Slate,false)
 link.Parent=shopAccess link.CanTouch=false link.CanQuery=false
 for _,edgeSide in ipairs({-1,1}) do
  local edge=part("CentralConnectorEdge_"..name.."_"..(edgeSide<0 and "L" or "R"),Vector3.new(linkLength-8,.04,.14),Vector3.new(linkCenter,.31,laneEnd+edgeSide*3.78),Color3.fromRGB(55,178,170),Enum.Material.Neon,false)
  edge.Parent=shopAccess edge.Transparency=.22 edge.CanTouch=false edge.CanQuery=false
 end
 local shops=side<0 and {{name="Upgrades",z=234.5},{name="Pets",z=256.5}} or {{name="Weapons",z=234.5},{name="Robux",z=256.5}}
 for _,shop in ipairs(shops) do
  local spurCenter=side*117.5
  local spur=part("ShopSpur_"..shop.name.."_"..name,Vector3.new(15,.08,8),Vector3.new(spurCenter,.24,shop.z),Color3.fromRGB(58,75,88),Enum.Material.Slate,false)
  spur.Parent=shopAccess spur.CanTouch=false spur.CanQuery=false
 end
end
for _,x in {-11.25,11.25} do
 local edge=part("PathEdgeGuide_"..(x<0 and "L" or "R"),Vector3.new(.14,.04,166),Vector3.new(x,.31,290),Color3.fromRGB(55,178,170),Enum.Material.Neon,false)
 edge.Transparency=.2 edge.CanTouch=false edge.CanQuery=false
end
for i=1,6 do part("PathStripe",Vector3.new(1,.06,8),Vector3.new(0,.31,226+(i-1)*28),gold,Enum.Material.SmoothPlastic,false) end
for _,x in {-174,206} do
	part("SideFence",Vector3.new(1,6,190),Vector3.new(x,3,295),metal,Enum.Material.CorrodedMetal)
	for z=220,370,37.5 do part("FencePost",Vector3.new(2,8,2),Vector3.new(x,4,z),wood,Enum.Material.WoodPlanks) end
end
part("RearFence",Vector3.new(380,6,1),Vector3.new(16,3,390),metal,Enum.Material.CorrodedMetal)
for x=-174,206,47.5 do part("RearPost",Vector3.new(2,8,2),Vector3.new(x,4,390),wood,Enum.Material.WoodPlanks) end
for _,x in {-25,25} do for _,z in {250,290,330} do
 part("LampPost",Vector3.new(1,12,1),Vector3.new(x,6,z),metal,Enum.Material.Metal)
 local light=part("Lamp",Vector3.new(2,.6,2),Vector3.new(x,12,z),Color3.fromRGB(255,221,152),Enum.Material.Neon,false)
 local glow=Instance.new("PointLight") glow.Color=light.Color glow.Range=18 glow.Brightness=1.2 glow.Parent=light
end end
for _,z in {265,315,340} do for _,x in {-60,80} do
 part("BenchSeat",Vector3.new(10,1,3),Vector3.new(x,2,z),wood,Enum.Material.WoodPlanks)
 part("BenchBack",Vector3.new(10,3,.5),Vector3.new(x,3.5,z+1.25),wood,Enum.Material.WoodPlanks)
 for _,dx in {-4,4} do part("BenchLeg",Vector3.new(.7,2,2),Vector3.new(x+dx,1,z),metal,Enum.Material.Metal) end
end end
for _,x in {-82,105} do
 part("ShelterRoof",Vector3.new(28,1,18),Vector3.new(x,8,285),Color3.fromRGB(85,118,105),Enum.Material.Fabric)
 for _,dx in {-12,12} do for _,dz in {-7,7} do part("ShelterPole",Vector3.new(1,8,1),Vector3.new(x+dx,4,285+dz),wood,Enum.Material.WoodPlanks) end end
 part("SupplyCrate",Vector3.new(4,4,4),Vector3.new(x-7,2,285),wood,Enum.Material.WoodPlanks)
 part("SupplyCrate",Vector3.new(4,4,4),Vector3.new(x+7,2,285),wood,Enum.Material.WoodPlanks)
end
local sign=part("RefugeSign",Vector3.new(22,4,.5),Vector3.new(0,10,346),gold,Enum.Material.Metal,false)
for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
 local surface=Instance.new("SurfaceGui") surface.Face=face surface.CanvasSize=Vector2.new(900,180) surface.LightInfluence=0 surface.Parent=sign
 local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.Text="REFUGE  •  ZONE SURE" label.TextColor3=Color3.fromRGB(38,48,68) label.Font=Enum.Font.Cartoon label.TextScaled=true label.Parent=surface
end
for _,x in {-9,9} do part("SignPost",Vector3.new(1,8,1),Vector3.new(x,4,346),metal,Enum.Material.Metal) end
root.Parent=workspace
return {Name=root.Name,Parts=#root:GetDescendants()}
