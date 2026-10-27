local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local feedback=game.ReplicatedStorage.Remotes:WaitForChild("ProgressFeedback")
local Service={}
local travelTimes={}
local noticeTimes={}
function Service.CanAccess(player,zone)
 local ls=player:FindFirstChild("leaderstats")
 return player:GetAttribute("ProgressReady")==true and ls and ls:FindFirstChild("Level") and ls.Level.Value>=zone.Level
end
local function teleport(player,position)
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") local r=c and c:FindFirstChild("HumanoidRootPart")
 if not r or not h or h.Health<=0 then return end
 c:PivotTo(CFrame.new(position)) r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero
end
local function deny(player,zone)
 if os.clock()-(noticeTimes[player] or -math.huge)<3 then return end noticeTimes[player]=os.clock()
 feedback:FireClient(player,"Locked",{Name=zone.Name,Level=zone.Level})
end
function Service.Init()
 for _,v in workspace.ProgressionZones:GetDescendants() do
  if v:IsA("ProximityPrompt") and v.Name=="ZoneTravel" then
   v.Triggered:Connect(function(player)
    local c=player.Character local r=c and c:FindFirstChild("HumanoidRootPart")
    if not r or (r.Position-v.Parent.Position).Magnitude>v.MaxActivationDistance+3 then return end
    if os.clock()-(travelTimes[player] or -math.huge)<1 then return end travelTimes[player]=os.clock()
    local id=v.Parent:GetAttribute("Destination")
    if id=="Camp" then teleport(player,Vector3.new(0,5,220)) return end
    for _,zone in Config.Zones do
     if zone.Id==id then
      if Service.CanAccess(player,zone) then teleport(player,zone.Arrival) feedback:FireClient(player,"Zone",{Name=zone.Name})
      else deny(player,zone) end
      break
     end
    end
   end)
  end
 end
 Players.PlayerRemoving:Connect(function(p) travelTimes[p]=nil noticeTimes[p]=nil end)
 task.spawn(function()
  while true do
   for _,player in Players:GetPlayers() do
    local c=player.Character local r=c and c:FindFirstChild("HumanoidRootPart")
    if r then
     local zone=Config.ZoneAt(r.Position)
     if zone and not Service.CanAccess(player,zone) then
      teleport(player,Vector3.new(0,5,220)) deny(player,zone)
      player:SetAttribute("CurrentZone","REFUGE")
     else player:SetAttribute("CurrentZone",zone and zone.Name or "REFUGE") end
     if r.Position.Y<-40 then teleport(player,Vector3.new(0,5,220)) end
    end
   end
   task.wait(0.25)
  end
 end)
end
return Service
