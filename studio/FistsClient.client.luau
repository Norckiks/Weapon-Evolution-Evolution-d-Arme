local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContextActionService=game:GetService("ContextActionService")
local UserInputService=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local settings=require(ReplicatedStorage:WaitForChild("PresentationConfig"))
local config=require(ReplicatedStorage:WaitForChild("FistsConfig"))
local Gameplay=require(ReplicatedStorage:WaitForChild("GameplayConfig"))
local WeaponVisuals=require(ReplicatedStorage:WaitForChild("WeaponVisuals"))
local WeaponMotion=require(ReplicatedStorage:WaitForChild("WeaponMotion"))
local meleeAxes=CFrame.Angles(0,0,math.pi)
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local assets=ReplicatedStorage:WaitForChild("PresentationAssets")
local WINDUP,STRIKE,RECOVER=0.09,0.08,0.30
local viewmodel=Instance.new("Folder") viewmodel.Name="FistsViewmodel"
local function part(name,size,color,material)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Color=color p.Material=material
 p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth return p
end
local function buildSide(sign)
 local model=Instance.new("Model") model.Name=sign<0 and "LeftArm" or "RightArm" model.Parent=viewmodel
 local pieces={}
 local template=assets:FindFirstChild(sign<0 and "LeftGlove" or "RightGlove")
 if template then
  local glove=template:FindFirstChildWhichIsA("MeshPart",true):Clone()
  glove.Parent=model glove.Anchored=true glove.CanCollide=false glove.CanTouch=false glove.CanQuery=false glove.CastShadow=false
  table.insert(pieces,{part=glove,rel=CFrame.Angles(math.pi/2,0,0)})
 else
  local palm=part("ClosedGlove",Vector3.new(0.56,0.46,0.55),Color3.fromRGB(67,54,42),Enum.Material.Leather) palm.Parent=model
  table.insert(pieces,{part=palm,rel=CFrame.identity})
  for i=1,4 do local p=part("Knuckle",Vector3.new(0.12,0.17,0.2),Color3.fromRGB(84,67,49),Enum.Material.Leather) p.Parent=model table.insert(pieces,{part=p,rel=CFrame.new((i-2.5)*0.13,0.18,-0.18)}) end
 end
 local sleeveAsset=assets:FindFirstChild("Sleeve")
 if sleeveAsset then
  local sleeve=sleeveAsset:FindFirstChildWhichIsA("MeshPart",true):Clone()
  sleeve.Name="TexturedSleeve" sleeve.Size=Vector3.new(0.5,0.5,1.5) sleeve.Anchored=true sleeve.CanCollide=false sleeve.CanQuery=false sleeve.CanTouch=false sleeve.CastShadow=false sleeve.Parent=model
  table.insert(pieces,{part=sleeve,rel=CFrame.new(0,-0.04,0.9)})
 else
  local sleeve=part("WeatheredSleeve",Vector3.new(0.48,0.49,1.35),Color3.fromRGB(47,52,50),Enum.Material.Fabric) sleeve.Parent=model
  table.insert(pieces,{part=sleeve,rel=CFrame.new(0,-0.08,1)})
 end
 return {parts=pieces,sign=sign,start=-math.huge,heavy=false,base=CFrame.new(sign*0.63,-0.78,-1.6)*CFrame.Angles(math.rad(-8),math.rad(sign*7),math.rad(-sign*4))}
end
local sides={Left=buildSide(-1),Right=buildSide(1)}
local heldWeapon,weaponPieces
local function buildWeapon()
 if heldWeapon then heldWeapon:Destroy() end
 heldWeapon,weaponPieces=WeaponVisuals.Build(player:GetAttribute("EquippedWeapon") or "Fists")
 heldWeapon.Name="FirstPersonWeapon" heldWeapon.Parent=viewmodel
end
player:GetAttributeChangedSignal("EquippedWeapon"):Connect(buildWeapon) buildWeapon()
local worldWeaponParts={}
local weaponConnection
local function watchWorldWeapon(character)
 if weaponConnection then weaponConnection:Disconnect() end table.clear(worldWeaponParts)
 local function remember(v) if v:IsA("BasePart") and v:FindFirstAncestor("EquippedWeaponVisual") then worldWeaponParts[v]=true end end
 for _,v in character:GetDescendants() do remember(v) end weaponConnection=character.DescendantAdded:Connect(remember)
end
player.CharacterAdded:Connect(watchWorldWeapon) if player.Character then watchWorldWeapon(player.Character) end
local gui=Instance.new("ScreenGui") gui.Name="Crosshair" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=12 gui.Parent=player:WaitForChild("PlayerGui")
local impactGui=Instance.new("ScreenGui") impactGui.Name="CartoonImpactFX" impactGui.IgnoreGuiInset=true impactGui.ResetOnSpawn=false impactGui.DisplayOrder=13 impactGui.Parent=player.PlayerGui
local cross=Instance.new("Frame") cross.Name="CrosshairRoot" cross.BackgroundTransparency=1 cross.AnchorPoint=Vector2.new(0.5,0.5) cross.Position=UDim2.fromScale(0.5,0.5) cross.Size=UDim2.fromOffset(30,30) cross.Parent=gui
local dot=Instance.new("Frame") dot.Name="Dot" dot.AnchorPoint=Vector2.new(0.5,0.5) dot.Position=UDim2.fromScale(0.5,0.5) dot.Size=UDim2.fromOffset(2,2) dot.BackgroundColor3=Color3.fromRGB(231,229,212) dot.BorderSizePixel=0 dot.Parent=cross
local marker={}
for i=1,4 do
 local p=Instance.new("Frame") p.Name="HitTick" p.AnchorPoint=Vector2.new(0.5,0.5)
 local angle=math.rad(45+i*90) p.Position=UDim2.new(0.5,math.cos(angle)*9,0.5,math.sin(angle)*9)
 p.Size=UDim2.fromOffset(6,1.4) p.Rotation=45+i*90 p.BorderSizePixel=0 p.BackgroundTransparency=1 p.Parent=cross table.insert(marker,p)
end
local function sound(ids,volume,speed)
 local s=Instance.new("Sound") s.SoundId="rbxassetid://"..ids[math.random(#ids)] s.Volume=volume s.PlaybackSpeed=(speed or 1)*(0.96+math.random()*0.08)
 s.SoundGroup=game.SoundService:FindFirstChild("WorldCombat") s.Parent=game.SoundService s:Play() Debris:AddItem(s,4)
end
local recoil=Vector3.zero
local fovImpulse=0
local hitUntil=0
local killMarker=false
local hitHeavy=false
local lastCF=workspace.CurrentCamera.CFrame
local sway=Vector3.zero
local gait=0
local sprintAlpha=0
local moveAlpha=0
local land=0
local lastState
local function punchPose(side,now)
 return WeaponMotion.Sample(side.weapon or "Fists",now-side.start,side.heavy,side.sign,side.combo)
end
RunService:BindToRenderStep("FistsViewmodel",Enum.RenderPriority.Camera.Value+1,function(dt)
 local camera=workspace.CurrentCamera if not camera then return end
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 local alive=h and h.Health>0
 local menu=player:GetAttribute("GameMenuOpen") or player:GetAttribute("OptionsOpen")
 local head=c and c:FindFirstChild("Head")
 local firstPerson=head and (camera.CFrame.Position-head.Position).Magnitude<1.4
 for part in worldWeaponParts do if part.Parent then part.LocalTransparencyModifier=firstPerson and 1 or 0 else worldWeaponParts[part]=nil end end
 viewmodel.Parent=alive and not menu and firstPerson and camera or nil gui.Enabled=alive~=nil and alive~=false and not menu
 impactGui.Enabled=gui.Enabled
 if not alive then sprintAlpha=0 fovImpulse=0 recoil=Vector3.zero lastState=nil camera.FieldOfView=settings.BaseFOV return end
 local reduced=player:GetAttribute("ReducedMotion")==true
 local motion=reduced and 0.25 or 1
 local moving=h.MoveDirection.Magnitude>0.1 and h.FloorMaterial~=Enum.Material.Air
 local sprint=c:GetAttribute("Sprinting")==true and moving
 sprintAlpha+=((sprint and 1 or 0)-sprintAlpha)*(1-math.exp(-dt*9))
 moveAlpha+=((moving and 1 or 0)-moveAlpha)*(1-math.exp(-dt*8))
 gait+=dt*(8+5*sprintAlpha)*moveAlpha
 local currentState=h:GetState()
 if lastState==Enum.HumanoidStateType.Freefall and currentState==Enum.HumanoidStateType.Landed then land=0.13 end
 lastState=currentState land*=math.exp(-dt*13)
 fovImpulse*=math.exp(-dt*12)
 local target=settings.BaseFOV+(reduced and 0 or (settings.SprintFOV-settings.BaseFOV)*sprintAlpha)-fovImpulse*motion
 if not reduced and (c:GetAttribute("DashUntil") or 0)>workspace:GetServerTimeNow() then target+=6 end
 camera.FieldOfView+=(target-camera.FieldOfView)*(1-math.exp(-dt*12))
 local base=camera.CFrame
 local rx,ry=lastCF:ToObjectSpace(base):ToEulerAnglesYXZ() lastCF=base
 sway=sway:Lerp(Vector3.new(math.clamp(ry*2.5,-0.12,0.12),math.clamp(-rx*2.5,-0.12,0.12),0),1-math.exp(-dt*10))
 recoil*=math.exp(-dt*16)
 camera.CFrame=base*CFrame.Angles(recoil.X*motion,recoil.Y*motion,recoil.Z*motion)
 local now=os.clock()
 local reloadAlpha
 local equippedId=player:GetAttribute("EquippedWeapon") or "Fists"
 local equippedDefinition=Gameplay.Weapons[equippedId]
 local gunAmmo=player:GetAttribute("GunAmmo")
 if equippedDefinition and equippedDefinition.Firearm and player:GetAttribute("GunReloading") then
  reloadAlpha=math.clamp((workspace:GetServerTimeNow()-(player:GetAttribute("GunReloadStarted") or 0))/math.max(.1,player:GetAttribute("GunReloadDuration") or 1.6),0,1)
 end
 for _,side in sides do
  local punch,active=punchPose(side,now)
  if reduced then punch=CFrame.identity:Lerp(punch,.25) end
  if reloadAlpha then punch=CFrame.identity:Lerp(WeaponMotion.Reload(reloadAlpha,side.sign,equippedId),reduced and .25 or 1) active=1 end
  local weaponPunch=punch
  if equippedDefinition and not equippedDefinition.Firearm then
   -- Melee meshes extend along +Y: reverse attack pitch/yaw without changing the hands.
   weaponPunch=CFrame.new(punch.Position)*meleeAxes*punch.Rotation*meleeAxes:Inverse()
  end
  local ability,abilityWeight=WeaponMotion.Ability(c:GetAttribute("AbilityId"),workspace:GetServerTimeNow()-(c:GetAttribute("AbilityAt") or -math.huge),side.sign)
  local abilityPose=CFrame.identity:Lerp(ability,reduced and .25 or 1)
  punch*=abilityPose weaponPunch*=abilityPose active=math.max(active,abilityWeight)
  local stride=math.sin(gait+(side.sign<0 and math.pi or 0))
  local run=sprintAlpha*(1-active)
  local bob=Vector3.new(math.cos(gait*0.5)*0.018,math.sin(gait)*0.025-land,0)*moveAlpha
  local idle=Vector3.new(0,math.sin(now*1.7)*0.007,0)
  local running=CFrame.new(-side.sign*0.06*run,(-0.13+stride*0.08)*run,stride*0.13*run)*CFrame.Angles(math.rad((-15+stride*10)*run),0,math.rad(side.sign*10*run))
  local basePose=side.base
  if equippedDefinition and equippedDefinition.Firearm then
   if side.sign>0 then
    basePose=CFrame.new(0.50,-0.66,-1.48)*CFrame.Angles(math.rad(-4),math.rad(4),math.rad(-2))
   elseif not reloadAlpha then
    if equippedId=="Shotgun" then
     basePose=CFrame.new(.43,-.70,-2.60)*CFrame.Angles(math.rad(18),math.rad(22),math.rad(-12))
     local support=WeaponMotion.Sample(equippedId,now-sides.Right.start,false,1,1)
     punch*=CFrame.identity:Lerp(support*CFrame.new(0,0,.22*WeaponMotion.Pump(now-sides.Right.start)),reduced and .25 or 1)
    elseif equippedId=="Marksman" then
     basePose=CFrame.new(.33,-.68,-2.4)*CFrame.Angles(math.rad(18),math.rad(22),math.rad(-12))
     local support=WeaponMotion.Sample(equippedId,now-sides.Right.start,false,1,1)
     punch*=CFrame.identity:Lerp(support,reduced and .25 or 1)
    elseif equippedId=="LMG" then
     basePose=CFrame.new(.4,-.73,-2.28)*CFrame.Angles(math.rad(20),math.rad(20),math.rad(-14))
     local support=WeaponMotion.Sample(equippedId,now-sides.Right.start,false,1,1)
     punch*=CFrame.identity:Lerp(support,reduced and .25 or 1)
    elseif equippedId=="Carbine" then
     basePose=CFrame.new(.33,-.68,-2.12)*CFrame.Angles(math.rad(18),math.rad(22),math.rad(-12))
    elseif equippedId=="SMG" then
     basePose=CFrame.new(0.24,-0.60,-1.52)*CFrame.Angles(math.rad(18),math.rad(28),math.rad(-14))
    else
     basePose=CFrame.new(0.36,-0.70,-1.45)*CFrame.Angles(math.rad(10),math.rad(16),math.rad(-8))
    end
   end
  end
  local rootBase=camera.CFrame*CFrame.new((sway+bob+idle)*motion)*basePose*running
  local root=rootBase*punch
  for _,item in side.parts do item.part.CFrame=root*item.rel end
  if side.sign>0 and weaponPieces then
   local isFirearm=equippedDefinition and equippedDefinition.Firearm
   local grip=isFirearm and CFrame.new(0,-.08,-.13)*CFrame.Angles(math.rad(5),0,0) or CFrame.new(0,0.12,-0.15)*CFrame.Angles(math.rad(-15),0,math.rad(-8))
   local weaponRoot=root*grip
   if not isFirearm then
    weaponRoot=CFrame.new(weaponRoot.Position)*(rootBase*weaponPunch*grip).Rotation
   end
   for _,item in weaponPieces do
    local magazine=CFrame.identity
    if reloadAlpha and equippedId~="Carbine" and equippedId~="Marksman" and equippedId~="LMG" and (item.part.Name=="Magazine" or item.part.Name=="MagazineBase") then
     local drop=math.sin(math.clamp((reloadAlpha-.15)/.65,0,1)*math.pi)
     magazine=CFrame.new(0,-.48*drop,.1*drop)
    end
    local mechanism=CFrame.identity:Lerp(WeaponMotion.PartPose(equippedId,item.part.Name,reloadAlpha,gunAmmo,now-sides.Right.start),reduced and (equippedId=="Shotgun" or equippedId=="Carbine" or equippedId=="Marksman" or equippedId=="LMG") and .25 or 1)
    item.part.CFrame=weaponRoot*magazine*mechanism*item.rel
   end
  end
 end
 local a=math.clamp((hitUntil-now)/0.22,0,1)
 for i,p in marker do
  local angle=math.rad(45+i*90) local spread=8+8*a
  p.Position=UDim2.new(0.5,math.cos(angle)*spread,0.5,math.sin(angle)*spread)
  p.Size=UDim2.fromOffset(6+4*a,1.5+1.2*a)
  p.BackgroundTransparency=1-a
  p.BackgroundColor3=killMarker and Color3.fromRGB(255,112,84) or (hitHeavy and Color3.fromRGB(255,197,66) or Color3.fromRGB(110,232,235))
 end
end)
local held=false
local attackEpoch=0
local lastPunch=-math.huge
local lastCombo=-math.huge
local combo=0
local nextHand="Right"
local function aimDirection(character)
 local camera=workspace.CurrentCamera local head=character:FindFirstChild("Head")
 if not head or (camera.CFrame.Position-head.Position).Magnitude<1.4 then return camera.CFrame.LookVector end
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
 local exclude={character} local target=camera.CFrame.Position+camera.CFrame.LookVector*500
 for _=1,32 do
  params.FilterDescendantsInstances=exclude
  local hit=workspace:Raycast(camera.CFrame.Position,camera.CFrame.LookVector*500,params)
  if not hit then break end
  local model=hit.Instance:FindFirstAncestorOfClass("Model")
  if hit.Instance.CanCollide or model and model:FindFirstChildOfClass("Humanoid") then target=hit.Position break end
  table.insert(exclude,hit.Instance)
 end
 local delta=target-head.Position
 return delta.Magnitude>.1 and delta.Unit or camera.CFrame.LookVector
end
local function punch()
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 or UserInputService:GetFocusedTextBox() or player:GetAttribute("OptionsOpen") or player:GetAttribute("GameMenuOpen") or player:GetAttribute("MouseUnlocked") or player:GetAttribute("HasStarted")~=true then return end
 local weaponId=player:GetAttribute("EquippedWeapon") or "Fists"
 local weapon=Gameplay.Weapons[weaponId] or Gameplay.Weapons.Fists
 local motion=WeaponMotion.Get(weaponId)
 local now=os.clock() if now-lastPunch<weapon.Cooldown then return end
 if weapon.Firearm then
  if player:GetAttribute("GunReloading") or (player:GetAttribute("GunAmmo") or 0)<=0 then return end
  lastPunch=now
  sides.Right.start=now sides.Right.weapon=weaponId sides.Right.heavy=false sides.Right.combo=1
  local isSMG=weaponId=="SMG"
  local revolver=weaponId=="Revolver"
  local shotgun=weaponId=="Shotgun"
  local marksman=weaponId=="Marksman" local lmg=weaponId=="LMG"
  recoil+=Vector3.new(math.rad(isSMG and .42 or lmg and .72 or marksman and 2.3 or shotgun and 2 or revolver and 1.7 or 1.1),0,isSMG and math.rad((math.random()-.5)*.3) or 0)
  fovImpulse=isSMG and .35 or lmg and .45 or marksman and 1.35 or shotgun and 1.2 or revolver and 1 or .75
  local shoot=remotes:FindFirstChild("Shoot") if shoot then shoot:FireServer(aimDirection(c)) end
  return
 end
 lastPunch=now if now-lastCombo>config.ComboWindow then combo=0 end
 combo=combo%config.ComboLength+1 lastCombo=now
 local heavy=combo==config.ComboLength
 local side=sides[weaponId~="Fists" and "Right" or nextHand] side.start=now side.heavy=heavy side.weapon=weaponId side.combo=combo nextHand=nextHand=="Right" and "Left" or "Right"
 sound(config.SwingSounds,heavy and 0.35 or 0.23,motion.Pitch*(heavy and 0.88 or 1))
 local epoch=attackEpoch
 task.delay(motion.Windup+motion.Strike,function()
  if epoch~=attackEpoch or player.Character~=c or h.Health<=0 or player:GetAttribute("EquippedWeapon")~=weaponId or player:GetAttribute("GameMenuOpen") or player:GetAttribute("OptionsOpen") or player:GetAttribute("MouseUnlocked") then return end
  fovImpulse=heavy and 1.5 or 0.7
  recoil+=Vector3.new(math.rad(heavy and 0.3 or 0.14),math.rad(side.sign*0.08),0)
  remotes.Punch:FireServer(aimDirection(c))
 end)
end
local function bindTouchActions()
ContextActionService:BindAction("FistsPunch",function(_,state)
 if UserInputService:GetFocusedTextBox() or player:GetAttribute("OptionsOpen") or player:GetAttribute("GameMenuOpen") or player:GetAttribute("MouseUnlocked") or player:GetAttribute("HasStarted")~=true then held=false return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin then held=true punch() elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then held=false end
 return Enum.ContextActionResult.Sink
end,true,Enum.UserInputType.MouseButton1,Enum.KeyCode.ButtonR2)
ContextActionService:SetTitle("FistsPunch","FRAPPER")
ContextActionService:SetPosition("FistsPunch",UDim2.new(1,-95,1,-160))
end
bindTouchActions()
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(bindTouchActions)
local function cancelHeldAttack() held=false attackEpoch+=1 end
UserInputService.WindowFocusReleased:Connect(cancelHeldAttack)
UserInputService.TextBoxFocused:Connect(cancelHeldAttack)
for _,attribute in {"GameMenuOpen","OptionsOpen","MouseUnlocked"} do
 player:GetAttributeChangedSignal(attribute):Connect(function() if player:GetAttribute(attribute) then cancelHeldAttack() end end)
end
player.CharacterAdded:Connect(function() cancelHeldAttack() combo=0 lastCombo=-math.huge for _,side in sides do side.start=-math.huge end end)
RunService.Heartbeat:Connect(function() if held then punch() end end)
local function cartoonHit(damage,heavy,killed,position,kind)
 if typeof(position)~="Vector3" or typeof(damage)~="number" then return end
 local camera=workspace.CurrentCamera if not camera then return end
 if camera.ViewportSize.X<140 or camera.ViewportSize.Y<110 then return end
 local reduced=player:GetAttribute("ReducedMotion")==true
 local projected,visible=camera:WorldToViewportPoint(position+Vector3.new(0,0.5,0))
 if projected.Z<=0 then return end
 local viewport=camera.ViewportSize
 local px=math.clamp(projected.X,62,viewport.X-62) local py=math.clamp(projected.Y,42,viewport.Y-54)
 local root=Instance.new("Frame") root.Name="ComicImpact" root.AnchorPoint=Vector2.new(0.5,0.5)
 root.Position=UDim2.fromOffset(px,py) root.Size=UDim2.fromOffset(140,92)
 root.Rotation=reduced and 0 or math.random(-8,8) root.BackgroundTransparency=1 root.Parent=impactGui
 local color=killed and Color3.fromRGB(255,115,92) or (heavy and Color3.fromRGB(255,195,59) or Color3.fromRGB(104,224,224))
 local rayCount=reduced and 4 or 8
 for i=1,rayCount do
  local a=math.rad((i-1)*360/rayCount)
  local ray=Instance.new("Frame") ray.Name="ComicRay" ray.AnchorPoint=Vector2.new(0.5,0.5)
  ray.Position=UDim2.new(0.5,math.cos(a)*54,0.5,math.sin(a)*33)
  ray.Size=UDim2.fromOffset(10,19) ray.Rotation=math.deg(a)+90 ray.BorderSizePixel=0 ray.BackgroundColor3=i%2==0 and Color3.fromRGB(255,239,157) or color ray.ZIndex=1 ray.Parent=root
  local rc=Instance.new("UICorner") rc.CornerRadius=UDim.new(1,0) rc.Parent=ray
 end
 local bubble=Instance.new("Frame") bubble.Name="ImpactBubble" bubble.AnchorPoint=Vector2.new(0.5,0.5)
 bubble.Position=UDim2.fromScale(0.5,0.5) bubble.Size=UDim2.fromOffset(100,60) bubble.BackgroundColor3=color
 bubble.BorderSizePixel=0 bubble.ZIndex=2 bubble.Parent=root
 local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,15) bc.Parent=bubble
 local bs=Instance.new("UIStroke") bs.Color=Color3.fromRGB(39,43,61) bs.Thickness=3 bs.Parent=bubble
 local bg=Instance.new("UIGradient") bg.Color=ColorSequence.new(Color3.fromRGB(255,255,222),color) bg.Rotation=90 bg.Parent=bubble
 local scale=Instance.new("UIScale") scale.Scale=reduced and 1 or .35 scale.Parent=bubble
 local title=Instance.new("TextLabel") title.Name="ComicWord" title.BackgroundTransparency=1
 title.Position=UDim2.fromOffset(4,1) title.Size=UDim2.new(1,-8,0,30)
 title.Text=kind=="Headshot" and "TETE!" or killed and "K.O.!" or (heavy and "BAM!!" or "POW!") title.Font=Enum.Font.Cartoon
 title.TextSize=(heavy or killed) and 25 or 23 title.TextColor3=Color3.fromRGB(42,47,62)
 title.TextStrokeColor3=Color3.fromRGB(255,255,231) title.TextStrokeTransparency=0.3 title.ZIndex=3 title.Parent=bubble
 local number=Instance.new("TextLabel") number.Name="DamageNumber" number.BackgroundTransparency=1
 number.Position=UDim2.fromOffset(4,30) number.Size=UDim2.new(1,-8,0,24)
 number.Text="-"..tostring(math.floor(damage+0.5)).." PV" number.Font=Enum.Font.Cartoon number.TextSize=19
 number.TextColor3=Color3.fromRGB(178,58,54) number.TextStrokeColor3=Color3.fromRGB(255,251,226)
 number.TextStrokeTransparency=0.18 number.ZIndex=3 number.Parent=bubble
 if not reduced then
 TweenService:Create(scale,TweenInfo.new(0.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.15}):Play()
 task.delay(0.12,function() if scale.Parent then TweenService:Create(scale,TweenInfo.new(0.09,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play() end end)
 TweenService:Create(root,TweenInfo.new(0.82,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(px,py-46),Rotation=0}):Play()
 end
 task.delay(0.42,function()
  if not root.Parent then return end
  TweenService:Create(bubble,TweenInfo.new(0.28,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
  TweenService:Create(bs,TweenInfo.new(0.28),{Transparency=1}):Play()
  for _,obj in root:GetChildren() do
   if obj:IsA("Frame") and obj~=bubble then TweenService:Create(obj,TweenInfo.new(0.28),{BackgroundTransparency=1}):Play() end
  end
  TweenService:Create(title,TweenInfo.new(0.28),{TextTransparency=1,TextStrokeTransparency=1}):Play()
  TweenService:Create(number,TweenInfo.new(0.28),{TextTransparency=1,TextStrokeTransparency=1}):Play()
 end)
 Debris:AddItem(root,0.88)
end
remotes.PunchHit.OnClientEvent:Connect(function(heavy,killed,damage,position,kind)
 recoil+=Vector3.new(math.rad(heavy and 0.45 or 0.22),0,math.rad(heavy and 0.13 or 0.06))
 hitUntil=os.clock()+0.22 killMarker=killed hitHeavy=heavy
 cartoonHit(damage,heavy,killed,position,kind)
end)
