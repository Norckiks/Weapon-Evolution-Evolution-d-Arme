local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local remote=game.ReplicatedStorage.Remotes:WaitForChild("ProgressFeedback")
local Service={}
local sessions={}
local started=false
local store
if not RunService:IsStudio() then store=DataStoreService:GetDataStore("WeaponEvolution_Progress_v1") end
local token=game.JobId..HttpService:GenerateGUID(false)
local function integer(n,fallback,max)
 if typeof(n)~="number" or n~=n or math.abs(n)==math.huge then return fallback end
 return math.clamp(math.floor(n),0,max)
end
local function stats(player)
 return player:FindFirstChild("leaderstats"),player:FindFirstChild("Progress")
end
local function publish(player)
 local ls,p=stats(player) if not ls or not p then return end
 player:SetAttribute("XPRequired",Config.RequiredXP(ls.Level.Value))
end
local function create(player)
 if sessions[player] then return end
 sessions[player]={loaded=false,loading=true,Meta={}}
 player:SetAttribute("ProgressReady",false)
 local ls=player:FindFirstChild("leaderstats") or Instance.new("Folder")
 ls.Name="leaderstats" ls.Parent=player
 for _,spec in {{"Coins",0},{"Level",1}} do
  if not ls:FindFirstChild(spec[1]) then local v=Instance.new("IntValue") v.Name=spec[1] v.Value=spec[2] v.Parent=ls end
 end
 local p=Instance.new("Folder") p.Name="Progress" p.Parent=player
 local xp=Instance.new("IntValue") xp.Name="XP" xp.Parent=p
 if store then
  local ok,data
  for attempt=1,3 do
   ok,data=pcall(function()
    return store:UpdateAsync("Player_"..player.UserId,function(old)
     old=typeof(old)=="table" and old or {}
     if old.Session and old.Session~=token and (old.LeaseUntil or 0)>os.time() then return nil end
     old.Session=token old.LeaseUntil=os.time()+180 return old
    end)
   end)
   if ok then break end task.wait(attempt)
  end
  if not player.Parent or not sessions[player] then
   if ok and typeof(data)=="table" then
    pcall(function() store:UpdateAsync("Player_"..player.UserId,function(old)
     if typeof(old)=="table" and old.Session==token then old.Session=nil old.LeaseUntil=0 return old end
     return nil
    end) end)
   end
   return
  end
  if ok and typeof(data)=="table" then
   ls.Coins.Value=integer(data.Coins,0,2000000000)
   ls.Level.Value=math.max(1,integer(data.Level,1,100000))
   xp.Value=integer(data.XP,0,2000000000)
   sessions[player].Meta=typeof(data.Meta)=="table" and data.Meta or {}
   while xp.Value>=Config.RequiredXP(ls.Level.Value) do xp.Value-=Config.RequiredXP(ls.Level.Value) ls.Level.Value+=1 end
   sessions[player].loaded=true player:SetAttribute("PersistenceMode","Saved")
  else
   player:SetAttribute("PersistenceMode","Unavailable")
   warn("Progress load unavailable for "..player.UserId.."; session progress will not overwrite stored data")
  end
 else
  player:SetAttribute("PersistenceMode","SessionStudio")
 end
 sessions[player].loading=false
 publish(player)
 ls.Level:GetPropertyChangedSignal("Value"):Connect(function() publish(player) end)
 player:SetAttribute("ProgressReady",true)
end
function Service.Save(player,release)
 local session=sessions[player]
 if not store or not session or not session.loaded then return false end
 if session.saving then
  if not release then return false end
  local deadline=os.clock()+12
  while session.saving and os.clock()<deadline do task.wait(0.1) end
  if session.saving then return false end
 end
 local ls,p=stats(player) if not ls or not p then return false end
 session.saving=true
 local commit=HttpService:GenerateGUID(false)
 local meta=HttpService:JSONDecode(HttpService:JSONEncode(session.Meta))
 local payload={Coins=ls.Coins.Value,Level=ls.Level.Value,XP=p.XP.Value,Meta=meta,CommitTag=commit,Session=not release and token or nil,LeaseUntil=not release and os.time()+180 or 0}
 local ok,result
 for attempt=1,3 do
  ok,result=pcall(function()
   return store:UpdateAsync("Player_"..player.UserId,function(old)
    if typeof(old)~="table" or old.Session~=token then return nil end
    return payload
   end)
  end)
  if ok then break end task.wait(attempt)
 end
 session.saving=false
 if not ok then warn("Progress save failed for "..player.UserId) end
 return ok and typeof(result)=="table" and result.CommitTag==commit
end
function Service.GetMeta(player)
 local s=sessions[player] return s and not s.loading and s.Meta or nil
end
function Service.GrantReceipt(player,purchaseId,grant)
 local s=sessions[player]
 if not s or not s.loaded or s.loading or not player.Parent then return false end
 local meta=s.Meta meta.Receipts=typeof(meta.Receipts)=="table" and meta.Receipts or {}
 if not meta.Receipts[purchaseId] then
  grant() meta.Receipts[purchaseId]=true
 end
 -- Acknowledge the receipt only after benefits AND receipt ID are durable together.
 return Service.Save(player,false)
end
function Service.AddRewards(player,coins,xp,name,eligibleForBoosts)
 if not player.Parent or not player:GetAttribute("ProgressReady") then return false end
 local ls,p=stats(player) if not ls or not p then return false end
 coins=math.max(0,math.floor(coins*(eligibleForBoosts and (player:GetAttribute("CoinsMultiplier") or 1) or 1)))
 xp=math.max(0,math.floor(xp*(eligibleForBoosts and (player:GetAttribute("XPMultiplier") or 1) or 1)))
 ls.Coins.Value=math.min(2000000000,ls.Coins.Value+coins) p.XP.Value+=xp
 local before=ls.Level.Value
 while p.XP.Value>=Config.RequiredXP(ls.Level.Value) do
  p.XP.Value-=Config.RequiredXP(ls.Level.Value) ls.Level.Value+=1
 end
 publish(player)
 remote:FireClient(player,"Reward",{Coins=coins,XP=xp,Name=name,Level=ls.Level.Value,LeveledUp=ls.Level.Value>before})
 return true
end
function Service.Init()
 if started then return end started=true
 Players.PlayerAdded:Connect(function(p) task.spawn(create,p) end)
 Players.PlayerRemoving:Connect(function(p) Service.Save(p,true) sessions[p]=nil end)
 for _,p in Players:GetPlayers() do task.spawn(create,p) end
 task.spawn(function() while true do task.wait(60) for p in sessions do task.spawn(Service.Save,p,false) end end end)
 game:BindToClose(function()
  local pending=0
  for p in sessions do pending+=1 task.spawn(function() Service.Save(p,true) pending-=1 end) end
  local deadline=os.clock()+25 while pending>0 and os.clock()<deadline do task.wait(0.1) end
 end)
end
return Service
