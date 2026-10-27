-- Temporary SessionStudio test. Reuses LevelRewardsBridge.client's generic GameAction bridge.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local W=require(game.ReplicatedStorage.WorldConfig) local C=require(game.ReplicatedStorage.GameplayConfig)
local bridge=game.ReplicatedStorage:WaitForChild("LevelRewardsQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="FirstDailyHuntQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function request(verb,id) task.wait(.17) bridge:InvokeClient(p,verb,id) task.wait(.18) end
local function xp() local total=p.Progress.XP.Value for lv=1,p.leaderstats.Level.Value-1 do total+=W.RequiredXP(lv) end return total end
local function restore()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) E.Refresh(p) E.Send(p) return true
end
local ok,err=pcall(function()
 check(C.FirstHunt.Coins==100 and C.FirstHunt.XP==50,"Configured reward 100 coins and 50 XP")
 m.Daily.Kills=0 m.Daily.FirstHuntClaimed=nil m.Receipts.FirstHuntQASentinel=true E.Send(p)
 check(m.Daily.FirstHuntClaimed==false and m.Receipts.FirstHuntQASentinel,"Legacy daily field initialized without erasing receipts")
 m.QuickContract={Index=3,Count=0,Seen={}} m.Pets={} m.EquippedPet="" m.XPBoostUntil=0 m.CoinBoostUntil=0
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Coins.Value=0 p.leaderstats.Level.Value=1 p.Progress.XP.Value=0 E.Refresh(p)
 request("ClaimDailyHunt","FirstHunt") check(p.leaderstats.Coins.Value==0 and xp()==0 and not m.Daily.FirstHuntClaimed,"No kill means no reward")
 request("DailyKill","999") check(m.Daily.Kills==0,"Client cannot forge daily kills")
 local target for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")=="Civilian" and v.Humanoid.Health>0 then target=v break end end assert(target)
 target.Humanoid:SetAttribute("LastAttacker",p.UserId) target.Humanoid:SetAttribute("LastHitAt",os.clock()) target.Humanoid:TakeDamage(1000) task.wait(.25)
 check(m.Daily.Kills==1 and p.leaderstats.Coins.Value==8 and xp()==20,"Real director death increments goal without altering base rewards")
 p:SetAttribute("HasStarted",false) request("ClaimDailyHunt","FirstHunt")
 check(not m.Daily.FirstHuntClaimed and p.leaderstats.Coins.Value==8,"Claim before Play refused") p:SetAttribute("HasStarted",true)
 request("ClaimDailyHunt","FirstHunt") check(m.Daily.FirstHuntClaimed and p.leaderstats.Coins.Value==108 and xp()==70,"Claim adds exact 100 coins and 50 XP")
 request("ClaimDailyHunt","FirstHunt") check(p.leaderstats.Coins.Value==108 and xp()==70,"Repeated daily claim refused")
 for _,id in {"","firsthunt","FirstHunt:1",{Kills=99,Coins=99999},1} do
  request("ClaimDailyHunt",id) check(p.leaderstats.Coins.Value==108 and xp()==70,"Invalid ID refused: "..typeof(id).." "..tostring(id))
 end
 m.Daily.FirstHuntClaimed=false m.XPBoostUntil=os.time()+600 m.CoinBoostUntil=os.time()+600 E.Refresh(p)
 p.leaderstats.Coins.Value=2000000000 local beforeXP=xp() request("ClaimDailyHunt","FirstHunt")
 check(not m.Daily.FirstHuntClaimed and p.leaderstats.Coins.Value==2000000000 and xp()==beforeXP,"Full wallet preserves daily claim and XP")
 p.leaderstats.Coins.Value=2000000000-99 request("ClaimDailyHunt","FirstHunt")
 check(not m.Daily.FirstHuntClaimed and p.leaderstats.Coins.Value==2000000000-99,"Insufficient wallet capacity preserves claim")
 p.leaderstats.Coins.Value=2000000000-100 request("ClaimDailyHunt","FirstHunt")
 check(m.Daily.FirstHuntClaimed and p.leaderstats.Coins.Value==2000000000 and xp()==beforeXP+50,"Exact capacity gives full reward; boosts do not multiply it")
 local copy=game.HttpService:JSONDecode(game.HttpService:JSONEncode(m))
 check(copy.Daily.FirstHuntClaimed==true and copy.Receipts.FirstHuntQASentinel,"JSON preserves daily receipt and unrelated receipts")
 m.Daily.Day=math.floor(os.time()/86400)-1 E.Send(p)
 check(m.Daily.Kills==0 and not m.Daily.FirstHuntClaimed and m.Receipts.FirstHuntQASentinel,"UTC day rollover resets hunt only with daily state")
 p.leaderstats.Coins.Value=0 request("ClaimDailyHunt","FirstHunt") check(not m.Daily.FirstHuntClaimed and p.leaderstats.Coins.Value==0,"New day requires another kill")
 E.OnZombieKill(p,"Civilian") beforeXP=xp() request("ClaimDailyHunt","FirstHunt")
 check(m.Daily.FirstHuntClaimed and p.leaderstats.Coins.Value==100 and xp()==beforeXP+50,"New day can pay once after new server kill callback")
 check(C.MonetizationEnabled==false,"Robux remains disabled")
end)
restore() result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil,Restored=true})
local prep=Instance.new("BindableFunction") prep.Name="PrepareFirstHuntUI" prep.Parent=game.ServerStorage
prep.OnInvoke=function(phase)
 m.Daily.Kills=phase=="Locked" and 0 or 1 m.Daily.FirstHuntClaimed=phase=="Claimed"
 p.leaderstats.Coins.Value=phase=="Full" and 2000000000 or 500 p:SetAttribute("HasStarted",true)
 E.Refresh(p) E.Send(p,nil,"Missions") return true
end
local reset=Instance.new("BindableFunction") reset.Name="RestoreFirstHuntQA" reset.Parent=game.ServerStorage reset.OnInvoke=restore
