local folder=Instance.new("Folder") folder.Name="WeatheredFacades" folder.Parent=workspace.PresentationV2
local colors={Color3.fromRGB(146,143,129),Color3.fromRGB(154,148,135),Color3.fromRGB(125,136,136),Color3.fromRGB(154,137,122)}
local function p(name,size,pos,color)
 local a=Instance.new("Part") a.Name=name a.Size=size a.Position=pos a.Color=color a.Material=Enum.Material.Concrete a.MaterialVariant="V2_AgedConcrete"
 a.Anchored=true a.CanCollide=false a.CanQuery=false a.CanTouch=false a.Parent=folder return a
end
local rng=Random.new(59)
for _,building in workspace.ApocalypseDistrict:GetChildren() do
 local f=building:FindFirstChild("Foundation")
 if not f then continue end
 local x,z=f.Position.X,f.Position.Z local side=math.sign(x) local w,d=f.Size.X-2,f.Size.Z-2
 local face=x-side*(w/2+0.5)
 local floors=0 for _,v in building:GetChildren() do if v.Name=="ExposedFloor" then floors+=1 end end
 local color=colors[rng:NextInteger(1,#colors)]
 for fl=1,floors-1 do
  local base=1+fl*11
  local broken=fl==floors-1
  p("WeatheredSpandrel",Vector3.new(0.55,2.9,d),Vector3.new(face,base+1.85,z),color)
  local length=broken and d*0.62 or d
  p("DamagedLintel",Vector3.new(0.55,2,length),Vector3.new(face,base+9.7,z+(broken and d*0.19 or 0)),color)
  for j=0,3 do
   if not(broken and j==1) then
    p("WindowJamb",Vector3.new(0.55,5.7,1.8),Vector3.new(face,base+6.1,z-d/2+j*d/3),color)
   end
  end
  if fl%2==0 then p("RainStain",Vector3.new(0.015,2.7,0.6),Vector3.new(face-side*0.285,base+1.6,z+d/4),color:Lerp(Color3.fromRGB(64,76,68),0.4)) end
 end
 task.wait()
end
for _,p in folder:GetChildren() do if p:IsA("BasePart") and p.Name~="RainStain" then p.CanCollide=true p.CanQuery=true end end
local sky=game.Lighting:FindFirstChildOfClass("Sky") if sky then sky.CelestialBodiesShown=false end
workspace.Terrain:FindFirstChildOfClass("Clouds").Cover=0.88
workspace.Terrain:FindFirstChildOfClass("Clouds").Density=0.68
return #folder:GetChildren()
