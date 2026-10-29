-- One-time Edit operation; never install as a startup script.
local storage=game:GetService("ServerStorage")
local cs=game:GetService("CollectionService")
local templates=storage:WaitForChild("ZombieTemplates")
local specs={
 {id="Civilian",scale=1,tag="Assistant-6b3080a8-5e4b-46ed-a0bb-2ffc8ce4ae20"},
 {id="Runner",scale=.94,tag="Assistant-c33ef837-345d-4a2c-b0fc-38917f72f131"},
 {id="Brute",scale=1.35,tag="Assistant-159cfe3e-7933-48ec-bf5b-674b8ef9f825"},
}
local names={head={visual="VisualHead",rig="Head",joint="Neck"},torso={visual="VisualTorso",rig="Torso"},
 ["left arm"]={visual="VisualLeftArm",rig="Left Arm",joint="Left Shoulder"},["right arm"]={visual="VisualRightArm",rig="Right Arm",joint="Right Shoulder"},
 ["left leg"]={visual="VisualLeftLeg",rig="Left Leg",joint="Left Hip"},["right leg"]={visual="VisualRightLeg",rig="Right Leg",joint="Right Hip"}}
local rigNames={HumanoidRootPart=true,Head=true,Torso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true}
assert(not storage:FindFirstChild("BeforeCityZombieRework") and not storage:FindFirstChild("CityZombieSculpts"),"Rework already installed")
local staged={}
for _,spec in specs do
 local old=templates:FindFirstChild(spec.id) local source=cs:GetTagged(spec.tag)[1]
 assert(old and source and source:IsA("Model") and old:FindFirstChild("VisualHead"),"Missing template or source: "..spec.id)
 local box,size=source:GetBoundingBox() local factor=6*spec.scale/size.Y local parts={}
 for _,p in source:GetDescendants() do if p:IsA("MeshPart") then local key=p.Name:gsub("_geom$",""):lower() if names[key] then assert(not parts[key],"Duplicate "..key) parts[key]=p end end end
 for key in names do assert(parts[key],"Missing "..key.." for "..spec.id) end
 local m=old:Clone() local root=m.HumanoidRootPart local torso=m.Torso
 for _,p in m:GetChildren() do if p:IsA("BasePart") and not rigNames[p.Name] then p:Destroy() elseif p.Name=="CityDetails" then p:Destroy() end end
 for key,info in names do
  local piece=parts[key] local rel=box:ToObjectSpace(piece.CFrame)
  local mesh=piece:Clone() mesh.Name=info.visual
  for _,child in mesh:GetDescendants() do if child:IsA("JointInstance") or child:IsA("WeldConstraint") then child:Destroy() end end
  mesh.Size=piece.Size*factor mesh.CFrame=root.CFrame*CFrame.new(rel.Position*factor)*rel.Rotation
  mesh.Anchored=false mesh.Massless=true mesh.CanCollide=false mesh.CanTouch=false mesh.CanQuery=true mesh.Parent=m
  local weld=Instance.new("WeldConstraint") weld.Part0=m[info.rig] weld.Part1=mesh weld.Parent=mesh
  if info.joint then
   local joint=torso:FindFirstChild(info.joint) assert(joint and joint:IsA("Motor6D"),info.joint)
   local pivotY=key=="head" and -piece.Size.Y*.38 or piece.Size.Y*.42
   local pivot=root.CFrame*CFrame.new((rel.Position+Vector3.new(0,pivotY,0))*factor)
   joint.C0=torso.CFrame:ToObjectSpace(pivot) joint.C1=m[info.rig].CFrame:ToObjectSpace(pivot)
  end
 end
 m:SetAttribute("CitySculptV2",true)
 table.insert(staged,{spec=spec,model=m,old=old,source=source})
end
local backup=Instance.new("Folder") backup.Name="BeforeCityZombieRework" backup.Parent=storage
local sources=Instance.new("Folder") sources.Name="CityZombieSculpts" sources.Parent=storage
for _,item in staged do
 item.old:Clone().Parent=backup
 item.source.Name=item.spec.id item.source.Parent=sources
 item.old:Destroy() item.model.Parent=templates
end
return "Installed three sculpted city rigs; originals and generated sources stored in ServerStorage"
