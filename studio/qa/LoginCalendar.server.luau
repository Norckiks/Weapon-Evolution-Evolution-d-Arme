-- Temporary SessionStudio Script; uses LevelRewardsQABridge and its client.
assert(game.RunService:IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService) local P=require(game.ServerScriptService.ProgressionService)
local C=require(game.ReplicatedStorage.GameplayConfig) local W=require(game.ReplicatedStorage.WorldConfig)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local bridge=game.ReplicatedStorage:WaitForChild("LevelRewardsQABridge",10) assert(bridge)
local result=Instance.new("StringValue",game.ServerStorage) result.Name="LoginCalendarResult" result.Value="Running"
local checks={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function request(id) task.wait(.17) bridge:InvokeClient(p,"ClaimLogin",id) task.wait(.18) end
local function xp() local total=p.Progress.XP.Value for lv=1,p.leaderstats.Level.Value-1 do total+=W.RequiredXP(lv) end return total end
local today=math.floor(os.time()/86400)
local function restore()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) E.Refresh(p) E.Send(p) return true
end
local ok,err=pcall(function()
 m.Login=nil m.Receipts.LoginQASentinel=true E.Send(p)
 check(m.Login.Step==0 and m.Login.Day==0 and m.Receipts.LoginQASentinel,"Legacy profile initialized without receipt loss")
 p.leaderstats.Coins.Value=0 p.leaderstats.Level.Value=1 p.Progress.XP.Value=0
 p:SetAttribute("HasStarted",false) request("Daily") check(m.Login.Step==0 and p.leaderstats.Coins.Value==0,"Claim before Play refused")
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 for _,id in {"", "daily", "Daily:7", "7", 7, {Amount=999999}} do request(id) check(m.Login.Step==0 and p.leaderstats.Coins.Value==0,"Forged identifier refused: "..tostring(id)) end
 m.Pets={} m.EquippedPet="" m.XPBoostUntil=os.time()+120 m.CoinBoostUntil=os.time()+120 E.Refresh(p)
 for i,reward in C.LoginRewards do
  m.Login={Step=i-1,Day=today-1} local coins,experience=p.leaderstats.Coins.Value,xp()
  local xpUntil,coinUntil=m.XPBoostUntil,m.CoinBoostUntil local pets=m.Pets.Buddy or 0
  request("Daily")
  check(m.Login.Day==today and m.Login.Step==i%7,"Day "..i.." advances one step")
  if reward.Kind=="Coins" then check(p.leaderstats.Coins.Value==coins+reward.Amount,"Day "..i.." fixed coins ignore boosts")
  elseif reward.Kind=="XP" then check(xp()==experience+reward.Amount,"Day "..i.." fixed XP ignores boosts")
  elseif reward.Kind=="XPBoost" then check(m.XPBoostUntil==xpUntil+600,"XP boost extends existing expiry")
  elseif reward.Kind=="CoinBoost" then check(m.CoinBoostUntil==coinUntil+600,"Coin boost extends existing expiry")
  else check(m.Pets.Buddy==pets+1 and m.EquippedPet=="Buddy","Permanent Buddy granted and equipped when empty") end
  local step,claimDay=m.Login.Step,m.Login.Day local buddy=m.Pets.Buddy
  xpUntil,coinUntil=m.XPBoostUntil,m.CoinBoostUntil coins=p.leaderstats.Coins.Value experience=xp()
  request("Daily") check(m.Login.Step==step and m.Login.Day==claimDay and m.Pets.Buddy==buddy and m.XPBoostUntil==xpUntil and m.CoinBoostUntil==coinUntil and p.leaderstats.Coins.Value==coins and xp()==experience,"Day "..i.." duplicate pays nothing")
 end
 check(m.Login.Step==0,"Seventh claim restarts cycle")
 m.Login={Step=0,Day=today-1} p.leaderstats.Coins.Value=2000000000
 request("Daily") check(m.Login.Day==today-1 and m.Login.Step==0 and p.leaderstats.Coins.Value==2000000000,"Full wallet preserves claim")
 p.leaderstats.Coins.Value=2000000000-199 request("Daily") check(m.Login.Day==today-1,"Partial capacity cannot consume reward")
 p.leaderstats.Coins.Value=2000000000-200 request("Daily") check(m.Login.Day==today and p.leaderstats.Coins.Value==2000000000,"Exact capacity pays full amount")
 m.Login={Step=6,Day=today-1} m.Pets.Buddy=100000 request("Daily")
 check(m.Login.Step==6 and m.Login.Day==today-1 and m.Pets.Buddy==100000,"Full pet inventory preserves claim")
 m.Pets.Buddy=99999 request("Daily") check(m.Pets.Buddy==100000 and m.Login.Step==0,"Last pet slot accepted")
 m.Login={Step=4,Day=today-14} p.leaderstats.Coins.Value=0 request("Daily")
 check(m.Login.Step==5 and p.leaderstats.Coins.Value==1000,"Missed days preserve progress without granting skipped gifts")
 m.Login={Step=2,Day=today+1} request("Daily") check(m.Login.Step==2 and m.Login.Day==today+1,"Future timestamp cannot double claim")
 m.Login={Step=3,Day=today} m.Daily.Day=today-1 E.Send(p)
 check(m.Daily.Day==today and m.Login.Step==3 and m.Login.Day==today,"Daily reset preserves calendar progress")
 local copy=game.HttpService:JSONDecode(game.HttpService:JSONEncode(m))
 check(copy.Login.Step==3 and copy.Login.Day==today and copy.Receipts.LoginQASentinel,"JSON round trip preserves calendar and receipts")
 m.Login={Step=0/0,Day="bad"} E.Send(p) check(m.Login.Step==0 and m.Login.Day==0,"Malformed fields normalized")
 check(not C.MonetizationEnabled,"Robux stays disabled")
end)
restore() result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Restored=true})
local prepare=Instance.new("BindableFunction",game.ServerStorage) prepare.Name="PrepareLoginCalendarUI"
prepare.OnInvoke=function(phase)
 assert(phase=="Ready" or phase=="Claimed" or phase=="Full")
 m.Login={Step=phase=="Claimed" and 1 or 0,Day=phase=="Claimed" and today or today-1}
 p.leaderstats.Coins.Value=phase=="Full" and 2000000000 or 500 p:SetAttribute("HasStarted",true) E.Refresh(p) E.Send(p,nil,"Time") return true
end
local reset=Instance.new("BindableFunction",game.ServerStorage) reset.Name="RestoreLoginCalendarQA" reset.OnInvoke=restore
