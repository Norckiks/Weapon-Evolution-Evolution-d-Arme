local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local CAS=game:GetService("ContextActionService")
local UIS=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer local C=require(RS:WaitForChild("GameplayConfig"))
local remotes=RS:WaitForChild("Remotes") local reload=remotes:WaitForChild("ReloadGun") local fx=remotes:WaitForChild("ShotFX")
local gui=Instance.new("ScreenGui") gui.Name="AmmoHUD" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=12 gui.Parent=player:WaitForChild("PlayerGui")
local card=Instance.new("TextLabel") card.Name="Ammo" card.AnchorPoint=Vector2.new(1,1) card.Position=UDim2.new(1,-24,1,-32) card.Size=UDim2.fromOffset(200,62) card.BackgroundColor3=Color3.fromRGB(255,201,75) card.TextColor3=Color3.fromRGB(38,48,68) card.BorderSizePixel=0 card.Font=Enum.Font.Cartoon card.TextSize=18 card.TextWrapped=true card.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,16) corner.Parent=card
local stroke=Instance.new("UIStroke") stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Color=Color3.fromRGB(38,48,68) stroke.Thickness=3 stroke.Parent=card
local reloadTrack=Instance.new("Frame") reloadTrack.Name="ReloadProgress" reloadTrack.AnchorPoint=Vector2.new(.5,1) reloadTrack.Position=UDim2.new(.5,0,1,-4) reloadTrack.Size=UDim2.new(1,-20,0,4) reloadTrack.BackgroundColor3=Color3.fromRGB(190,139,45) reloadTrack.BorderSizePixel=0 reloadTrack.Parent=card
local reloadFill=Instance.new("Frame") reloadFill.Name="Fill" reloadFill.Size=UDim2.fromScale(0,1) reloadFill.BackgroundColor3=Color3.fromRGB(38,48,68) reloadFill.BorderSizePixel=0 reloadFill.Parent=reloadTrack
local reloadStamp=0
local soundStage=0
local lastViewport=Vector2.zero
local lastTouch
local nextLayout=0
game:GetService("RunService").RenderStepped:Connect(function()
 local viewport=workspace.CurrentCamera.ViewportSize
 if viewport~=lastViewport or UIS.TouchEnabled~=lastTouch or os.clock()>=nextLayout then
  nextLayout=os.clock()+.2
  lastViewport=viewport lastTouch=UIS.TouchEnabled
  if UIS.TouchEnabled then
   local portrait=viewport.X<viewport.Y
   local y=portrait and 242 or 65
   for _,name in (portrait and {"StatusPanel","ActiveBoosts","QuickNavigation","CameraToggle","MovementHint"} or {"ProgressCard","OptionsButton"}) do
    local item=player.PlayerGui:FindFirstChild(name,true)
    if item and item.Visible then y=math.max(y,item.AbsolutePosition.Y+item.AbsoluteSize.Y+8) end
   end
   if not portrait and viewport.X<700 then
    -- The compact action cluster occupies the upper right on narrow phones.
    y=0
    for _,name in {"StatusPanel","ActiveBoosts"} do
     local item=player.PlayerGui:FindFirstChild(name,true)
     if item and item.Visible then y=math.max(y,item.AbsolutePosition.Y+item.AbsoluteSize.Y+8) end
    end
    card.AnchorPoint=Vector2.zero card.Position=UDim2.fromOffset(14,y-gui.AbsolutePosition.Y)
   else
    card.AnchorPoint=Vector2.new(1,0) card.Position=UDim2.new(1,-24,0,y-gui.AbsolutePosition.Y)
   end
   card.Size=UDim2.fromOffset(170,42) card.TextSize=12
  else
   card.AnchorPoint=Vector2.new(1,1) card.Position=UDim2.new(1,-24,1,-32) card.Size=UDim2.fromOffset(200,62) card.TextSize=18
  end
 end
 local active=player:GetAttribute("GunReloading")==true
 reloadTrack.Visible=active
 if not active or not card.Visible then soundStage=0 return end
 local stamp=player:GetAttribute("GunReloadStarted") or 0
 local duration=math.max(.1,player:GetAttribute("GunReloadDuration") or 1.6)
 local alpha=math.clamp((workspace:GetServerTimeNow()-stamp)/duration,0,1)
 reloadFill.Size=UDim2.fromScale(alpha,1)
 if stamp~=reloadStamp then reloadStamp=stamp soundStage=0 end
 local weaponId=player:GetAttribute("EquippedWeapon")
 local isSMG=weaponId=="SMG"
 local isRevolver=weaponId=="Revolver"
 local isCarbine=weaponId=="Carbine"
 local isMarksman=weaponId=="Marksman" local isLMG=weaponId=="LMG"
 local stage=0
 if weaponId=="Shotgun" then
  stage=alpha>=.88 and 6 or math.clamp(math.floor((alpha-.15)/.14)+1,0,5)
 elseif isLMG then
  stage=alpha>=.9 and 4 or alpha>=.7 and 3 or alpha>=.4 and 2 or alpha>=.12 and 1 or 0
 elseif isMarksman then
  stage=alpha>=.9 and 3 or alpha>=.6 and 2 or alpha>=.22 and 1 or 0
 elseif isCarbine then
  stage=alpha>=.88 and 3 or alpha>=.58 and 2 or alpha>=.18 and 1 or 0
 elseif isRevolver then
  stage=alpha>=.87 and 3 or alpha>=.55 and 2 or alpha>=.15 and 1 or 0
 elseif isSMG then
  stage=alpha>=.82 and 3 or alpha>=.48 and 2 or alpha>=.15 and 1 or 0
 else
  stage=alpha>=.72 and 2 or alpha>=.18 and 1 or 0
 end
 if stage>soundStage then
  soundStage=stage
  if player:GetAttribute("SFXEnabled")~=false then
   local pitch=isLMG and (stage==1 and .9 or stage==2 and 1.1 or stage==3 and .95 or 1.35) or isMarksman and (stage==1 and 1.1 or stage==2 and 1.4 or 1.25) or isCarbine and (stage==1 and 1.4 or stage==2 and 1.65 or 1.8) or isRevolver and (stage==1 and 1.2 or stage==2 and 1.75 or 1.05) or isSMG and (stage==1 and 2.15 or stage==2 and 1.62 or 1.9) or (stage==1 and 1.9 or 1.35)
   local s=Instance.new("Sound") s.Name="ReloadClick" s.SoundId=require(RS.PresentationConfig).Audio.Metal s.Volume=.17 s.PlaybackSpeed=pitch s.SoundGroup=game.SoundService:FindFirstChild("WorldCombat") s.Parent=game.SoundService s:Play() Debris:AddItem(s,.14)
  end
 end
end)
local function equipped()
 local w=C.Weapons[player:GetAttribute("EquippedWeapon")] return w and w.Firearm
end
local function visible()
 return equipped() and player:GetAttribute("HasStarted")==true and not player:GetAttribute("GameMenuOpen") and not player:GetAttribute("OptionsOpen")
end
local function update()
 card.Visible=visible()==true
 local hint=UIS.TouchEnabled and "RECHARGE : bouton tactile" or UIS.GamepadEnabled and "X · RECHARGER" or "R · RECHARGER"
 local weapon=C.Weapons[player:GetAttribute("EquippedWeapon") or "Fists"]
 card.Text=player:GetAttribute("GunReloading") and "RECHARGEMENT..." or string.format("%s   %d / %d\n%s",weapon and (weapon.ShortName or "PISTOLET") or "ARME",player:GetAttribute("GunAmmo") or 0,player:GetAttribute("GunMagazine") or 0,hint)
end
for _,attr in {"EquippedWeapon","GunAmmo","GunMagazine","GunReloading","HasStarted","GameMenuOpen","OptionsOpen"} do player:GetAttributeChangedSignal(attr):Connect(update) end update()
local function bindTouchActions()
CAS:BindAction("SurvivalReload",function(_,state)
 if not visible() or UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin then reload:FireServer() end return Enum.ContextActionResult.Sink
end,true,Enum.KeyCode.R,Enum.KeyCode.ButtonX)
CAS:SetTitle("SurvivalReload","RECHARGE")
end
bindTouchActions()
UIS:GetPropertyChangedSignal("TouchEnabled"):Connect(bindTouchActions)
fx.OnClientEvent:Connect(function(shooter,origin,destinations,weaponId)
 if typeof(origin)~="Vector3" then return end
 if typeof(destinations)=="Vector3" then destinations={destinations} end
 if type(destinations)~="table" then return end
 if (workspace.CurrentCamera.CFrame.Position-origin).Magnitude>180 then return end
 weaponId=weaponId or (shooter and shooter:GetAttribute("EquippedWeapon")) or "Pistol"
 local weaponDef=C.Weapons[weaponId]
 local isSMG=weaponId=="SMG" local isRevolver=weaponId=="Revolver" local shotgun=weaponId=="Shotgun"
 local tracerColor=weaponDef and weaponDef.Color or Color3.fromRGB(255,221,115)
 local first
 for i,destination in destinations do
  if i>12 then break end
  if typeof(destination)~="Vector3" then continue end
  local delta=destination-origin if delta.Magnitude<.05 then continue end
  first=first or delta.Unit
  local tracer=Instance.new("Part") tracer.Name="GunTracer" tracer.Anchored=true tracer.CanCollide=false tracer.CanTouch=false tracer.CanQuery=false tracer.CastShadow=false tracer.Material=Enum.Material.Neon tracer.Color=tracerColor
  local width=isSMG and .028 or shotgun and .025 or .038
  tracer.Size=Vector3.new(width,width,delta.Magnitude) tracer.CFrame=CFrame.lookAt(origin,destination)*CFrame.new(0,0,-delta.Magnitude/2) tracer.Parent=workspace Debris:AddItem(tracer,isSMG and .045 or .06)
 end
 if not first then return end
 local flash=Instance.new("Part") flash.Name="GunFlash" flash.Shape=Enum.PartType.Ball flash.Size=shotgun and Vector3.new(.3,.3,.3) or isSMG and Vector3.new(.14,.14,.14) or Vector3.new(.2,.2,.2) flash.Anchored=true flash.CanCollide=false flash.CanTouch=false flash.CanQuery=false flash.CastShadow=false flash.Material=Enum.Material.Neon flash.Color=tracerColor flash.Position=origin+first*.7 flash.Parent=workspace Debris:AddItem(flash,isSMG and .04 or .05)
 local function sound(name,pitch,volume)
  if player:GetAttribute("SFXEnabled")==false then return end
  local s=Instance.new("Sound") s.Name=name s.SoundId=require(RS.PresentationConfig).Audio.Metal s.Volume=volume s.PlaybackSpeed=pitch s.RollOffMaxDistance=100 s.SoundGroup=game.SoundService:FindFirstChild("WorldCombat") s.Parent=shooter and shooter.Character and shooter.Character:FindFirstChild("Head") or flash s:Play() Debris:AddItem(s,.35)
 end
 sound("GunShot",weaponId=="LMG" and (1.22+math.random()*.04) or weaponId=="Marksman" and (.68+math.random()*.04) or weaponId=="Carbine" and (1.13+math.random()*.05) or shotgun and .75 or isSMG and (1.92+math.random()*.16) or isRevolver and (.95+math.random()*.06) or (1.38+math.random()*.08),weaponId=="LMG" and .5 or weaponId=="Marksman" and .62 or shotgun and .62 or isSMG and .38 or isRevolver and .58 or .48)
 if weaponId=="Marksman" then task.delay(.32,function()
  local c=shooter and shooter.Character local h=c and c:FindFirstChildOfClass("Humanoid")
  if shooter and shooter.Parent and shooter:GetAttribute("EquippedWeapon")==weaponId and h and h.Health>0 and c:FindFirstChild("Head") then sound("MarksmanBolt",1.2,.18) end
 end)
 elseif weaponId=="Carbine" then task.delay(.08,function()
  if shooter and shooter.Parent and shooter:GetAttribute("EquippedWeapon")==weaponId and shooter.Character and shooter.Character:FindFirstChild("Head") then sound("CarbineBolt",1.9,.1) end
 end) end
 if shotgun then task.delay(.36,function()
  if shooter and shooter.Parent and shooter:GetAttribute("EquippedWeapon")==weaponId and shooter.Character and shooter.Character:FindFirstChild("Head") then sound("ShotgunPump",1.55,.18) end
 end) end
end)
