local CS=game:GetService("CollectionService")
local assets=game.ReplicatedStorage.PresentationAssets
assert(not workspace.PresentationV2:FindFirstChild("DetailedEnvironmentAssets"),"Detailed environment already installed")
local function source(tag,name)
 local model=CS:GetTagged(tag)[1] assert(model,"Missing generated "..name)
 model.Name=name model.Parent=assets return model
end
local car=source("Assistant-75650a7c-391e-4499-8932-1c3239eea4c6","WreckSedan")
local weeds=source("Assistant-38136ea2-e5e1-4198-a6d1-532720a0c7e9","Weeds")
local rubble=source("Assistant-1a8800dc-e841-43f9-a015-09e9acf53d61","Rubble")
local folder=Instance.new("Folder") folder.Name="DetailedEnvironmentAssets" folder.Parent=workspace.PresentationV2
local function place(template,name,position,yaw,scale)
 local m=template:Clone() m.Name=name
 if scale then m:ScaleTo(scale) end
 local box,size=m:GetBoundingBox()
 local target=CFrame.new(position+Vector3.new(0,size.Y/2,0))*CFrame.Angles(0,yaw or 0,0)
 m:PivotTo(target*box:ToObjectSpace(m:GetPivot()))
 for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false end end
 m.Parent=folder return m
end
local replaced=0
for _,model in workspace.ApocalypseDistrict:GetDescendants() do
 if model:IsA("Model") and model.Name=="AbandonedCar" then
  local chassis=model:FindFirstChild("Chassis")
  if chassis then
   for _,p in model:GetDescendants() do if p:IsA("BasePart") then p:SetAttribute("V2OriginalTransparency",p.Transparency) p.Transparency=1 p.CanCollide=p.Name=="Chassis" or p.Name=="Cabin" p.CanQuery=p.CanCollide end end
   local _,yaw=chassis.CFrame:ToOrientation()
   place(car,"DetailedWreck",Vector3.new(chassis.Position.X,0.3,chassis.Position.Z),yaw,1)
   replaced+=1
  end
 end
end
local rng=Random.new(338)
for _,cx in {0,620,1240} do
 for i=1,22 do
  local side=i%2==0 and 1 or -1
  local x=cx+side*rng:NextNumber(24,30)
  local z=rng:NextNumber(-245,0)
  place(weeds,"ReclaimedGrass",Vector3.new(x,0.6,z),rng:NextNumber(0,6),rng:NextNumber(0.4,0.8))
 end
 for i=1,7 do
  local side=i%2==0 and 1 or -1
  local x=cx+side*rng:NextNumber(32,45)
  local z=rng:NextNumber(-240,-20)
  place(rubble,"ConcreteRubble",Vector3.new(x,0.6,z),rng:NextNumber(0,6),rng:NextNumber(0.5,0.95))
 end
end
for _,pos in {Vector3.new(660,0.3,-35),Vector3.new(580,0.3,-178),Vector3.new(1265,0.3,-190)} do place(car,"EvacuationWreck",pos,rng:NextNumber(-0.6,0.6),1) end
return {replacedCars=replaced,environmentInstances=#folder:GetDescendants()}
