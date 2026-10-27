local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local Factory={}
-- Expedition species reuse the existing six-mesh human rigs, with new silhouettes and gear.
-- This only clones a named template; it never modifies the original nine species.
local function expeditionModel(parent,id,def)
 local base=game.ServerStorage.ZombieTemplates:FindFirstChild(def.Template)
 assert(base and base:FindFirstChild("VisualHead"),"Upgraded base template required: "..def.Template)
 local m=base:Clone() m.Name=id m:ScaleTo(def.Scale)
 local rig={HumanoidRootPart=true,Head=true,Torso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true}
 for _,v in m:GetChildren() do
  if v:IsA("BasePart") then
   if v:IsA("MeshPart") and v.Name:sub(1,6)=="Visual" then
    v.Color=(v.Name=="VisualHead" or v.Name:find("Arm")) and def.Skin or def.Cloth:Lerp(Color3.new(1,1,1),.45)
   elseif not rig[v.Name] then v:Destroy() end
  end
 end
 local scale=def.Scale local ink=Color3.fromRGB(32,44,51) local rust=Color3.fromRGB(131,91,61)
 local function deco(name,target,size,offset,color,material,shape)
  local p=Instance.new("Part") p.Name=name p.Size=size*scale
  p.CFrame=target.CFrame*CFrame.new(offset.Position*scale)*offset.Rotation
  p.Color=color p.Material=material or Enum.Material.SmoothPlastic p.Shape=shape or Enum.PartType.Block
  p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Massless=true p.Parent=m
  local w=Instance.new("WeldConstraint") w.Part0=target w.Part1=p w.Parent=p return p
 end
 local head,torso,right,left=m.Head,m.Torso,m["Right Arm"],m["Left Arm"]
 if id=="Conductor" then
  deco("ConductorCap",head,Vector3.new(1.85,.45,1.4),CFrame.new(0,.6,0),def.Cloth)
  deco("CapBrim",head,Vector3.new(1.9,.12,.75),CFrame.new(0,.42,-.65),ink)
  deco("TicketBadge",torso,Vector3.new(.4,.5,.1),CFrame.new(-.5,.55,-.61),Color3.fromRGB(235,199,105),Enum.Material.Metal)
  deco("UniformBelt",torso,Vector3.new(2.1,.2,1.12),CFrame.new(0,-.65,0),ink)
  deco("LanternHandle",right,Vector3.new(.12,.85,.12),CFrame.new(.15,-1.15,-.3),rust,Enum.Material.Metal)
  deco("SignalLantern",right,Vector3.new(.65,.85,.65),CFrame.new(.15,-1.7,-.3),ink,Enum.Material.Metal)
  deco("LanternGlow",right,Vector3.new(.48,.5,.68),CFrame.new(.15,-1.7,-.3),Color3.fromRGB(129,246,191),Enum.Material.Neon)
  for _,sign in {-1,1} do
   deco("Epaulette",sign<0 and left or right,Vector3.new(1.08,.18,1.05),CFrame.new(0,.86,0),Color3.fromRGB(205,179,106))
   deco("CoatTail",torso,Vector3.new(.7,1,.22),CFrame.new(sign*.6,-.95,.48),def.Cloth,Enum.Material.Fabric)
  end
 elseif id=="TunnelRunner" then
  deco("MinerHelmet",head,Vector3.new(1.8,.55,1.4),CFrame.new(0,.6,0),def.Cloth,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
  deco("Headlamp",head,Vector3.new(.48,.42,.3),CFrame.new(0,.52,-.72),Color3.fromRGB(255,232,155),Enum.Material.Neon)
  deco("DustMask",head,Vector3.new(1.1,.45,.3),CFrame.new(0,-.2,-.7),ink)
  for _,sign in {-1,1} do
   deco("RespiratorFilter",head,Vector3.new(.3,.4,.32),CFrame.new(sign*.48,-.2,-.74),rust,Enum.Material.Metal)
   deco("ReflectiveHarness",torso,Vector3.new(.2,1.8,.12),CFrame.new(sign*.55,.1,-.57),Color3.fromRGB(240,223,115),Enum.Material.Neon)
   deco("KneeGuard",m[sign<0 and "Left Leg" or "Right Leg"],Vector3.new(.9,.55,.22),CFrame.new(0,-.2,-.53),ink,Enum.Material.Metal)
   deco("ScrapClaw",sign<0 and left or right,Vector3.new(.14,.75,.17),CFrame.new(sign*.3,-1,-.45)*CFrame.Angles(.3,0,sign*.2),rust,Enum.Material.CorrodedMetal)
  end
  deco("TunnelPack",torso,Vector3.new(1.3,1.8,.65),CFrame.new(0,.15,.8),ink,Enum.Material.Fabric)
 elseif id=="RailTitan" then
  deco("RailFaceplate",head,Vector3.new(1.65,1.25,.22),CFrame.new(0,.1,-.72),ink,Enum.Material.Metal)
  deco("EyeSlit",head,Vector3.new(1.2,.14,.08),CFrame.new(0,.18,-.88),Color3.fromRGB(146,244,200),Enum.Material.Neon)
  deco("RailArmor",torso,Vector3.new(2.3,1.9,.35),CFrame.new(0,.15,-.7),def.Cloth,Enum.Material.CorrodedMetal)
  for _,sign in {-1,1} do
   deco("SleeperBack",torso,Vector3.new(.42,3.1,.5),CFrame.new(sign*.68,.25,.9)*CFrame.Angles(0,0,sign*.2),rust,Enum.Material.Wood)
   deco("RailShoulder",sign<0 and left or right,Vector3.new(1.5,.42,1.4),CFrame.new(0,.82,0),ink,Enum.Material.Metal)
  end
  deco("RailHammerShaft",right,Vector3.new(.2,3,.2),CFrame.new(.2,-.7,-.3),rust,Enum.Material.Metal)
  deco("RailHammerHead",right,Vector3.new(1.9,.65,.65),CFrame.new(.2,.9,-.3),ink,Enum.Material.CorrodedMetal)
 elseif id=="Lineman" then
  deco("InsulatedHelmet",head,Vector3.new(1.85,.6,1.45),CFrame.new(0,.6,0),def.Cloth,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
  deco("FaceShield",head,Vector3.new(1.55,.8,.12),CFrame.new(0,.02,-.8),Color3.fromRGB(95,191,225),Enum.Material.Glass)
  for _,sign in {-1,1} do
   deco("SafetyStripe",torso,Vector3.new(.22,1.9,.1),CFrame.new(sign*.58,.05,-.6),Color3.fromRGB(245,238,153),Enum.Material.Neon)
   deco("InsulatedGlove",sign<0 and left or right,Vector3.new(1.06,.7,1.06),CFrame.new(0,-.8,0),ink)
  end
  deco("CableSpool",torso,Vector3.new(1.45,1.45,.45),CFrame.new(0,.1,.8),rust,Enum.Material.Metal,Enum.PartType.Ball)
  deco("RepairRod",right,Vector3.new(.14,2.6,.14),CFrame.new(.2,-.75,-.35),Color3.fromRGB(205,202,176),Enum.Material.Metal)
 elseif id=="SparkRunner" then
  deco("ArcVisor",head,Vector3.new(1.5,.32,.2),CFrame.new(0,.15,-.72),Color3.fromRGB(105,217,255),Enum.Material.Neon)
  for _,sign in {-1,1} do
   deco("Capacitor",torso,Vector3.new(.35,1.9,.38),CFrame.new(sign*.5,.15,.75),Color3.fromRGB(174,139,238),Enum.Material.Metal)
   for i=1,3 do deco("DischargeFin",sign<0 and left or right,Vector3.new(.15,.55,.5),CFrame.new(sign*.4,.5-i*.4,.1)*CFrame.Angles(0,0,-sign*.5),Color3.fromRGB(113,222,249),Enum.Material.Neon) end
   deco("SpeedBoot",m[sign<0 and "Left Leg" or "Right Leg"],Vector3.new(.95,.5,1.45),CFrame.new(0,-.75,-.15),ink)
  end
 elseif id=="CoilGolem" then
  deco("TransformerBack",torso,Vector3.new(2.5,2.5,.7),CFrame.new(0,.2,.95),ink,Enum.Material.Metal)
  for _,sign in {-1,1} do
   local arm=sign<0 and left or right
   for i=1,4 do deco("CopperCoil",arm,Vector3.new(1.5,.16,1.5),CFrame.new(0,.7-i*.42,0),rust,Enum.Material.Metal) end
   deco("Terminal",head,Vector3.new(.28,.85,.28),CFrame.new(sign*.55,.85,0),Color3.fromRGB(201,174,253),Enum.Material.Neon)
  end
  deco("CoreWindow",torso,Vector3.new(1.1,1.1,.15),CFrame.new(0,.2,-.85),Color3.fromRGB(178,141,255),Enum.Material.Neon)
 elseif id=="Drowned" then
  deco("SailorCap",head,Vector3.new(1.8,.32,1.35),CFrame.new(0,.65,0),def.Cloth)
  deco("CapBrim",head,Vector3.new(1.9,.1,.7),CFrame.new(0,.48,-.65),ink)
  deco("CapBadge",head,Vector3.new(.3,.22,.06),CFrame.new(0,.62,-.71),Color3.fromRGB(216,181,103),Enum.Material.Metal)
  for _,sign in {-1,1} do
   deco("LifeVest",torso,Vector3.new(.62,1.35,.3),CFrame.new(sign*.54,.25,-.62),Color3.fromRGB(192,122,64),Enum.Material.Fabric)
   deco("VestStripe",torso,Vector3.new(.6,.12,.32),CFrame.new(sign*.54,.5,-.64),Color3.fromRGB(214,211,157))
   deco("CoatTail",torso,Vector3.new(.65,1.15,.22),CFrame.new(sign*.5,-.8,.54)*CFrame.Angles(.2,0,sign*.1),def.Cloth,Enum.Material.Fabric)
  end
  for i=1,3 do deco("Seaweed",left,Vector3.new(.14,.65+i*.12,.13),CFrame.new(-.4+(i-1)*.14,-.55,.3),Color3.fromRGB(63,100,72),Enum.Material.Grass) end
 elseif id=="Raider" then
  deco("DivingMask",head,Vector3.new(1.4,.55,.22),CFrame.new(0,.12,-.68),ink)
  deco("AmberVisor",head,Vector3.new(1.1,.31,.05),CFrame.new(0,.13,-.81),Color3.fromRGB(226,166,72),Enum.Material.Glass)
  for _,sign in {-1,1} do
   deco("Filter",head,Vector3.new(.35,.35,.32),CFrame.new(sign*.45,-.3,-.72),rust,Enum.Material.CorrodedMetal,Enum.PartType.Ball)
   deco("AirTank",torso,Vector3.new(.45,1.7,.45),CFrame.new(sign*.4,.2,.82),Color3.fromRGB(134,152,143),Enum.Material.Metal,Enum.PartType.Ball)
   deco("TankBand",torso,Vector3.new(.48,.1,.49),CFrame.new(sign*.4,.5,.82),ink)
  end
  deco("HarpoonShaft",right,Vector3.new(.12,2.8,.12),CFrame.new(.25,-.9,-.2)*CFrame.Angles(.2,0,-.1),rust,Enum.Material.CorrodedMetal)
  deco("HarpoonHead",right,Vector3.new(.34,.6,.16),CFrame.new(.38,.65,-.52)*CFrame.Angles(.2,0,-.35),Color3.fromRGB(175,190,190),Enum.Material.Metal)
  deco("HarpoonBarb",right,Vector3.new(.42,.1,.16),CFrame.new(.25,.4,-.47)*CFrame.Angles(0,0,.35),ink,Enum.Material.Metal)
  deco("ChestStrap",torso,Vector3.new(.22,1.8,.16),CFrame.new(.1,.25,-.55)*CFrame.Angles(0,0,-.35),ink)
 elseif id=="AnchorTitan" then
  deco("DiverHelmet",head,Vector3.new(2,1.55,1.65),CFrame.new(0,.1,0),rust,Enum.Material.CorrodedMetal,Enum.PartType.Ball)
  deco("HelmetWindow",head,Vector3.new(1.05,.75,.15),CFrame.new(0,.05,-.85),Color3.fromRGB(48,87,103),Enum.Material.Glass)
  for _,x in {-.32,0,.32} do deco("WindowBar",head,Vector3.new(.07,.72,.09),CFrame.new(x,.05,-.96),ink,Enum.Material.Metal) end
  for _,sign in {-1,1} do
   deco("HullShoulder",sign<0 and left or right,Vector3.new(1.5,.4,1.35),CFrame.new(0,.82,0)*CFrame.Angles(0,0,-sign*.15),rust,Enum.Material.CorrodedMetal)
  end
  deco("AnchorStem",right,Vector3.new(.25,2.7,.25),CFrame.new(.2,-.85,-.3),ink,Enum.Material.Metal)
  deco("AnchorStock",right,Vector3.new(1.4,.22,.22),CFrame.new(.2,-.1,-.3),rust,Enum.Material.CorrodedMetal)
  deco("AnchorCrown",right,Vector3.new(1.7,.3,.4),CFrame.new(.2,-2.1,-.3),ink,Enum.Material.Metal)
  for _,sign in {-1,1} do deco("AnchorFluke",right,Vector3.new(.45,.8,.38),CFrame.new(.2+sign*.7,-1.88,-.3)*CFrame.Angles(0,0,-sign*.5),rust,Enum.Material.CorrodedMetal) end
  for i=1,5 do deco("ChainLink",torso,Vector3.new(.25,.3,.12),CFrame.new(-.55+i*.15,.9-i*.25,-.61)*CFrame.Angles(0,0,.4),rust,Enum.Material.Metal) end
 end
 local h=m.Humanoid h.MaxHealth=def.Health h.Health=def.Health h.WalkSpeed=def.Speed
 m:SetAttribute("ZombieType",id) m:SetAttribute("CoinsReward",def.Coins) m:SetAttribute("XPReward",def.XP)
 m:SetAttribute("HarborSpecies",true) m.Parent=parent return m
end
function Factory.Build(parent,id)
 local def=Config.Zombies[id]
 if def.Template then return expeditionModel(parent,id,def) end
 local m=Instance.new("Model") m.Name=id
 local function part(name,size,cf,color,material,shape)
  local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf
  p.Color=color p.Material=material or Enum.Material.SmoothPlastic
  p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
  p.CanCollide=false p.Massless=true if shape then p.Shape=shape end p.Parent=m return p
 end
 local skin,cloth=def.Skin,def.Cloth
 local root=part("HumanoidRootPart",Vector3.new(2,2,1),CFrame.new(0,3,0),skin) root.Transparency=1 root.Massless=false
 local torso=part("Torso",Vector3.new(2,2,1),CFrame.new(0,3,0),cloth) torso.CanCollide=true
 local head=part("Head",Vector3.new(1.65,1,1.1),CFrame.new(0,4.5,0),skin)
 local left=part("Left Arm",Vector3.new(1,2,1),CFrame.new(-1.5,3,0),skin)
 local right=part("Right Arm",Vector3.new(1,2,1),CFrame.new(1.5,3,0),skin)
 local ll=part("Left Leg",Vector3.new(1,2,1),CFrame.new(-0.5,1,0),cloth:Lerp(Color3.new(0,0,0),0.35))
 local rl=part("Right Leg",Vector3.new(1,2,1),CFrame.new(0.5,1,0),cloth:Lerp(Color3.new(0,0,0),0.35))
 local function motor(name,a,b,c0,c1)
  local j=Instance.new("Motor6D") j.Name=name j.Part0=a j.Part1=b j.C0=c0 j.C1=c1 j.Parent=a return j
 end
 motor("RootJoint",root,torso,CFrame.identity,CFrame.identity)
 motor("Neck",torso,head,CFrame.new(0,1,0),CFrame.new(0,-0.5,0))
 motor("Left Shoulder",torso,left,CFrame.new(-1,0.5,0),CFrame.new(0.5,0.5,0))
 motor("Right Shoulder",torso,right,CFrame.new(1,0.5,0),CFrame.new(-0.5,0.5,0))
 motor("Left Hip",torso,ll,CFrame.new(-0.5,-1,0),CFrame.new(0,1,0))
 motor("Right Hip",torso,rl,CFrame.new(0.5,-1,0),CFrame.new(0,1,0))
 local function deco(name,target,size,offset,color,mat,shape)
  local p=part(name,size,target.CFrame*offset,color,mat,shape)
  local weld=Instance.new("WeldConstraint") weld.Part0=target weld.Part1=p weld.Parent=p return p
 end
 local black=Color3.fromRGB(24,29,25)
 local red=Color3.fromRGB(218,88,47)
 for _,sx in {-1,1} do
  deco("EyeSocket",head,Vector3.new(0.48,0.3,0.12),CFrame.new(sx*0.4,0.08,-0.57),black)
  deco("InfectedEye",head,Vector3.new(0.22,0.13,0.13),CFrame.new(sx*0.4,0.08,-0.65),id=="Hazmat" and Color3.fromRGB(111,255,85) or red,Enum.Material.Neon)
 end
 deco("BrokenJaw",head,Vector3.new(0.8,0.2,0.12),CFrame.new(0,-0.32,-0.59),black)
 for i=-1,1 do deco("Tooth",head,Vector3.new(0.1,0.13,0.12),CFrame.new(i*0.2,-0.28,-0.67),Color3.fromRGB(204,198,150)) end
 if id=="Civilian" then
  deco("TornJacket",torso,Vector3.new(0.65,1.6,0.12),CFrame.new(-0.65,0,-0.56),Color3.fromRGB(53,63,89))
  deco("Backpack",torso,Vector3.new(1.5,1.5,0.6),CFrame.new(0,0,0.7),Color3.fromRGB(75,61,47),Enum.Material.Fabric)
  deco("MissingSleeve",right,Vector3.new(1.03,0.6,1.03),CFrame.new(0,0.7,0),cloth)
 elseif id=="Runner" then
  torso.Size=Vector3.new(1.55,1.8,0.8)
  for _,arm in {left,right} do
   arm.Size=Vector3.new(0.65,2.6,0.65)
   for i=-1,1 do deco("FingerClaw",arm,Vector3.new(0.12,0.7,0.13),CFrame.new(i*0.18,-1.45,-0.15)*CFrame.Angles(-0.3,0,0),Color3.fromRGB(160,150,110)) end
  end
  deco("Hood",head,Vector3.new(1.95,0.55,1.35),CFrame.new(0,0.45,0.05),cloth,Enum.Material.Fabric,Enum.PartType.Ball)
  deco("ChestRibs",torso,Vector3.new(1.3,0.15,0.13),CFrame.new(0,-0.3,-0.46),skin)
 elseif id=="Brute" then
  torso.Size=Vector3.new(2.8,2.4,1.5)
  for _,arm in {left,right} do
   arm.Size=Vector3.new(1.35,2.4,1.3)
   deco("HugeFist",arm,Vector3.new(1.65,1.05,1.5),CFrame.new(0,-1,0),skin)
  end
  deco("HeavyJaw",head,Vector3.new(1.9,0.6,1.3),CFrame.new(0,-0.4,0),skin:Lerp(black,0.2))
  deco("ChestHarness",torso,Vector3.new(0.35,2.5,1.65),CFrame.new(-0.7,0,0),Color3.fromRGB(57,46,36),Enum.Material.Leather)
 elseif id=="Worker" then
  deco("HardHat",head,Vector3.new(2,0.75,1.5),CFrame.new(0,0.5,0),Color3.fromRGB(234,174,39),Enum.Material.Plastic,Enum.PartType.Ball)
  deco("HatBrim",head,Vector3.new(2.2,0.12,1.9),CFrame.new(0,0.3,-0.12),Color3.fromRGB(234,174,39))
  for _,y in {-0.4,0.4} do deco("ReflectiveVest",torso,Vector3.new(2.08,0.18,1.08),CFrame.new(0,y,0),Color3.fromRGB(224,221,116),Enum.Material.Metal) end
  deco("ToolBelt",torso,Vector3.new(2.15,0.3,1.3),CFrame.new(0,-0.85,0),black)
 elseif id=="Soldier" then
  deco("CombatHelmet",head,Vector3.new(2,0.8,1.5),CFrame.new(0,0.45,0.05),cloth,Enum.Material.Metal,Enum.PartType.Ball)
  deco("BodyArmor",torso,Vector3.new(2.25,1.7,0.4),CFrame.new(0,0,-0.65),Color3.fromRGB(42,54,44),Enum.Material.DiamondPlate)
  for _,x in {-0.65,0,0.65} do deco("AmmoPouch",torso,Vector3.new(0.45,0.6,0.35),CFrame.new(x,-0.3,-1),cloth) end
  deco("HelmetAntenna",head,Vector3.new(0.08,1.2,0.08),CFrame.new(0.8,0.9,0.3),black,Enum.Material.Metal)
 elseif id=="Scrapper" then
  torso.Size=Vector3.new(2.5,2.3,1.5)
  for _,arm in {left,right} do
   deco("ScrapShoulder",arm,Vector3.new(1.75,0.6,1.6),CFrame.new(0,0.8,0)*CFrame.Angles(0,0,0.2),Color3.fromRGB(110,83,57),Enum.Material.CorrodedMetal)
  end
  deco("CrusherFist",right,Vector3.new(2,1.3,1.8),CFrame.new(0,-1,0),Color3.fromRGB(94,103,100),Enum.Material.DiamondPlate)
  deco("WeldingMask",head,Vector3.new(1.8,1.2,0.3),CFrame.new(0,0,-0.75),Color3.fromRGB(59,62,59),Enum.Material.Metal)
  deco("MaskSlit",head,Vector3.new(1,0.17,0.1),CFrame.new(0,0.15,-0.95),Color3.fromRGB(245,159,69),Enum.Material.Neon)
 elseif id=="Hazmat" then
  deco("HazmatHood",head,Vector3.new(2.1,1.5,1.6),CFrame.new(0,0.15,0.1),cloth,Enum.Material.Fabric,Enum.PartType.Ball)
  deco("MaskVisor",head,Vector3.new(1.6,0.75,0.18),CFrame.new(0,0.12,-0.78),Color3.fromRGB(61,108,87),Enum.Material.Glass)
  for _,x in {-0.5,0.5} do
   deco("RespiratorFilter",head,Vector3.new(0.45,0.45,0.4),CFrame.new(x,-0.35,-0.84),black,Enum.Material.Metal,Enum.PartType.Ball)
   deco("ChemicalTank",torso,Vector3.new(0.65,1.8,0.65),CFrame.new(x,0,0.95),Color3.fromRGB(103,205,56),Enum.Material.Neon,Enum.PartType.Ball)
  end
 elseif id=="Stalker" then
  torso.Size=Vector3.new(1.5,2,0.8)
  for _,arm in {left,right} do
   arm.Size=Vector3.new(0.65,3.1,0.7)
   for i=-1,1 do deco("LongTalon",arm,Vector3.new(0.1,1.2,0.18),CFrame.new(i*0.2,-1.8,-0.25)*CFrame.Angles(-0.5,0,0),Color3.fromRGB(190,184,155),Enum.Material.SmoothPlastic) end
  end
  for i=1,5 do deco("DorsalSpine",torso,Vector3.new(0.35,0.6,0.8),CFrame.new(0,1.4-i*0.45,0.7)*CFrame.Angles(0.5,0,0),Color3.fromRGB(137,126,162)) end
  deco("ElongatedSkull",head,Vector3.new(1.25,1.35,1.2),CFrame.new(0,0.25,0),skin,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 elseif id=="Abomination" then
  torso.Size=Vector3.new(3,2.7,1.8) right.Size=Vector3.new(2.3,3.3,2)
  deco("MutantFist",right,Vector3.new(2.7,1.7,2.4),CFrame.new(0,-1.4,-0.2),skin)
  for i=1,8 do
   deco("ToxicGrowth",torso,Vector3.new(0.55,0.55,0.6),CFrame.new(math.sin(i*2)*1.2,math.cos(i*3)*0.9,-0.93),Color3.fromRGB(156,221,56),Enum.Material.Neon,Enum.PartType.Ball)
  end
  for _,x in {-1,1} do deco("BoneHorn",head,Vector3.new(0.3,1.2,0.4),CFrame.new(x*0.8,0.9,0.1)*CFrame.Angles(0,0,-x*0.5),Color3.fromRGB(189,184,135)) end
 end
 local humanoid=Instance.new("Humanoid") humanoid.Name="Humanoid" humanoid.MaxHealth=def.Health humanoid.Health=def.Health humanoid.WalkSpeed=def.Speed humanoid.BreakJointsOnDeath=false humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None humanoid.Parent=m
 local animator=Instance.new("Animator") animator.Parent=humanoid
 m.PrimaryPart=root
 m:SetAttribute("ZombieType",id) m:SetAttribute("CoinsReward",def.Coins) m:SetAttribute("XPReward",def.XP)
 m:ScaleTo(def.Scale)
 m.Parent=parent return m
end
return Factory
