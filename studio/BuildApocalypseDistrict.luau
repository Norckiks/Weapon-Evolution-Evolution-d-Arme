local city=workspace:FindFirstChild("ApocalypseCity")
assert(city,"Missing generated camp")
city.Name="SurvivorCamp"
city:ScaleTo(1.25)
local old=city:GetPivot()
city:PivotTo(CFrame.new(0,0,120))
local box,size=city:GetBoundingBox()
city:PivotTo(city:GetPivot()+Vector3.new(0,-(box.Position.Y-size.Y/2),0))
local folder=Instance.new("Folder")
folder.Name="ApocalypseDistrict"
folder.Parent=workspace
local rng=Random.new(73)
local concrete=Color3.fromRGB(101,105,100)
local dark=Color3.fromRGB(30,35,35)
local rust=Color3.fromRGB(103,65,43)
local function group(name)
 local g=Instance.new("Model") g.Name=name return g
end
local function part(g,name,size,pos,color,mat,rot)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=CFrame.new(pos)*(rot or CFrame.identity) p.Anchored=true p.Color=color or concrete p.Material=mat or Enum.Material.Concrete p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=g return p
end
local function sign(g,name,cf,size,text,color)
 local p=part(g,name,size,cf.Position,color or dark,Enum.Material.Metal)
 p.CFrame=cf
 local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Front gui.PixelsPerStud=35 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.Parent=p
 local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.Font=Enum.Font.Oswald label.TextScaled=true label.TextColor3=Color3.fromRGB(230,220,191) label.Text=text label.Parent=gui
 return p
end
local roads=group("Streets")
part(roads,"DistrictGround",Vector3.new(440,2,520),Vector3.new(0,-1,-30),Color3.fromRGB(72,77,62),Enum.Material.Ground)
part(roads,"MainAvenue",Vector3.new(42,0.3,310),Vector3.new(0,0.15,-105),Color3.fromRGB(39,42,43),Enum.Material.Asphalt)
part(roads,"CrossStreet",Vector3.new(360,0.3,34),Vector3.new(0,0.16,-65),Color3.fromRGB(43,45,45),Enum.Material.Asphalt)
for _,x in {-26,26} do
 part(roads,"Sidewalk",Vector3.new(9,0.65,290),Vector3.new(x,0.325,-110),Color3.fromRGB(113,111,101))
 part(roads,"Kerb",Vector3.new(0.5,0.9,290),Vector3.new(x-math.sign(x)*4.4,0.45,-110),Color3.fromRGB(146,143,130))
end
for z=-250,30,14 do if math.abs(z+65)>23 then
 part(roads,"FadedLane",Vector3.new(0.35,0.04,6),Vector3.new(-0.7,0.33,z),Color3.fromRGB(177,151,66))
 part(roads,"FadedLane",Vector3.new(0.35,0.04,6),Vector3.new(0.7,0.33,z),Color3.fromRGB(177,151,66))
end end
for x=-17,17,5 do part(roads,"Crosswalk",Vector3.new(2.8,0.04,9),Vector3.new(x,0.35,-39),Color3.fromRGB(177,174,151)) end
for i=1,42 do
 local x,z=rng:NextNumber(-18,18),rng:NextNumber(-248,15)
 local p=part(roads,"AsphaltScar",Vector3.new(rng:NextNumber(0.12,0.3),0.035,rng:NextNumber(2,9)),Vector3.new(x,0.34,z),Color3.fromRGB(20,24,23))
 p.Orientation=Vector3.new(0,rng:NextNumber(-75,75),0) p.CanCollide=false
end
roads.Parent=folder task.wait()
local function building(index,x,z,w,d,floors)
 local g=group("RuinedBlock_"..index)
 local h=floors*11
 local col=Color3.fromRGB(rng:NextInteger(85,125),rng:NextInteger(85,117),rng:NextInteger(76,102))
 part(g,"Foundation",Vector3.new(w+2,1,d+2),Vector3.new(x,0.5,z),col)
 for floor=0,floors do
  local y=1+floor*11
  if floor<floors then part(g,"ExposedFloor",Vector3.new(w,0.65,d),Vector3.new(x,y,z),col)
  else
   part(g,"BrokenRoof",Vector3.new(w*0.56,0.8,d),Vector3.new(x-w*0.22,y,z),col)
   part(g,"BrokenRoofFragment",Vector3.new(w*0.2,0.7,d*0.45),Vector3.new(x+w*0.3,y-1,z-d*0.25),col,Enum.Material.Concrete,CFrame.Angles(0,0,math.rad(-12)))
  end
 end
 for _,sx in {-1,1} do for _,sz in {-1,1} do
  local ph=(sx==1 and sz==1) and h*0.7 or h
  part(g,"ConcreteColumn",Vector3.new(2.2,ph,2.2),Vector3.new(x+sx*(w/2-1),ph/2,z+sz*(d/2-1)),col)
 end end
 -- Street-facing walls with actual open window gaps and fractured top edge.
 for fl=0,floors-1 do
  local y=1+fl*11
  for _,sz in {-1,1} do
   part(g,"WindowSill",Vector3.new(w,2.6,1.2),Vector3.new(x,y+1.6,z+sz*d/2),col,Enum.Material.Brick)
   if not(fl==floors-1 and sz==1) then
    part(g,"WindowLintel",Vector3.new(w,1.5,1.2),Vector3.new(x,y+9.7,z+sz*d/2),col)
   end
   for j=0,3 do
    local wx=x-w/2+1+j*(w-2)/3
    if not(fl==floors-1 and j==2) then
     part(g,"WindowPier",Vector3.new(1.6,6,1.3),Vector3.new(wx,y+6,z+sz*d/2),col,Enum.Material.Brick)
    end
   end
   if fl%2==0 then
    local board=part(g,"BoardedWindow",Vector3.new(w/3-2,0.7,0.35),Vector3.new(x-w/6,y+6,z+sz*(d/2+0.8)),Color3.fromRGB(92,72,49),Enum.Material.WoodPlanks,CFrame.Angles(0,0,math.rad(15)))
   end
  end
  local side=math.sign(x)
  part(g,"OuterWall",Vector3.new(1.3,9.5,d),Vector3.new(x+side*w/2,y+5,z),col,Enum.Material.Brick)
  -- Inner wall has a large ground-floor entrance, open structural bays above.
  if fl>0 then part(g,"InnerSill",Vector3.new(1.3,2.5,d),Vector3.new(x-side*w/2,y+1.7,z),col,Enum.Material.Brick) end
 end
 for i=1,12 do
  local p=part(g,"Rubble",Vector3.new(rng:NextNumber(1,4),rng:NextNumber(0.5,2.5),rng:NextNumber(1,4)),Vector3.new(x+rng:NextNumber(-w/2-3,w/2+3),1.1,z+rng:NextNumber(-d/2-3,d/2+3)),col,Enum.Material.Concrete,CFrame.Angles(rng:NextNumber(-0.5,0.5),rng:NextNumber(0,6),rng:NextNumber(-0.4,0.4)))
 end
 for i=1,5 do part(g,"ExposedRebar",Vector3.new(0.12,rng:NextNumber(2,5),0.12),Vector3.new(x-w*0.08+i*0.55,h+2,z+d/2),rust,Enum.Material.CorrodedMetal,CFrame.Angles(0,0,math.rad(i*6))) end
 g.Parent=folder task.wait()
 return g
end
local specs={
 {-58,0,44,40,3},{58,0,44,40,4},
 {-65,-120,55,50,4},{64,-121,50,50,3},
 {-62,-202,46,48,2},{61,-202,48,48,5},
 {-135,-124,48,48,3},{135,-124,48,48,4},
 {-136,0,47,42,4},{137,0,47,42,2},
 {-137,-207,51,45,5},{138,-207,48,45,3}
}
for i,s in specs do building(i,table.unpack(s)) end
local detail=group("QuarantineAndStreetProps")
-- checkpoint spans entrance, leaving a wide central walking lane
for _,x in {-20,20} do part(detail,"GateColumn",Vector3.new(2,17,2),Vector3.new(x,8.5,22),dark,Enum.Material.Metal) end
sign(detail,"QuarantineGate",CFrame.new(0,15.5,22)*CFrame.Angles(0,math.pi,0),Vector3.new(39,4,0.6),"QUARANTAINE  /  SECTEUR 07",Color3.fromRGB(78,53,40))
sign(detail,"Warning",CFrame.new(24,5,20)*CFrame.Angles(0,math.pi,0),Vector3.new(7,5,0.5),"DANGER\nZONE INFECTEE",Color3.fromRGB(103,44,32))
sign(detail,"Shelter",CFrame.new(-22,5,45),Vector3.new(9,3,0.5),"REFUGE  /  SURVIVANTS",Color3.fromRGB(51,78,65))
for _,x in {-14,14} do
 for row=0,2 do
  for j=0,3 do
   part(detail,"Sandbag",Vector3.new(3.6,1,2),Vector3.new(x+(j-1.5)*3.5+(row%2)*0.8,0.6+row*0.9,24),Color3.fromRGB(129,121,87),Enum.Material.Fabric)
  end
 end
end
for _,z in {-230,-170,-105,-15,50,150} do
 for _,x in {-29,29} do
  part(detail,"LampPost",Vector3.new(0.5,16,0.5),Vector3.new(x,8,z),dark,Enum.Material.Metal)
  part(detail,"LampArm",Vector3.new(5,0.4,0.4),Vector3.new(x-math.sign(x)*2,15.8,z),dark,Enum.Material.Metal)
  local lamp=part(detail,"SodiumLamp",Vector3.new(2,0.3,1.3),Vector3.new(x-math.sign(x)*4,15.5,z),Color3.fromRGB(255,183,85),Enum.Material.Neon)
  if z~=-170 then local light=Instance.new("PointLight") light.Color=lamp.Color light.Brightness=1.5 light.Range=27 light.Shadows=false light.Parent=lamp end
 end
end
local function car(x,z,angle,color,burn)
 local g=group("AbandonedCar") local cf=CFrame.new(x,0.5,z)*CFrame.Angles(0,math.rad(angle),0)
 local function p(n,s,v,c,m) local a=part(g,n,s,Vector3.zero,c,m) a.CFrame=cf*CFrame.new(v) return a end
 p("Chassis",Vector3.new(6,1.6,12),Vector3.new(0,1.4,0),color,Enum.Material.CorrodedMetal)
 p("Cabin",Vector3.new(5.3,1.8,5.8),Vector3.new(0,3,0.7),color,Enum.Material.Metal)
 p("Windshield",Vector3.new(4.7,1.2,0.1),Vector3.new(0,3.1,-2.25),Color3.fromRGB(42,59,57),Enum.Material.Glass)
 for _,side in {-1,1} do
  p("SideWindow",Vector3.new(0.1,1.1,4.5),Vector3.new(side*2.67,3.1,0.7),Color3.fromRGB(35,48,47),Enum.Material.Glass)
  p("Headlight",Vector3.new(1.2,0.6,0.15),Vector3.new(side*1.9,1.9,-6.05),Color3.fromRGB(169,159,115),Enum.Material.Glass)
  for _,dz in {-3.8,3.8} do
   local wheel=p("FlatTyre",Vector3.new(1,2.3,2.3),Vector3.new(side*3,0.8,dz),Color3.fromRGB(19,22,21),Enum.Material.Rubber) wheel.Shape=Enum.PartType.Cylinder
  end
 end
 if burn then
  local hood=p("BurntEngine",Vector3.new(4,0.3,3),Vector3.new(0,2.3,-4),Color3.fromRGB(25,26,24),Enum.Material.CorrodedMetal)
  local fire=Instance.new("Fire") fire.Size=4 fire.Heat=5 fire.Color=Color3.fromRGB(255,124,35) fire.SecondaryColor=Color3.fromRGB(89,34,13) fire.Parent=hood
  local smoke=Instance.new("Smoke") smoke.Color=Color3.fromRGB(42,43,39) smoke.Size=8 smoke.RiseVelocity=5 smoke.Opacity=0.32 smoke.Parent=hood
  local light=Instance.new("PointLight") light.Color=Color3.fromRGB(255,136,51) light.Brightness=2 light.Range=22 light.Parent=hood
 end
 g.Parent=detail
end
car(-11,-12,16,Color3.fromRGB(94,57,42),false)
car(11,-94,-25,Color3.fromRGB(52,69,70),true)
car(-13,-170,160,Color3.fromRGB(120,112,83),false)
car(-105,-63,83,Color3.fromRGB(50,55,52),true)
car(98,-61,-73,Color3.fromRGB(106,96,71),false)
for i=1,28 do
 local x=rng:NextNumber(-175,175) local z=rng:NextNumber(-245,10)
 if math.abs(x)>33 then
  local p=part(detail,"Debris",Vector3.new(rng:NextNumber(1,4),rng:NextNumber(0.5,2),rng:NextNumber(1,4)),Vector3.new(x,0.7,z),concrete,Enum.Material.Concrete,CFrame.Angles(0,rng:NextNumber(0,6),0))
 end
end
-- distant silhouettes keep the skyline closed
for i=1,13 do
 local x=-204+(i-1)*34 local h=rng:NextNumber(40,95)
 part(detail,"DistantRuin",Vector3.new(25,h,23),Vector3.new(x,h/2,-276),Color3.fromRGB(64,71,67))
end
detail.Parent=folder task.wait()
local spawn=workspace:FindFirstChildOfClass("SpawnLocation")
spawn.CFrame=CFrame.new(0,1,175)
spawn.Size=Vector3.new(7,1,7) spawn.Transparency=1 spawn.Neutral=true spawn.Duration=0
for _,v in spawn:GetChildren() do if v:IsA("Decal") then v.Transparency=1 end end
local dummy=workspace:FindFirstChild("TrainingDummy")
local template=game.ServerStorage:FindFirstChild("TrainingDummyTemplate")
local target=CFrame.new(0,4,160)*CFrame.Angles(0,math.pi,0)
if dummy then dummy:PivotTo(target) end
if template then template:PivotTo(target) end
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(0,8,182),Vector3.new(0,6,90))
return {mapParts=#folder:GetDescendants(),campParts=#city:GetDescendants(),spawn=tostring(spawn.Position)}
