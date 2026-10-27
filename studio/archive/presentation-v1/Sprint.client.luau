local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContextActionService=game:GetService("ContextActionService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local ContentProvider=game:GetService("ContentProvider")
local player=Players.LocalPlayer
local Config=require(ReplicatedStorage:WaitForChild("SprintConfig"))
local remote=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Sprint")
local hud=player:WaitForChild("PlayerGui"):WaitForChild("SurvivalHUD",30)
assert(hud,"SurvivalHUD missing from PlayerGui")
local panel=hud:WaitForChild("StatusPanel",10)
local card=panel:WaitForChild("StaminaCard")
local h,character,track,animation,footsteps,breathing
local connections={}
local request=false
local displayStamina=Config.MaxStamina
local sources={}
local actionName="SurvivalSprint"
local function setRequest(on)
 if request==on then return end
 request=on remote:FireServer(on)
end
local function releaseAll()
 table.clear(sources) setRequest(false)
end
local function input(_,state,inputObject)
 local key=inputObject and inputObject.KeyCode or Enum.KeyCode.Unknown
 if state==Enum.UserInputState.Begin then
  if UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
  sources[key]=true
 elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then sources[key]=nil end
 setRequest(next(sources)~=nil)
 return Enum.ContextActionResult.Sink
end
ContextActionService:BindAction(actionName,input,true,Enum.KeyCode.LeftShift,Enum.KeyCode.RightShift,Enum.KeyCode.ButtonL3)
ContextActionService:SetTitle(actionName,"SPRINT")
ContextActionService:SetPosition(actionName,UDim2.new(1,-175,1,-230))
UserInputService.WindowFocusReleased:Connect(releaseAll)
UserInputService.TextBoxFocused:Connect(releaseAll)
local function cleanup()
 releaseAll()
 for _,c in connections do c:Disconnect() end table.clear(connections)
 if track then track:Stop(0) track:Destroy() track=nil end
 if animation then animation:Destroy() animation=nil end
 if footsteps then footsteps:Destroy() footsteps=nil end
 if breathing then breathing:Destroy() breathing=nil end
 h=nil character=nil
end
local function bind(newCharacter)
 cleanup() character=newCharacter displayStamina=Config.MaxStamina
 local humanoid=newCharacter:WaitForChild("Humanoid",10)
 if not humanoid or character~=newCharacter then return end
 h=humanoid
 local root=newCharacter:WaitForChild("HumanoidRootPart",10)
 local animator=humanoid:WaitForChild("Animator",10)
 if character~=newCharacter or not root or not animator then return end
 animation=Instance.new("Animation") animation.Name="SprintAnimation"
 animation.AnimationId=humanoid.RigType==Enum.HumanoidRigType.R15 and Config.R15Animation or Config.R6Animation
 local ok,result=pcall(function() return animator:LoadAnimation(animation) end)
 if ok then track=result track.Priority=Enum.AnimationPriority.Movement track.Looped=true end
 footsteps=Instance.new("Sound") footsteps.Name="SprintFootsteps" footsteps.SoundId=Config.Footsteps
 footsteps.Looped=true footsteps.Volume=0 footsteps.PlaybackSpeed=1.65 footsteps.Parent=root
 breathing=Instance.new("Sound") breathing.Name="SprintBreathing" breathing.SoundId=Config.Breathing
 breathing.Looped=true breathing.Volume=0 breathing.Parent=workspace.CurrentCamera
 task.spawn(function() pcall(function() ContentProvider:PreloadAsync({footsteps,breathing}) end) end)
 table.insert(connections,humanoid.Died:Connect(function()
  releaseAll() if track then track:Stop(0.12) end
  if footsteps then footsteps:Stop() end if breathing then breathing:Stop() end
 end))
end
player.CharacterAdded:Connect(bind)
player.CharacterRemoving:Connect(function(old) if character==old then cleanup() end end)
if player.Character then task.spawn(bind,player.Character) end
RunService.RenderStepped:Connect(function(dt)
 local alive=h and h.Health>0 and character==player.Character
 local max=alive and (character:GetAttribute("MaxStamina") or Config.MaxStamina) or Config.MaxStamina
 local stamina=alive and (character:GetAttribute("Stamina") or max) or 0
 local exhausted=alive and character:GetAttribute("SprintExhausted") or false
 local sprinting=alive and character:GetAttribute("Sprinting") or false
 local ratio=max>0 and stamina/max or 0
 displayStamina+=(stamina-displayStamina)*(1-math.exp(-dt*14))
 card.Track.Fill.Size=UDim2.fromScale(math.clamp(displayStamina/max,0,1),1)
 card.StaminaValue.Text=string.format("%d / %d",math.ceil(stamina),max)
 card.Title.Text=exhausted and "EPUISE" or "ENDURANCE"
 card.Hint.Text=exhausted and "RELACHE POUR RECUPERER" or (UserInputService.TouchEnabled and "MAINTENIR SPRINT" or UserInputService.GamepadEnabled and "L3  /  SPRINT" or "MAJ  /  SPRINT")
 local color=(exhausted or ratio<0.25) and Color3.fromRGB(247,156,72) or Color3.fromRGB(91,205,197)
 card.Track.Fill.BackgroundColor3=color card.Bolt.TextColor3=color
 local running=sprinting and alive and h.MoveDirection.Magnitude>0.1 and h.FloorMaterial~=Enum.Material.Air
 if track then
  if running then if not track.IsPlaying then track:Play(0.18) end track:AdjustSpeed(1.45)
  elseif track.IsPlaying then track:Stop(0.18) end
 end
 if footsteps then
  if running then
   if not footsteps.IsPlaying then footsteps:Play() end footsteps.Volume=0.32
  else footsteps.Volume=0 if footsteps.IsPlaying then footsteps:Stop() end end
  -- Avoid layering the default walking loop over the sprint loop.
  local rootPart=character and character:FindFirstChild("HumanoidRootPart")
  local normal=rootPart and rootPart:FindFirstChild("Running")
  if running and normal and normal:IsA("Sound") then normal.Volume=0
  elseif normal and normal:IsA("Sound") then normal.Volume=0.65 end
 end
 if breathing then
  local wanted=alive and ((ratio<0.4 and 0.28 or sprinting and 0.12) or 0) or 0
  breathing.Volume+=(wanted-breathing.Volume)*(1-math.exp(-dt*3))
  if wanted>0 and not breathing.IsPlaying then breathing:Play() end
  if wanted==0 and breathing.Volume<0.005 then breathing:Stop() end
 end
end)
