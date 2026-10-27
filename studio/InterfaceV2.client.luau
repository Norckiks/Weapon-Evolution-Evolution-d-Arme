local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local ContextActionService=game:GetService("ContextActionService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local Art=require(game:GetService("ReplicatedStorage"):WaitForChild("CartoonArt"))
local gui=player:WaitForChild("PlayerGui"):WaitForChild("SurvivalHUD",30)
local panel=gui:WaitForChild("StatusPanel")
local health=panel.HealthCard
local stamina=panel.StaminaCard
local coins=panel.CoinsCard
local progress=gui:WaitForChild("ProgressCard",30)
local function styleCard(card)
 card.BackgroundColor3=Color3.fromRGB(13,20,23) card.BackgroundTransparency=0.18
 local corner=card:FindFirstChildOfClass("UICorner") if corner then corner.CornerRadius=UDim.new(0,5) end
 local stroke=card:FindFirstChildOfClass("UIStroke") if stroke then stroke.Color=Color3.fromRGB(109,126,124) stroke.Transparency=0.7 stroke.Thickness=1 end
 local gradient=card:FindFirstChildOfClass("UIGradient") if gradient then gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(224,231,229)) end
end
panel.Size=UDim2.fromOffset(232,114)
for _,card in {health,stamina,coins} do styleCard(card) end
health.Position=UDim2.fromOffset(0,0) health.Size=UDim2.fromOffset(232,38)
health.Title.Position=UDim2.fromOffset(40,3) health.Title.TextSize=10 health.Title.TextColor3=Color3.fromRGB(173,188,181)
health.HealthValue.Position=UDim2.fromOffset(112,1) health.HealthValue.Size=UDim2.fromOffset(108,24)
health.HealthValue.Font=Enum.Font.RobotoMono health.HealthValue.TextSize=19
health.MedicalCross.Position=UDim2.fromOffset(15,18) health.MedicalCross.Size=UDim2.fromOffset(17,6)
health.MedicalCross.Vertical.Size=UDim2.fromOffset(6,17)
health.Track.Position=UDim2.fromOffset(40,27) health.Track.Size=UDim2.fromOffset(180,7)
health.Track.Fill.Gradient.Color=ColorSequence.new(Color3.fromRGB(244,160,121),Color3.fromRGB(205,93,76))
stamina.Position=UDim2.fromOffset(0,43) stamina.Size=UDim2.fromOffset(232,31)
stamina.Title.Position=UDim2.fromOffset(37,5) stamina.Title.Size=UDim2.fromOffset(105,15) stamina.Title.TextSize=10
stamina.Bolt.Position=UDim2.fromOffset(12,2) stamina.Bolt.Size=UDim2.fromOffset(18,22) stamina.Bolt.TextSize=22
stamina.StaminaValue.Position=UDim2.fromOffset(144,3) stamina.StaminaValue.Size=UDim2.fromOffset(76,18) stamina.StaminaValue.Font=Enum.Font.RobotoMono stamina.StaminaValue.TextSize=12
stamina.Track.Position=UDim2.fromOffset(37,23) stamina.Track.Size=UDim2.fromOffset(183,5)
stamina.Hint.Position=UDim2.fromOffset(15,33) stamina.Hint.TextSize=8 stamina.Hint.Size=UDim2.fromOffset(265,10)
stamina.Hint.Visible=false
coins.Position=UDim2.fromOffset(0,79) coins.Size=UDim2.fromOffset(232,35)
coins.Title.Position=UDim2.fromOffset(64,6) coins.Title.TextSize=9 coins.Title.TextColor3=Color3.fromRGB(173,176,158)
coins.CoinsValue.Position=UDim2.fromOffset(97,3) coins.CoinsValue.Size=UDim2.fromOffset(123,27)
coins.CoinsValue.Font=Enum.Font.RobotoMono coins.CoinsValue.TextSize=21
local cap=coins.CoinsValue:FindFirstChildOfClass("UITextSizeConstraint") if cap then cap.MaxTextSize=21 end
local logo=coins:WaitForChild("CoinLogo",15) if logo then logo.Visible=false end
health.MedicalCross.Visible=false stamina.Bolt.Visible=false
Art.Icon(health,"Health",32,UDim2.fromOffset(4,1)).ZIndex=4
Art.Icon(stamina,"Speed",28,UDim2.fromOffset(3,0)).ZIndex=4
Art.Icon(coins,"Coins",32,UDim2.fromOffset(4,1)).ZIndex=4
coins.Title.Position=UDim2.fromOffset(39,10) coins.Title.Size=UDim2.fromOffset(60,16)
styleCard(progress) progress.Size=UDim2.fromOffset(320,58) progress.Position=UDim2.new(0.5,0,0,14)
Art.Icon(progress,"XP",30,UDim2.fromOffset(8,2)).ZIndex=4
progress.Level.Position=UDim2.fromOffset(43,8) progress.Level.Size=UDim2.fromOffset(116,22) progress.Level.TextSize=16 progress.Level.TextColor3=Color3.fromRGB(224,207,164)
progress.XP.Position=UDim2.fromOffset(165,10) progress.XP.Size=UDim2.fromOffset(142,18) progress.XP.Font=Enum.Font.RobotoMono progress.XP.TextSize=10
progress.XPTrack.Position=UDim2.fromOffset(12,33) progress.XPTrack.Size=UDim2.fromOffset(296,6)
progress.XPTrack.Fill.BackgroundColor3=Color3.fromRGB(160,181,138)
progress.Zone.Position=UDim2.fromOffset(12,42) progress.Zone.Size=UDim2.fromOffset(296,13) progress.Zone.TextSize=9
local toast=gui:WaitForChild("ProgressToast",15)
styleCard(toast) toast.Position=UDim2.new(0.5,0,0,86) toast.Size=UDim2.fromOffset(380,48) toast.TextSize=13 toast.Font=Enum.Font.GothamMedium
local toastBorder=Instance.new("UIStroke") toastBorder.Color=Color3.fromRGB(168,147,96) toastBorder.Transparency=0.6 toastBorder.Parent=toast
local function label(name,parent,text,pos,size,font,textSize,color)
 local t=Instance.new("TextLabel") t.Name=name t.BackgroundTransparency=1 t.Position=pos t.Size=size t.Text=text t.Font=font t.TextSize=textSize t.TextColor3=color t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=parent return t
end
local controls=label("ControlHints",panel,UserInputService.TouchEnabled and "SURVIE  /  SECTEUR 07" or "MAJ COURIR   F TORCHE   P OPTIONS",UDim2.fromOffset(0,120),UDim2.fromOffset(232,12),Enum.Font.GothamMedium,8,Color3.fromRGB(175,188,183))
controls.Visible=not UserInputService.TouchEnabled
local ghost=health.Track.Fill:Clone() ghost.Name="DamageTrail" ghost.BackgroundColor3=Color3.fromRGB(231,192,131)
local gradient=ghost:FindFirstChildOfClass("UIGradient") if gradient then gradient:Destroy() end ghost.ZIndex=1 ghost.Parent=health.Track health.Track.Fill.ZIndex=2
local hConnections={}
local trailTween
local function bindHealth(c)
 for _,conn in hConnections do conn:Disconnect() end table.clear(hConnections)
 local h=c:WaitForChild("Humanoid",10) if not h or player.Character~=c then return end
 local function syncTrail()
  if trailTween then trailTween:Cancel() end
  ghost.Size=UDim2.fromScale(h.MaxHealth>0 and math.clamp(h.Health/h.MaxHealth,0,1) or 0,1)
 end
 local last=h.Health syncTrail()
 table.insert(hConnections,h.HealthChanged:Connect(function(hp)
  if trailTween then trailTween:Cancel() end
  local ratio=h.MaxHealth>0 and math.clamp(hp/h.MaxHealth,0,1) or 0
  if hp<last and player:GetAttribute("ReducedMotion")~=true then
   ghost.Size=UDim2.fromScale(math.clamp(last/h.MaxHealth,0,1),1)
   trailTween=TweenService:Create(ghost,TweenInfo.new(0.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0.15),{Size=UDim2.fromScale(ratio,1)}) trailTween:Play()
  else ghost.Size=UDim2.fromScale(ratio,1) end last=hp
 end))
 table.insert(hConnections,h:GetPropertyChangedSignal("MaxHealth"):Connect(syncTrail))
 table.insert(hConnections,player:GetAttributeChangedSignal("ReducedMotion"):Connect(function() if player:GetAttribute("ReducedMotion")==true then syncTrail() end end))
end
player.CharacterAdded:Connect(bindHealth) if player.Character then task.spawn(bindHealth,player.Character) end
local money=player:WaitForChild("leaderstats"):WaitForChild("Coins")
local count=Instance.new("NumberValue") count.Value=money.Value
local countTween
local function format(value)
 return tostring(math.max(0,math.floor(value+0.5))):reverse():gsub("(%d%d%d)","%1 "):reverse():gsub("^ ","")
end
count.Changed:Connect(function(v) coins.CoinsValue.Text=format(v) end)
money.Changed:Connect(function(v)
 if countTween then countTween:Cancel() end countTween=TweenService:Create(count,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Value=v}) countTween:Play()
end)
local options=Instance.new("Frame") options.Name="SurvivalOptions" options.AnchorPoint=Vector2.new(1,0)
options.Position=UDim2.new(1,-18,0,145) options.Size=UDim2.fromOffset(270,247) options.BackgroundColor3=Color3.fromRGB(14,22,25) options.BorderSizePixel=0 options.Visible=false options.Parent=gui styleCard(options)
label("Title",options,"OPTIONS",UDim2.fromOffset(16,12),UDim2.fromOffset(240,22),Enum.Font.GothamBold,15,Color3.fromRGB(232,224,202))
local function button(parent,text,y)
 local b=Instance.new("TextButton") b.Position=UDim2.fromOffset(14,y) b.Size=UDim2.fromOffset(242,34)
 b.BackgroundColor3=Color3.fromRGB(32,43,45) b.BorderSizePixel=0 b.TextColor3=Color3.fromRGB(211,219,209) b.Font=Enum.Font.GothamMedium b.TextSize=11 b.Text=text b.Modal=true b.AutoButtonColor=true b.Parent=parent
 local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,4) corner.Parent=b return b
end
local quality=button(options,"QUALITE : ELEVEE",44) quality.Name="Quality"
local rain=button(options,"PLUIE : ACTIVE",84) rain.Name="Rain"
local motion=button(options,"MOUVEMENTS CAMERA : COMPLETS",124) motion.Name="CameraMotion"
local audio=button(options,"EFFETS SONORES : ACTIFS",164) audio.Name="Sound"
local close=button(options,"FERMER",204) close.Name="Close" close.Size=UDim2.fromOffset(242,28)
local function update()
 quality.Text=player:GetAttribute("HighGraphics")==false and "QUALITE : STANDARD" or "QUALITE : ELEVEE"
 rain.Text=player:GetAttribute("RainEnabled")==false and "PLUIE : DESACTIVEE" or "PLUIE : ACTIVE"
 motion.Text=player:GetAttribute("ReducedMotion")==true and "MOUVEMENTS CAMERA : REDUITS" or "MOUVEMENTS CAMERA : COMPLETS"
 audio.Text=player:GetAttribute("SFXEnabled")==false and "EFFETS SONORES : COUPES" or "EFFETS SONORES : ACTIFS"
end
quality.Activated:Connect(function() player:SetAttribute("HighGraphics",player:GetAttribute("HighGraphics")==false) update() end)
rain.Activated:Connect(function() player:SetAttribute("RainEnabled",player:GetAttribute("RainEnabled")==false) update() end)
motion.Activated:Connect(function() player:SetAttribute("ReducedMotion",player:GetAttribute("ReducedMotion")~=true) update() end)
audio.Activated:Connect(function() player:SetAttribute("SFXEnabled",player:GetAttribute("SFXEnabled")==false) update() end)
local previousCameraType=Enum.CameraType.Custom
local function toggle()
 if player:GetAttribute("GameMenuOpen") and not options.Visible then return end
 options.Visible=not options.Visible
 player:SetAttribute("OptionsOpen",options.Visible)
 local camera=workspace.CurrentCamera
 if options.Visible then
  previousCameraType=camera.CameraType
  camera.CameraType=Enum.CameraType.Scriptable
 else
  camera.CameraType=previousCameraType
  -- Menu entry resets voluntary mouse release; restore combat input on close.
  if player:GetAttribute("MouseUnlocked") or player:GetAttribute("ThirdPerson")==true then
   UserInputService.MouseBehavior=Enum.MouseBehavior.Default UserInputService.MouseIconEnabled=true
  else
   UserInputService.MouseIconEnabled=false
   UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter
  end
 end
 update()
end
game:GetService("RunService"):BindToRenderStep("SurvivalOptionsCursor",Enum.RenderPriority.Camera.Value+10,function()
 if options.Visible then
  local camera=workspace.CurrentCamera camera.CameraType=Enum.CameraType.Scriptable
  UserInputService.MouseBehavior=Enum.MouseBehavior.Default UserInputService.MouseIconEnabled=true
  local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if h then h:Move(Vector3.zero,false) end
 end
end)
local toggleButton=Instance.new("TextButton") toggleButton.Name="OptionsButton" toggleButton.AnchorPoint=Vector2.new(1,0) toggleButton.Position=UDim2.new(1,-18,0,106)
toggleButton.Size=UDim2.fromOffset(86,27) toggleButton.Text="OPTIONS [P]" toggleButton.TextSize=9 toggleButton.Font=Enum.Font.GothamMedium
toggleButton.TextColor3=Color3.fromRGB(213,220,210) toggleButton.BackgroundColor3=Color3.fromRGB(20,30,32) toggleButton.BackgroundTransparency=0.2 toggleButton.BorderSizePixel=0 toggleButton.Parent=gui
toggleButton.Activated:Connect(toggle) close.Activated:Connect(toggle)
ContextActionService:BindAction("SurvivalOptions",function(_,state)
 if state==Enum.UserInputState.Begin and not UserInputService:GetFocusedTextBox() then toggle() end
 return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.P)
update()

-- Modal buttons release the first-person cursor through the standard camera controller.
local mouseUnlocked=false
player:SetAttribute("MouseUnlocked",false)
local mouseBtn=Instance.new("TextButton") mouseBtn.Name="MouseUnlockButton" mouseBtn.AnchorPoint=Vector2.new(1,0)
mouseBtn.Position=UDim2.new(1,-18,0,72) mouseBtn.Size=UDim2.fromOffset(120,30) mouseBtn.Text="SOURIS [M]"
mouseBtn.TextSize=9 mouseBtn.Font=Enum.Font.GothamMedium mouseBtn.TextColor3=Color3.fromRGB(213,220,210)
mouseBtn.BackgroundColor3=Color3.fromRGB(20,30,32) mouseBtn.BackgroundTransparency=0.2 mouseBtn.BorderSizePixel=0 mouseBtn.Parent=gui
local function canUseMouse()
 local character=player.Character local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 return UserInputService.MouseEnabled and not UserInputService.TouchEnabled
  and player:GetAttribute("HasStarted")==true and humanoid and humanoid.Health>0
  and not player:GetAttribute("GameMenuOpen") and not player:GetAttribute("OptionsOpen")
end
local function applyMouseState()
 local active=canUseMouse()
 mouseBtn.Modal=mouseUnlocked and active or false
 if UserInputService.TouchEnabled or not UserInputService.MouseEnabled then return end
 if mouseUnlocked or not active or player:GetAttribute("ThirdPerson")==true then
  UserInputService.MouseBehavior=Enum.MouseBehavior.Default UserInputService.MouseIconEnabled=true
 else
  UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter UserInputService.MouseIconEnabled=false
 end
end
player:GetAttributeChangedSignal("ThirdPerson"):Connect(applyMouseState)
local function resetMouseLock()
 mouseUnlocked=false player:SetAttribute("MouseUnlocked",false) applyMouseState()
end
local function toggleMouse()
 if not canUseMouse() or UserInputService:GetFocusedTextBox() then return end
 mouseUnlocked=not mouseUnlocked player:SetAttribute("MouseUnlocked",mouseUnlocked)
 applyMouseState()
end
local function updateMouseBtn()
 mouseBtn.Visible=canUseMouse()==true
 mouseBtn.Modal=mouseUnlocked and mouseBtn.Visible
 mouseBtn.Text=mouseUnlocked and "REPRENDRE [M]" or "SOURIS [M]"
end
mouseBtn.Activated:Connect(toggleMouse)
ContextActionService:BindAction("SurvivalMouseUnlock",function(_,state)
 if not canUseMouse() or UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin then toggleMouse() end
 return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.M)
player:GetAttributeChangedSignal("HasStarted"):Connect(updateMouseBtn)
player:GetAttributeChangedSignal("GameMenuOpen"):Connect(function()
 if player:GetAttribute("GameMenuOpen") then resetMouseLock() end updateMouseBtn()
end)
player:GetAttributeChangedSignal("OptionsOpen"):Connect(function()
 if player:GetAttribute("OptionsOpen") then resetMouseLock() end updateMouseBtn()
end)
player:GetAttributeChangedSignal("MouseUnlocked"):Connect(function() mouseUnlocked=player:GetAttribute("MouseUnlocked")==true updateMouseBtn() end)
local deviceRevision=0
local function mouseDeviceChanged()
 updateMouseBtn()
 deviceRevision+=1 local revision=deviceRevision
 task.delay(.2,function()
  if revision~=deviceRevision then return end
  if UserInputService.TouchEnabled or not UserInputService.MouseEnabled then resetMouseLock() end
  updateMouseBtn()
 end)
end
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(mouseDeviceChanged)
UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(mouseDeviceChanged)
local mouseDeathConnection
local function bindMouseCharacter(character)
 if mouseDeathConnection then mouseDeathConnection:Disconnect() mouseDeathConnection=nil end
 resetMouseLock()
 local humanoid=character:WaitForChild("Humanoid",10)
 if character~=player.Character or not humanoid then return end
 mouseDeathConnection=humanoid.Died:Connect(function() resetMouseLock() updateMouseBtn() end)
 updateMouseBtn()
end
player.CharacterAdded:Connect(bindMouseCharacter)
if player.Character then task.spawn(bindMouseCharacter,player.Character) end
RunService:BindToRenderStep("SurvivalMouseNavigation",Enum.RenderPriority.Camera.Value+30,function()
 if mouseUnlocked and canUseMouse() then applyMouseState() end
end)
task.defer(updateMouseBtn)

local menuScale=Instance.new("UIScale") menuScale.Parent=options
local resizeConnection
local function resizeMenu()
 local camera=workspace.CurrentCamera if not camera then return end
 local viewport=camera.ViewportSize
 local compact=viewport.Y<500
 options.Position=UDim2.new(1,-18,0,compact and 60 or 145)
 local toggleY=compact and 22 or 20
 if UserInputService.TouchEnabled and viewport.X<viewport.Y then toggleY=progress.AbsolutePosition.Y+progress.AbsoluteSize.Y-gui.AbsolutePosition.Y+4 end
 toggleButton.Position=UDim2.new(1,-18,0,toggleY)
 mouseBtn.Position=UDim2.new(1,-18,0,compact and 60 or 54)
 mouseBtn.Size=UDim2.fromOffset(viewport.X<700 and 96 or 120,30)
 menuScale.Scale=math.clamp((viewport.Y-100)/247,0.68,1)
end
local function watchCamera()
 if resizeConnection then resizeConnection:Disconnect() end
 if workspace.CurrentCamera then resizeConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeMenu) end resizeMenu()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
progress:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeMenu)
progress:GetPropertyChangedSignal("AbsolutePosition"):Connect(resizeMenu)
watchCamera()

local touchLayoutConnection
local function layoutTouchControls()
 if not UserInputService.TouchEnabled or not player.PlayerGui:FindFirstChild("ContextActionGui") then return end
 local camera=workspace.CurrentCamera if not camera then return end
 local jump=player.PlayerGui:FindFirstChild("JumpButton",true)
 local base=jump and jump:IsA("GuiObject") and (jump.AbsolutePosition+Vector2.new(jump.AbsoluteSize.X/2,-45)) or Vector2.new(camera.ViewportSize.X-70,camera.ViewportSize.Y-155)
 local info={
  {"FistsPunch","COUP",base,Color3.fromRGB(196,169,111)},
  {"SurvivalSprint","SPRINT",base+Vector2.new(-68,-68),Color3.fromRGB(119,189,179)},
  {"SurvivorFlashlight","LAMPE",base+Vector2.new(-68,0),Color3.fromRGB(170,181,177)}
 }
 for _,item in info do
  local b=ContextActionService:GetAllBoundActionInfo()[item[1]] and ContextActionService:GetButton(item[1])
  if b and b.Parent then
   b.AnchorPoint=Vector2.new(0.5,0.5) b.Size=UDim2.fromOffset(54,54)
   local relative=item[3]-b.Parent.AbsolutePosition
   b.Position=UDim2.fromOffset(relative.X,relative.Y)
   b.ImageTransparency=1 b.BackgroundTransparency=0.15 b.BackgroundColor3=Color3.fromRGB(20,31,33) b.BorderSizePixel=0
   local c=b:FindFirstChild("SurvivalCorner") or Instance.new("UICorner") c.Name="SurvivalCorner" c.CornerRadius=UDim.new(1,0) c.Parent=b
   local border=b:FindFirstChild("SurvivalBorder") or Instance.new("UIStroke") border.Name="SurvivalBorder" border.Color=item[4] border.Transparency=0.4 border.Thickness=1 border.Parent=b
   local title=b:FindFirstChild("ActionTitle")
   if title then title.Text=item[2] title.Font=Enum.Font.GothamBold title.TextSize=10 title.TextWrapped=false title.TextScaled=false title.TextColor3=Color3.fromRGB(222,227,214) end
   b.Visible=player:GetAttribute("OptionsOpen")~=true and player:GetAttribute("GameMenuOpen")~=true
  end
 end
end
player:GetAttributeChangedSignal("OptionsOpen"):Connect(layoutTouchControls)
player:GetAttributeChangedSignal("GameMenuOpen"):Connect(layoutTouchControls)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(layoutTouchControls)
local function watchTouchCamera()
 if touchLayoutConnection then touchLayoutConnection:Disconnect() end
 if workspace.CurrentCamera then touchLayoutConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() task.defer(layoutTouchControls) end) end
 task.delay(0.3,layoutTouchControls)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchTouchCamera)
watchTouchCamera()

-- Cartoon HUD pass: bold ink outlines, warm paper cards, bright status colors.
local INK=Color3.fromRGB(38,48,68)
local CREAM=Color3.fromRGB(255,243,210)
local WHITE=Color3.fromRGB(255,251,231)
local SKY=Color3.fromRGB(87,193,221)
local LIME=Color3.fromRGB(116,205,115)
local GOLD=Color3.fromRGB(255,196,65)
local CORAL=Color3.fromRGB(242,100,83)
local function cartoonCorner(obj,radius)
 local c=obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,radius) c.Parent=obj return c
end
local function cartoonStroke(obj,color,thickness,transparency)
 local s=obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
 s.Color=color s.Thickness=thickness s.Transparency=transparency or 0
 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=obj return s
end
local function cartoonGradient(obj,top,bottom,rotation)
 local g=obj:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
 g.Color=ColorSequence.new(top,bottom) g.Rotation=rotation or 90 g.Parent=obj
end
local function cartoonShadow(obj,radius,offset)
 local parent=obj.Parent
 local shadow=parent:FindFirstChild(obj.Name.."CartoonShadow")
 if not shadow then shadow=Instance.new("Frame") shadow.Name=obj.Name.."CartoonShadow" shadow.Parent=parent end
 shadow.AnchorPoint=obj.AnchorPoint shadow.Position=obj.Position+UDim2.fromOffset(offset,offset)
 shadow.Size=obj.Size shadow.BackgroundColor3=INK shadow.BackgroundTransparency=0.12
 shadow.BorderSizePixel=0 shadow.ZIndex=math.max(0,obj.ZIndex-1) shadow.Visible=obj.Visible
 cartoonCorner(shadow,radius)
 obj:GetPropertyChangedSignal("Position"):Connect(function() shadow.Position=obj.Position+UDim2.fromOffset(offset,offset) end)
 obj:GetPropertyChangedSignal("Size"):Connect(function() shadow.Size=obj.Size end)
 obj:GetPropertyChangedSignal("Visible"):Connect(function() shadow.Visible=obj.Visible end)
 -- Sibling shadows must inherit the card's own scale as well as the parent's scale.
 local shadowScale=Instance.new("UIScale") shadowScale.Name="CardShadowScale" shadowScale.Parent=shadow
 local function trackScale(child)
  if child:IsA("UIScale") then
   shadowScale.Scale=child.Scale
   child:GetPropertyChangedSignal("Scale"):Connect(function() shadowScale.Scale=child.Scale end)
  end
 end
 for _,child in obj:GetChildren() do trackScale(child) end
 obj.ChildAdded:Connect(trackScale)
 obj.ChildRemoved:Connect(function(child) if child:IsA("UIScale") then shadowScale.Scale=1 end end)
 return shadow
end
local function inkText(obj,color,size)
 if not obj or not obj:IsA("TextLabel") then return end
 obj.Font=Enum.Font.FredokaOne obj.TextColor3=color obj.TextStrokeColor3=WHITE
 obj.TextStrokeTransparency=0.72
 if size then obj.TextSize=size end
end
local function cartoonCard(card,top,bottom,radius)
 card.BackgroundTransparency=0 card.BackgroundColor3=Color3.new(1,1,1) card.BorderSizePixel=0 card.ZIndex=3
 cartoonCorner(card,radius) cartoonGradient(card,top,bottom)
 cartoonStroke(card,INK,3,0) cartoonShadow(card,radius,3)
end
local function cartoonTrack(track,fillColor)
 if not track then return end
 track.BackgroundColor3=Color3.fromRGB(68,78,96) track.BackgroundTransparency=0
 track.BorderSizePixel=0 track.ClipsDescendants=true cartoonCorner(track,8)
 local stroke=track:FindFirstChildOfClass("UIStroke")
 if stroke then stroke:Destroy() end
 local fill=track:FindFirstChild("Fill")
 if fill then fill.BackgroundColor3=Color3.new(1,1,1) fill.BorderSizePixel=0 cartoonCorner(fill,8) cartoonGradient(fill,Color3.fromRGB(255,255,235),fillColor) end
end
cartoonCard(health,Color3.fromRGB(255,250,224),Color3.fromRGB(247,218,176),12)
cartoonCard(stamina,Color3.fromRGB(224,250,255),Color3.fromRGB(166,225,241),10)
cartoonCard(coins,Color3.fromRGB(255,231,125),Color3.fromRGB(255,178,55),12)
cartoonCard(progress,Color3.fromRGB(130,217,239),Color3.fromRGB(64,157,211),14)
cartoonCard(toast,Color3.fromRGB(255,225,107),Color3.fromRGB(255,174,61),18)
for _,item in {health.Title,health.HealthValue,stamina.Title,stamina.StaminaValue,stamina.Hint,coins.Title,coins.CoinsValue,progress.Level,progress.XP,progress.Zone,toast,controls} do
 inkText(item,INK)
end
health.Title.TextColor3=Color3.fromRGB(64,137,82) health.Title.TextSize=12
health.HealthValue.TextSize=21 health.HealthValue.TextStrokeColor3=Color3.fromRGB(255,238,206)
stamina.Title.TextColor3=Color3.fromRGB(42,125,164) stamina.Title.TextSize=11
stamina.StaminaValue.TextSize=14 stamina.Hint.TextSize=9 stamina.Hint.TextColor3=Color3.fromRGB(51,108,135)
coins.Title.TextColor3=Color3.fromRGB(134,87,22) coins.Title.TextSize=10
coins.CoinsValue.TextSize=23 coins.CoinsValue.TextStrokeColor3=Color3.fromRGB(255,229,143)
progress.Level.TextSize=18 progress.Level.TextColor3=Color3.fromRGB(255,251,223)
progress.XP.TextSize=11 progress.XP.TextColor3=Color3.fromRGB(255,249,223)
progress.Zone.TextSize=10 progress.Zone.TextColor3=Color3.fromRGB(241,250,255)
toast.TextSize=14 toast.TextColor3=INK toast.TextStrokeColor3=Color3.fromRGB(255,235,165)
cartoonTrack(health.Track,CORAL) cartoonTrack(stamina.Track,SKY) cartoonTrack(progress.XPTrack,GOLD)
health.MedicalCross.BackgroundColor3=CORAL
if health.MedicalCross:FindFirstChild("Vertical") then health.MedicalCross.Vertical.BackgroundColor3=CORAL end
stamina.Bolt.TextColor3=GOLD stamina.Bolt.TextStrokeColor3=INK stamina.Bolt.TextStrokeTransparency=0.3
if logo and logo:IsA("GuiObject") then
 cartoonCorner(logo,logo.AbsoluteSize.X)
 cartoonStroke(logo,INK,2,0)
end
cartoonCorner(options,20) options.BackgroundColor3=CREAM options.BackgroundTransparency=0
cartoonStroke(options,INK,4,0) cartoonShadow(options,20,5)
local optionTitle=options:FindFirstChild("Title")
if optionTitle then
 optionTitle.Font=Enum.Font.FredokaOne optionTitle.TextSize=20 optionTitle.TextColor3=Color3.fromRGB(255,247,214)
 optionTitle.BackgroundColor3=Color3.fromRGB(58,115,165) optionTitle.BackgroundTransparency=0
 optionTitle.Size=UDim2.fromOffset(240,30) optionTitle.Position=UDim2.fromOffset(15,10)
 optionTitle.TextXAlignment=Enum.TextXAlignment.Center optionTitle.TextStrokeColor3=INK optionTitle.TextStrokeTransparency=0.3
 cartoonCorner(optionTitle,12) cartoonStroke(optionTitle,INK,2,0)
end
local optionColors={
 [quality]=Color3.fromRGB(87,193,221),[rain]=Color3.fromRGB(111,201,135),
 [motion]=Color3.fromRGB(194,153,222),[audio]=Color3.fromRGB(255,183,77),[close]=Color3.fromRGB(242,100,83)
}
for b,color in optionColors do
 b.BorderSizePixel=0 b.BackgroundTransparency=0 b.BackgroundColor3=color
 b.TextColor3=WHITE b.Font=Enum.Font.FredokaOne b.TextSize=14 b.TextStrokeColor3=INK b.TextStrokeTransparency=0.35
 cartoonCorner(b,12) cartoonStroke(b,INK,2,0)
 local baseSize=b.Size
 b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{Size=baseSize+UDim2.fromOffset(4,2)}):Play() end)
 b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{Size=baseSize}):Play() end)
end
local oldUpdate=update
update=function()
 oldUpdate()
 quality.BackgroundColor3=player:GetAttribute("HighGraphics")==false and Color3.fromRGB(147,160,175) or Color3.fromRGB(87,193,221)
 rain.BackgroundColor3=player:GetAttribute("RainEnabled")==false and Color3.fromRGB(147,160,175) or Color3.fromRGB(111,201,135)
 motion.BackgroundColor3=player:GetAttribute("ReducedMotion")==true and Color3.fromRGB(147,160,175) or Color3.fromRGB(194,153,222)
 audio.BackgroundColor3=player:GetAttribute("SFXEnabled")==false and Color3.fromRGB(147,160,175) or Color3.fromRGB(255,183,77)
end
update()
toggleButton.BorderSizePixel=0 toggleButton.BackgroundTransparency=0 toggleButton.BackgroundColor3=GOLD
toggleButton.Font=Enum.Font.FredokaOne toggleButton.TextSize=13 toggleButton.TextColor3=INK
toggleButton.TextStrokeColor3=WHITE toggleButton.TextStrokeTransparency=0.65
cartoonCorner(toggleButton,13) cartoonStroke(toggleButton,INK,2,0) cartoonShadow(toggleButton,13,3)
local toggleBaseSize=toggleButton.Size
toggleButton.MouseEnter:Connect(function() TweenService:Create(toggleButton,TweenInfo.new(0.12),{Size=toggleBaseSize+UDim2.fromOffset(4,3)}):Play() end)
toggleButton.MouseLeave:Connect(function() TweenService:Create(toggleButton,TweenInfo.new(0.12),{Size=toggleBaseSize}):Play() end)
-- Cartoon style for mouse unlock button (SKY blue = neutral action)
mouseBtn.BorderSizePixel=0 mouseBtn.BackgroundTransparency=0 mouseBtn.BackgroundColor3=SKY
mouseBtn.Font=Enum.Font.FredokaOne mouseBtn.TextSize=13 mouseBtn.TextColor3=INK
mouseBtn.TextStrokeColor3=WHITE mouseBtn.TextStrokeTransparency=0.65
cartoonCorner(mouseBtn,13) cartoonStroke(mouseBtn,INK,2,0) cartoonShadow(mouseBtn,13,3)
mouseBtn.TextScaled=true
local mouseTextLimit=Instance.new("UITextSizeConstraint") mouseTextLimit.MinTextSize=10 mouseTextLimit.MaxTextSize=13 mouseTextLimit.Parent=mouseBtn
local mouseHoverScale=Instance.new("UIScale") mouseHoverScale.Parent=mouseBtn
mouseBtn.MouseEnter:Connect(function() if not player:GetAttribute("ReducedMotion") then TweenService:Create(mouseHoverScale,TweenInfo.new(.12),{Scale=1.025}):Play() end end)
mouseBtn.MouseLeave:Connect(function() TweenService:Create(mouseHoverScale,TweenInfo.new(player:GetAttribute("ReducedMotion") and 0 or .12),{Scale=1}):Play() end)
controls.Font=Enum.Font.FredokaOne controls.TextSize=10 controls.TextColor3=Color3.fromRGB(255,238,183)
for _,item in {{health,CORAL},{stamina,SKY},{coins,GOLD}} do
 local card,color=item[1],item[2]
 card.MouseEnter:Connect(function() end)
 local icon=card:FindFirstChild("MedicalCross") or card:FindFirstChild("Bolt")
 if icon and icon:IsA("TextLabel") then icon.TextStrokeColor3=INK icon.TextStrokeTransparency=0.2 end
end
local touchCartoon={FistsPunch=CORAL,SurvivalSprint=SKY,SurvivorFlashlight=GOLD}
local function recolorTouchButtons()
 if not player.PlayerGui:FindFirstChild("ContextActionGui") then return end
 for action,color in touchCartoon do
  local b=ContextActionService:GetAllBoundActionInfo()[action] and ContextActionService:GetButton(action)
  if b and b.Parent then
   b.BackgroundTransparency=0 b.BackgroundColor3=color
   local border=b:FindFirstChild("SurvivalBorder") if border then border.Color=INK border.Thickness=3 border.Transparency=0 end
   local title=b:FindFirstChild("ActionTitle")
   if title then title.Font=Enum.Font.FredokaOne title.TextSize=12 title.TextColor3=INK title.TextStrokeColor3=WHITE title.TextStrokeTransparency=0.55 end
  end
 end
end
task.defer(recolorTouchButtons)
player:GetAttributeChangedSignal("OptionsOpen"):Connect(recolorTouchButtons)
player:GetAttributeChangedSignal("GameMenuOpen"):Connect(recolorTouchButtons)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function() controls.Visible=not UserInputService.TouchEnabled recolorTouchButtons() end)
