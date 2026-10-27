local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local StarterGui=game:GetService("StarterGui")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local gui=script.Parent
local panel=gui:WaitForChild("StatusPanel")
local health=panel:WaitForChild("HealthCard")
local coins=panel:WaitForChild("CoinsCard")
local fill=health.Track.Fill
local value=health.HealthValue
local scale=panel.UIScale
local coinValue=coins.CoinsValue
local CoinIcon=require(game:GetService("ReplicatedStorage"):WaitForChild("CoinIcon"))
local logo=CoinIcon.create(coins,48)
logo.Position=UDim2.fromOffset(14,9)
local healthConnections={}
local fillTween
local coinTween
local boundCharacter
local function formatNumber(number)
 local text=tostring(math.max(0,math.floor(number)))
 return text:reverse():gsub("(%d%d%d)","%1 "):reverse():gsub("^ ","")
end
local function updateHealth(humanoid,instant)
 local hp=math.max(0,humanoid.Health)
 local max=math.max(0,humanoid.MaxHealth)
 local ratio=max>0 and math.clamp(hp/max,0,1) or 0
 value.Text=string.format("%d / %d",math.ceil(hp),math.ceil(max))
 local color=ratio<=0.25 and Color3.fromRGB(255,72,65) or Color3.fromRGB(233,93,79)
 health.MedicalCross.BackgroundColor3=color
 if fillTween then fillTween:Cancel() end
 if instant or player:GetAttribute("ReducedMotion")==true then fill.Size=UDim2.fromScale(ratio,1)
 else fillTween=TweenService:Create(fill,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.fromScale(ratio,1)}) fillTween:Play() end
 fill.BackgroundColor3=color
 health.Title.Text=hp<=0 and "A TERRE" or ratio<=.25 and "VIE CRITIQUE" or "VIE"
 health.Title.TextColor3=ratio<=.25 and Color3.fromRGB(170,48,55) or Color3.fromRGB(64,137,82)
 value.TextColor3=ratio<=.25 and Color3.fromRGB(170,48,55) or Color3.fromRGB(38,48,68)
end
local function bindCharacter(character)
 boundCharacter=character
 for _,connection in healthConnections do connection:Disconnect() end
 table.clear(healthConnections)
 local humanoid=character:WaitForChild("Humanoid",10)
 if not humanoid or boundCharacter~=character or player.Character~=character then return end
 updateHealth(humanoid,true)
 table.insert(healthConnections,humanoid.HealthChanged:Connect(function() updateHealth(humanoid,false) end))
 table.insert(healthConnections,humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function() updateHealth(humanoid,false) end))
 table.insert(healthConnections,player:GetAttributeChangedSignal("ReducedMotion"):Connect(function() if player:GetAttribute("ReducedMotion")==true then updateHealth(humanoid,true) end end))
end
player.CharacterAdded:Connect(bindCharacter)
player.CharacterRemoving:Connect(function(character)
 if boundCharacter~=character then return end
 boundCharacter=nil
 for _,connection in healthConnections do connection:Disconnect() end
 table.clear(healthConnections)
 if fillTween then fillTween:Cancel() end
 value.Text="0 / 0" fill.Size=UDim2.fromScale(0,1)
end)
if player.Character then task.spawn(bindCharacter,player.Character) end
-- Disable the duplicate built-in health display while retaining our HUD.
task.spawn(function()
 for _=1,8 do
  if pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false) end) then break end
  task.wait(0.5)
 end
end)
local function resize()
 local camera=workspace.CurrentCamera
 if not camera then return end
 local viewport=camera.ViewportSize
 scale.Scale=math.clamp(math.min(viewport.X/1050,viewport.Y/740),UserInputService.TouchEnabled and 0.8 or 0.68,1)
 if UserInputService.TouchEnabled and viewport.X<1000 then
  panel.AnchorPoint=Vector2.zero panel.Position=UDim2.fromOffset(14,88)
 else
  panel.AnchorPoint=Vector2.new(0,1) panel.Position=UDim2.new(0,24,1,-26)
 end
end
local viewportConnection
local function bindCamera()
 if viewportConnection then viewportConnection:Disconnect() end
 local camera=workspace.CurrentCamera
 if camera then viewportConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
 resize()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(resize)
bindCamera()
local stats=player:WaitForChild("leaderstats")
local money=stats:WaitForChild("Coins")
local previous=money.Value
local function updateCoins()
 local current=money.Value
 coinValue.Text=formatNumber(current)
 if coinTween then coinTween:Cancel() end
 coinValue.TextColor3=current>previous and Color3.fromRGB(30,112,68) or Color3.fromRGB(84,55,20)
 coinTween=TweenService:Create(coinValue,TweenInfo.new(0.5),{TextColor3=Color3.fromRGB(84,55,20)})
 coinTween:Play()
 previous=current
end
money:GetPropertyChangedSignal("Value"):Connect(updateCoins)
updateCoins()
