-- Temporary SessionStudio test; pure rules + real director payout with a synthetic kill credit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local Q=require(game.ReplicatedStorage.QuickContracts) local W=require(game.ReplicatedStorage.WorldConfig)
local bridge=game.ReplicatedStorage:WaitForChild("LevelRewardsQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="ContractZonesQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={} local metrics={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function xp() local total=p.Progress.XP.Value for lv=1,p.leaderstats.Level.Value-1 do total+=W.RequiredXP(lv) end return total end
local function restore()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) E.Refresh(p) E.Send(p) return true
end
local ok,err=pcall(function()
 for zone,multiplier in Q.ZoneMultipliers do
  for index,d in Q.Definitions do
   local meta={QuickContract={Index=index,Count=0,Seen={}}} local reward
   for i=1,d.Target do reward=Q.OnKill(meta,d.Variety and tostring(i) or "A",zone) if i<d.Target then assert(not reward,"Early payout") end end
   check(reward.Coins==d.Coins*multiplier and reward.XP==d.XP*multiplier and reward.Multiplier==multiplier,"Exact reward "..zone.." / "..index)
   check(meta.QuickContract.Index==index%#Q.Definitions+1 and meta.QuickContract.Count==0 and meta.QuickContract.Multiplier==1,"Cycle advances and resets multiplier "..zone.." / "..index)
  end
 end
 for _,zones in {{"Power","Power","City"},{"City","Power","Power"},{"Lab","Harbor","Power"}} do
  local meta={} local reward for _,zone in zones do reward=Q.OnKill(meta,"A",zone) end
  local factor=zones[1]=="Lab" and 4 or 1
  check(reward.Coins==40*factor and reward.Multiplier==factor,"Mixed zones use lowest contributing tier: "..table.concat(zones,"/"))
 end
 local variety={QuickContract={Index=2,Count=0,Seen={}}}
 Q.OnKill(variety,"A","Power") Q.OnKill(variety,"A","City")
 check(variety.QuickContract.Count==1 and variety.QuickContract.Multiplier==10,"Duplicate species does not lower an unchanged variety objective")
 local reward=Q.OnKill(variety,"B","Power") check(reward.Coins==600 and reward.XP==300,"Distinct high-zone species keep x10")
 local legacy={QuickContract={Index=1,Count=2,Seen={}},Receipts={keep=true}}
 reward=Q.OnKill(legacy,"A","Power") check(reward.Coins==40 and legacy.Receipts.keep,"Old partial contracts conservatively retain base tier")
 local unknown={} Q.OnKill(unknown,"A","Unknown") Q.OnKill(unknown,"A","Power") reward=Q.OnKill(unknown,"A","Power")
 check(reward.Multiplier==1,"Unknown zone defaults to base tier")
 for _,case in {{Value=0/0,Expected=1},{Value=math.huge,Expected=1},{Value="10",Expected=1},{Value=-9,Expected=1},{Value=999,Expected=14},{Value=2.9,Expected=2}} do
  local meta={QuickContract={Index=1,Count=1,Seen={},Multiplier=case.Value}} local s=Q.Ensure(meta)
  check(s.Multiplier==case.Expected,"Saved multiplier bounded: "..tostring(case.Value))
 end
 check(Q.Reward({Index=1,Count=0,Multiplier=10}).Coins==40,"Empty contract preview always shows base reward")
 m.QuickContract={Index=1,Count=2,Seen={},Multiplier=10} m.Receipts.ContractZoneQASentinel=true
 m.Pets={Civilian=1} m.EquippedPet="Civilian" m.CoinBoostUntil=os.time()+600 m.XPBoostUntil=os.time()+600
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=28 p.leaderstats.Coins.Value=0 p.Progress.XP.Value=0 E.Refresh(p)
 task.wait(.17) bridge:InvokeClient(p,"ContractKill","Power") task.wait(.2)
 check(m.QuickContract.Count==2 and p.leaderstats.Coins.Value==0,"Client cannot forge contract kills or tier")
 local target for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")=="Lineman" and v.Humanoid.Health>0 then target=v break end end assert(target)
 local def=W.Zombies.Lineman local baseCoins=math.floor(def.Coins*p:GetAttribute("CoinsMultiplier")) local baseXP=math.floor(def.XP*p:GetAttribute("XPMultiplier"))
 local beforeXP=xp() target.Humanoid:SetAttribute("LastAttacker",p.UserId) target.Humanoid:SetAttribute("LastHitAt",os.clock()) target.Humanoid:TakeDamage(10000) task.wait(.25)
 check(p.leaderstats.Coins.Value==baseCoins+400 and xp()==beforeXP+baseXP+200,"Real director completion pays x10 contract without multiplying it again")
 check(m.QuickContract.Index==2 and m.QuickContract.Count==0 and m.QuickContract.Multiplier==1,"Real completion commits next contract")
 metrics.BaseCoins=baseCoins metrics.BaseXP=baseXP metrics.ContractCoins=400 metrics.ContractXP=200
 m.QuickContract={Index=1,Count=1,Seen={},Multiplier=7} m.Daily.Day=math.floor(os.time()/86400)-1 E.Send(p)
 check(m.QuickContract.Count==1 and m.QuickContract.Multiplier==7,"Daily rollover preserves partial contract tier")
 local copy=game.HttpService:JSONDecode(game.HttpService:JSONEncode(m))
 check(copy.QuickContract.Multiplier==7 and copy.Receipts.ContractZoneQASentinel,"JSON keeps tier and unrelated receipts")
end)
restore() result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Metrics=metrics,Error=not ok and tostring(err) or nil,Restored=true})
local prep=Instance.new("BindableFunction") prep.Name="PrepareContractZoneUI" prep.Parent=game.ServerStorage
prep.OnInvoke=function(multiplier,count)
 m.QuickContract={Index=1,Count=count,Seen={},Multiplier=multiplier} p:SetAttribute("HasStarted",true) E.Send(p,nil,"Missions") return true
end
local reset=Instance.new("BindableFunction") reset.Name="RestoreContractZoneQA" reset.Parent=game.ServerStorage reset.OnInvoke=restore
