local Players=game:GetService("Players")
local RS=game.ReplicatedStorage
local RunService=game:GetService("RunService")
local CAS=game:GetService("ContextActionService")
local UIS=game:GetService("UserInputService")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer local Gameplay=require(RS:WaitForChild("GameplayConfig")) local C=Gameplay.Pulse local Abilities=Gameplay.Abilities
local remotes=RS:WaitForChild("Remotes") local use=remotes:WaitForChild("UseAbility") local fx=remotes:WaitForChild("PulseFX") local abilityFx=remotes:WaitForChild("AbilityFX")
local gui=Instance.new("ScreenGui") gui.Name="AbilityHUD" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=16 gui.Parent=player:WaitForChild("PlayerGui")
local ink=Color3.fromRGB(38,48,68) local cyan=Color3.fromRGB(101,221,230)
local button=Instance.new("TextButton") button.Name="AbilityButton" button.Font=Enum.Font.Cartoon button.TextColor3=ink button.TextWrapped=true button.BorderSizePixel=0 button.AutoButtonColor=false button.Parent=gui
local corner=Instance.new("UICorner") corner.Parent=button
local stroke=Instance.new("UIStroke") stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Thickness=3 stroke.Color=ink stroke.Parent=button
local scale=Instance.new("UIScale") scale.Parent=button
local glow local function hover(value)
 if glow then glow:Cancel() end
 glow=Tween:Create(scale,TweenInfo.new(player:GetAttribute("ReducedMotion") and 0 or .12),{Scale=value}) glow:Play()
end
button.MouseEnter:Connect(function() hover(1.04) end) button.MouseLeave:Connect(function() hover(1) end)
local canUse=false local layoutElapsed=0 local selected="Pulse"
local function status(id)
 local d=id=="Pulse" and C or Abilities[id]
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 local visible=h and h.Health>0 and player:GetAttribute("HasStarted")==true and not player:GetAttribute("GameMenuOpen") and not player:GetAttribute("OptionsOpen")
 if not visible then return false,false,"" end
 local ls=player:FindFirstChild("leaderstats") local level=ls and ls:FindFirstChild("Level")
 if not level or level.Value<d.Level then return true,false,"NIV. "..d.Level end
 local attr=id=="Pulse" and "PulseReadyAt" or id.."ReadyAt"
 local now=workspace:GetServerTimeNow() local remaining=math.max(0,(c:GetAttribute(attr) or 0)-now)
 if remaining>0 then return true,false,string.format("%.1f s",remaining) end
 if player:GetAttribute("CurrentZone")=="REFUGE" then return true,false,UIS.TouchEnabled and "ZONE" or "EN EXPEDITION" end
 if h.FloorMaterial==Enum.Material.Air then return true,false,"AU SOL" end
 if id=="SecondSouffle" and h.Health>=h.MaxHealth then return true,false,"PV MAX" end
 if c:GetAttribute("Sliding") or c:GetAttribute("Vaulting") or c:GetAttribute("Crouching") or (c:GetAttribute("DashUntil") or 0)>now or player:GetAttribute("GunReloading") or player:GetAttribute("MouseUnlocked") then return true,false,"ATTENDS" end
 if (c:GetAttribute("Stamina") or 0)<d.Cost then return true,false,UIS.TouchEnabled and "END." or (d.Cost.." ENDURANCE") end
 return true,true,UIS.TouchEnabled and (d.Cost.." END.") or ("PRETE · "..d.Cost.." END.")
end
local function request(id)
 local visible,ready=status(id)
 if visible and ready and not UIS:GetFocusedTextBox() then local camera=workspace.CurrentCamera use:FireServer(id,id=="Frost" and camera and camera.CFrame.LookVector or nil) end
end
button.Activated:Connect(function() request(UIS.TouchEnabled and selected or "Pulse") end)
local selector=button:Clone() selector.Name="AbilitySelector" selector.Text="›" selector.Size=UDim2.fromOffset(44,56) selector.TextSize=28 selector.Parent=gui
selector.Activated:Connect(function()
 local order={"Pulse","Slam","Frost","Aegis","SecondSouffle","Arc"} local index=table.find(order,selected) or 1 selected=order[index%#order+1]
end)
local smallButtons={}
for id,d in Abilities do
 local b=button:Clone() b.Name=id.."Button" b.Size=UDim2.fromOffset(48,48) b.TextSize=9 b.Parent=gui
 b.Activated:Connect(function() request(id) end) smallButtons[id]=b
end
local function bind(id,key,pad)
 CAS:BindAction("Survival"..id,function(_,state)
  local visible=status(id)
  if not visible or UIS:GetFocusedTextBox() or player:GetAttribute("MouseUnlocked") then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Begin then request(id) end return Enum.ContextActionResult.Sink
 end,false,key,pad)
end
bind("Pulse",Enum.KeyCode.Q,Enum.KeyCode.ButtonL1)
for id,d in Abilities do bind(id,Enum.KeyCode[d.Key],Enum.KeyCode[d.Pad]) end
RunService.Heartbeat:Connect(function(dt)
 layoutElapsed+=dt if layoutElapsed<.1 then return end layoutElapsed%=.1
 local camera=workspace.CurrentCamera if not camera then return end
 local v=camera.ViewportSize local origin=gui.AbsolutePosition
 local visible,ready,detail=status("Pulse") canUse=ready
 button.BackgroundColor3=ready and cyan or Color3.fromRGB(169,188,199)
 for id,d in Abilities do
  local b=smallButtons[id] local shown,available,info=status(id) b.Visible=shown==true
  b.BackgroundColor3=available and d.Color or Color3.fromRGB(169,188,199)
  local hint=UIS.GamepadEnabled and ({DPadLeft="←",DPadRight="→",ButtonR3="R3",DPadDown="↓",ButtonL2="L2"})[d.Pad] or d.Key
  b.Text=d.Name.."\n"..(available and hint or info)
  if UIS.TouchEnabled then b.Visible=false end
 end
 if UIS.TouchEnabled then
  button.AnchorPoint=Vector2.new(.5,.5) button.Size=UDim2.fromOffset(56,56) button.TextSize=10 corner.CornerRadius=UDim.new(1,0)
  local center=Vector2.new(v.X-(v.X<=v.Y and 40 or 180),v.Y-160)
  local action=v.X>v.Y and v.X>=700 and "SurvivalReload" or "SurvivalVault"
  local anchor=player.PlayerGui:FindFirstChild("ContextActionGui") and CAS:GetAllBoundActionInfo()[action] and CAS:GetButton(action)
  if anchor and anchor.Parent and anchor.Parent:IsA("GuiObject") and anchor.Parent.Visible then center=anchor.AbsolutePosition+anchor.AbsoluteSize/2-Vector2.new(68,0) end
  center=Vector2.new(math.clamp(center.X,38,math.max(38,v.X-38)),math.clamp(center.Y,75,math.max(75,v.Y-38)))
  button.Position=UDim2.fromOffset(center.X-origin.X,center.Y-origin.Y)
  local d=selected=="Pulse" and C or Abilities[selected] local shown,available,info=status(selected)
  canUse=available
  button.Visible=shown==true button.BackgroundColor3=available and (d.Color or cyan) or Color3.fromRGB(169,188,199)
  button.Text=(selected=="Pulse" and "ONDE" or d.Name).."\n"..info
  selector.Visible=shown==true selector.AnchorPoint=Vector2.new(.5,.5) selector.Position=UDim2.fromOffset(center.X-62-origin.X,center.Y-origin.Y)
  selector.Size=UDim2.fromOffset(44,56) selector.Text="›"
 else
  button.Visible=visible==true selector.Visible=false
  button.AnchorPoint=Vector2.new(1,1) button.Size=UDim2.fromOffset(190,48) button.Position=UDim2.new(1,-24,1,-112) button.TextSize=14 corner.CornerRadius=UDim.new(0,15)
  button.Text=(UIS.GamepadEnabled and "L1" or "Q").." · ONDE DE CHOC\n"..detail
  local slots={{"Slam",1},{"Frost",2},{"Aegis",3},{"SecondSouffle",4},{"Arc",5}}
  for _,slot in slots do local id,index=slot[1],slot[2] local b=smallButtons[id] b.AnchorPoint=Vector2.new(1,1) b.Position=UDim2.new(1,-24-(index%2)*54,1,-168-math.floor((index-1)/2)*54) b.Size=UDim2.fromOffset(48,48) end
 end
 button:SetAttribute("Ready",canUse)
end)
local effects=Instance.new("Folder") effects.Name="LocalPulseFX" effects.Parent=workspace
fx.OnClientEvent:Connect(function(shooter,position,hits)
 if typeof(position)~="Vector3" or position~=position then return end
 local camera=workspace.CurrentCamera if not camera or (camera.CFrame.Position-position).Magnitude>100 then return end
 local reduced=player:GetAttribute("ReducedMotion")==true local chargeTime=reduced and .16 or .42 local duration=reduced and .18 or .42
 local anchor=Instance.new("Part") anchor.Name="PulseSoundAnchor" anchor.Size=Vector3.new(.1,.1,.1) anchor.Transparency=1 anchor.Anchored=true anchor.CanCollide=false anchor.CanTouch=false anchor.CanQuery=false anchor.Position=position anchor.Parent=effects Debris:AddItem(anchor,2)
 local center=position-Vector3.new(0,2.2,0)
 local purple=Color3.fromRGB(174,91,255) local magenta=Color3.fromRGB(242,114,255)
 local tint=Instance.new("ColorCorrectionEffect") tint.Name="PulseChargeTint" tint.TintColor=Color3.new(1,1,1) tint.Parent=camera
 Tween:Create(tint,TweenInfo.new(chargeTime,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TintColor=reduced and Color3.fromRGB(220,202,255) or Color3.fromRGB(184,133,255),Saturation=reduced and 0 or .18,Contrast=reduced and 0 or .12,Brightness=reduced and 0 or -.025}):Play()
 Debris:AddItem(tint,1.4)
 local count=reduced and 8 or 16
 for i=1,count do
  local angle=i*math.pi*2/count local radial=Vector3.new(math.cos(angle),0,math.sin(angle)) local tangent=Vector3.new(-radial.Z,0,radial.X)
  local startRadius=reduced and 2.6 or 4.6 local endRadius=reduced and startRadius or 1.9
  local mark=Instance.new("Part") mark.Name="PulseChargeMark" mark.Size=Vector3.new(.12,.08,reduced and .65 or 1.05) mark.Color=i%4==0 and magenta or purple mark.Material=Enum.Material.Neon mark.Transparency=.12 mark.Anchored=true mark.CanCollide=false mark.CanTouch=false mark.CanQuery=false mark.CastShadow=false
  mark.CFrame=CFrame.lookAt(center+radial*startRadius,center+radial*startRadius+tangent) mark.Parent=effects
  if not reduced then
   Tween:Create(mark,TweenInfo.new(chargeTime,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{CFrame=CFrame.lookAt(center+radial*endRadius,center+radial*endRadius+tangent),Size=Vector3.new(.16,.1,1.45),Color=magenta}):Play()
  end
  Debris:AddItem(mark,chargeTime+.28)
 end
 local core=Instance.new("Part") core.Name="PulseChargeCore" core.Shape=Enum.PartType.Ball core.Size=Vector3.new(.45,.35,.45) core.Color=purple core.Material=Enum.Material.Neon core.Transparency=.22 core.Anchored=true core.CanCollide=false core.CanTouch=false core.CanQuery=false core.CastShadow=false core.Position=center+Vector3.new(0,.25,0) core.Parent=effects
 if not reduced then Tween:Create(core,TweenInfo.new(chargeTime,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=Vector3.new(2,1.1,2),Color=magenta,Transparency=.08}):Play() end
 Debris:AddItem(core,chargeTime+.24)
 local billboard=Instance.new("BillboardGui") billboard.Name="PulseComic" billboard.Size=reduced and UDim2.fromOffset(180,62) or UDim2.fromOffset(140,48) billboard.StudsOffsetWorldSpace=reduced and Vector3.new(0,2.9,0) or Vector3.new(0,2.2,0) billboard.AlwaysOnTop=true billboard.MaxDistance=55 billboard.Parent=anchor
 local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundTransparency=1 text.Text="BOUM !" text.Font=Enum.Font.Cartoon text.TextSize=32 text.TextColor3=Color3.fromRGB(255,217,96) text.TextStrokeColor3=ink text.TextTransparency=1 text.TextStrokeTransparency=1 text.Rotation=reduced and 0 or -8 text.Parent=billboard
 task.delay(chargeTime,function()
  if not anchor.Parent then return end
  local waveCount=reduced and 6 or 24
  local function makeWave(segments,color,reach,delay)
   for i=1,segments do
    local angle=(i-.5)*math.pi*2/segments local radial=Vector3.new(math.cos(angle),0,math.sin(angle)) local tangent=Vector3.new(-radial.Z,0,radial.X)
    local radius=reduced and C.Range*.62 or 1.9
    local part=Instance.new("Part") part.Name="PulseBlastArc" part.Size=Vector3.new(reduced and .22 or .4,.14,reduced and 1.1 or 1.5) part.Color=color part.Material=Enum.Material.Neon part.Transparency=.04 part.Anchored=true part.CanCollide=false part.CanTouch=false part.CanQuery=false part.CastShadow=false
    part.CFrame=CFrame.lookAt(center+radial*radius,center+radial*radius+tangent) part.Parent=effects
    local goal={Transparency=1}
    if not reduced then goal.CFrame=CFrame.lookAt(center+radial*(C.Range*reach),center+radial*(C.Range*reach)+tangent) goal.Size=Vector3.new(.14,.08,3.2) end
    Tween:Create(part,TweenInfo.new(duration,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0,false,delay),goal):Play()
    Debris:AddItem(part,duration+delay+.05)
   end
  end
  makeWave(waveCount,purple,1,0)
  if not reduced then makeWave(18,magenta,.76,.08) end
  local burst=Instance.new("Part") burst.Name="PulseBlastCore" burst.Shape=Enum.PartType.Ball burst.Size=Vector3.new(.8,.7,.8) burst.Color=magenta burst.Material=Enum.Material.Neon burst.Transparency=.18 burst.Anchored=true burst.CanCollide=false burst.CanTouch=false burst.CanQuery=false burst.CastShadow=false burst.Position=center+Vector3.new(0,.5,0) burst.Parent=effects
  if not reduced then Tween:Create(burst,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(9,6,9),Transparency=1}):Play() else burst.Transparency=1 end
  Debris:AddItem(burst,.28)
  if not reduced then Tween:Create(tint,TweenInfo.new(.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TintColor=Color3.fromRGB(133,67,222),Saturation=.24,Contrast=.18,Brightness=-.015}):Play() end
  if not reduced then Tween:Create(billboard,TweenInfo.new(.14,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(180,62),StudsOffsetWorldSpace=Vector3.new(0,2.9,0)}):Play() end
  Tween:Create(text,TweenInfo.new(.06,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0,TextStrokeTransparency=0}):Play()
  task.delay(.12,function()
   if text.Parent then Tween:Create(text,TweenInfo.new(.34,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=1,TextStrokeTransparency=1,Rotation=reduced and 0 or 5}):Play() end
  end)
  local soundDelay=reduced and 0 or .03
  if player:GetAttribute("SFXEnabled")~=false then
   task.delay(soundDelay,function()
    if not anchor.Parent then return end
    local s=Instance.new("Sound") s.Name="PulseImpact" s.SoundId="rbxassetid://"..require(RS.FistsConfig).HeavyHitSounds[1] s.Volume=.5 s.PlaybackSpeed=.78 s.RollOffMaxDistance=65 s.SoundGroup=game.SoundService:FindFirstChild("WorldCombat") s.Parent=anchor s:Play()
   end)
  end
  local function clearTint(duration)
   if tint.Parent then Tween:Create(tint,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TintColor=Color3.new(1,1,1),Saturation=0,Contrast=0,Brightness=0}):Play() end
  end
  if reduced then clearTint(.18) else task.delay(.08,function() clearTint(.34) end) end
 end)
end)
abilityFx.OnClientEvent:Connect(function(id,shooter,position,hits,endpoint)
 local d=Abilities[id]
 if not d or typeof(position)~="Vector3" or position~=position then return end
 local camera=workspace.CurrentCamera if not camera or (camera.CFrame.Position-position).Magnitude>100 then return end
 local reduced=player:GetAttribute("ReducedMotion")==true local color=d.Color local center=position-Vector3.new(0,2.25,0)
 local anchor=Instance.new("Part") anchor.Name="AbilityFXAnchor" anchor.Size=Vector3.new(.1,.1,.1) anchor.Transparency=1 anchor.Anchored=true anchor.CanCollide=false anchor.CanTouch=false anchor.CanQuery=false anchor.Position=position anchor.Parent=effects Debris:AddItem(anchor,id=="Aegis" and 3.6 or 2)
 local tint=Instance.new("ColorCorrectionEffect") tint.Name=id.."Tint" tint.TintColor=Color3.new(1,1,1) tint.Parent=camera Debris:AddItem(tint,1.3)
 Tween:Create(tint,TweenInfo.new(reduced and .16 or .36,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TintColor=reduced and Color3.new(.94,.9,1) or color:Lerp(Color3.new(1,1,1),.48),Saturation=reduced and 0 or .1,Contrast=reduced and 0 or .08}):Play()
 local marks=reduced and 6 or (id=="Frost" and 8 or 14)
 for i=1,marks do
  local a=math.pi*2*i/marks local radial=Vector3.new(math.cos(a),0,math.sin(a)) local start=reduced and 2.4 or 4.6
  local p=Instance.new("Part") p.Name="AbilityChargeMark" p.Size=Vector3.new(.14,.08,reduced and .6 or 1.3) p.Color=color p.Material=Enum.Material.Neon p.Transparency=.12 p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false p.CFrame=CFrame.lookAt(center+radial*start,center+radial*start+Vector3.new(-radial.Z,0,radial.X)) p.Parent=effects
  if not reduced then Tween:Create(p,TweenInfo.new(id=="Frost" and .16 or .38,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{CFrame=p.CFrame+radial*(id=="Frost" and -1.2 or -2.2),Color=Color3.new(1,1,1)}):Play() end Debris:AddItem(p,.72)
 end
 if id=="Arc" and typeof(endpoint)=="table" then
  for link=2,math.min(#endpoint,d.MaxTargets+1) do
   local from,to=endpoint[link-1],endpoint[link]
   if typeof(from)~="Vector3" or typeof(to)~="Vector3" then continue end
   local segments=reduced and 1 or 3 local previous=from
   for segment=1,segments do
    local point=from:Lerp(to,segment/segments)+(segment<segments and Vector3.new(0,segment%2==0 and -.5 or .5,.15) or Vector3.zero)
    local length=(point-previous).Magnitude
    if length>.01 then
     local bolt=Instance.new("Part") bolt.Name="ArcChainBolt" bolt.Size=Vector3.new(reduced and .09 or .16,reduced and .09 or .16,length) bolt.Material=Enum.Material.Neon bolt.Color=reduced and color or segment==2 and Color3.fromRGB(255,246,157) or color bolt.Transparency=reduced and .4 or .08
     bolt.Anchored=true bolt.CanCollide=false bolt.CanTouch=false bolt.CanQuery=false bolt.CastShadow=false bolt.CFrame=CFrame.lookAt((previous+point)/2,point) bolt.Parent=effects
     if not reduced then Tween:Create(bolt,TweenInfo.new(.3),{Transparency=1}):Play() end Debris:AddItem(bolt,.36)
    end
    previous=point
   end
  end
  if player:GetAttribute("SFXEnabled")~=false then
   local sound=Instance.new("Sound") sound.Name="ArcDischarge" sound.SoundId="rbxassetid://"..require(RS.FistsConfig).HeavyHitSounds[1] sound.Volume=.35 sound.PlaybackSpeed=1.65 sound.RollOffMaxDistance=65 sound.SoundGroup=game.SoundService:FindFirstChild("WorldCombat") sound.Parent=anchor sound:Play()
  end
 elseif id=="Frost" then
  local root=shooter.Character and shooter.Character:FindFirstChild("HumanoidRootPart")
  if root then
   local forward=typeof(endpoint)=="Vector3" and (endpoint-position).Unit or root.CFrame.LookVector local from=position+forward*2+Vector3.new(0,.8,0)
   local to=typeof(endpoint)=="Vector3" and endpoint or (from+forward*d.Range)
   local tip=Instance.new("Part") tip.Name="CryoProjectileTip" tip.Shape=Enum.PartType.Ball tip.Size=Vector3.new(1.1,3.2,1.1) tip.Color=Color3.fromRGB(238,255,255) tip.Material=Enum.Material.Neon tip.Transparency=.06 tip.Anchored=true tip.CanCollide=false tip.CanTouch=false tip.CanQuery=false tip.CastShadow=false tip.CFrame=CFrame.lookAt(from,to)*CFrame.Angles(math.rad(90),0,0) tip.Parent=effects
   local a1=Instance.new("Attachment") a1.Parent=anchor a1.Position=from-position
   local endAnchor=Instance.new("Part") endAnchor.Name="CryoTrailEnd" endAnchor.Size=Vector3.new(.1,.1,.1) endAnchor.Transparency=1 endAnchor.Anchored=true endAnchor.CanCollide=false endAnchor.CanTouch=false endAnchor.CanQuery=false endAnchor.Position=from endAnchor.Parent=effects
   local a2=Instance.new("Attachment") a2.Parent=endAnchor
   for _,width in {reduced and 1.4 or 3.2,reduced and .45 or .9} do
    local beam=Instance.new("Beam") beam.Name="CryoLanceTrail" beam.Attachment0=a1 beam.Attachment1=a2 beam.FaceCamera=true beam.LightEmission=1 beam.LightInfluence=0 beam.Width0=width beam.Width1=width*.16 beam.Color=ColorSequence.new(color,Color3.new(1,1,1)) beam.Transparency=NumberSequence.new(.12,1) beam.Parent=anchor
    a1=Instance.new("Attachment") a1.Position=Vector3.new(0,0,0) a1.Parent=tip
   end
   local dir=(to-from).Unit local right=dir:Cross(Vector3.yAxis).Unit local back=right:Cross(dir)
   tip.CFrame=CFrame.fromMatrix(from,right,dir,back)
   if not reduced then Tween:Create(tip,TweenInfo.new(.24,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=to}):Play() Tween:Create(endAnchor,TweenInfo.new(.24,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=to}):Play() else tip.Position=to end
   Debris:AddItem(tip,.38) Debris:AddItem(endAnchor,.38)
  end
  for i=1,(reduced and 3 or 7) do
   local a=i*math.pi*2/(reduced and 3 or 7) local shard=Instance.new("Part") shard.Name="CryoImpactShard" shard.Size=Vector3.new(.25,.25,.9) shard.Material=Enum.Material.Neon shard.Color=i%2==0 and Color3.new(1,1,1) or color shard.Anchored=true shard.CanCollide=false shard.CanTouch=false shard.CanQuery=false shard.CastShadow=false
   local impact=typeof(endpoint)=="Vector3" and endpoint or position+Vector3.new(0,0,-d.Range) shard.CFrame=CFrame.new(impact+Vector3.new(math.cos(a)*.6,.2,math.sin(a)*.6))*CFrame.Angles(math.rad(25),a,math.rad(35)) shard.Parent=effects
   if not reduced then Tween:Create(shard,TweenInfo.new(.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=shard.Position+Vector3.new(math.cos(a)*2,1.4,math.sin(a)*2),Transparency=1}):Play() else shard.Transparency=.15 end Debris:AddItem(shard,.4)
  end
  local impact=typeof(endpoint)=="Vector3" and endpoint or position+Vector3.new(0,0,-d.Range) local ringCount=reduced and 4 or 8
  for i=1,ringCount do
   local a=i*math.pi*2/ringCount local radial=Vector3.new(math.cos(a),0,math.sin(a)) local tangent=Vector3.new(-radial.Z,0,radial.X)
   local chip=Instance.new("Part") chip.Name="CryoImpactHalo" chip.Size=Vector3.new(.12,.08,.85) chip.Color=i%2==0 and Color3.new(1,1,1) or color chip.Material=Enum.Material.Neon chip.Transparency=.12 chip.Anchored=true chip.CanCollide=false chip.CanTouch=false chip.CanQuery=false chip.CastShadow=false chip.CFrame=CFrame.lookAt(impact+radial*1.2+Vector3.new(0,.12,0),impact+radial*1.2+tangent+Vector3.new(0,.12,0)) chip.Parent=effects
   if not reduced then Tween:Create(chip,TweenInfo.new(.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=CFrame.lookAt(impact+radial*2.8+Vector3.new(0,.12,0),impact+radial*2.8+tangent+Vector3.new(0,.12,0)),Transparency=1}):Play() else chip.Transparency=.35 end Debris:AddItem(chip,.36)
  end
 elseif id=="Aegis" then
  local root=shooter.Character and shooter.Character:FindFirstChild("HumanoidRootPart")
  if root then
   local segments=reduced and 8 or 12 local radius=3.2
   for i=1,(reduced and 1 or 3) do for j=1,segments do
    local a=(j-.5)*math.pi*2/segments local axis=i==1 and "Horizontal" or i==2 and "VerticalX" or "VerticalZ"
    local point=axis=="Horizontal" and Vector3.new(math.cos(a)*radius,1.15,math.sin(a)*radius) or axis=="VerticalX" and Vector3.new(math.cos(a)*radius,1.15+math.sin(a)*radius,0) or Vector3.new(0,1.15+math.sin(a)*radius,math.cos(a)*radius)
    local tangent=axis=="Horizontal" and Vector3.new(-math.sin(a),0,math.cos(a)) or axis=="VerticalX" and Vector3.new(-math.sin(a),math.cos(a),0) or Vector3.new(0,math.cos(a),-math.sin(a))
    local ring=Instance.new("Part") ring.Name="AegisHalo" ring.Size=Vector3.new(.17,.17,2*radius*math.sin(math.pi/segments)*1.18) ring.Material=Enum.Material.Neon ring.Color=i==2 and Color3.new(1,1,1) or color ring.Transparency=reduced and .62 or .12 ring.Anchored=false ring.Massless=true ring.CanCollide=false ring.CanTouch=false ring.CanQuery=false ring.CastShadow=false
    local worldPoint=root.CFrame:PointToWorldSpace(point) local worldTangent=root.CFrame:VectorToWorldSpace(tangent) ring.CFrame=CFrame.lookAt(worldPoint,worldPoint+worldTangent) ring.Parent=effects
    local weld=Instance.new("WeldConstraint") weld.Part0=root weld.Part1=ring weld.Parent=ring
    if not reduced then Tween:Create(ring,TweenInfo.new(2.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.52}):Play() end Debris:AddItem(ring,3.25)
   end end
   for i=1,(reduced and 3 or 6) do
    local a=i*math.pi*2/(reduced and 3 or 6) local point=Vector3.new(math.cos(a)*1.85,1.4,math.sin(a)*1.85)
    local crystal=Instance.new("Part") crystal.Name="AegisOrbitCrystal" crystal.Shape=Enum.PartType.Ball crystal.Size=Vector3.new(.28,.28,.28) crystal.Material=Enum.Material.Neon crystal.Color=i%2==0 and Color3.new(1,1,1) or color crystal.Transparency=reduced and .5 or .08 crystal.Anchored=false crystal.Massless=true crystal.CanCollide=false crystal.CanTouch=false crystal.CanQuery=false crystal.CastShadow=false crystal.CFrame=root.CFrame*CFrame.new(point)*CFrame.Angles(0,-a,0) crystal.Parent=effects
    local weld=Instance.new("WeldConstraint") weld.Part0=root weld.Part1=crystal weld.Parent=crystal
    if not reduced then Tween:Create(crystal,TweenInfo.new(.48,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Size=Vector3.new(.42,.42,.42),Transparency=.42}):Play() end Debris:AddItem(crystal,3.25)
   end
  end
 elseif id=="Slam" then
  for i=1,(reduced and 6 or 12) do
   local a=i*math.pi*2/(reduced and 6 or 12) local ray=Instance.new("Part") ray.Name="SlamGroundCrack" ray.Size=Vector3.new(.22,.09,reduced and 2.4 or 4) ray.Material=Enum.Material.Neon ray.Color=i%3==0 and Color3.fromRGB(255,238,151) or color ray.Transparency=.06 ray.Anchored=true ray.CanCollide=false ray.CanTouch=false ray.CanQuery=false ray.CastShadow=false ray.CFrame=CFrame.new(center+Vector3.new(0,.08,0))*CFrame.Angles(0,-a,0) ray.Parent=effects
   if not reduced then Tween:Create(ray,TweenInfo.new(.34,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=Vector3.new(.08,.04,10),Transparency=1}):Play() else ray.Transparency=.2 end Debris:AddItem(ray,.4)
  end
  local ringCount=reduced and 6 or 12
  for i=1,ringCount do
   local a=(i-.5)*math.pi*2/ringCount local radial=Vector3.new(math.cos(a),0,math.sin(a)) local tangent=Vector3.new(-radial.Z,0,radial.X)
   local wave=Instance.new("Part") wave.Name="SlamPressureWave" wave.Size=Vector3.new(.18,.07,1.5) wave.Material=Enum.Material.Neon wave.Color=i%3==0 and Color3.fromRGB(255,238,151) or color wave.Transparency=reduced and .4 or .08 wave.Anchored=true wave.CanCollide=false wave.CanTouch=false wave.CanQuery=false wave.CastShadow=false wave.CFrame=CFrame.lookAt(center+radial*1.7+Vector3.new(0,.13,0),center+radial*1.7+tangent+Vector3.new(0,.13,0)) wave.Parent=effects
   if not reduced then Tween:Create(wave,TweenInfo.new(.36,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=CFrame.lookAt(center+radial*7+Vector3.new(0,.13,0),center+radial*7+tangent+Vector3.new(0,.13,0)),Size=Vector3.new(.1,.04,2.2),Transparency=1}):Play() end Debris:AddItem(wave,.4)
  end
 elseif id=="SecondSouffle" then
  for i=1,(reduced and 4 or 12) do
   local a=i*math.pi*2/(reduced and 4 or 12) local orb=Instance.new("Part") orb.Name="HealSpiralSpark" orb.Shape=Enum.PartType.Ball orb.Size=Vector3.new(.34,.34,.34) orb.Material=Enum.Material.Neon orb.Color=i%2==0 and Color3.fromRGB(255,225,122) or color orb.Anchored=true orb.CanCollide=false orb.CanTouch=false orb.CanQuery=false orb.CastShadow=false orb.Position=center+Vector3.new(math.cos(a)*1.1,.25,math.sin(a)*1.1) orb.Parent=effects
   if not reduced then Tween:Create(orb,TweenInfo.new(.7,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=center+Vector3.new(math.cos(a+2)*1.8,4,math.sin(a+2)*1.8),Size=Vector3.new(.08,.08,.08),Transparency=.08}):Play() else orb.Transparency=.18 end Debris:AddItem(orb,.76)
  end
  local ringCount=reduced and 4 or 8
  for i=1,ringCount do
   local a=(i-.5)*math.pi*2/ringCount local radial=Vector3.new(math.cos(a),0,math.sin(a)) local tangent=Vector3.new(-radial.Z,0,radial.X)
   local halo=Instance.new("Part") halo.Name="HealGroundHalo" halo.Size=Vector3.new(.12,.06,1.1) halo.Material=Enum.Material.Neon halo.Color=i%2==0 and Color3.fromRGB(255,225,122) or color halo.Transparency=reduced and .48 or .12 halo.Anchored=true halo.CanCollide=false halo.CanTouch=false halo.CanQuery=false halo.CastShadow=false halo.CFrame=CFrame.lookAt(center+radial*1.2+Vector3.new(0,.12,0),center+radial*1.2+tangent+Vector3.new(0,.12,0)) halo.Parent=effects
   if not reduced then Tween:Create(halo,TweenInfo.new(.52,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=CFrame.lookAt(center+radial*3.5+Vector3.new(0,.12,0),center+radial*3.5+tangent+Vector3.new(0,.12,0)),Transparency=1}):Play() end Debris:AddItem(halo,.56)
  end
 end
 local label=Instance.new("BillboardGui") label.Name="AbilityComic" label.Size=UDim2.fromOffset(190,54) label.StudsOffsetWorldSpace=Vector3.new(0,3,0) label.AlwaysOnTop=true label.MaxDistance=75 label.Parent=anchor
 local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundTransparency=1 text.Font=Enum.Font.Cartoon text.TextSize=30 text.TextColor3=color text.TextStrokeColor3=ink text.TextStrokeTransparency=0 text.Text=({Arc=hits>0 and "ZZAP x"..hits.." !" or "ZZAP !",Slam="IMPACT !",Frost=hits>0 and "GEL !" or "LANCE !",Aegis="PROTÉGÉ !",SecondSouffle="SOUFFLE +"})[id] text.Parent=label
 if not reduced then Tween:Create(label,TweenInfo.new(.65,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{StudsOffsetWorldSpace=Vector3.new(0,4.4,0)}):Play() end
 task.delay(.25,function() if text.Parent then Tween:Create(text,TweenInfo.new(.3),{TextTransparency=1,TextStrokeTransparency=1}):Play() end end)
 Tween:Create(tint,TweenInfo.new(reduced and .2 or .36,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,reduced and .08 or .4),{TintColor=Color3.new(1,1,1),Saturation=0,Contrast=0,Brightness=0}):Play()
end)
