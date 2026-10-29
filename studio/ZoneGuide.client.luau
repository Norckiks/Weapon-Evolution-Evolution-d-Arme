-- Local guidance for newly unlocked expedition zones; level/access authority stays on the server.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local CAS=game:GetService("ContextActionService")
local player=Players.LocalPlayer
local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local level=player:WaitForChild("leaderstats"):WaitForChild("Level")
local gui=Instance.new("ScreenGui") gui.Name="ZoneUnlockGuide" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=16 gui.Parent=player:WaitForChild("PlayerGui")
local ink=Color3.fromRGB(38,48,68) local gold=Color3.fromRGB(255,205,74)
local marker=Instance.new("Frame") marker.Name="DirectionMarker" marker.AnchorPoint=Vector2.new(.5,.5) marker.Size=UDim2.fromOffset(100,74) marker.BackgroundTransparency=1 marker.Visible=false marker.Parent=gui
local function rounded(object,radius)
 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,radius) c.Parent=object
 local s=Instance.new("UIStroke") s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Color=ink s.Thickness=2 s.Parent=object
end
local disc=Instance.new("Frame") disc.Name="ArrowDisc" disc.AnchorPoint=Vector2.new(.5,0) disc.Position=UDim2.fromScale(.5,0) disc.Size=UDim2.fromOffset(46,46) disc.BackgroundColor3=gold disc.BorderSizePixel=0 disc.Parent=marker rounded(disc,23)
local arrow=Instance.new("TextLabel") arrow.Name="Arrow" arrow.BackgroundTransparency=1 arrow.Size=UDim2.fromScale(1,1) arrow.Font=Enum.Font.GothamBlack arrow.Text="▲" arrow.TextSize=32 arrow.TextColor3=ink arrow.Parent=disc
local label=Instance.new("TextLabel") label.Name="Destination" label.Position=UDim2.fromOffset(0,50) label.Size=UDim2.fromOffset(100,24) label.BackgroundColor3=Color3.fromRGB(255,244,216) label.BorderSizePixel=0 label.TextColor3=ink label.Font=Enum.Font.Cartoon label.TextSize=11 label.Parent=marker rounded(label,8)
local pulse=Instance.new("UIScale") pulse.Parent=marker
local world=Instance.new("BillboardGui") world.Name="ZoneUnlockPortalMarker" world.ResetOnSpawn=false world.Size=UDim2.fromOffset(180,76) world.StudsOffsetWorldSpace=Vector3.new(0,7,0) world.AlwaysOnTop=true world.MaxDistance=250 world.Enabled=false world.Parent=player.PlayerGui
local title=Instance.new("TextLabel") title.Name="Title" title.BackgroundColor3=gold title.BorderSizePixel=0 title.Size=UDim2.new(1,0,0,46) title.TextColor3=ink title.TextSize=13 title.Font=Enum.Font.Cartoon title.TextWrapped=true title.Parent=world rounded(title,12)
local down=Instance.new("TextLabel") down.Name="PortalArrow" down.Position=UDim2.fromOffset(0,46) down.Size=UDim2.new(1,0,0,30) down.BackgroundTransparency=1 down.Text="▼" down.TextSize=32 down.TextColor3=gold down.TextStrokeColor3=ink down.TextStrokeTransparency=0 down.Parent=world
local pending,lastLevel
local fields={}
local rectangles={}
local refreshAt=0
local short={City="VILLE",Factory="USINE",Lab="LABO",Harbor="PORT",Power="CENTRALE",Metro="METRO",Quarantine="FOSSE",Dam="BARRAGE",Citadel="CITADELLE"}
local function clear(reason)
 pending=nil marker.Visible=false world.Enabled=false world.Adornee=nil
 gui:SetAttribute("DestinationZone",nil) gui:SetAttribute("TargetPosition",nil) gui:SetAttribute("GuidanceStage",reason or "Idle")
end
local function onLevel()
 if player:GetAttribute("ProgressReady")~=true then lastLevel=nil return end
 local current=level.Value local previous=lastLevel lastLevel=current
 if pending and current<pending.Level then clear("Locked") end
 if not previous or current<=previous then return end
 local newest
 for _,zone in Config.Zones do
  if zone.Level>previous and zone.Level<=current and (not newest or zone.Level>newest.Level) then newest=zone end
 end
 if newest then pending=newest gui:SetAttribute("DestinationZone",newest.Id) gui:SetAttribute("GuidanceStage","Portal") end
end
level.Changed:Connect(onLevel) player:GetAttributeChangedSignal("ProgressReady"):Connect(onLevel) onLevel()
local function shown(object)
 if not object or not object.Parent or not object:IsA("GuiObject") then return false end
 local node=object
 while node and node~=player.PlayerGui do
  if node:IsA("GuiObject") and not node.Visible then return false end
  if node:IsA("LayerCollector") and not node.Enabled then return false end
  node=node.Parent
 end
 return true
end
local function refresh()
 table.clear(fields) table.clear(rectangles)
 local zones=workspace:FindFirstChild("ProgressionZones")
 if zones then
  for _,v in zones:GetDescendants() do
   if v:IsA("ProximityPrompt") and v.Name=="ZoneTravel" and v.Parent:IsA("BasePart") then table.insert(fields,v.Parent) end
  end
 end
 local origin=gui.AbsolutePosition
 local function avoid(v)
  if shown(v) then
   local p=v.AbsolutePosition-origin local s=v.AbsoluteSize
   table.insert(rectangles,{X=p.X-6,Y=p.Y-6,W=s.X+12,H=s.Y+12})
  end
 end
 for _,name in {"StatusPanel","ProgressCard","ProgressToast","HubToast","ActiveBoosts","Ammo","QuickNavigation","QuickContract","MouseUnlockButton","OptionsButton","MovementHint","DashStatus","LevelCelebration","AbilityButton","AbilitySelector","SlamButton","FrostButton","AegisButton","SecondSouffleButton"} do
  avoid(player.PlayerGui:FindFirstChild(name,true))
 end
 local bound=CAS:GetAllBoundActionInfo()
 for _,id in {"FistsPunch","SurvivalSprint","SurvivorFlashlight","SurvivalDash","SurvivalCrouch","SurvivalVault","SurvivalReload"} do
  if player.PlayerGui:FindFirstChild("ContextActionGui") and bound[id] then avoid(CAS:GetButton(id)) end
 end
 avoid(player.PlayerGui:FindFirstChild("JumpButton",true))
end
local function target(root)
 local region=Config.ZoneAt(root.Position)
 if region and region.Id==pending.Id then clear("Arrived") return end
 local returning=region and region.Id~="City"
 local destination=returning and "Camp" or pending.Id
 local best,distance
 for _,field in fields do
  if field.Parent and field:GetAttribute("Destination")==destination then
   local zone=Config.ZoneAt(field.Position)
   if not returning or (zone and zone.Id==region.Id) then
    local d=(field.Position-root.Position).Magnitude
    if not distance or d<distance then best=field distance=d end
   end
  end
 end
 return best,returning
end
local function overlap(point)
 local score=0 local x,y=point.X-50,point.Y-37
 for _,r in rectangles do
  score+=math.max(0,math.min(x+100,r.X+r.W)-math.max(x,r.X))*math.max(0,math.min(y+74,r.Y+r.H)-math.max(y,r.Y))
 end
 return score
end
RunService.RenderStepped:Connect(function()
 if not pending then marker.Visible=false world.Enabled=false return end
 local camera=workspace.CurrentCamera local character=player.Character local root=character and character:FindFirstChild("HumanoidRootPart") local h=character and character:FindFirstChildOfClass("Humanoid")
 local visible=camera and root and h and h.Health>0 and player:GetAttribute("HasStarted")==true and not player:GetAttribute("GameMenuOpen") and not player:GetAttribute("OptionsOpen")
 if not visible then marker.Visible=false world.Enabled=false return end
 local now=os.clock()
 if now>=refreshAt then refreshAt=now+.2 refresh() end
 -- CAS button discovery may yield; a level change can clear the pending guide meanwhile.
 if not pending then marker.Visible=false world.Enabled=false return end
 local field,returning=target(root) if not pending then return end
 if not field then marker.Visible=false world.Enabled=false return end
 gui:SetAttribute("GuidanceStage",returning and "Return" or "Portal")
 gui:SetAttribute("TargetPosition",field.Position)
 label.Text=returning and "REFUGE" or ((short[pending.Id] or "ZONE").." · NIV. "..pending.Level)
 title.Text=(returning and "RETOUR AU REFUGE" or "NOUVELLE ZONE").."\n"..pending.Name.." · NIV. "..pending.Level
 world.Adornee=field world.Enabled=true marker.Visible=true
 local viewport=camera.ViewportSize local center=viewport/2
 local point=camera:WorldToViewportPoint(field.Position+Vector3.new(0,4,0))
 local finite=point.X==point.X and point.Y==point.Y and math.abs(point.X)<1e8 and math.abs(point.Y)<1e8
 local direction
 if finite then
  direction=Vector2.new(point.X-center.X,point.Y-center.Y)
  if point.Z<=0 then direction=-direction end
 else
  local relative=camera.CFrame:PointToObjectSpace(field.Position)
  direction=Vector2.new(relative.X,relative.Z)
 end
 if direction.Magnitude<.001 then direction=Vector2.new(0,1) end
 direction=direction.Unit
 local angle=math.atan2(direction.Y,direction.X)
 local best,bestScore
 local minY=math.min(100,viewport.Y/2)
 for i,offset in {0,.45,-.45,.9,-.9,1.35,-1.35,1.8,-1.8,2.25,-2.25,math.pi} do
  local a=angle+offset
  local pos=center+Vector2.new(math.cos(a)*viewport.X*.34,math.sin(a)*viewport.Y*.28)
  pos=Vector2.new(math.clamp(pos.X,60,math.max(60,viewport.X-60)),math.clamp(pos.Y,minY,math.max(minY,viewport.Y-45)))
  local score=overlap(pos)*1000+i
  if not bestScore or score<bestScore then best=pos bestScore=score end
 end
 marker.Position=UDim2.fromOffset(best.X,best.Y)
 local aim=finite and point.Z>0 and Vector2.new(point.X,point.Y) or center+direction*math.max(viewport.X,viewport.Y)*2
 local delta=aim-(best-Vector2.new(0,14))
 arrow.Rotation=math.deg(math.atan2(delta.Y,delta.X))+90
 pulse.Scale=player:GetAttribute("ReducedMotion") and 1 or 1+math.sin(now*4)*.025
end)
