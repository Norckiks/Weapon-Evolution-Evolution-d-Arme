-- Layer accepted attacks over the normal R6/R15 Animator poses.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Motion=require(game.ReplicatedStorage:WaitForChild("WeaponMotion"))
local Weapons=require(game.ReplicatedStorage:WaitForChild("GameplayConfig")).Weapons
local entries={} local applied={}
local function watch(player)
 local entry={Player=player} entries[player]=entry
 entry.Connection=player.CharacterAdded:Connect(function(character) entry.Character=character entry.Right=nil entry.Left=nil entry.Joints=nil entry.Crouch=0 entry.Slide=0 entry.Vault=0 entry.ShotAt=nil entry.ShotWeapon=nil end)
 entry.Character=player.Character
end
for _,player in Players:GetPlayers() do watch(player) end
Players.PlayerAdded:Connect(watch)
Players.PlayerRemoving:Connect(function(player)
 local entry=entries[player] if entry then entry.Connection:Disconnect() entries[player]=nil end
end)
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShotFX").OnClientEvent:Connect(function(player,_,_,id)
 local entry=entries[player] if entry then entry.ShotAt=os.clock() entry.ShotWeapon=id end
end)
RunService.PreAnimation:Connect(function()
 -- Remove only the layer applied last frame, before Animator writes its next pose.
 for motor,base in applied do if motor.Parent then motor.Transform=base end end
 table.clear(applied)
end)
local function shoulder(character,right)
 local name=right and "RightShoulder" or "LeftShoulder"
 local oldName=right and "Right Shoulder" or "Left Shoulder"
 for _,v in character:GetDescendants() do if (v:IsA("Motor6D") or v:IsA("AnimationConstraint")) and (v.Name==name or v.Name==oldName) then return v end end
end
local function layer(joint,pose)
 if not joint or not joint.Parent then return end
 applied[joint]=applied[joint] or joint.Transform
 local axes=joint.C0.Rotation
 joint.Transform=joint.Transform*axes:Inverse()*pose*axes
end
RunService.PreSimulation:Connect(function(dt)
 local now=workspace:GetServerTimeNow() local camera=workspace.CurrentCamera
 local motionScale=Players.LocalPlayer:GetAttribute("ReducedMotion") and .25 or 1
 for _,entry in entries do
  local c=entry.Character local h=c and c:FindFirstChildOfClass("Humanoid") local root=c and c:FindFirstChild("HumanoidRootPart")
  if not root or not h or h.Health<=0 or not camera or (root.Position-camera.CFrame.Position).Magnitude>120 then continue end
  if not entry.Joints then
   entry.Joints={}
   for _,v in c:GetDescendants() do if v:IsA("Motor6D") or v:IsA("AnimationConstraint") then entry.Joints[v.Name:gsub(" ","")]=v end end
  end
  local blend=1-math.exp(-dt*14)
  entry.Crouch=(entry.Crouch or 0)+((c:GetAttribute("Crouching") and 1 or 0)-(entry.Crouch or 0))*blend
  entry.Slide=(entry.Slide or 0)+((c:GetAttribute("Sliding") and 1 or 0)-(entry.Slide or 0))*blend
  entry.Vault=(entry.Vault or 0)+((c:GetAttribute("Vaulting") and 1 or 0)-(entry.Vault or 0))*blend
  local crouch,slide,vault=entry.Crouch,entry.Slide,entry.Vault local j=entry.Joints
  local velocity=root.CFrame:VectorToObjectSpace(root.AssemblyLinearVelocity)
  local moving=Vector3.new(velocity.X,0,velocity.Z).Magnitude>3 and h.FloorMaterial~=Enum.Material.Air
  local run=c:GetAttribute("Sprinting")==true and moving and not c:GetAttribute("Sliding") and not c:GetAttribute("Vaulting") and 1 or 0
  entry.Run=(entry.Run or 0)+(run-(entry.Run or 0))*blend
  local lean=entry.Run*motionScale
  layer(j.Waist or j.RootJoint,CFrame.Angles(-.16*lean,0,math.clamp(-velocity.X/40,-.12,.12)*lean))
  local abilityPose,abilityWeight,bodyAngle=Motion.Ability(c:GetAttribute("AbilityId"),now-(c:GetAttribute("AbilityAt") or -math.huge),1)
  abilityWeight*=motionScale
  local ax,ay,az=abilityPose:ToOrientation()
  layer(j.LeftShoulder,CFrame.Angles(ax*abilityWeight,ay*abilityWeight,-az*abilityWeight))
  layer(j.RightShoulder,CFrame.Angles(ax*abilityWeight,-ay*abilityWeight,az*abilityWeight))
  layer(j.Waist or j.RootJoint,CFrame.Angles(math.rad(bodyAngle)*motionScale,0,0))
  layer(j.Waist,CFrame.Angles(.22*crouch-.35*slide+.2*vault,0,0))
  layer(j.LeftHip,CFrame.Angles(-.55*crouch-.9*slide-.65*vault,0,-.08*slide))
  layer(j.RightHip,CFrame.Angles(-.55*crouch-.35*slide-.35*vault,0,.08*slide))
  layer(j.LeftKnee,CFrame.Angles(.9*crouch+1.3*slide+1.1*vault,0,0))
  layer(j.RightKnee,CFrame.Angles(.9*crouch+.6*slide+.7*vault,0,0))
  layer(j.LeftShoulder,CFrame.Angles(-.35*crouch-.7*slide-1.1*vault,0,-.2*slide))
  layer(j.RightShoulder,CFrame.Angles(-.35*crouch-.7*slide-1.1*vault,0,.2*slide))
  local equipped=entry.Player:GetAttribute("EquippedWeapon")
  local firearm=Weapons[equipped] and Weapons[equipped].Firearm
  if firearm then
   local model=c:FindFirstChild("EquippedWeaponVisual")
   -- A replicated model can arrive before all of its joints.
   if entry.WeaponModel~=model or not entry.Mechanisms or #entry.Mechanisms~=(model and model:GetAttribute("MechanismCount") or 0) then
    entry.WeaponModel=model entry.Mechanisms={}
    if model then for _,v in model:GetDescendants() do if v:IsA("Motor6D") and v.Name=="WeaponMechanism" then table.insert(entry.Mechanisms,v) end end end
   end
   local usable=entry.Player:GetAttribute("HasStarted")==true and not entry.Player:GetAttribute("InGameMenu")
   local stance=usable and math.max(0,1-vault-slide*.65) or 0
   local shotgun=equipped=="Shotgun"
   local smg=equipped=="SMG" or equipped=="Carbine" or equipped=="Marksman" or equipped=="LMG" or shotgun
   local revolver=equipped=="Revolver"
   local lowered=c:GetAttribute("Sprinting") and .45 or 1
   local reload=0 local reloadAlpha
   if entry.Player:GetAttribute("GunReloading") then
    local alpha=math.clamp((now-(entry.Player:GetAttribute("GunReloadStarted") or now))/math.max(.1,entry.Player:GetAttribute("GunReloadDuration") or 1),0,1)
    reloadAlpha=alpha reload=math.sin(alpha*math.pi)
   end
   -- Start short visual cycles on receipt, so network delay cannot skip them.
   local received=entry.ShotWeapon==equipped
   local age=received and os.clock()-entry.ShotAt or now-(c:GetAttribute("SwingAt") or -math.huge)
   for _,joint in entry.Mechanisms do
    if joint.Parent and joint.Part1 then
     local pose=Motion.PartPose(equipped,joint.Part1.Name,reloadAlpha,entry.Player:GetAttribute("GunAmmo"),(received or c:GetAttribute("SwingWeapon")==equipped) and age or -1)
     joint.Transform=CFrame.identity:Lerp(pose,(shotgun or equipped=="Carbine" or equipped=="Marksman" or equipped=="LMG") and motionScale or 1)
    end
   end
   local recoil=0
   if received or c:GetAttribute("SwingWeapon")==equipped then
    local shotPose=Motion.Sample(equipped,age,false,1,1)
    recoil=select(1,shotPose:ToOrientation())
   end
   reload*=motionScale recoil*=motionScale
   local right=CFrame.Angles((1.35*lowered-reload*(revolver and .2 or .35)-recoil*.3)*stance,(-.08-reload*(revolver and .2 or 0))*stance,(-.12-reload*(revolver and .65 or .3))*stance)
   local left=CFrame.Angles(((smg and 1.15 or 1.25)*lowered-reload*(revolver and .45 or .65))*stance,(smg and -.35 or -.55)*stance,((smg and .35 or .6)+reload*(revolver and .3 or 0))*stance)
   if shotgun and not entry.Player:GetAttribute("GunReloading") then left*=CFrame.Angles(-.28*Motion.Pump(age)*motionScale,0,0) end
   entry.GunRight=(entry.GunRight or CFrame.identity):Lerp(right,blend)
   entry.GunLeft=(entry.GunLeft or CFrame.identity):Lerp(left,blend)
   layer(j.RightShoulder,entry.GunRight) layer(j.LeftShoulder,entry.GunLeft)
   continue
  end
  entry.GunRight=nil entry.GunLeft=nil
  local stamp=c:GetAttribute("SwingAt") if typeof(stamp)~="number" then continue end
  local id=c:GetAttribute("SwingWeapon") or "Fists" local combo=c:GetAttribute("SwingCombo") or 1 local profile=Motion.Get(id)
  local age=now-stamp if age<0 or age>profile.Windup+profile.Strike+profile.Recover then continue end
  if entry.Player:GetAttribute("EquippedWeapon")~=id then continue end
  local right=id~="Fists" or combo%2==1
  if not entry.Right or not entry.Right.Parent then entry.Right=shoulder(c,true) end
  if not entry.Left or not entry.Left.Parent then entry.Left=shoulder(c,false) end
  local motor=right and entry.Right or entry.Left if not motor then continue end
  local pose,weight=Motion.Sample(id,age,combo==3,right and 1 or -1,combo)
  local rx,ry,rz=pose:ToOrientation()
  local offset=CFrame.Angles(math.rad(70)*weight+rx*.55,ry*.55,rz*.65)
  layer(motor,CFrame.identity:Lerp(offset,motionScale))
 end
end)
