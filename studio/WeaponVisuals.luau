local C=require(script.Parent:WaitForChild("GameplayConfig"))
local V={}
local finalPalettes={
 ArcPike={accent=Color3.fromRGB(255,207,25),hardware=Color3.fromRGB(42,205,225),core=Color3.fromRGB(99,238,255)},
 BlackoutEdge={accent=Color3.fromRGB(24,146,255),hardware=Color3.fromRGB(255,141,73),core=Color3.fromRGB(255,190,74)},
 EclipseGlaive={accent=Color3.fromRGB(164,68,255),hardware=Color3.fromRGB(255,201,84),core=Color3.fromRGB(255,101,216)}
}
local function recolorImported(model,id,definition)
 local hasSilhouette,hasCore=false,false
 local colors,saturation,partCount={},0,0
 for _,part in model:GetDescendants() do
  if part:IsA("BasePart") then
   local name=string.lower(part.Name)
   hasSilhouette=hasSilhouette or string.find(name,"silhouette",1,true)~=nil
   hasCore=hasCore or string.find(name,"noyau",1,true)~=nil
   local color=part.Color
   colors[string.format("%d,%d,%d",math.round(color.R*255),math.round(color.G*255),math.round(color.B*255))]=true
   local _,sat=color:ToHSV() saturation+=sat partCount+=1
  end
 end
 local unique=0 for _ in colors do unique+=1 end
 local palette=finalPalettes[id]
 if not (hasSilhouette and hasCore) or (not palette and unique>=5 and saturation/math.max(partCount,1)>=.55) then return end
 local hue,_,value=definition.Color:ToHSV()
 local accent=palette and palette.accent or Color3.fromHSV(hue,.92,math.clamp(value,.72,.94))
 local hardware=palette and palette.hardware or accent:Lerp(Color3.fromRGB(229,181,99),.25)
 local core=palette and palette.core or accent:Lerp(Color3.new(1,1,1),.34)
 local leather=accent:Lerp(Color3.fromRGB(39,25,23),.58)
 local steel=accent:Lerp(Color3.fromRGB(33,43,50),.70)
 for _,part in model:GetDescendants() do
  if part:IsA("BasePart") then
   local name=string.lower(part.Name)
   local color,material
   if string.find(name,"noyau",1,true) then color,material=core,palette and Enum.Material.Neon or Enum.Material.SmoothPlastic
   elseif string.find(name,"silhouette",1,true) or string.find(name,"pommeau",1,true) or string.find(name,"ailette",1,true) then color,material=accent,palette and Enum.Material.Neon or Enum.Material.SmoothPlastic
   elseif string.find(name,"bande",1,true) then color,material=leather,Enum.Material.Fabric
   elseif string.find(name,"manche",1,true) then color,material=steel,Enum.Material.Metal
   elseif string.find(name,"collier",1,true) or string.find(name,"garde",1,true) or string.find(name,"rivet",1,true) or string.find(name,"face",1,true) or string.find(name,"tete",1,true) then color,material=hardware,Enum.Material.Metal
   elseif string.find(name,"renfort",1,true) then color,material=hardware:Lerp(Color3.fromRGB(30,39,53),.30),Enum.Material.Metal
   else color,material=steel,Enum.Material.Metal end
   part.Color,part.Material,part.MaterialVariant=color,material,""
   for _,child in part:GetChildren() do if child:IsA("SurfaceAppearance") then child.Color=color end end
  end
 end
end
function V.Build(id)
 local d=C.Weapons[id] local m=Instance.new("Model") m.Name="EquippedWeaponVisual" local pieces={}
 local function p(name,size,cf,color,shape,material)
  local x=Instance.new("Part") x.Name=name x.Size=size x.CFrame=cf x.Color=color
  x.Material=material or Enum.Material.SmoothPlastic x.Shape=shape or Enum.PartType.Block
  x.Anchored=true x.CanCollide=false x.CanTouch=false x.CanQuery=false x.CastShadow=false x.Parent=m
  table.insert(pieces,{part=x,rel=cf}) return x
 end
 if not d or id=="Fists" then return m,pieces end
 local models=script.Parent:FindFirstChild("WeaponModels")
 local source=models and models:FindFirstChild(id)
 if source and source:IsA("Model") then
  m:Destroy() m=source:Clone() m.Name="EquippedWeaponVisual"
  recolorImported(m,id,d)
  local gripPart
  for _,part in m:GetDescendants() do
   if part:IsA("BasePart") and string.find(string.lower(part.Name),"manche",1,true) then gripPart=part break end
  end
  gripPart=gripPart or m:FindFirstChildWhichIsA("BasePart",true)
  local pivot=m:GetPivot()
  if gripPart then
   local offset=pivot:PointToObjectSpace(gripPart.Position)
   local shift=pivot:VectorToWorldSpace(-offset)
   for _,part in m:GetDescendants() do
    if part:IsA("BasePart") then
     part.CFrame=CFrame.new(shift)*part.CFrame
     part.Anchored=true part.CanCollide=false part.CanTouch=false part.CanQuery=false part.CastShadow=false
    end
   end
   m.PrimaryPart=nil m.WorldPivot=pivot
   pivot=m:GetPivot()
  end
  for _,part in m:GetDescendants() do
   if part:IsA("BasePart") then table.insert(pieces,{part=part,rel=pivot:ToObjectSpace(part.CFrame)}) end
  end
  return m,pieces
 end
 local ink=Color3.fromRGB(36,43,63) local metal=Color3.fromRGB(209,235,242)
 local gold=Color3.fromRGB(255,196,64)
 local function ring(name,y,r,color)
  return p(name,Vector3.new(.09,r,r),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.pi/2),color,Enum.PartType.Cylinder,Enum.Material.Metal)
 end
 local function bolt(x,y,z)
  p("HexRivet",Vector3.new(.1,.1,.06),CFrame.new(x,y,z)*CFrame.Angles(0,0,math.pi/4),gold,nil,Enum.Material.Metal)
 end
 if not d.Firearm then
 p("Grip",Vector3.new(0.16,0.65,0.18),CFrame.identity,ink)
 for i=1,6 do p("GripWrap",Vector3.new(0.21,0.055,0.23),CFrame.new(0,-0.31+i*0.10,0)*CFrame.Angles(0,0,-.18),d.Color) end
 ring("Pommel",-.37,.26,gold)
 end
 if id=="LMG" then
  p("Grip",Vector3.new(.3,.65,.34),CFrame.new(0,-.05,.12)*CFrame.Angles(-.2,0,0),ink)
  p("HeavyReceiver",Vector3.new(.52,.54,1.15),CFrame.new(0,.34,-.45),metal,nil,Enum.Material.Metal)
  p("ReceiverInset",Vector3.new(.54,.22,.9),CFrame.new(0,.32,-.45),ink)
  p("Stock",Vector3.new(.38,.44,.9),CFrame.new(0,.23,.6),d.Color)
  p("ButtPad",Vector3.new(.45,.52,.12),CFrame.new(0,.18,1.1),ink)
  p("HeavyHandguard",Vector3.new(.56,.46,1.1),CFrame.new(0,.36,-1.4),d.Color)
  p("HeavyBarrel",Vector3.new(1.9,.24,.24),CFrame.new(0,.47,-1.7)*CFrame.Angles(0,math.pi/2,0),metal,Enum.PartType.Cylinder,Enum.Material.Metal)
  p("MuzzleBrake",Vector3.new(.38,.35,.24),CFrame.new(0,.47,-2.7),ink,nil,Enum.Material.Metal)
  p("Bore",Vector3.new(.15,.15,.015),CFrame.new(0,.47,-2.829),Color3.fromRGB(8,12,18))
  p("Foregrip",Vector3.new(.25,.55,.26),CFrame.new(0,-.06,-1.3),ink)
  p("Magazine",Vector3.new(.8,.8,.7),CFrame.new(.05,-.23,-.6),d.Color,nil,Enum.Material.Metal)
  p("MagazineBase",Vector3.new(.9,.1,.76),CFrame.new(.05,-.67,-.6),ink,nil,Enum.Material.Metal)
  p("FeedCover",Vector3.new(.5,.12,.92),CFrame.new(0,.66,-.45),ink,nil,Enum.Material.Metal)
  p("BoltHandle",Vector3.new(.34,.11,.14),CFrame.new(.35,.46,-.2),gold,nil,Enum.Material.Metal)
  p("RearSight",Vector3.new(.36,.26,.12),CFrame.new(0,.84,.03),ink)
  p("FrontSight",Vector3.new(.1,.35,.12),CFrame.new(0,.72,-2.28),ink)
  p("TriggerGuard",Vector3.new(.32,.13,.48),CFrame.new(0,-.25,-.18),metal,nil,Enum.Material.Metal)
  p("Trigger",Vector3.new(.07,.2,.09),CFrame.new(0,-.08,-.17),gold)
  p("CarryHandleTop",Vector3.new(.18,.13,.75),CFrame.new(.48,1,-.53),d.Color)
  for _,z in {-.86,-.2} do p("CarryHandleLeg",Vector3.new(.18,.27,.13),CFrame.new(.48,.84,z),ink) end
  for _,side in {-1,1} do
   p("BipodLeg",Vector3.new(.12,1.1,.14),CFrame.new(side*.34,-.18,-2.12)*CFrame.Angles(0,0,side*.35),metal,nil,Enum.Material.Metal)
   p("BipodFoot",Vector3.new(.35,.1,.24),CFrame.new(side*.52,-.7,-2.12),ink)
   for i=1,6 do p("CoolingVent",Vector3.new(.035,.2,.08),CFrame.new(side*.29,.39,-1.85+i*.15),ink) end
  end
  for i=1,4 do bolt(.28,.27,-.9+i*.23) end
 elseif id=="Carbine" then
  p("Grip",Vector3.new(.28,.62,.3),CFrame.new(0,-.03,.1)*CFrame.Angles(-.22,0,0),ink)
  p("Receiver",Vector3.new(.38,.42,.95),CFrame.new(0,.36,-.32),metal,nil,Enum.Material.Metal)
  p("ReceiverInset",Vector3.new(.4,.15,.64),CFrame.new(0,.35,-.3),ink)
  p("Stock",Vector3.new(.32,.39,.82),CFrame.new(0,.23,.59)*CFrame.Angles(.12,0,0),d.Color)
  p("ButtPad",Vector3.new(.37,.46,.1),CFrame.new(0,.18,1.02),ink)
  p("Handguard",Vector3.new(.46,.34,.86),CFrame.new(0,.37,-1.14),d.Color)
  p("Barrel",Vector3.new(1.55,.18,.18),CFrame.new(0,.45,-1.36)*CFrame.Angles(0,math.pi/2,0),metal,Enum.PartType.Cylinder,Enum.Material.Metal)
  p("Muzzle",Vector3.new(.28,.28,.18),CFrame.new(0,.45,-2.15),ink,nil,Enum.Material.Metal)
  p("Bore",Vector3.new(.12,.12,.014),CFrame.new(0,.45,-2.247),Color3.fromRGB(8,12,18))
  p("Foregrip",Vector3.new(.22,.46,.24),CFrame.new(0,-.01,-1.13)*CFrame.Angles(-.12,0,0),ink)
  p("Magazine",Vector3.new(.27,.72,.34),CFrame.new(0,-.19,-.48)*CFrame.Angles(.18,0,0),ink)
  p("MagazineBase",Vector3.new(.32,.09,.38),CFrame.new(0,-.55,-.54)*CFrame.Angles(.18,0,0),d.Color)
  p("BoltHandle",Vector3.new(.24,.1,.13),CFrame.new(.27,.47,-.18),gold,nil,Enum.Material.Metal)
  p("SightBase",Vector3.new(.3,.08,.4),CFrame.new(0,.67,-.28),ink)
  for _,x in {-.16,.16} do p("SightFrame",Vector3.new(.05,.32,.12),CFrame.new(x,.83,-.27),ink) end
  p("SightTop",Vector3.new(.37,.05,.12),CFrame.new(0,1,-.27),ink)
  local lens=p("SightLens",Vector3.new(.26,.25,.015),CFrame.new(0,.83,-.27),Color3.fromRGB(111,225,238),nil,Enum.Material.Glass) lens.Transparency=.55
  p("FrontSight",Vector3.new(.07,.16,.1),CFrame.new(0,.66,-1.56),gold)
  p("TriggerGuard",Vector3.new(.1,.08,.36),CFrame.new(0,-.04,-.18),ink)
  p("Trigger",Vector3.new(.06,.18,.06),CFrame.new(0,.06,-.15),gold)
  for i=1,6 do p("RailTooth",Vector3.new(.34,.07,.055),CFrame.new(0,.6,-.62-i*.14),ink) end
  for _,x in {-.238,.238} do for i=1,4 do p("CoolingVent",Vector3.new(.016,.11,.07),CFrame.new(x,.38,-.77-i*.15),ink) end end
  for i=1,4 do p("GripRidge",Vector3.new(.3,.035,.31),CFrame.new(0,-.25+i*.09,.1),d.Color) end
 elseif id=="Marksman" then
  p("Grip",Vector3.new(.26,.63,.32),CFrame.new(0,-.05,.12)*CFrame.Angles(-.2,0,0),ink)
  p("Receiver",Vector3.new(.42,.4,1.2),CFrame.new(0,.38,-.4),metal,nil,Enum.Material.Metal)
  p("Stock",Vector3.new(.36,.42,1.15),CFrame.new(0,.22,.76)*CFrame.Angles(.1,0,0),d.Color)
  p("ButtPad",Vector3.new(.41,.5,.12),CFrame.new(0,.17,1.35),ink)
  p("CheekRest",Vector3.new(.4,.18,.6),CFrame.new(0,.48,.88),ink)
  p("Foreend",Vector3.new(.44,.3,1.18),CFrame.new(0,.32,-1.35),d.Color)
  p("LongBarrel",Vector3.new(2.6,.17,.17),CFrame.new(0,.46,-1.72)*CFrame.Angles(0,math.pi/2,0),metal,Enum.PartType.Cylinder,Enum.Material.Metal)
  p("MuzzleBrake",Vector3.new(.31,.3,.35),CFrame.new(0,.46,-3.03),ink,nil,Enum.Material.Metal)
  p("Bore",Vector3.new(.13,.13,.015),CFrame.new(0,.46,-3.212),Color3.fromRGB(8,12,18))
  p("Magazine",Vector3.new(.29,.44,.39),CFrame.new(0,-.02,-.5),ink)
  p("MagazineBase",Vector3.new(.34,.09,.43),CFrame.new(0,-.28,-.5),d.Color)
  p("BoltStem",Vector3.new(.29,.08,.08),CFrame.new(.3,.55,-.15),metal,nil,Enum.Material.Metal)
  p("BoltHandle",Vector3.new(.22,.22,.22),CFrame.new(.49,.55,-.15),gold,Enum.PartType.Ball,Enum.Material.Metal)
  p("DiopterBase",Vector3.new(.3,.1,.32),CFrame.new(0,.64,.03),ink)
  for _,x in {-.12,.12} do p("DiopterSide",Vector3.new(.05,.24,.09),CFrame.new(x,.8,.03),ink) end
  p("DiopterTop",Vector3.new(.29,.05,.09),CFrame.new(0,.93,.03),ink)
  p("FrontSight",Vector3.new(.06,.25,.08),CFrame.new(0,.72,-2.52),gold)
  for _,sign in {-1,1} do
   p("BipodLeg",Vector3.new(.1,.85,.12),CFrame.new(sign*.22,.02,-1.82)*CFrame.Angles(0,0,-sign*.35),ink,nil,Enum.Material.Metal)
   p("BipodFoot",Vector3.new(.24,.07,.24),CFrame.new(sign*.37,-.38,-1.82),metal,nil,Enum.Material.Metal)
   for i=1,4 do p("ForeendInset",Vector3.new(.02,.11,.12),CFrame.new(sign*.23,.33,-.83-i*.22),ink) end
  end
  p("TriggerGuard",Vector3.new(.1,.08,.36),CFrame.new(0,-.04,-.16),ink)
  p("Trigger",Vector3.new(.06,.18,.06),CFrame.new(0,.06,-.15),gold)
  for i=1,4 do p("StockStud",Vector3.new(.08,.08,.02),CFrame.new(.19,.22,.36+i*.18),gold,nil,Enum.Material.Metal) end
 elseif id=="Shotgun" then
  p("Grip",Vector3.new(.28,.62,.32),CFrame.new(0,-.04,.12)*CFrame.Angles(-.25,0,0),ink)
  p("Receiver",Vector3.new(.38,.39,.86),CFrame.new(0,.36,-.2),ink,nil,Enum.Material.Metal)
  p("ReceiverPlate",Vector3.new(.02,.22,.57),CFrame.new(.2,.38,-.19),metal,nil,Enum.Material.Metal)
  p("EjectionPort",Vector3.new(.025,.12,.23),CFrame.new(.214,.4,-.22),ink)
  p("Stock",Vector3.new(.32,.42,.75),CFrame.new(0,.17,.57)*CFrame.Angles(.16,0,0),d.Color)
  p("ButtPad",Vector3.new(.36,.49,.1),CFrame.new(0,.11,.98)*CFrame.Angles(.16,0,0),ink)
  p("Barrel",Vector3.new(1.65,.22,.22),CFrame.new(0,.5,-1.38)*CFrame.Angles(0,math.pi/2,0),metal,Enum.PartType.Cylinder,Enum.Material.Metal)
  p("MagazineTube",Vector3.new(1.34,.19,.19),CFrame.new(0,.22,-1.16)*CFrame.Angles(0,math.pi/2,0),ink,Enum.PartType.Cylinder,Enum.Material.Metal)
  p("Foreend",Vector3.new(.35,.28,.6),CFrame.new(0,.2,-1.12),d.Color)
  for i=1,5 do p("PumpRib",Vector3.new(.38,.31,.035),CFrame.new(0,.2,-.82-i*.1),ink) end
  p("Muzzle",Vector3.new(.28,.28,.1),CFrame.new(0,.5,-2.24),ink,nil,Enum.Material.Metal)
  p("Bore",Vector3.new(.16,.16,.012),CFrame.new(0,.5,-2.296),Color3.fromRGB(8,12,18))
  p("FrontSight",Vector3.new(.07,.1,.08),CFrame.new(0,.67,-2.1),gold)
  p("RearSight",Vector3.new(.25,.09,.08),CFrame.new(0,.6,.08),d.Color)
  p("TriggerGuard",Vector3.new(.1,.08,.42),CFrame.new(0,-.05,-.18),ink)
  p("GuardFront",Vector3.new(.1,.25,.08),CFrame.new(0,.04,-.39),ink)
  p("Trigger",Vector3.new(.06,.16,.06),CFrame.new(0,.08,-.18),gold)
  for i=1,3 do
   p("SpareShell",Vector3.new(.1,.27,.1),CFrame.new(-.25,.35,.1-i*.17),d.Color)
   p("ShellBrass",Vector3.new(.11,.05,.11),CFrame.new(-.25,.19,.1-i*.17),gold,nil,Enum.Material.Metal)
  end
 elseif id=="Revolver" then
  p("Grip",Vector3.new(.3,.65,.32),CFrame.new(0,-.06,.09)*CFrame.Angles(-.23,0,0),ink)
  for _,x in {-.16,.16} do
   p("WoodGrip",Vector3.new(.025,.44,.28),CFrame.new(x,-.08,.10)*CFrame.Angles(-.23,0,0),d.Color)
   p("GripMedallion",Vector3.new(.035,.1,.1),CFrame.new(x,-.02,.1),gold,Enum.PartType.Cylinder,Enum.Material.Metal)
  end
  p("Frame",Vector3.new(.27,.31,.95),CFrame.new(0,.36,-.2),ink,nil,Enum.Material.Metal)
  p("TopStrap",Vector3.new(.27,.09,.75),CFrame.new(0,.65,-.25),metal,nil,Enum.Material.Metal)
  p("Barrel",Vector3.new(.28,.28,.82),CFrame.new(0,.47,-1.02),metal,nil,Enum.Material.Metal)
  p("BarrelRib",Vector3.new(.1,.055,.83),CFrame.new(0,.64,-1.02),ink,nil,Enum.Material.Metal)
  p("Muzzle",Vector3.new(.32,.32,.11),CFrame.new(0,.47,-1.47),ink,nil,Enum.Material.Metal)
  p("Bore",Vector3.new(.15,.15,.014),CFrame.new(0,.47,-1.533),Color3.fromRGB(8,12,18),Enum.PartType.Block)
  local cylinder=CFrame.new(0,.37,-.29)*CFrame.Angles(0,math.pi/2,0)
  p("Cylinder",Vector3.new(.5,.52,.52),cylinder,metal,Enum.PartType.Cylinder,Enum.Material.Metal)
  for i=0,5 do
   local a=i*math.pi/3 local x,y=math.cos(a)*.17,.37+math.sin(a)*.17
   p("ChamberRim",Vector3.new(.025,.115,.115),CFrame.new(x,y,-.026)*CFrame.Angles(0,math.pi/2,0),gold,Enum.PartType.Cylinder,Enum.Material.Metal)
   p("ChamberPrimer",Vector3.new(.03,.046,.046),CFrame.new(x,y,-.01)*CFrame.Angles(0,math.pi/2,0),ink,Enum.PartType.Cylinder)
  end
  p("CylinderAxle",Vector3.new(.08,.08,.72),CFrame.new(0,.37,-.29),ink,nil,Enum.Material.Metal)
  p("EjectorRod",Vector3.new(.07,.07,.65),CFrame.new(.17,.23,-.83),ink,nil,Enum.Material.Metal)
  p("Hammer",Vector3.new(.16,.2,.14),CFrame.new(0,.60,.24)*CFrame.Angles(-.35,0,0),gold,nil,Enum.Material.Metal)
  p("TriggerGuard",Vector3.new(.11,.08,.45),CFrame.new(0,-.05,-.25),ink)
  p("GuardFront",Vector3.new(.11,.27,.08),CFrame.new(0,.04,-.48),ink)
  p("Trigger",Vector3.new(.06,.16,.06),CFrame.new(0,.09,-.2)*CFrame.Angles(-.25,0,0),gold)
  p("RearSight",Vector3.new(.26,.08,.09),CFrame.new(0,.72,.08),d.Color)
  p("FrontSight",Vector3.new(.07,.1,.08),CFrame.new(0,.72,-1.35),d.Color)
 elseif id=="SMG" then
  p("Grip",Vector3.new(.28,.65,.3),CFrame.new(0,-.03,.12)*CFrame.Angles(-.15,0,0),ink)
  p("Receiver",Vector3.new(.4,.38,1.2),CFrame.new(0,.37,-.27),ink,nil,Enum.Material.Metal)
  p("UpperRail",Vector3.new(.28,.1,1.05),CFrame.new(0,.61,-.3),metal,nil,Enum.Material.Metal)
  p("Handguard",Vector3.new(.36,.32,.55),CFrame.new(0,.32,-.93),d.Color)
  p("Barrel",Vector3.new(.14,.14,.46),CFrame.new(0,.4,-1.38),metal,nil,Enum.Material.Metal)
  p("Muzzle",Vector3.new(.22,.22,.2),CFrame.new(0,.4,-1.62),ink,nil,Enum.Material.Metal)
  p("Bore",Vector3.new(.1,.1,.012),CFrame.new(0,.4,-1.727),Color3.fromRGB(8,12,18))
  p("Magazine",Vector3.new(.24,.68,.3),CFrame.new(0,-.2,-.43)*CFrame.Angles(.12,0,0),metal,nil,Enum.Material.Metal)
  p("MagazineBase",Vector3.new(.29,.09,.35),CFrame.new(0,-.56,-.47),d.Color)
  p("StockBeam",Vector3.new(.12,.12,.6),CFrame.new(0,.35,.6),metal,nil,Enum.Material.Metal)
  p("StockPad",Vector3.new(.3,.5,.12),CFrame.new(0,.18,.93),ink)
  p("RearSight",Vector3.new(.25,.12,.08),CFrame.new(0,.72,.12),d.Color)
  p("FrontSight",Vector3.new(.08,.12,.08),CFrame.new(0,.72,-.76),d.Color)
  p("TriggerGuard",Vector3.new(.1,.08,.38),CFrame.new(0,-.04,-.14),ink)
  p("Trigger",Vector3.new(.06,.18,.06),CFrame.new(0,.06,-.12),gold)
  for i=1,4 do
   p("CoolingVent",Vector3.new(.37,.045,.055),CFrame.new(0,.34,-.71-i*.1),ink)
   p("GripRidge",Vector3.new(.3,.035,.31),CFrame.new(0,-.23+i*.09,.12),d.Color)
  end
 elseif id=="Pistol" then
  p("Grip",Vector3.new(.29,.62,.31),CFrame.new(0,-.02,.03)*CFrame.Angles(math.rad(-12),0,0),ink)
  for _,x in {-.153,.153} do
   p("GripPanel",Vector3.new(.018,.4,.23),CFrame.new(x,-.04,.035)*CFrame.Angles(math.rad(-12),0,0),d.Color)
   for i=1,4 do p("GripTexture",Vector3.new(.023,.025,.23),CFrame.new(x,-.23+i*.08,.035)*CFrame.Angles(math.rad(-12),0,0),ink) end
  end
  p("Magazine",Vector3.new(.26,.47,.25),CFrame.new(0,-.18,.03),metal,nil,Enum.Material.Metal)
  p("MagazineBase",Vector3.new(.34,.09,.36),CFrame.new(0,-.43,.03),d.Color)
  p("Receiver",Vector3.new(.36,.28,.92),CFrame.new(0,.35,-.28),ink,nil,Enum.Material.Metal)
  p("Slide",Vector3.new(.32,.18,.95),CFrame.new(0,.56,-.3),metal,nil,Enum.Material.Metal)
  p("Muzzle",Vector3.new(.22,.22,.12),CFrame.new(0,.4,-.81),ink,nil,Enum.Material.Metal)
  p("Bore",Vector3.new(.1,.1,.015),CFrame.new(0,.4,-.877),Color3.fromRGB(8,12,18))
  p("RearSight",Vector3.new(.26,.09,.09),CFrame.new(0,.69,.08),d.Color)
  p("FrontSight",Vector3.new(.07,.09,.09),CFrame.new(0,.69,-.7),d.Color)
  p("TriggerGuard",Vector3.new(.12,.09,.48),CFrame.new(0,-.04,-.31),ink)
  p("GuardFront",Vector3.new(.12,.28,.08),CFrame.new(0,.08,-.51),ink)
  p("Trigger",Vector3.new(.07,.18,.06),CFrame.new(0,.09,-.25)*CFrame.Angles(math.rad(-18),0,0),gold,nil,Enum.Material.Metal)
  p("EjectionPort",Vector3.new(.012,.1,.21),CFrame.new(.167,.56,-.24),ink)
  p("SlideAccent",Vector3.new(.014,.035,.38),CFrame.new(-.168,.56,-.36),d.Color)
  for i=1,4 do p("SlideGroove",Vector3.new(.34,.12,.035),CFrame.new(0,.56,.09-i*.07),ink) end
 elseif id=="Machete" then
  local steel=Color3.fromRGB(63,151,165) local rust=Color3.fromRGB(163,76,54) local edge=Color3.fromRGB(177,239,220)
  p("Blade",Vector3.new(.38,1.5,.12),CFrame.new(.04,1.15,0),steel,nil,Enum.Material.Metal)
  p("BladeTip",Vector3.new(.38,.34,.12),CFrame.new(.04,2.06,0)*CFrame.Angles(0,0,math.pi),steel,Enum.PartType.Wedge,Enum.Material.Metal)
  p("SharpenedEdge",Vector3.new(.065,1.48,.125),CFrame.new(.255,1.15,0),edge,nil,Enum.Material.Metal)
  p("RustSpine",Vector3.new(.075,1.5,.13),CFrame.new(-.165,1.15,0),d.Color,nil,Enum.Material.Metal)
  p("Guard",Vector3.new(.4,.1,.24),CFrame.new(0,.36,0),rust,nil,Enum.Material.Metal)
  for _,side in {-1,1} do
   for _,y in {.53,.73} do p("BladeRivet",Vector3.new(.035,.09,.09),CFrame.new(0,y,side*.08)*CFrame.Angles(0,math.pi/2,0),gold,Enum.PartType.Cylinder,Enum.Material.Metal) end
   for _,y in {.9,1.1,1.3} do p("BladeScratch",Vector3.new(.09,.025,.015),CFrame.new(-.08,y,side*.069),edge,nil,Enum.Material.Metal) end
  end
 elseif id=="Sledgehammer" then
  local steel=Color3.fromRGB(55,145,164) local rust=Color3.fromRGB(187,77,59)
  p("Shaft",Vector3.new(.2,1.75,.2),CFrame.new(0,.63,0),ink,nil,Enum.Material.Metal)
  ring("HeadCollar",1.48,.31,d.Color)
  p("HammerHead",Vector3.new(1.05,.52,.52),CFrame.new(0,1.78,0),steel,nil,Enum.Material.Metal)
  for _,x in {-.55,.55} do p("StrikingFace",Vector3.new(.13,.59,.59),CFrame.new(x,1.78,0),metal,nil,Enum.Material.Metal) end
  for _,side in {-1,1} do
   for _,x in {-.36,.36} do p("SafetyStripe",Vector3.new(.12,.43,.025),CFrame.new(x,1.78,side*.275),d.Color,nil,Enum.Material.Metal) end
   p("HeadBrace",Vector3.new(.15,.43,.03),CFrame.new(0,1.78,side*.28),ink,nil,Enum.Material.Metal)
   for _,x in {-.24,.24} do for _,y in {1.65,1.91} do p("HeadBolt",Vector3.new(.035,.09,.09),CFrame.new(x,y,side*.31)*CFrame.Angles(0,math.pi/2,0),rust,Enum.PartType.Cylinder,Enum.Material.Metal) end end
  end
 elseif id=="Pipe" then
  p("Pipe",Vector3.new(0.2,1.9,0.2),CFrame.new(0,0.9,0),d.Color,nil,Enum.Material.Metal)
  p("Elbow",Vector3.new(0.55,0.22,0.22),CFrame.new(0.17,1.8,0),metal,nil,Enum.Material.Metal)
  for _,y in {.38,1.5,1.7} do ring("IndustrialCollar",y,.32,ink) end
  p("PipeMouth",Vector3.new(.045,.16,.16),CFrame.new(.46,1.8,0),ink,Enum.PartType.Cylinder)
  p("ValveStem",Vector3.new(.45,.09,.09),CFrame.new(.16,1.25,0),gold)
  p("ValveWheel",Vector3.new(.07,.42,.42),CFrame.new(.4,1.25,0),Color3.fromRGB(244,100,81),Enum.PartType.Cylinder)
  bolt(.445,1.25,0)
 elseif id=="Bat" then
  p("WoodBarrel",Vector3.new(0.33,1.55,0.33),CFrame.new(0,1,0),d.Color)
  for i=1,3 do p("Spike",Vector3.new(0.75,0.07,0.07),CFrame.new(0,0.9+i*0.24,0)*CFrame.Angles(0,math.rad(i*50),0),metal,nil,Enum.Material.Metal) end
  ring("EndCap",1.79,.39,ink)
  for _,y in {.65,1.46} do ring("ReinforcedBand",y,.4,metal) end
  for i=1,3 do p("WoodGrain",Vector3.new(.025,.66,.018),CFrame.new((i-2)*.09,1.03,-.174)*CFrame.Angles(0,0,.08*i),Color3.fromRGB(112,67,43)) end
  p("WarningStripe",Vector3.new(.35,.13,.35),CFrame.new(0,1.63,0),gold)
 elseif id=="Axe" then
  p("Shaft",Vector3.new(0.17,1.9,0.18),CFrame.new(0,0.8,0),Color3.fromRGB(155,111,69))
  p("AxeHead",Vector3.new(0.95,0.55,0.19),CFrame.new(0.22,1.55,0)*CFrame.Angles(0,0,0.15),d.Color,nil,Enum.Material.Metal)
  p("Edge",Vector3.new(0.13,0.62,0.21),CFrame.new(0.72,1.55,0)*CFrame.Angles(0,0,0.15),metal,nil,Enum.Material.Metal)
  p("HeadReinforcement",Vector3.new(.2,.64,.25),CFrame.new(.07,1.55,0),ink,nil,Enum.Material.Metal)
  for _,z in {-.145,.145} do bolt(.07,1.38,z) bolt(.07,1.7,z) end
  p("RescuePick",Vector3.new(.34,.15,.16),CFrame.new(-.4,1.7,0)*CFrame.Angles(0,0,-.25),metal,nil,Enum.Material.Metal)
  for i=1,3 do p("SafetyGrip",Vector3.new(.2,.11,.21),CFrame.new(0,.55+i*.2,0),ink) end
 else
  p("Guard",Vector3.new(0.65,0.1,0.38),CFrame.new(0,0.37,0),d.Color,nil,Enum.Material.Metal)
  p("Blade",Vector3.new(0.18,2.2,0.09),CFrame.new(0,1.5,0),id=="LimitedBlade" and d.Color or metal,nil,id=="LimitedBlade" and Enum.Material.Neon or Enum.Material.Metal)
  p("BladeEdge",Vector3.new(0.035,2.2,0.1),CFrame.new(0.11,1.5,0),Color3.fromRGB(241,255,246),nil,id=="LimitedBlade" and Enum.Material.Neon or Enum.Material.Metal)
  ring("GuardInlay",.4,.35,gold)
  p("BladeSpine",Vector3.new(.055,2.15,.13),CFrame.new(-.11,1.48,0),ink,nil,Enum.Material.Metal)
  p("AngledTip",Vector3.new(.14,.28,.09),CFrame.new(.025,2.66,0)*CFrame.Angles(0,0,-.27),metal,nil,Enum.Material.Metal)
  if id=="LimitedBlade" then
   for i=1,5 do p("NovaRune",Vector3.new(.12,.12,.11),CFrame.new(0,.65+i*.32,0)*CFrame.Angles(0,0,math.pi/4),Color3.fromRGB(230,197,255),nil,Enum.Material.Neon) end
   for _,sign in {-1,1} do p("NovaWing",Vector3.new(.16,.48,.15),CFrame.new(sign*.33,.52,0)*CFrame.Angles(0,0,-sign*.55),d.Color,nil,Enum.Material.Neon) end
  else
   for i=1,4 do p("BladeEtching",Vector3.new(.09,.025,.012),CFrame.new(0,.65+i*.12,-.052),d.Color,nil,Enum.Material.Neon) end
  end
 end
 m.PrimaryPart=pieces[1].part return m,pieces
end
return V
