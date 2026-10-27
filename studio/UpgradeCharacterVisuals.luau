local CS=game:GetService("CollectionService")
local assets=game.ReplicatedStorage.PresentationAssets
assert(not game.ServerStorage.ZombieTemplates.Civilian:FindFirstChild("VisualHead"),"Character visuals already upgraded")
local definitions={
 {"CivilianBody","Assistant-d90cfe88-4b49-41bc-ba5d-e55e58420d00"},
 {"WorkerBody","Assistant-d514688b-d822-4634-b870-bf37257d5877"},
 {"HazmatBody","Assistant-c3f06894-97b8-4ce6-bf41-7e4d878e89b0"},
 {"Gloves","Assistant-91215785-e7ea-404c-ac0d-469dca575502"}
}
for _,spec in definitions do local m=CS:GetTagged(spec[2])[1] assert(m,spec[1]) m.Name=spec[1] m.Parent=assets end
game.ServerStorage.ZombieTemplates:Clone().Parent=game.ServerStorage.BeforePresentationV2
local rigs={Head=true,Torso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true,HumanoidRootPart=true}
local mapping={Head="Head",Torso="Torso",LeftArm="Left Arm",RightArm="Right Arm",LeftLeg="Left Leg",RightLeg="Right Leg"}
local sources={Civilian="CivilianBody",Runner="CivilianBody",Brute="CivilianBody",Worker="WorkerBody",Soldier="CivilianBody",Scrapper="WorkerBody",Hazmat="HazmatBody",Stalker="CivilianBody",Abomination="CivilianBody"}
local keep={
 Civilian={Backpack=true},Runner={FingerClaw=true},Brute={ChestHarness=true},
 Worker={},Soldier={CombatHelmet=true,BodyArmor=true,AmmoPouch=true,HelmetAntenna=true},
 Scrapper={ScrapShoulder=true,CrusherFist=true,WeldingMask=true,MaskSlit=true},
 Hazmat={},Stalker={LongTalon=true,DorsalSpine=true},Abomination={ToxicGrowth=true,BoneHorn=true}
}
local config=require(game.ReplicatedStorage.WorldConfig)
for id,sourceName in sources do
 local m=game.ServerStorage.ZombieTemplates[id]
 local def=config.Zombies[id] local scale=def.Scale
 local offsets={}
 for _,v in m:GetDescendants() do
  if v:IsA("WeldConstraint") and v.Part0 and v.Part1 then table.insert(offsets,{part=v.Part1,target=v.Part0,offset=v.Part0.CFrame:ToObjectSpace(v.Part1.CFrame)}) end
 end
 local torso=m.Torso
 -- Move the rigid animation pivots to the shoulder/hip positions of the human mesh.
 for _,spec in {
  {"Neck",Vector3.new(0,1.9,0)},
  {"Left Shoulder",Vector3.new(-0.78,1.35,0)},
  {"Right Shoulder",Vector3.new(0.78,1.35,0)},
  {"Left Hip",Vector3.new(-0.45,-0.05,0)},
  {"Right Hip",Vector3.new(0.45,-0.05,0)}
 } do
  local j=torso:FindFirstChild(spec[1])
  j.C0=CFrame.new(spec[2]*scale)
  j.Part1.CFrame=j.Part0.CFrame*j.C0*j.C1:Inverse()
 end
 for _,item in offsets do if item.part.Parent then item.part.CFrame=item.target.CFrame*item.offset end end
 for _,p in m:GetChildren() do
  if p:IsA("BasePart") then
   if rigs[p.Name] then p.Transparency=1 p.CanQuery=false
   elseif not keep[id][p.Name] then p:Destroy()
   else
    if p.Name=="ToxicGrowth" then p.Material=Enum.Material.SmoothPlastic p.Color=Color3.fromRGB(101,133,72)
    elseif p.Material==Enum.Material.Metal or p.Material==Enum.Material.CorrodedMetal or p.Material==Enum.Material.DiamondPlate then p.Material=Enum.Material.CorrodedMetal p.MaterialVariant="V2_OxidizedSteel" p.Color=Color3.fromRGB(128,127,113) end
   end
  end
 end
 local source=assets[sourceName] local box=source:GetBoundingBox()
 for _,piece in source:GetDescendants() do
  if piece:IsA("MeshPart") then
   local key=piece.Name:gsub("_geom$","")
   local targetName=mapping[key]
   if targetName then
    local rel=box:ToObjectSpace(piece.CFrame)
    local mesh=piece:Clone() mesh.Name="Visual"..key
    for _,v in mesh:GetChildren() do if v:IsA("JointInstance") then v:Destroy() end end
    mesh.Size=piece.Size*scale
    if id=="Runner" or id=="Stalker" then
     if key=="Torso" then mesh.Size*=Vector3.new(0.85,1,0.9) end
     if key=="LeftArm" or key=="RightArm" then mesh.Size*=Vector3.new(0.85,1.1,0.9) end
    elseif id=="Brute" or id=="Abomination" then
     if key=="Torso" then mesh.Size*=Vector3.new(1.25,1,1.15) end
     if key=="RightArm" and id=="Abomination" then mesh.Size*=Vector3.new(1.5,1.18,1.4) end
    end
    mesh.CFrame=m.HumanoidRootPart.CFrame*CFrame.new(rel.Position*scale)*rel.Rotation
    mesh.Anchored=false mesh.CanCollide=false mesh.CanQuery=true mesh.CanTouch=false mesh.Massless=true
    mesh.Color=id=="Stalker" and Color3.fromRGB(178,190,200) or id=="Abomination" and Color3.fromRGB(194,210,177) or Color3.new(1,1,1)
    if key=="Head" and id~="Hazmat" then mesh.Color=Color3.fromRGB(159,174,146) end
    mesh.Parent=m
    local weld=Instance.new("WeldConstraint") weld.Part0=m[targetName] weld.Part1=mesh weld.Parent=mesh
   end
  end
 end
 m:SetAttribute("PresentationV2",true)
 task.wait()
end
-- Normalize glove meshes for the first-person rig. Keep the original pair as an asset.
local gloves=assets.Gloves
for _,side in {"Left","Right"} do
 local found
 for _,v in gloves:GetDescendants() do if v:IsA("MeshPart") and v.Name==side.."Glove_geom" then found=v break end end
 assert(found,side.." glove mesh")
 local model=Instance.new("Model") model.Name=side.."Glove"
 local p=found:Clone() p.Name="Glove"
 p.Size=Vector3.new(0.6,0.48,0.65)
 p.CFrame=CFrame.Angles(math.pi/2,0,0)
 p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false
 p.Parent=model model.PrimaryPart=p model.Parent=assets
end
return {upgradedTemplates=#game.ServerStorage.ZombieTemplates:GetChildren(),assets=#assets:GetChildren()}
