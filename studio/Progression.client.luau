local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local ChainConfig=require(game.ReplicatedStorage:WaitForChild("GameplayConfig")).KillChain
local remote=game.ReplicatedStorage.Remotes:WaitForChild("ProgressFeedback")
local gui=player:WaitForChild("PlayerGui"):WaitForChild("SurvivalHUD",30)
assert(gui,"Missing SurvivalHUD")
local panel=Instance.new("Frame") panel.Name="ProgressCard" panel.AnchorPoint=Vector2.new(0.5,0)
panel.Position=UDim2.new(0.5,0,0,12) panel.Size=UDim2.fromOffset(350,80)
panel.BackgroundColor3=Color3.fromRGB(19,26,27) panel.BackgroundTransparency=0.12 panel.BorderSizePixel=0 panel.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,10) corner.Parent=panel
local border=Instance.new("UIStroke") border.Color=Color3.fromRGB(135,158,135) border.Transparency=0.5 border.Parent=panel
local scale=Instance.new("UIScale") scale.Parent=panel
local function text(name,parent,string,pos,size,color,sizeText,alignment)
 local t=Instance.new("TextLabel") t.Name=name t.Text=string t.Position=pos t.Size=size t.BackgroundTransparency=1
 t.Font=Enum.Font.GothamBold t.TextColor3=color t.TextSize=sizeText t.TextXAlignment=alignment or Enum.TextXAlignment.Left t.Parent=parent return t
end
local level=text("Level",panel,"NIVEAU 1",UDim2.fromOffset(15,10),UDim2.fromOffset(170,24),Color3.fromRGB(245,215,139),20)
local xpText=text("XP",panel,"0 / 80 XP",UDim2.fromOffset(180,14),UDim2.fromOffset(155,18),Color3.fromRGB(198,214,195),12,Enum.TextXAlignment.Right)
local track=Instance.new("Frame") track.Name="XPTrack" track.Position=UDim2.fromOffset(15,43) track.Size=UDim2.fromOffset(320,8) track.BorderSizePixel=0 track.BackgroundColor3=Color3.fromRGB(45,59,51) track.ClipsDescendants=true track.Parent=panel
local tc=Instance.new("UICorner") tc.CornerRadius=UDim.new(0,4) tc.Parent=track
local fill=Instance.new("Frame") fill.Name="Fill" fill.Size=UDim2.fromScale(0,1) fill.BorderSizePixel=0 fill.BackgroundColor3=Color3.fromRGB(148,206,113) fill.Parent=track tc:Clone().Parent=fill
local zone=text("Zone",panel,"REFUGE",UDim2.fromOffset(15,56),UDim2.fromOffset(320,18),Color3.fromRGB(174,188,177),11,Enum.TextXAlignment.Center)
local toast=Instance.new("TextLabel") toast.Name="ProgressToast" toast.AnchorPoint=Vector2.new(0.5,0) toast.Position=UDim2.new(0.5,0,0,103)
toast.Size=UDim2.fromOffset(440,54) toast.BackgroundColor3=Color3.fromRGB(21,29,26) toast.BackgroundTransparency=0.15 toast.BorderSizePixel=0
toast.Font=Enum.Font.GothamBold toast.TextSize=16 toast.TextColor3=Color3.fromRGB(247,214,133) toast.TextWrapped=true toast.Visible=false toast.Parent=gui
corner:Clone().Parent=toast
local toastScale=Instance.new("UIScale") toastScale.Parent=toast
local stats=player:WaitForChild("leaderstats")
local lvl=stats:WaitForChild("Level",30)
local xp=player:WaitForChild("Progress",30):WaitForChild("XP",30)
local tween
local prompts=game:GetService("ProximityPromptService")
local portalButton=Instance.new("TextButton") portalButton.Name="PortalPrompt" portalButton.AnchorPoint=Vector2.new(.5,.5)
portalButton.Position=UDim2.fromScale(.5,.62) portalButton.Size=UDim2.fromOffset(250,68) portalButton.Visible=false
portalButton.BackgroundColor3=Color3.fromRGB(255,235,177) portalButton.BorderSizePixel=0 portalButton.TextColor3=Color3.fromRGB(38,48,68)
portalButton.Font=Enum.Font.Cartoon portalButton.TextSize=16 portalButton.TextWrapped=true portalButton.ZIndex=25 portalButton.Parent=gui
local promptCorner=Instance.new("UICorner") promptCorner.CornerRadius=UDim.new(0,16) promptCorner.Parent=portalButton
local promptBorder=Instance.new("UIStroke") promptBorder.ApplyStrokeMode=Enum.ApplyStrokeMode.Border promptBorder.Color=Color3.fromRGB(38,48,68) promptBorder.Thickness=3 promptBorder.Parent=portalButton
local activePrompt,activeInput,heldInput,changeConnection
local function releasePrompt()
 if activePrompt and heldInput then activePrompt:InputHoldEnd() end
 heldInput=nil
end
local function refreshPrompt()
 local hidden=player:GetAttribute("HasStarted")~=true or player:GetAttribute("InGameMenu")==true or player:GetAttribute("GameMenuOpen")==true or player:GetAttribute("OptionsOpen")==true
 portalButton.Visible=activePrompt~=nil and not hidden
 if hidden then releasePrompt() end
 if activePrompt then
  local key=activeInput==Enum.ProximityPromptInputType.Touch and "MAINTIENS ICI" or activeInput==Enum.ProximityPromptInputType.Gamepad and "MAINTIENS "..activePrompt.GamepadKeyCode.Name or "MAINTIENS "..activePrompt.KeyboardKeyCode.Name
  portalButton.Text=activePrompt.ObjectText.."\n"..(activePrompt.ActionText=="Verrouille" and "VERROUILLE" or key)
 end
end
prompts.PromptShown:Connect(function(prompt,input)
 if prompt.Name~="ZoneTravel" then return end
 releasePrompt() if changeConnection then changeConnection:Disconnect() end
 activePrompt=prompt activeInput=input changeConnection=prompt.Changed:Connect(refreshPrompt) refreshPrompt()
end)
prompts.PromptHidden:Connect(function(prompt)
 if activePrompt~=prompt then return end
 releasePrompt() activePrompt=nil if changeConnection then changeConnection:Disconnect() changeConnection=nil end refreshPrompt()
end)
portalButton.InputBegan:Connect(function(input)
 if activePrompt and not heldInput and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1) then heldInput=input activePrompt:InputHoldBegin() end
end)
UIS.InputEnded:Connect(function(input) if input==heldInput then releasePrompt() end end)
for _,attr in {"HasStarted","InGameMenu","GameMenuOpen","OptionsOpen"} do player:GetAttributeChangedSignal(attr):Connect(refreshPrompt) end
local function portals()
 local world=workspace:FindFirstChild("ProgressionZones") if not world then return end
 for _,v in world:GetDescendants() do
  if v:IsA("ProximityPrompt") and v.Name=="ZoneTravel" then
   v.Style=Enum.ProximityPromptStyle.Custom
   local id=v.Parent:GetAttribute("Destination")
   for _,z in Config.Zones do if z.Id==id then
    local unlocked=player:GetAttribute("ProgressReady") and lvl.Value>=z.Level
    v.ObjectText=z.Name.." - NIV. "..z.Level
    v.ActionText=unlocked and "Maintenir pour entrer" or "Verrouille"
    v.Parent.Color=unlocked and z.Color or Color3.fromRGB(190,65,51)
   end end
  end
 end
end
local function update()
 if not player:GetAttribute("ProgressReady") then level.Text="CHARGEMENT..." else level.Text="NIVEAU "..lvl.Value end
 local required=Config.RequiredXP(lvl.Value)
 xpText.Text=xp.Value.." / "..required.." XP"
 if tween then tween:Cancel() end
 tween=TweenService:Create(fill,TweenInfo.new(0.25),{Size=UDim2.fromScale(math.clamp(xp.Value/required,0,1),1)}) tween:Play()
 portals()
end
lvl.Changed:Connect(update) xp.Changed:Connect(update)
player:GetAttributeChangedSignal("ProgressReady"):Connect(update)
local function zoneText() zone.Text=player:GetAttribute("CurrentZone") or "REFUGE" end
player:GetAttributeChangedSignal("CurrentZone"):Connect(zoneText) zoneText()
local noticeKind,noticeText,noticeColor
local noticeUntil=0
local burstCoins,burstXP,lastReward=0,0,-math.huge
local function celebrate(newLevel)
 local old=gui:FindFirstChild("LevelCelebration") if old then old:Destroy() end
 local banner=Instance.new("TextLabel") banner.Name="LevelCelebration" banner.AnchorPoint=Vector2.new(.5,.5) banner.Position=UDim2.fromScale(.5,.35) banner.Size=UDim2.fromOffset(300,70)
 banner.BackgroundColor3=Color3.fromRGB(255,204,73) banner.TextColor3=Color3.fromRGB(38,48,68) banner.BorderSizePixel=0 banner.Font=Enum.Font.Cartoon banner.TextSize=27 banner.Text="NIVEAU "..newLevel.." !" banner.ZIndex=15 banner.Parent=gui
 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,22) c.Parent=banner
 local s=Instance.new("UIStroke") s.Color=Color3.fromRGB(38,48,68) s.Thickness=3 s.Parent=banner
 local scale=Instance.new("UIScale") scale.Parent=banner
 local maxScale=math.min(1,(workspace.CurrentCamera.ViewportSize.X-36)/300)
 scale.Scale=player:GetAttribute("ReducedMotion") and maxScale or maxScale*.6
 TweenService:Create(scale,TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=maxScale}):Play()
 task.delay(2,function() if banner.Parent then banner:Destroy() end end)
end
remote.OnClientEvent:Connect(function(kind,data)
 if typeof(data)~="table" then return end
 if kind=="Reward" then
  if os.clock()-lastReward>1 then burstCoins=0 burstXP=0 end
  burstCoins+=data.Coins burstXP+=data.XP lastReward=os.clock()
  toast.Text="+"..burstCoins.." PIECES   /   +"..burstXP.." XP"
  toast.TextColor3=Color3.fromRGB(38,48,68)
  if data.LeveledUp then celebrate(data.Level) end
 elseif kind=="Locked" then toast.Text=data.Name.."\nNIVEAU "..data.Level.." REQUIS" toast.TextColor3=Color3.fromRGB(143,41,39)
 elseif kind=="Zone" then toast.Text=data.Name toast.TextColor3=Color3.fromRGB(27,88,56)
 else return
 end
 noticeKind=kind noticeText=toast.Text noticeColor=toast.TextColor3
 noticeUntil=os.clock()+(kind=="Locked" and 3 or 2.5)
end)
local chainTrack=Instance.new("Frame") chainTrack.Name="ChainCountdown" chainTrack.AnchorPoint=Vector2.new(.5,1) chainTrack.Position=UDim2.new(.5,0,1,-3) chainTrack.Size=UDim2.new(1,-22,0,4) chainTrack.BackgroundColor3=Color3.fromRGB(171,148,88) chainTrack.BorderSizePixel=0 chainTrack.Visible=false chainTrack.Parent=toast
local chainFill=Instance.new("Frame") chainFill.Name="Fill" chainFill.Size=UDim2.fromScale(1,1) chainFill.BackgroundColor3=Color3.fromRGB(38,48,68) chainFill.BorderSizePixel=0 chainFill.Parent=chainTrack
local chainPulse,lastChain
local function chainCaption(count)
 local title=count>=10 and "INARRETABLE !" or count>=5 and "EN FURIE !" or count==3 and "TRIPLE K.O. !" or count==2 and "DOUBLE K.O. !" or "BELLE SERIE !"
 return "SERIE "..count.." · "..title
end
RunService.RenderStepped:Connect(function()
 local viewport=workspace.CurrentCamera.ViewportSize
 local landscape=UIS.TouchEnabled and viewport.X>viewport.Y
 local portrait=UIS.TouchEnabled and viewport.X<=viewport.Y
 portalButton.Position=UDim2.fromScale(landscape and .75 or .5,landscape and .47 or .62)
 portalButton.Size=UDim2.fromOffset(math.min(250,viewport.X-24),landscape and 48 or 68)
 portalButton.TextSize=landscape and 14 or 16
 local width=landscape and math.min(300,math.max(220,viewport.X-430)) or 380
 local center,y=viewport.X/2,86
 local status=gui:FindFirstChild("StatusPanel")
 if landscape and status then center=math.max(center,status.AbsolutePosition.X+status.AbsoluteSize.X+8+width*math.clamp(viewport.X/650,.65,1)/2) end
 if portrait then
  local boosts=player.PlayerGui:FindFirstChild("ActiveBoosts",true)
  local ammo=player.PlayerGui:FindFirstChild("Ammo",true)
  for _,item in {status,boosts,ammo} do
   if item and item.Visible then y=math.max(y,item.AbsolutePosition.Y+item.AbsoluteSize.Y+8) end
  end
 end
 toast.Size=UDim2.fromOffset(width,48) toast.Position=UDim2.fromOffset(center,y)
 local character=player.Character local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 local playing=player:GetAttribute("HasStarted")==true and humanoid and humanoid.Health>0
 local menu=player:GetAttribute("GameMenuOpen") or player:GetAttribute("OptionsOpen")
 local count=player:GetAttribute("KillChain") or 0
 local remaining=math.max(0,(player:GetAttribute("KillChainUntil") or 0)-workspace:GetServerTimeNow())
 local chainActive=playing and count>=2 and remaining>0
 local noticeActive=os.clock()<noticeUntil
 toast.Visible=playing and not menu and (noticeActive or chainActive) or false
 local chainShown=chainActive and (not noticeActive or noticeKind=="Reward")
 chainTrack.Visible=chainShown==true
 if chainShown then
  local caption=chainCaption(count)
  toast.Text=noticeActive and (noticeText.."\n"..caption) or (caption.."\nRECORD DE SESSION : "..(player:GetAttribute("BestKillChain") or count))
  toast.TextColor3=Color3.fromRGB(38,48,68)
  chainFill.Size=UDim2.fromScale(math.clamp(remaining/ChainConfig.Window,0,1),1)
 elseif noticeActive then toast.Text=noticeText toast.TextColor3=noticeColor end
 if chainActive and count~=lastChain then
  if chainPulse then chainPulse:Cancel() end
  local maxScale=math.clamp(workspace.CurrentCamera.ViewportSize.X/650,.65,1)
  if player:GetAttribute("ReducedMotion") then toastScale.Scale=maxScale
  else
   toastScale.Scale=maxScale*.92
   chainPulse=TweenService:Create(toastScale,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=maxScale}) chainPulse:Play()
  end
 end
 lastChain=chainActive and count or nil
end)
local viewportConnection
local function resize()
 local camera=workspace.CurrentCamera if not camera then return end
 local width=camera.ViewportSize.X
 scale.Scale=math.clamp(width/650,0.68,1)
 toastScale.Scale=math.clamp(width/650,0.65,1)
end
local function cameraChanged()
 if viewportConnection then viewportConnection:Disconnect() end
 if workspace.CurrentCamera then viewportConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end resize()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraChanged) cameraChanged()
update()
