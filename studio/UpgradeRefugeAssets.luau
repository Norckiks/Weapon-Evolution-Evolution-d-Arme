local assets=game.ReplicatedStorage.PresentationAssets
assert(not workspace.PresentationV2:FindFirstChild("DetailedRefuge"),"Refuge assets already upgraded")
local CS=game:GetService("CollectionService")
for _,item in {{"Sleeve","Assistant-b7f1996a-8fc8-4ed5-a26f-b34063397b4e"},{"Tent","Assistant-82000ced-b429-4d19-923a-0e3bc3e434f1"},{"ArmoredTruck","Assistant-c642e22f-3b77-46aa-bd15-f99088de7573"}} do
 local m=CS:GetTagged(item[2])[1] assert(m,item[1]) m.Name=item[1] m.Parent=assets
end
local folder=Instance.new("Folder") folder.Name="DetailedRefuge" folder.Parent=workspace.PresentationV2
local function collider(model,size,cf)
 local p=Instance.new("Part") p.Name="CollisionProxy" p.Size=size p.CFrame=cf p.Transparency=1 p.Anchored=true p.Parent=model
end
local function place(template,name,position,yaw,scale)
 local m=template:Clone() m.Name=name m:ScaleTo(scale)
 local box,size=m:GetBoundingBox()
 local target=CFrame.new(position+Vector3.new(0,size.Y/2,0))*CFrame.Angles(0,yaw,0)
 m:PivotTo(target*box:ToObjectSpace(m:GetPivot()))
 for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false end end
 m.Parent=folder return m,target,size
end
local counts={tents=0,trucks=0}
for _,old in workspace.SurvivorCamp:GetDescendants() do
 if old:IsA("Model") and (old.Name=="Tent" or old.Name=="ArmoredVehicle") then
  local box,size=old:GetBoundingBox()
  for _,p in old:GetDescendants() do if p:IsA("BasePart") then p:SetAttribute("V2OriginalTransparency",p.Transparency) p.Transparency=1 p.CanCollide=false p.CanQuery=false p.CanTouch=false end end
  local base=Vector3.new(box.Position.X,0.2,box.Position.Z)
  if old.Name=="Tent" then
   local m,cf,s=place(assets.Tent,"CanvasShelter",base,base.X>0 and math.pi/2 or -math.pi/2,0.95)
   local ground=CFrame.new(base)*cf.Rotation
   for _,side in {-1,1} do collider(m,Vector3.new(0.3,3.8,s.Z*0.8),ground*CFrame.new(side*s.X*0.4,1.9,0)) end
   collider(m,Vector3.new(s.X*0.75,3.8,0.3),ground*CFrame.new(0,1.9,s.Z*0.38))
   counts.tents+=1
  else
   local m,cf,s=place(assets.ArmoredTruck,"MilitaryWreck",base,0,0.85)
   collider(m,Vector3.new(s.X*0.84,s.Y*0.75,s.Z*0.8),cf)
   counts.trucks+=1
  end
 end
end
for _,v in workspace.ProgressionZones:GetDescendants() do
 if v:IsA("SurfaceGui") and v.Face==Enum.NormalId.Front then local back=v:Clone() back.Face=Enum.NormalId.Back back.Parent=v.Parent end
end
return counts
