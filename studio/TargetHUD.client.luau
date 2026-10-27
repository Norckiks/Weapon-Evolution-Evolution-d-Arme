local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local CollectionService=game:GetService("CollectionService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui") gui.Name="TargetHUD" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=11 gui.Parent=player:WaitForChild("PlayerGui")
local card=Instance.new("Frame") card.Name="TargetCard" card.AnchorPoint=Vector2.new(.5,0) card.Position=UDim2.fromScale(.5,.62) card.Size=UDim2.fromOffset(220,58) card.BackgroundColor3=Color3.fromRGB(255,244,216) card.BorderSizePixel=0 card.Visible=false card.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,14) corner.Parent=card
local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(38,48,68) stroke.Thickness=2 stroke.Parent=card
local function label(name,y,height,size)
 local t=Instance.new("TextLabel") t.Name=name t.Position=UDim2.fromOffset(10,y) t.Size=UDim2.fromOffset(200,height) t.BackgroundTransparency=1 t.TextColor3=Color3.fromRGB(38,48,68) t.Font=Enum.Font.Cartoon t.TextSize=size t.TextTruncate=Enum.TextTruncate.AtEnd t.Parent=card return t
end
local name=label("EnemyName",3,21,15)
local info=label("HealthAndRange",25,16,11)
local track=Instance.new("Frame") track.Name="Track" track.Position=UDim2.fromOffset(10,46) track.Size=UDim2.fromOffset(200,6) track.BackgroundColor3=Color3.fromRGB(54,62,82) track.BorderSizePixel=0 track.Parent=card corner:Clone().Parent=track
local fill=Instance.new("Frame") fill.Name="Fill" fill.Size=UDim2.fromScale(1,1) fill.BackgroundColor3=Color3.fromRGB(243,117,96) fill.BorderSizePixel=0 fill.Parent=track corner:Clone().Parent=fill
local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.IgnoreWater=true
local elapsed=0 local target local tween local lastHP=-1 local lastMax=-1
RunService.Heartbeat:Connect(function(dt)
 elapsed+=dt if elapsed<.1 then return end elapsed=0
 local camera=workspace.CurrentCamera local char=player.Character local human=char and char:FindFirstChildOfClass("Humanoid")
 if not camera or not human or human.Health<=0 or player:GetAttribute("HasStarted")~=true or player:GetAttribute("GameMenuOpen") or player:GetAttribute("OptionsOpen") then card.Visible=false target=nil return end
 params.FilterDescendantsInstances={char,camera}
 local result=workspace:Raycast(camera.CFrame.Position,camera.CFrame.LookVector*55,params)
 local candidate=result and result.Instance
 while candidate and candidate~=workspace and not (candidate:IsA("Model") and CollectionService:HasTag(candidate,"Zombie")) do candidate=candidate.Parent end
 local h=candidate and candidate~=workspace and candidate:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 then card.Visible=false target=nil return end
 card.Visible=true
 local elite=candidate:GetAttribute("Elite")==true
 card.BackgroundColor3=elite and Color3.fromRGB(255,227,149) or Color3.fromRGB(255,244,216)
 fill.BackgroundColor3=elite and Color3.fromRGB(238,178,59) or Color3.fromRGB(243,117,96)
 name.Text=h.DisplayName~="" and h.DisplayName or candidate.Name
 local root=char:FindFirstChild("HumanoidRootPart")
 local distance=root and (root.Position-result.Position).Magnitude or result.Distance
 info.Text=string.format("%d / %d PV   ·   %d studs",math.ceil(h.Health),math.ceil(h.MaxHealth),math.floor(distance+.5))
 local ratio=h.MaxHealth>0 and math.clamp(h.Health/h.MaxHealth,0,1) or 0
 if target~=candidate or h.Health~=lastHP or h.MaxHealth~=lastMax then
  if tween then tween:Cancel() end
  if target~=candidate then fill.Size=UDim2.fromScale(ratio,1)
  else tween=TweenService:Create(fill,TweenInfo.new(.12),{Size=UDim2.fromScale(ratio,1)}) tween:Play() end
  target=candidate lastHP=h.Health lastMax=h.MaxHealth
 end
end)
