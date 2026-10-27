local Players=game:GetService("Players")
local CAS=game:GetService("ContextActionService")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local remote=game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MovementAction")
local Config=require(game.ReplicatedStorage:WaitForChild("MovementConfig"))
local Audio=require(game.ReplicatedStorage:WaitForChild("PresentationConfig")).Audio
local Debris=game:GetService("Debris")
remote.OnClientEvent:Connect(function(kind,character,expires,direction)
 if kind~="VaultAccepted" or character~=player.Character or typeof(expires)~="number" or typeof(direction)~="Vector3" then return end
 local remaining=expires-workspace:GetServerTimeNow()
 if remaining<=0 or remaining>1 or direction~=direction or direction.Magnitude<.9 or direction.Magnitude>1.1 then return end
 local h=character:FindFirstChildOfClass("Humanoid") local root=character:FindFirstChild("HumanoidRootPart")
 if not h or not root or h.Health<=0 or root.Anchored or h.FloorMaterial==Enum.Material.Air then return end
 h:ChangeState(Enum.HumanoidStateType.Freefall)
 root.AssemblyLinearVelocity=direction*Config.VaultForwardSpeed+Vector3.new(0,math.max(root.AssemblyLinearVelocity.Y,Config.VaultUpSpeed),0)
end)
local soundConnections={}
local function sound(character,id,volume,pitch)
 if player:GetAttribute("SFXEnabled")==false then return end
 local root=character:FindFirstChild("HumanoidRootPart") if not root then return end
 local s=Instance.new("Sound") s.Name="MovementFoley" s.SoundId=id s.Volume=volume s.PlaybackSpeed=pitch s.RollOffMaxDistance=35 s.RollOffMinDistance=4 s.SoundGroup=game.SoundService:FindFirstChild("WorldFoley") s.Parent=root s:Play() Debris:AddItem(s,2)
end
local function bindSounds(character)
 for _,connection in soundConnections do connection:Disconnect() end table.clear(soundConnections)
 for _,item in {{"Sliding",Audio.Cloth,.38,.75},{"Vaulting",Audio.Cloth,.3,1.2},{"Crouching",Audio.Cloth,.18,.9}} do
  table.insert(soundConnections,character:GetAttributeChangedSignal(item[1]):Connect(function() if character:GetAttribute(item[1]) then sound(character,item[2],item[3],item[4]) end end))
 end
 local humanoid=character:WaitForChild("Humanoid",10) if not humanoid or character~=player.Character then return end
 table.insert(soundConnections,humanoid.StateChanged:Connect(function(old,new)
  if old==Enum.HumanoidStateType.Freefall and new==Enum.HumanoidStateType.Landed then sound(character,Audio.StepConcrete,.25,.85) end
 end))
end
player.CharacterAdded:Connect(bindSounds) if player.Character then task.spawn(bindSounds,player.Character) end
local function allowed()
 return player:GetAttribute("HasStarted")==true and not player:GetAttribute("GameMenuOpen") and not player:GetAttribute("OptionsOpen") and not UIS:GetFocusedTextBox()
end
local function action(verb)
 return function(_,state)
  if not allowed() then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Begin then remote:FireServer(verb) end
  return Enum.ContextActionResult.Sink
 end
end
local function bindTouchActions()
CAS:BindAction("SurvivalCrouch",action("Crouch"),true,Enum.KeyCode.C,Enum.KeyCode.ButtonR1)
CAS:SetTitle("SurvivalCrouch","GLISSE")
CAS:BindAction("SurvivalVault",action("Vault"),true,Enum.KeyCode.V,Enum.KeyCode.ButtonY)
CAS:SetTitle("SurvivalVault","FRANCHIR")
end
bindTouchActions()
UIS:GetPropertyChangedSignal("TouchEnabled"):Connect(bindTouchActions)
local gui=Instance.new("ScreenGui") gui.Name="MovementHUD" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=12 gui.Parent=player:WaitForChild("PlayerGui")
local label=Instance.new("TextLabel") label.Name="MovementHint" label.AnchorPoint=Vector2.new(.5,1) label.Position=UDim2.new(.5,0,1,-62) label.Size=UDim2.fromOffset(320,24) label.BackgroundColor3=Color3.fromRGB(38,48,68) label.BackgroundTransparency=.15 label.TextColor3=Color3.fromRGB(255,244,216) label.Font=Enum.Font.Cartoon label.TextSize=12 label.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,10) corner.Parent=label
local cameraButton=Instance.new("TextButton") cameraButton.Name="CameraToggle" cameraButton.Size=UDim2.fromOffset(144,44)
cameraButton.BackgroundColor3=Color3.fromRGB(255,200,75) cameraButton.BorderSizePixel=0 cameraButton.Font=Enum.Font.Cartoon cameraButton.TextSize=13 cameraButton.TextColor3=Color3.fromRGB(38,48,68) cameraButton.Parent=gui
local co=Instance.new("UICorner") co.CornerRadius=UDim.new(0,14) co.Parent=cameraButton
local border=Instance.new("UIStroke") border.Color=Color3.fromRGB(38,48,68) border.Thickness=3 border.ApplyStrokeMode=Enum.ApplyStrokeMode.Border border.Parent=cameraButton
label.BackgroundColor3=Color3.fromRGB(255,244,216) label.BackgroundTransparency=0 label.TextColor3=Color3.fromRGB(38,48,68) label.Size=UDim2.fromOffset(320,36)
local lb=border:Clone() lb.Parent=label
local function applyView()
 if player:GetAttribute("ThirdPerson")==true then
  player.CameraMaxZoomDistance=14 player.CameraMinZoomDistance=8 player.CameraMode=Enum.CameraMode.Classic
 else
  player.CameraMinZoomDistance=.5 player.CameraMaxZoomDistance=.5 player.CameraMode=Enum.CameraMode.LockFirstPerson
 end
end
if player:GetAttribute("ThirdPerson")==nil then player:SetAttribute("ThirdPerson",false) end
player:GetAttributeChangedSignal("ThirdPerson"):Connect(applyView)
player.CharacterAdded:Connect(function() task.defer(applyView) end)
local function toggleView()
 if allowed() then player:SetAttribute("ThirdPerson",player:GetAttribute("ThirdPerson")~=true) end
end
cameraButton.Activated:Connect(toggleView)
CAS:BindAction("SurvivalView",function(_,state)
 if state==Enum.UserInputState.Begin then toggleView() end return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.O,Enum.KeyCode.ButtonSelect)
applyView()
local offset=0
RunService:BindToRenderStep("SurvivalMovementPresentation",Enum.RenderPriority.Camera.Value+2,function(dt)
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 local active=allowed() and h and h.Health>0 label.Visible=active==true cameraButton.Visible=active==true
 cameraButton.Text=(player:GetAttribute("ThirdPerson") and "VUE 3E PERSONNE" or "VUE 1RE PERSONNE")..(UIS.TouchEnabled and "" or " [O]")
 if not h then offset=0 return end
 local slide=c:GetAttribute("Sliding")==true local crouch=c:GetAttribute("Crouching")==true local vault=c:GetAttribute("Vaulting")==true
 local target=active and (slide and -.7 or crouch and -.45 or 0) or 0
 offset+=(target-offset)*(1-math.exp(-dt*12))
 local third=active and player:GetAttribute("ThirdPerson")==true
 h.CameraOffset=Vector3.new(third and 1.5 or 0,offset+(third and .25 or 0),0)
 if active then
  local state=slide and "GLISSADE" or crouch and "ACCROUPI" or vault and "FRANCHISSEMENT" or ""
  local root=c:FindFirstChild("HumanoidRootPart")
  local speed=root and Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude or 0
  local phase=state~="" and state or c:GetAttribute("MovementState") or "Repos"
  label.Text=string.upper(phase).."  ·  "..math.floor(speed+.5).." studs/s\n"..(UIS.TouchEnabled and "Glisse + franchissement" or "C : glisse · V : franchir")
 end
 local viewport=workspace.CurrentCamera.ViewportSize
 label.AnchorPoint=Vector2.new(.5,1) label.Position=UDim2.new(.5,0,1,-62) label.Size=UDim2.fromOffset(math.min(320,viewport.X-30),36)
 cameraButton.AnchorPoint=Vector2.zero cameraButton.Position=UDim2.fromOffset(14,20)
 if UIS.TouchEnabled then
  local bottom=80
  for _,name in {"StatusPanel","ActiveBoosts"} do
   local v=player.PlayerGui:FindFirstChild(name,true)
   if v and v.Visible then bottom=math.max(bottom,v.AbsolutePosition.Y+v.AbsoluteSize.Y+8) end
  end
  bottom-=gui.AbsolutePosition.Y
  cameraButton.AnchorPoint=Vector2.zero cameraButton.Position=UDim2.fromOffset(14,bottom)
  label.Visible=active==true and viewport.Y>viewport.X
  label.AnchorPoint=Vector2.zero label.Position=UDim2.fromOffset(168,bottom) label.Size=UDim2.fromOffset(math.max(120,viewport.X-182),44)
 end
end)
