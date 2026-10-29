local config=require(game.ReplicatedStorage.WorldConfig)
assert(not workspace:FindFirstChild("ProgressionZones"),"Zones already built")
local root=Instance.new("Folder") root.Name="ProgressionZones" root.Parent=workspace
local function p(parent,name,size,pos,color,mat)
 local a=Instance.new("Part") a.Name=name a.Size=size a.Position=pos a.Color=color a.Material=mat or Enum.Material.Concrete a.Anchored=true a.TopSurface=Enum.SurfaceType.Smooth a.BottomSurface=Enum.SurfaceType.Smooth a.Parent=parent return a
end
local function sign(parent,cf,size,text,color)
 local a=p(parent,"ZoneSign",size,cf.Position,color,Enum.Material.Metal) a.CFrame=cf a.CanCollide=false a.CanTouch=false a.CanQuery=false
 local s=Instance.new("SurfaceGui") s.Face=Enum.NormalId.Front s.PixelsPerStud=30 s.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud s.Parent=a
 local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Text=text t.TextScaled=true t.Font=Enum.Font.Oswald t.TextColor3=Color3.fromRGB(245,235,202) t.Parent=s return a
end
local function portal(parent,zone,position,returning)
 local g=Instance.new("Model") g.Name=returning and ("Return_"..zone.Id) or ("Travel_"..zone.Id)
 local color=returning and Color3.fromRGB(84,190,174) or zone.Color
 p(g,"Platform",Vector3.new(12,0.5,8),position+Vector3.new(0,0.25,0),Color3.fromRGB(41,46,45),Enum.Material.DiamondPlate)
 for _,sx in {-1,1} do p(g,"Pillar",Vector3.new(0.7,10,0.7),position+Vector3.new(sx*5,5,0),color,Enum.Material.Neon) end
 local gate=p(g,"Field",Vector3.new(9.5,8.5,0.3),position+Vector3.new(0,4.5,0),color,Enum.Material.ForceField)
 gate.Transparency=0.65 gate.CanCollide=false gate.CanTouch=false gate:SetAttribute("Destination",returning and "Camp" or zone.Id)
 local prompt=Instance.new("ProximityPrompt") prompt.Name="ZoneTravel" prompt.ActionText=returning and "Retour au refuge" or "Entrer"
 prompt.ObjectText=returning and "REFUGE" or zone.Name.." - NIV. "..zone.Level prompt.HoldDuration=0.35 prompt.MaxActivationDistance=10 prompt.RequiresLineOfSight=false prompt.Parent=gate
 local face=returning and CFrame.new(position+Vector3.new(0,11,0)) or CFrame.new(position+Vector3.new(0,11,0))
 local boardWidth=zone.Id=="City" and 20 or 14
 sign(g,face,Vector3.new(boardWidth,2.8,0.5),returning and "RETOUR REFUGE" or zone.Name.."\nNIVEAU "..zone.Level,color:Lerp(Color3.new(0,0,0),0.6))
 g.Parent=parent return g
end
local hub=Instance.new("Folder") hub.Name="RefugePortals" hub.Parent=root
for i,z in config.Zones do portal(hub,z,Vector3.new((i-2)*32,0,208),false) end
sign(hub,CFrame.new(0,15,214),Vector3.new(68,3,0.7),"EXPEDITIONS  /  CHOISIS TON SECTEUR",Color3.fromRGB(36,56,51))
for index=2,3 do
 local zone=config.Zones[index] local x=zone.Center.X
 local g=Instance.new("Model") g.Name=zone.Id
 local dark=Color3.fromRGB(54,61,59) local accent=zone.Color
 p(g,"Ground",Vector3.new(290,2,320),Vector3.new(x,-1,-120),index==2 and Color3.fromRGB(77,68,51) or Color3.fromRGB(58,72,62),Enum.Material.Concrete)
 p(g,"CentralAvenue",Vector3.new(100,0.2,295),Vector3.new(x,0.1,-120),dark,Enum.Material.Asphalt)
 for _,side in {-1,1} do
  p(g,"PerimeterWall",Vector3.new(3,16,320),Vector3.new(x+side*145,8,-120),dark)
  for z=-245,0,35 do
   local base=p(g,"Lamp",Vector3.new(0.6,13,0.6),Vector3.new(x+side*55,6.5,z),dark,Enum.Material.Metal)
   local glow=p(g,"LampGlow",Vector3.new(2,0.4,2),Vector3.new(x+side*55,13,z),accent,Enum.Material.Neon)
   local l=Instance.new("PointLight") l.Color=accent l.Range=32 l.Brightness=1.5 l.Parent=glow
  end
 end
 p(g,"BackWall",Vector3.new(290,16,3),Vector3.new(x,8,-280),dark)
 for z=-255,10,18 do
  p(g,"LaneMark",Vector3.new(0.6,0.05,8),Vector3.new(x,0.25,z),accent)
 end
 sign(g,CFrame.new(x,15,5)*CFrame.Angles(0,math.pi,0),Vector3.new(48,5,1),zone.Name.."\nACCES NIVEAU "..zone.Level,dark)
 portal(g,zone,Vector3.new(x+22,0,20),true)
 if index==2 then
  for _,side in {-1,1} do
   for z=-230,-50,90 do
    p(g,"WarehouseBack",Vector3.new(3,24,58),Vector3.new(x+side*132,12,z),Color3.fromRGB(104,78,56),Enum.Material.CorrodedMetal)
    p(g,"WarehouseRoof",Vector3.new(56,1,60),Vector3.new(x+side*105,24,z),Color3.fromRGB(75,79,73),Enum.Material.CorrodedMetal)
    for _,offset in {-27,27} do p(g,"SteelColumn",Vector3.new(1.5,24,1.5),Vector3.new(x+side*78,12,z+offset),dark,Enum.Material.Metal) end
   end
  end
  for i=1,5 do
   local tank=p(g,"StorageTank",Vector3.new(24,13,13),Vector3.new(x-103,13,-25-i*42),Color3.fromRGB(117,94,63),Enum.Material.CorrodedMetal)
   tank.Shape=Enum.PartType.Cylinder tank.Orientation=Vector3.new(0,0,90)
   p(g,"HazardBand",Vector3.new(0.4,3,12),Vector3.new(x-95,6,-25-i*42),accent,Enum.Material.Metal)
  end
  for _,z in {-105,-200} do
   p(g,"OverheadPipe",Vector3.new(130,2,2),Vector3.new(x,28,z),Color3.fromRGB(124,84,46),Enum.Material.CorrodedMetal)
   for _,sx in {-1,1} do p(g,"PipeSupport",Vector3.new(2,28,2),Vector3.new(x+sx*62,14,z),dark,Enum.Material.Metal) end
  end
  sign(g,CFrame.new(x-74,7,-45)*CFrame.Angles(0,-math.pi/2,0),Vector3.new(14,5,0.5),"DANGER\nCONTAMINATION",dark)
 else
  for _,side in {-1,1} do
   for z=-220,-60,80 do
    p(g,"LabStructure",Vector3.new(48,20,52),Vector3.new(x+side*113,10,z),Color3.fromRGB(90,111,105),Enum.Material.Metal)
    p(g,"ObservationWindow",Vector3.new(0.3,7,34),Vector3.new(x+side*88.8,12,z),Color3.fromRGB(53,124,105),Enum.Material.Glass)
    p(g,"EmergencyStrip",Vector3.new(0.35,0.6,45),Vector3.new(x+side*88.5,18,z),accent,Enum.Material.Neon)
   end
  end
  for _,side in {-1,1} do for z=-220,-80,70 do
   local pod=p(g,"ContainmentPod",Vector3.new(12,5.5,5.5),Vector3.new(x+side*69,6,z),Color3.fromRGB(96,141,110),Enum.Material.Glass)
   pod.Shape=Enum.PartType.Cylinder pod.Orientation=Vector3.new(0,0,90) pod.Transparency=0.25
   local fluid=p(g,"Mutagen",Vector3.new(9,4.2,4.2),Vector3.new(x+side*69,5,z),accent,Enum.Material.Neon)
   fluid.Shape=Enum.PartType.Cylinder fluid.Orientation=Vector3.new(0,0,90)
  end end
  sign(g,CFrame.new(x,9,-265),Vector3.new(50,6,0.5),"PROJET ZERO\nCONFINEMENT ROMPU",dark)
 end
 g.Parent=root task.wait()
end
return "Three level-gated expedition portals and two new themed zones built"
