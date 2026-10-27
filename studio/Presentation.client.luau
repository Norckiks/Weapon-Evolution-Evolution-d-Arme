local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ContentProvider=game:GetService("ContentProvider")
local Debris=game:GetService("Debris")
local ContextActionService=game:GetService("ContextActionService")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local Settings=require(game.ReplicatedStorage:WaitForChild("PresentationConfig"))
player:SetAttribute("HighGraphics",true)
player:SetAttribute("RainEnabled",Settings.RainEnabled)
player:SetAttribute("ReducedMotion",false)
player:SetAttribute("SFXEnabled",true)
local fx=Instance.new("Folder") fx.Name="LocalPresentation" fx.Parent=workspace
local function anchor(name)
 local p=Instance.new("Part") p.Name=name p.Size=Vector3.new(0.1,0.1,0.1) p.Transparency=1 p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false p.Parent=fx return p
end
local function sound(parent,id,volume,loop,group,pitch)
 local s=Instance.new("Sound") s.Name=group.."Sound" s.SoundId=id s.Volume=volume s.Looped=loop or false s.PlaybackSpeed=pitch or 1
 s.SoundGroup=game.SoundService:FindFirstChild(group) s.RollOffMinDistance=4 s.RollOffMaxDistance=50 s.RollOffMode=Enum.RollOffMode.InverseTapered s.Parent=parent
 if loop then s:Play() end return s
end
local function shot(parent,id,volume,pitch,group)
 local s=sound(parent,id,volume,false,group or "WorldFoley",pitch or 1) s:Play() Debris:AddItem(s,5)
end
local wind=sound(game.SoundService,Settings.Audio.Wind,0,true,"WorldAmbience")
local rainSound=sound(game.SoundService,Settings.Audio.Rain,0,true,"WorldAmbience")
local machine=sound(game.SoundService,Settings.Audio.Metal,0,true,"WorldAmbience",0.75)
local labHum=sound(game.SoundService,Settings.Audio.LabHum,0,true,"WorldAmbience")
local zoneGrade=Instance.new("ColorCorrectionEffect") zoneGrade.Name="LocalZoneGrade" zoneGrade.Parent=game.Lighting
local heartbeat=sound(game.SoundService,Settings.Audio.Heartbeat,0,true,"WorldFoley")
local windEQ=Instance.new("EqualizerSoundEffect") windEQ.HighGain=-3 windEQ.MidGain=-1 windEQ.Parent=wind
local room=Instance.new("ReverbSoundEffect") room.Name="InteriorAcoustics" room.DecayTime=1.4 room.WetLevel=-18 room.DryLevel=0 room.Enabled=false
room.Parent=game.SoundService:WaitForChild("WorldFoley")
local preload={}
local audioResults={}
for name,id in Settings.Audio do
 local s=Instance.new("Sound") s.Name=name s.SoundId=id table.insert(preload,s)
end
task.spawn(function()
 pcall(function() ContentProvider:PreloadAsync(preload,function(id,status) audioResults[id]=status.Name end) end)
 local failures=0 for _,status in audioResults do if status~="Success" then failures+=1 end end
 for _,s in preload do s:Destroy() end
 player:SetAttribute("PresentationAudioFailures",failures) player:SetAttribute("PresentationAudioReady",true)
end)
local rainAnchor=anchor("RainVolume") rainAnchor.Size=Vector3.new(45,1,45)
local rain=Instance.new("ParticleEmitter") rain.Name="FineRain" rain.Texture="rbxasset://textures/particles/sparkles_main.dds"
rain.Rate=0 rain.Lifetime=NumberRange.new(0.5,0.8) rain.Speed=NumberRange.new(44,56) rain.Acceleration=Vector3.new(3,-24,1)
rain.EmissionDirection=Enum.NormalId.Bottom rain.SpreadAngle=Vector2.new(3,3) rain.Orientation=Enum.ParticleOrientation.VelocityParallel
rain.Size=NumberSequence.new(0.035) rain.Squash=NumberSequence.new(-10)
rain.Color=ColorSequence.new(Color3.fromRGB(188,208,215)) rain.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.72),NumberSequenceKeypoint.new(0.8,0.79),NumberSequenceKeypoint.new(1,1)})
rain.LightInfluence=0.65 rain.Parent=rainAnchor
local dustAnchor=anchor("DriftingDust") dustAnchor.Size=Vector3.new(30,12,30)
local dust=Instance.new("ParticleEmitter") dust.Name="DustMotes" dust.Texture="rbxasset://textures/particles/smoke_main.dds"
dust.Rate=6 dust.Lifetime=NumberRange.new(3,5) dust.Speed=NumberRange.new(0.15,0.4) dust.Drag=0.5
dust.Size=NumberSequence.new(0.05) dust.Transparency=NumberSequence.new(0.85) dust.LightInfluence=0.8 dust.SpreadAngle=Vector2.new(180,180) dust.Parent=dustAnchor
local torchPart=anchor("Flashlight")
local torch=Instance.new("SpotLight") torch.Name="SurvivorFlashlight" torch.Face=Enum.NormalId.Front torch.Angle=68 torch.Range=62
torch.Brightness=2.2 torch.Color=Color3.fromRGB(251,239,210) torch.Enabled=false torch.Parent=torchPart
local torchOn=false
local function bindTouchActions()
ContextActionService:BindAction("SurvivorFlashlight",function(_,state)
 if state==Enum.UserInputState.Begin and not UserInputService:GetFocusedTextBox() then
  torchOn=not torchOn
  player:SetAttribute("FlashlightEnabled",torchOn)
  shot(game.SoundService,Settings.Audio.Cloth,0.12,1.4,"WorldUI")
 end
 return Enum.ContextActionResult.Sink
end,true,Enum.KeyCode.F,Enum.KeyCode.DPadUp)
ContextActionService:SetTitle("SurvivorFlashlight","TORCHE")
ContextActionService:SetPosition("SurvivorFlashlight",UDim2.new(1,-175,1,-150))
end
bindTouchActions()
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(bindTouchActions)
local lights={}
local fireSounds=setmetatable({},{__mode="k"})
local foliage=setmetatable({},{__mode="k"})
local papers=setmetatable({},{__mode="k"})
local function observeWorld(v)
 if v:IsA("Model") and v.Name=="ReclaimedGrass" then foliage[v]=v:GetPivot()
 elseif v:IsA("BasePart") and v:GetAttribute("WindPaper") then papers[v]=v.CFrame
 elseif v:IsA("BasePart") and v:GetAttribute("RadioStatic") then
  local s=sound(v,Settings.Audio.Radio,0.12,true,"WorldAmbience") s.RollOffMinDistance=2 s.RollOffMaxDistance=20
 elseif v:IsA("PointLight") or v:IsA("SpotLight") then
  if not v:IsDescendantOf(fx) then lights[v]={brightness=v.Brightness,flicker=v:GetAttribute("FlickerBase")~=nil} end
 elseif v:IsA("Fire") and v.Parent:IsA("BasePart") and not fireSounds[v.Parent] then
  local s=sound(v.Parent,Settings.Audio.Fire,0.22,true,"WorldAmbience")
  s.RollOffMaxDistance=38 s.RollOffMinDistance=5 fireSounds[v.Parent]=s
 end
end
for _,v in workspace:GetDescendants() do observeWorld(v) end
workspace.DescendantAdded:Connect(observeWorld)
local npcs={}
local pending={}
local function tryNPC(m)
 if npcs[m] or not m.Parent then return end
 local r=m:FindFirstChild("HumanoidRootPart") local torso=m:FindFirstChild("Torso") or m:FindFirstChild("UpperTorso") local h=m:FindFirstChildOfClass("Humanoid")
 if not r or not torso or not h then return end
 local joints={}
 for _,v in m:GetDescendants() do
  if v:IsA("Motor6D") or v:IsA("AnimationConstraint") then local name=v.Name:gsub(" ","") if name=="Root" then name="RootJoint" end joints[name]=v end
 end
 npcs[m]={root=r,h=h,joints=joints,phase=math.random()*6,blend=0,lastFoot=-1}
 if pending[m] then pending[m]:Disconnect() pending[m]=nil end
end
local live=workspace:WaitForChild("LiveZombies")
local function added(m)
 if not m:IsA("Model") then return end
 tryNPC(m)
 if not npcs[m] then pending[m]=m.ChildAdded:Connect(function() tryNPC(m) end) end
end
for _,m in live:GetChildren() do added(m) end
live.ChildAdded:Connect(added)
live.ChildRemoved:Connect(function(m) npcs[m]=nil if pending[m] then pending[m]:Disconnect() pending[m]=nil end end)
local footClock=0
local wasGrounded=true
local lastYVelocity=0
local healthPrevious
local characterConnections={}
local hurt=0
local function bindCharacter(c)
 for _,conn in characterConnections do conn:Disconnect() end table.clear(characterConnections)
 local h=c:WaitForChild("Humanoid",10) if not h then return end healthPrevious=h.Health
 local function assignGroup(v) if v:IsA("Sound") and not v.SoundGroup then v.SoundGroup=game.SoundService:FindFirstChild("WorldFoley") end end
 for _,v in c:GetDescendants() do assignGroup(v) end
 table.insert(characterConnections,c.DescendantAdded:Connect(assignGroup))
 table.insert(characterConnections,h.HealthChanged:Connect(function(hp)
  if healthPrevious and hp<healthPrevious then hurt=0.6 end healthPrevious=hp
 end))
 wasGrounded=true lastYVelocity=0 footClock=0
end
player.CharacterAdded:Connect(bindCharacter)
if player.Character then task.spawn(bindCharacter,player.Character) end
local gui=Instance.new("ScreenGui") gui.Name="AtmosphereOverlay" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=3 gui.Parent=player:WaitForChild("PlayerGui")
local edges={}
for _,info in {{Vector2.new(0,0),UDim2.new(0.12,0,1,0),0},{Vector2.new(1,0),UDim2.new(0.12,0,1,0),180},{Vector2.new(0,0),UDim2.new(1,0,0.12,0),90},{Vector2.new(0,1),UDim2.new(1,0,0.12,0),-90}} do
 local frame=Instance.new("Frame") frame.AnchorPoint=info[1] frame.Position=UDim2.fromScale(info[1].X,info[1].Y) frame.Size=info[2] frame.BorderSizePixel=0 frame.BackgroundColor3=Color3.fromRGB(108,28,22) frame.BackgroundTransparency=1 frame.Parent=gui
 local gradient=Instance.new("UIGradient") gradient.Rotation=info[3] gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}) gradient.Parent=frame table.insert(edges,frame)
end
local outdoor=true
local accumulated=0
local ema=1/60
RunService.RenderStepped:Connect(function(dt)
 local camera=workspace.CurrentCamera if not camera then return end
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") local r=c and c:FindFirstChild("HumanoidRootPart")
 local alive=h and r and h.Health>0
 local high=player:GetAttribute("HighGraphics")~=false
 local now=workspace:GetServerTimeNow()
 ema+=(dt-ema)*0.03
 rainAnchor.CFrame=CFrame.new(camera.CFrame.Position+Vector3.new(0,17,0))
 dustAnchor.CFrame=CFrame.new(camera.CFrame.Position)
 torchPart.CFrame=camera.CFrame*CFrame.new(0.2,-0.14,-0.4)
 torch.Enabled=torchOn and alive or false torch.Shadows=high
 rain.Rate=alive and outdoor and player:GetAttribute("RainEnabled")~=false and (high and Settings.RainRate or 40) or 0
 dust.Rate=high and 7 or 2
 if alive then
  local moving=h.MoveDirection.Magnitude>0.1
  local grounded=h.FloorMaterial~=Enum.Material.Air
  local sprint=c:GetAttribute("Sprinting")==true
  if moving and grounded then
   footClock+=dt
   local interval=sprint and 0.29 or 0.43
   if footClock>=interval then
    footClock=footClock%interval
    local metal=h.FloorMaterial==Enum.Material.Metal or h.FloorMaterial==Enum.Material.DiamondPlate
    shot(r,metal and Settings.Audio.StepMetal or Settings.Audio.StepConcrete,sprint and 0.25 or 0.17,(sprint and 1.08 or 0.98)+math.random()*0.08)
    if sprint and math.random()<0.3 then shot(r,Settings.Audio.Cloth,0.055,1.1) end
   end
  else footClock=0 end
  if grounded and not wasGrounded and lastYVelocity<-12 then shot(r,Settings.Audio.StepConcrete,0.3,0.78) hurt=math.max(hurt,0.03) end
  wasGrounded=grounded lastYVelocity=r.AssemblyLinearVelocity.Y
 end
 for m,s in npcs do
  if not s.root.Parent or not m.Parent then npcs[m]=nil continue end
  if m:GetAttribute("Dead") or s.h.Health<=0 then continue end
  local distance=(s.root.Position-camera.CFrame.Position).Magnitude
  local bar=m:FindFirstChild("Head") and m.Head:FindFirstChild("ZombieHealth")
  if bar then bar.Enabled=distance>4 and (distance<22 or (s.h.Health<s.h.MaxHealth and distance<38)) end
  if distance>(high and Settings.MaxAnimatedDistance or 75) then continue end
  local velocity=s.root.AssemblyLinearVelocity local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
  s.blend+=((speed>1 and 1 or 0)-s.blend)*(1-math.exp(-dt*7))
  s.phase+=dt*math.clamp(speed*0.8,2,13)
  local stride=math.sin(s.phase)*0.48*s.blend
  local attackTime=now-(m:GetAttribute("AttackAt") or -math.huge)
  local windup=m:GetAttribute("AttackWindup") or .45 local recovery=m:GetAttribute("AttackRecovery") or .35
  local phase=m:GetAttribute("AttackPhase") local attack,lean=0,0
  local function smooth(a) a=math.clamp(a,0,1) return a*a*(3-2*a) end
  if phase=="Windup" and attackTime>=0 then
   local alpha=math.clamp(attackTime/windup,0,1)
   if alpha<.8 then local a=smooth(alpha/.8) attack=-.32*a lean=-.07*a
   else local a=smooth((alpha-.8)/.2) attack=-.32+1.32*a lean=-.07+.2*a end
  elseif phase=="Recovery" then attack=1-smooth((attackTime-windup)/recovery) lean=.13*attack end

  local hitTime=now-(m:GetAttribute("HitAt") or -math.huge)
  local flinch=hitTime>=0 and hitTime<0.3 and math.sin(hitTime/0.3*math.pi)*(m:GetAttribute("HitHeavy") and 0.24 or 0.12) or 0
  for name,j in s.joints do
   if not j or not j.Parent then continue end
   local x,y,z=0,0,0
   if name=="LeftHip" then x=stride elseif name=="RightHip" then x=-stride
   elseif name=="LeftShoulder" then x=-0.38-stride*0.4-attack*1.05+flinch
   elseif name=="RightShoulder" then x=-0.38+stride*0.4-attack*1.15+flinch
   elseif name=="Neck" then x=0.08+math.sin(now*1.6)*0.018-flinch*0.8 y=math.sin(now*0.7)*0.035
   elseif name=="RootJoint" then x=0.035*s.blend+lean-flinch z=math.sin(s.phase)*0.025*s.blend end
   local target=CFrame.new(0,name=="RootJoint" and math.sin(s.phase*2)*0.014*s.blend or 0,0)*CFrame.Angles(x,y,z)
   if player:GetAttribute("ReducedMotion") then target=CFrame.identity:Lerp(target,.25) end
   j.Transform=j.Transform:Lerp(target,1-math.exp(-dt*18))
  end
  local foot=math.floor(s.phase/math.pi)
  if foot~=s.lastFoot and speed>1 and distance<25 then s.lastFoot=foot shot(s.root,Settings.Audio.StepConcrete,0.065,0.8+math.random()*0.1) end
 end
 hurt*=math.exp(-dt*6)
 local low=alive and math.clamp((0.3-h.Health/h.MaxHealth)/0.3,0,1) or 0
 for _,edge in edges do edge.BackgroundTransparency=1-math.clamp(hurt*0.5+low*(0.08+math.sin(now*3)*0.02),0,0.4) end
 heartbeat.Volume+=(low*0.19-heartbeat.Volume)*(1-math.exp(-dt*3))
 accumulated+=dt
 if accumulated>=0.25 then
  accumulated=0
  player:SetAttribute("PresentationFrameMS",math.floor(ema*10000)/10)
  local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
  local exclude={fx,live} if c then table.insert(exclude,c) end params.FilterDescendantsInstances=exclude
  outdoor=not workspace:Raycast(camera.CFrame.Position+Vector3.new(0,1,0),Vector3.new(0,65,0),params)
  windEQ.HighGain=outdoor and -3 or -16
  room.Enabled=not outdoor
  local zone=player:GetAttribute("CurrentZone") or "REFUGE"
  local factory=string.find(zone,"USINE",1,true)~=nil local lab=string.find(zone,"LABORATOIRE",1,true)~=nil
  local harbor=zone=="PORT DES CENDRES"
  local power=zone=="CENTRALE FOUDROYEE"
  local targetWind=alive and (outdoor and (harbor and .15 or .11) or 0.045) or 0
  wind.Volume+=(targetWind-wind.Volume)*0.25
  rainSound.Volume+=((alive and outdoor and player:GetAttribute("RainEnabled")~=false and 0.12 or 0)-rainSound.Volume)*0.25
  machine.Volume+=(((factory or power) and 0.07 or 0)-machine.Volume)*0.2
  labHum.Volume+=((lab and 0.065 or 0)-labHum.Volume)*0.2
  local tint=power and Color3.fromRGB(239,230,255) or harbor and Color3.fromRGB(227,239,249) or lab and Color3.fromRGB(229,247,233) or factory and Color3.fromRGB(255,242,224) or zone=="REFUGE" and Color3.fromRGB(255,251,241) or Color3.fromRGB(244,248,251)
  zoneGrade.TintColor=zoneGrade.TintColor:Lerp(tint,0.12)
  for light,data in lights do
   if not light.Parent or not light.Parent:IsA("BasePart") then lights[light]=nil continue end
   local distance=(light.Parent.Position-camera.CFrame.Position).Magnitude
   light.Shadows=high and light:IsA("SpotLight") and distance<65
   if data.flicker and distance<90 then light.Brightness=data.brightness*(0.94+0.06*math.noise(now*4,light.Parent.Position.X)) end
  end
  if high then
   for model,base in foliage do
    if not model.Parent then foliage[model]=nil
    elseif (base.Position-camera.CFrame.Position).Magnitude<55 then
     model:PivotTo(base*CFrame.Angles(math.sin(now*1.3+base.Position.X)*0.012,0,math.cos(now*0.8+base.Position.Z)*0.008))
    end
   end
   for paper,base in papers do if not paper.Parent then papers[paper]=nil elseif (base.Position-camera.CFrame.Position).Magnitude<40 then paper.CFrame=base*CFrame.Angles(0,math.sin(now+base.Position.Z)*0.015,0) end end
  end
  local enabled=player:GetAttribute("SFXEnabled")~=false
  for _,group in game.SoundService:GetChildren() do if group:IsA("SoundGroup") and string.sub(group.Name,1,5)=="World" then group.Volume=enabled and (group.Name=="WorldAmbience" and 0.65 or group.Name=="WorldUI" and 0.55 or 0.8) or 0 end end
 end
end)
game.ReplicatedStorage.Remotes.ProgressFeedback.OnClientEvent:Connect(function(kind,data)
 if kind=="Reward" then shot(game.SoundService,Settings.Audio.Reward,data.LeveledUp and 0.22 or 0.12,data.LeveledUp and 1.12 or 0.95,"WorldUI") end
end)
