-- One-time Edit builder. Never install as a runtime Script.
assert(not game:GetService("RunService"):IsRunning(),"Run only in Edit")
local existing=workspace:FindFirstChild("TraversalCover")
if existing then
 assert(existing:GetAttribute("Complete")==true and existing:GetAttribute("Version")==1,"Inspect incomplete/existing cover before changing it")
 for _,name in {"FactoryCrate","FactoryPipeRack","LabConsole","LabBarrier"} do assert(existing:FindFirstChild(name),"Missing cover model: "..name) end
 return "Traversal cover already installed"
end
local root=Instance.new("Folder") root.Name="TraversalCover" root:SetAttribute("Version",1) root:SetAttribute("Complete",false) root.Parent=workspace
local ink=Color3.fromRGB(46,53,61)
local steel=Color3.fromRGB(127,140,143)
local amber=Color3.fromRGB(236,173,64)
local mint=Color3.fromRGB(125,209,171)
local function makeModel(name,zone,x,z,width,height,depth,kind)
 local params=RaycastParams.new() params.RespectCanCollide=true params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={root}
 local hit=workspace:Raycast(Vector3.new(x,20,z),Vector3.new(0,-30,0),params)
 assert(hit and hit.Normal.Y>.9,"No flat support for "..name)
 local floor=hit.Position.Y
 local base=CFrame.new(x,floor,z)
 local model=Instance.new("Model") model.Name=name
 model:SetAttribute("ZoneId",zone) model:SetAttribute("CoverType",kind)
 local function part(label,size,offset,color,material,collidable)
  local p=Instance.new("Part") p.Name=label p.Size=size p.CFrame=base*offset p.Anchored=true
  p.Color=color p.Material=material or Enum.Material.Metal
  p.CanCollide=collidable==true p.CanTouch=false p.CanQuery=collidable==true p.CastShadow=label~="ApproachPaint"
  p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=model
  return p
 end
 local color=kind=="Crate" and Color3.fromRGB(121,91,65) or kind=="PipeRack" and Color3.fromRGB(79,91,98) or Color3.fromRGB(116,142,138)
 local core=part("VaultCore",Vector3.new(width,height,depth),CFrame.new(0,height/2,0),color,kind=="Crate" and Enum.Material.CorrodedMetal or Enum.Material.Metal,true)
 core:SetAttribute("TraversalObstacle",true) model.PrimaryPart=core
 model:SetAttribute("Approach",Vector3.new(x,floor+5,z+depth/2+3))
 model:SetAttribute("VaultDirection",Vector3.new(0,0,-1))
 for _,side in {-1,1} do
  part("EdgeGuard",Vector3.new(.18,height+.04,depth+.08),CFrame.new(side*(width/2-.1),height/2,0),ink)
 end
 if kind=="Crate" then
  for _,side in {-1,1} do
   part("ShippingStrap",Vector3.new(.19,height+.08,depth+.14),CFrame.new(side*width*.26,height/2,0),steel)
  end
  for _,y in {.3,height-.3} do
   part("ReinforcedRim",Vector3.new(width-.3,.12,.08),CFrame.new(0,y,depth/2+.045),ink)
   for _,xOffset in {-width*.4,0,width*.4} do
    part("Bolt",Vector3.new(.11,.11,.04),CFrame.new(xOffset,y,depth/2+.1)*CFrame.Angles(0,0,math.pi/4),amber)
   end
  end
  for i=1,3 do
   part("WeatheringScratch",Vector3.new(.035,.45,.015),CFrame.new(-.7+i*.32,height*.58,depth/2+.09)*CFrame.Angles(0,0,-.2),steel)
  end
 elseif kind=="PipeRack" then
  for _,y in {.48,1.08} do
   for _,zOffset in {-.23,.23} do
    local pipe=part("RecoveredPipe",Vector3.new(width-.4,.46,.46),CFrame.new(0,y,zOffset),steel)
    pipe.Shape=Enum.PartType.Cylinder
    for _,xOffset in {-width*.36,width*.36} do
     local collar=part("PipeCollar",Vector3.new(.12,.51,.51),CFrame.new(xOffset,y,zOffset),amber)
     collar.Shape=Enum.PartType.Cylinder
    end
   end
  end
  part("RackLip",Vector3.new(width,.15,.12),CFrame.new(0,height-.1,depth/2+.07),ink)
 elseif kind=="Console" then
  part("BrokenScreen",Vector3.new(width-.7,.7,.07),CFrame.new(0,height*.68,depth/2+.05),ink,Enum.Material.Glass)
  for i=1,5 do
   part("ScreenTelemetry",Vector3.new(.45+i*.16,.035,.015),CFrame.new(-.7,height*.49+i*.105,depth/2+.095),mint,Enum.Material.Neon)
  end
  for i=1,4 do part("ConsoleKey",Vector3.new(.25,.12,.08),CFrame.new(-.65+i*.35,.38,depth/2+.06),i==4 and amber or ink) end
  part("WarningPanel",Vector3.new(.5,.45,.08),CFrame.new(width*.36,.42,depth/2+.06),amber)
 else
  part("SafetyRail",Vector3.new(width,.18,depth+.12),CFrame.new(0,height-.08,0),mint)
  for i=1,5 do
   part("HazardStripe",Vector3.new(.3,height*.55,.035),CFrame.new((i-3)*1.05,height*.48,depth/2+.04)*CFrame.Angles(0,0,-.3),amber)
  end
  for _,side in {-1,1} do part("BarrierFoot",Vector3.new(.8,.15,depth+.3),CFrame.new(side*(width/2-.4),.08,0),ink) end
 end
 for _,side in {-1,1} do
  part("ApproachPaint",Vector3.new(1.1,.018,.12),CFrame.new(side*.4,.012,depth/2+2.2)*CFrame.Angles(0,-side*.55,0),zone=="Factory" and amber or mint,Enum.Material.SmoothPlastic)
 end
 model.Parent=root
 return model
end
makeModel("FactoryCrate","Factory",638,-28,6,2.2,1.4,"Crate") task.wait()
makeModel("FactoryPipeRack","Factory",602,-42,6.5,1.6,1.1,"PipeRack") task.wait()
makeModel("LabConsole","Lab",1258,-28,5.8,2.4,1.4,"Console") task.wait()
makeModel("LabBarrier","Lab",1222,-42,7,1.9,.8,"Barrier")
root:SetAttribute("Complete",true)
return "Four traversal cover models added; only VaultCore parts collide"
