-- Temporary ordinary SessionStudio Script; generic LevelRewards client bridge.
assert(game.RunService:IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local C=require(game.ReplicatedStorage.GameplayConfig) local W=require(game.ReplicatedStorage.WorldConfig) local S=require(game.ReplicatedStorage.SprintConfig)
local bridge=game.ReplicatedStorage:WaitForChild("LevelRewardsQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue",game.ServerStorage) result.Name="PetRanksQAResult" result.Value="Running"
local checks={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function request(verb,id) task.wait(.17) bridge:InvokeClient(p,verb,id) task.wait(.18) end
local function close(a,b) return math.abs(a-b)<.0001 end
local function restore()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) E.Refresh(p) E.Send(p) return true
end
local ok,err=pcall(function()
 m.PetRanks=nil m.Receipts.PetRanksQASentinel=true E.Send(p)
 check(typeof(m.PetRanks)=="table" and m.Receipts.PetRanksQASentinel,"Legacy profile gains ranks without losing receipts")
 m.Pets={} m.Fragments={} m.XPBoostUntil=0 m.CoinBoostUntil=0 m.SpeedLevel=0
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 for _,id in C.PetOrder do
  local d=C.Pets[id] m.Pets[id]=1 m.EquippedPet=id E.Refresh(p)
  check(close(p:GetAttribute("CoinsMultiplier"),1+d.Coins) and close(p:GetAttribute("XPMultiplier"),1+d.XP) and close(p:GetAttribute("BaseWalkSpeed"),S.WalkSpeed*(1+d.Speed)),"Rank zero preserves existing bonuses: "..id)
 end
 m.Pets.RailTitan=2 m.EquippedPet="RailTitan" request("UpgradePet","RailTitan")
 check(m.Pets.RailTitan==2 and not m.PetRanks.RailTitan,"Two copies cannot evolve")
 m.Pets.RailTitan=13 p:SetAttribute("HasStarted",false) request("UpgradePet","RailTitan")
 check(m.Pets.RailTitan==13 and not m.PetRanks.RailTitan,"Evolution before Play refused") p:SetAttribute("HasStarted",true)
 for _,id in {"Unknown","RailTitan:3","",3,{Rank=3}} do request("UpgradePet",id) check(m.Pets.RailTitan==13 and not m.PetRanks.RailTitan,"Forged rank request rejected: "..tostring(id)) end
 m.Pets.Civilian=0 request("UpgradePet","Civilian") check(not m.PetRanks.Civilian,"Unowned pet cannot evolve")
 local remaining={11,7,1}
 for rank=1,3 do
  request("UpgradePet","RailTitan")
  check(m.PetRanks.RailTitan==rank and m.Pets.RailTitan==remaining[rank] and m.EquippedPet=="RailTitan","Rank "..rank.." consumes copies and keeps active pet")
  local factor=1+rank*.15
  check(close(p:GetAttribute("CoinsMultiplier"),1+.9*factor) and close(p:GetAttribute("XPMultiplier"),1+.75*factor) and close(p:GetAttribute("BaseWalkSpeed"),S.WalkSpeed*(1+.1*factor)) and close(p:GetAttribute("SprintWalkSpeed"),S.SprintSpeed*(1+.1*factor)),"Rank "..rank.." applies exact coin/XP/walk/sprint bonuses")
 end
 request("UpgradePet","RailTitan") check(m.PetRanks.RailTitan==3 and m.Pets.RailTitan==1,"Maximum rank cannot consume the last copy")
 m.Pets.RailTitan=13 m.PetRanks.RailTitan=0 task.wait(.17)
 bridge:InvokeClient(p,"UpgradeBurst","RailTitan") task.wait(.18)
 check(m.PetRanks.RailTitan==1 and m.Pets.RailTitan==11,"Simultaneous burst advances once")
 m.Pets.Buddy=3 m.EquippedPet="Buddy" request("UpgradePet","Buddy") check(m.PetRanks.Buddy==1 and m.Pets.Buddy==1,"Buddy duplicates also evolve")
 m.Login={Step=6,Day=math.floor(os.time()/86400)-1} request("ClaimLogin","Daily") check(m.Pets.Buddy==2 and m.PetRanks.Buddy==1,"Calendar copy preserves existing rank")
 m.PetRanks.Civilian=2 m.Pets.Civilian=1 m.Fragments.Civilian=3 request("Fuse","Civilian")
 check(m.Pets.Civilian==2 and m.PetRanks.Civilian==2 and m.Fragments.Civilian==0,"Fragment fusion preserves species rank")
 m.Pets.Civilian=100000 m.Fragments.Civilian=3 request("Fuse","Civilian")
 check(m.Pets.Civilian==100000 and m.Fragments.Civilian==3,"Full inventory cannot waste fragments")
 m.Pets.Buddy=100000 m.Daily.Seconds=1800 m.Daily.Claimed["5"]=nil request("ClaimTime","5")
 check(m.Pets.Buddy==100000 and not m.Daily.Claimed["5"],"Full inventory preserves timed pet gift")
 m.Pets.Buddy=99999 request("ClaimTime","5") check(m.Pets.Buddy==100000 and m.Daily.Claimed["5"] and m.PetRanks.Buddy==1,"Last inventory slot accepts timed gift without resetting rank")
 request("EquipPet","") check(p:GetAttribute("CoinsMultiplier")==1 and p:GetAttribute("XPMultiplier")==1 and p:GetAttribute("BaseWalkSpeed")==S.WalkSpeed,"Unequip removes all rank bonuses")
 m.PetRanks={Civilian=0/0,Runner=math.huge,Brute=-2,Worker=99,Soldier=1.9,Unknown=3} E.Send(p)
 check(m.PetRanks.Civilian==0 and m.PetRanks.Runner==0 and m.PetRanks.Brute==0 and m.PetRanks.Worker==3 and m.PetRanks.Soldier==1 and m.PetRanks.Unknown==nil,"Malformed and unknown saved ranks normalized")
 m.PetRanks.RailTitan=3 m.Pets.RailTitan=1 m.EquippedPet="RailTitan" m.QuickContract={Index=3,Count=0,Seen={}}
 p.leaderstats.Coins.Value=0 p.leaderstats.Level.Value=1 p.Progress.XP.Value=0 E.Refresh(p)
 local target for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")=="Civilian" and v.Humanoid.Health>0 then target=v break end end assert(target)
 target.Humanoid:SetAttribute("LastAttacker",p.UserId) target.Humanoid:SetAttribute("LastHitAt",os.clock()) target.Humanoid:TakeDamage(10000) task.wait(.2)
 check(p.leaderstats.Coins.Value==18 and p.Progress.XP.Value==41,"Real director death uses evolved multipliers and integer rewards")
 m.XPBoostUntil=os.time()+600 m.CoinBoostUntil=os.time()+600 E.Refresh(p)
 check(close(p:GetAttribute("CoinsMultiplier"),2*2.305) and close(p:GetAttribute("XPMultiplier"),2*2.0875),"Time boosts multiply evolved bonuses once")
 m.Daily.Day=math.floor(os.time()/86400)-1 E.Send(p) local copy=game.HttpService:JSONDecode(game.HttpService:JSONEncode(m))
 check(copy.PetRanks.RailTitan==3 and copy.Pets.RailTitan==1 and copy.Receipts.PetRanksQASentinel,"Daily rollover and JSON preserve rank, active copy and unrelated receipts")
 check(C.MonetizationEnabled==false,"Robux stays disabled")
end)
restore() result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Restored=true})
local prepare=Instance.new("BindableFunction",game.ServerStorage) prepare.Name="PreparePetRankUI"
prepare.OnInvoke=function(phase)
 assert(phase=="Ready" or phase=="Locked" or phase=="Max" or phase=="RankOnly")
 m.EquippedPet="" m.Pets.Civilian=phase=="Locked" and 2 or phase=="Max" and 1 or 3
 m.PetRanks.Civilian=phase=="Max" and 3 or phase=="RankOnly" and 1 or 0 m.Fragments.Civilian=6
 p:SetAttribute("HasStarted",true) E.Refresh(p) local page if phase~="RankOnly" then page="Pets" end E.Send(p,nil,page) return true
end
local reset=Instance.new("BindableFunction",game.ServerStorage) reset.Name="RestorePetRanksQA" reset.OnInvoke=restore
