local Debris=game:GetService("Debris")
local Players=game:GetService("Players")
local Settings=require(game.ReplicatedStorage:WaitForChild("PresentationConfig"))
local Service={}
local function sound(parent,id,volume,pitch,group)
 local s=Instance.new("Sound") s.Name="SpatialFoley" s.SoundId=id s.Volume=volume s.PlaybackSpeed=pitch or 1
 s.RollOffMode=Enum.RollOffMode.InverseTapered s.RollOffMinDistance=5 s.RollOffMaxDistance=Settings.MaxVoiceDistance
 s.SoundGroup=game.SoundService:FindFirstChild(group or "WorldVoices") s.Parent=parent s:Play() Debris:AddItem(s,10) return s
end
function Service.Hit(model,direction,heavy)
 model:SetAttribute("HitDirection",direction)
 model:SetAttribute("HitHeavy",heavy)
 model:SetAttribute("HitAt",workspace:GetServerTimeNow())
end
function Service.Attack(model)
 model:SetAttribute("AttackAt",workspace:GetServerTimeNow())
 local windup=sound(model.HumanoidRootPart,Settings.Audio.Cloth,0.12,0.8+math.random()*0.2,"WorldFoley") windup.Name="ZombieWindup"
 windup.Ended:Once(function() windup:Destroy() end)
end
function Service.Swipe(model)
 local root=model:FindFirstChild("HumanoidRootPart") if not root then return end
 local swipe=sound(root,Settings.Audio.Cloth,.16,1.15,"WorldFoley") swipe.Name="ZombieSwipe"
 swipe.Ended:Once(function() swipe:Destroy() end)
end
function Service.Voice(s)
 local near=false
 for _,p in Players:GetPlayers() do local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart") if r and (r.Position-s.root.Position).Magnitude<60 then near=true break end end
 if not near then return end
 local now=os.clock()
 if now>=(s.voiceAt or 0) then
  s.voiceAt=now+math.random(7,13)
  sound(s.root,Settings.Audio.Growl,0.24,math.clamp(1.05/s.def.Scale,0.62,1.15))
 end
end
function Service.Ragdoll(model)
 model:SetAttribute("Dead",true)
 local h=model.Humanoid h.AutoRotate=false h.PlatformStand=true
 for _,joint in model:GetDescendants() do
  if joint:IsA("Motor6D") and joint.Name~="RootJoint" then
   local a=Instance.new("Attachment") a.Name="Ragdoll0" a.CFrame=joint.C0 a.Parent=joint.Part0
   local b=Instance.new("Attachment") b.Name="Ragdoll1" b.CFrame=joint.C1 b.Parent=joint.Part1
   local socket=Instance.new("BallSocketConstraint") socket.Attachment0=a socket.Attachment1=b
   socket.LimitsEnabled=true socket.UpperAngle=joint.Name=="Neck" and 20 or 45
   socket.TwistLimitsEnabled=true socket.TwistLowerAngle=-30 socket.TwistUpperAngle=30 socket.Parent=joint.Part0 joint.Enabled=false
  end
 end
 for _,part in model:GetChildren() do
  if part:IsA("BasePart") then
   part.CanCollide=part:IsA("MeshPart") and string.sub(part.Name,1,6)=="Visual"
   part.CanQuery=false
  end
 end
 model.HumanoidRootPart.Anchored=false
 model.HumanoidRootPart.AssemblyLinearVelocity+=Vector3.new(math.random(-3,3),0,math.random(-3,3))
 sound(model.HumanoidRootPart,Settings.Audio.Cloth,0.2,0.7,"WorldFoley")
end
return Service
