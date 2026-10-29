-- One-time Edit operation; the director clones these templates, never run as a startup script.
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
local ids={"Civilian","Runner","Brute"}
assert(not game.ServerStorage:FindFirstChild("BeforeCityZombieDetails"),"City zombie backup already exists")
for _,id in ids do
 local m=templates:FindFirstChild(id)
 assert(m and m:FindFirstChild("VisualHead") and m:FindFirstChild("VisualTorso") and not m:FindFirstChild("CityDetails"),"Unexpected template: "..id)
end
local backup=Instance.new("Folder") backup.Name="BeforeCityZombieDetails" backup.Parent=game.ServerStorage
for _,id in ids do templates[id]:Clone().Parent=backup end
local palette={cloth=Color3.fromRGB(48,55,58), leather=Color3.fromRGB(76,59,46), bone=Color3.fromRGB(180,174,138), wound=Color3.fromRGB(86,40,36), metal=Color3.fromRGB(92,91,79), rust=Color3.fromRGB(125,75,49), eye=Color3.fromRGB(230,101,49)}
local function decorate(m,scale)
 local folder=Instance.new("Folder") folder.Name="CityDetails" folder.Parent=m
 local function add(name,target,size,position,color,material,angle)
  local base=m:FindFirstChild("Visual"..target) assert(base,"Missing visual "..target)
  local p=Instance.new("Part") p.Name=name p.Size=size*scale
  p.CFrame=base.CFrame*CFrame.new(position*scale)*CFrame.Angles(0,0,angle or 0)
  p.Color=palette[color] p.Material=material or Enum.Material.Fabric
  p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Massless=true p.Parent=folder
  local w=Instance.new("WeldConstraint") w.Part0=base w.Part1=p w.Parent=p
 end
 if m.Name=="Civilian" then
  for _,side in {-1,1} do
   add("JacketStrap","Torso",Vector3.new(.12,1.6,.08),Vector3.new(side*.45,.15,-.74),"leather",nil,side*.10)
   add("Eye","Head",Vector3.new(.12,.08,.04),Vector3.new(side*.22,.12,-.52),"eye",Enum.Material.Neon)
  end
  add("ChestTear","Torso",Vector3.new(.48,.52,.07),Vector3.new(.3,-.34,-.75),"wound",nil,-.28)
  for i=1,3 do add("Stitch","Torso",Vector3.new(.34,.035,.04),Vector3.new(.3,-.48+i*.12,-.80),"bone",nil,.2) end
  add("ArmBandage","RightArm",Vector3.new(.96,.24,.92),Vector3.new(0,-.55,0),"bone")
  add("CoatHem","Torso",Vector3.new(.75,.52,.08),Vector3.new(-.45,-1.13,-.66),"cloth",nil,-.12)
 elseif m.Name=="Runner" then
  add("HoodBack","Head",Vector3.new(1.08,.64,.28),Vector3.new(0,.23,.39),"cloth")
  for _,side in {-1,1} do
   add("HoodEdge","Head",Vector3.new(.18,.72,.28),Vector3.new(side*.47,.15,-.34),"cloth",nil,side*.12)
   add("Eye","Head",Vector3.new(.15,.08,.04),Vector3.new(side*.21,.12,-.52),"eye",Enum.Material.Neon)
   add("WristWrap",side<0 and "LeftArm" or "RightArm",Vector3.new(.8,.25,.82),Vector3.new(0,-.78,0),"wound")
  end
  for i=1,3 do add("ExposedRib","Torso",Vector3.new(.75-i*.12,.075,.08),Vector3.new(0,.12-i*.21,-.64),"bone",nil,(i-2)*.08) end
  add("TornSash","Torso",Vector3.new(.16,1.6,.09),Vector3.new(.36,0,-.65),"wound",nil,-.35)
 elseif m.Name=="Brute" then
  for _,side in {-1,1} do
   local arm=side<0 and "LeftArm" or "RightArm"
   add("ShoulderPlate",arm,Vector3.new(1.25,.28,1.15),Vector3.new(0,1.18,0),"metal",Enum.Material.CorrodedMetal,side*.12)
   add("PlateRivet",arm,Vector3.new(.18,.12,.18),Vector3.new(0,1.36,-.38),"rust",Enum.Material.Metal)
   add("WristGuard",arm,Vector3.new(1.2,.34,1.05),Vector3.new(0,-.8,0),"leather")
   add("Eye","Head",Vector3.new(.13,.08,.04),Vector3.new(side*.21,.12,-.52),"eye",Enum.Material.Neon)
  end
  add("IronChestPlate","Torso",Vector3.new(1.05,.72,.12),Vector3.new(.25,.45,-.85),"metal",Enum.Material.CorrodedMetal,-.14)
  add("Belt","Torso",Vector3.new(2.32,.22,1.65),Vector3.new(0,-.95,0),"leather")
  add("Buckle","Torso",Vector3.new(.38,.32,.1),Vector3.new(0,-.95,-.84),"rust",Enum.Material.Metal)
  for i=1,3 do add("Scar","Head",Vector3.new(.035,.35,.04),Vector3.new(.3+i*.08,-.08,-.54),"wound",nil,-.5) end
 end
end
for _,spec in {{"Civilian",1},{"Runner",.94},{"Brute",1.35}} do decorate(templates[spec[1]],spec[2]) end
return "City zombie details installed; originals in ServerStorage.BeforeCityZombieDetails"
