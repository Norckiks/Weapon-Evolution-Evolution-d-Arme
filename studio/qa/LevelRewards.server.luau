-- Temporary SessionStudio test with real client requests and restorable UI fixture.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService)
local E=require(game.ServerScriptService.EconomyService)
local C=require(game.ReplicatedStorage.GameplayConfig)
local bridge=game.ReplicatedStorage:WaitForChild("LevelRewardsQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="LevelRewardsQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function request(verb,id) task.wait(.16) bridge:InvokeClient(p,verb,id) task.wait(.16) end
local function restore()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) E.Refresh(p) E.Send(p)
 return true
end
local ok,err=pcall(function()
 check(typeof(m.LevelRewards)=="table","Legacy profile receives a claim map")
 m.LevelRewards={} m.Receipts.LevelRewardQASentinel=true
 m.CoinBoostUntil=os.time()+600 m.XPBoostUntil=os.time()+600
 p:SetAttribute("HasStarted",true) p.leaderstats.Coins.Value=0 p.leaderstats.Level.Value=1 p.Progress.XP.Value=0 E.Refresh(p)
 request("ClaimLevel","2") check(not m.LevelRewards["2"] and p.leaderstats.Coins.Value==0,"Locked level refused")
 p.leaderstats.Level.Value=2 p:SetAttribute("HasStarted",false)
 request("ClaimLevel","2") check(not m.LevelRewards["2"] and p.leaderstats.Coins.Value==0,"Before Play refused") p:SetAttribute("HasStarted",true)
 request("ClaimLevel","2") check(m.LevelRewards["2"]==true and p.leaderstats.Coins.Value==150 and p.Progress.XP.Value==0,"Exact coins without pet/time multiplier or XP")
 for _,id in {"2","02","2.0","2e0"} do
  request("ClaimLevel",id) check(p.leaderstats.Coins.Value==150 and m.LevelRewards["2"]==true,"Canonical duplicate refused: "..id)
 end
 for _,id in {"0","-2","2.5","999","nan","1e999",string.rep("2",65),{Level=2,Coins=999999},22} do
  request("ClaimLevel",id) check(p.leaderstats.Coins.Value==150,"Invalid claim refused: "..typeof(id).." "..tostring(id))
 end
 p.leaderstats.Level.Value=C.LevelRewardOrder[#C.LevelRewardOrder] local total=150
 for _,level in C.LevelRewardOrder do
  if level==2 then continue end
  request("ClaimLevel",tostring(level)) total+=C.LevelRewards[level]
  check(m.LevelRewards[tostring(level)]==true and p.leaderstats.Coins.Value==total,"Exact one-time reward level "..level)
 end
 task.wait(.16) for _=1,5 do bridge:InvokeClient(p,"ClaimLevel","22") end task.wait(.2)
 check(p.leaderstats.Coins.Value==total,"Repeated burst cannot pay twice")
 local copy=game.HttpService:JSONDecode(game.HttpService:JSONEncode(m))
 check(copy.LevelRewards["22"]==true and copy.Receipts.LevelRewardQASentinel==true,"JSON preserves milestones and existing receipts")
 m.Daily.Day=math.floor(os.time()/86400)-1 E.Send(p)
 check(m.LevelRewards["2"] and m.LevelRewards["22"],"Daily rollover preserves permanent receipts")
 request("ClaimLevel","22") check(p.leaderstats.Coins.Value==total,"Daily rollover cannot replay milestone")
 m.LevelRewards["2"]=nil p.leaderstats.Coins.Value=2000000000
 request("ClaimLevel","2") check(not m.LevelRewards["2"] and p.leaderstats.Coins.Value==2000000000,"Full wallet preserves unclaimed reward")
 p.leaderstats.Coins.Value=2000000000-149
 request("ClaimLevel","2") check(not m.LevelRewards["2"] and p.leaderstats.Coins.Value==2000000000-149,"One coin short of capacity preserves reward")
 p.leaderstats.Coins.Value=2000000000-150
 request("ClaimLevel","2") check(m.LevelRewards["2"]==true and p.leaderstats.Coins.Value==2000000000,"Exact capacity grants entire reward")
 check(C.MonetizationEnabled==false,"Robux remains disabled")
end)
restore()
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil,Restored=true})
local prepare=Instance.new("BindableFunction") prepare.Name="PrepareLevelRewardUI" prepare.Parent=game.ServerStorage
prepare.OnInvoke=function(level)
 assert(ok and (level==1 or C.LevelRewards[level]))
 m.LevelRewards={} p.leaderstats.Level.Value=level p.leaderstats.Coins.Value=500
 p:SetAttribute("HasStarted",true) E.Refresh(p) E.Send(p,nil,"Time") return true
end
local read=Instance.new("BindableFunction") read.Name="ReadLevelRewardQA" read.Parent=game.ServerStorage
read.OnInvoke=function() return game.HttpService:JSONEncode({Coins=p.leaderstats.Coins.Value,Claims=m.LevelRewards}) end
local reset=Instance.new("BindableFunction") reset.Name="RestoreLevelRewardQA" reset.Parent=game.ServerStorage reset.OnInvoke=restore
