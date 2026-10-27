-- Temporary Studio Play only. Synthetic kills exercise server callbacks; claims use a client remote.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local X=require(game.ReplicatedStorage.Expeditions) local W=require(game.ReplicatedStorage.WorldConfig)
local bridge=game.ReplicatedStorage:WaitForChild("ExpeditionsQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={CF=p.Character:GetPivot(),Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="ExpeditionsQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={} local totals={Coins=0,XP=0}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function totalXP()
 local n=p.Progress.XP.Value for lv=1,p.leaderstats.Level.Value-1 do n+=W.RequiredXP(lv) end return n
end
local function request(action,key) task.wait(.18) bridge:InvokeClient(p,action,key) task.wait(.16) end
local function claim(zone,step)
 local before,previousXP=p.leaderstats.Coins.Value,totalXP() local reward=X.Reward(zone.Id,step)
 request("Claim",zone.Id..":"..step)
 check(m.Expeditions[zone.Id].Claimed==step and p.leaderstats.Coins.Value==before+reward.Coins and totalXP()==previousXP+reward.XP,"Exact one-time reward "..zone.Id..":"..step)
 totals.Coins+=reward.Coins totals.XP+=reward.XP
 local after=p.leaderstats.Coins.Value request("Claim",zone.Id..":"..step)
 check(p.leaderstats.Coins.Value==after and m.Expeditions[zone.Id].Claimed==step,"Duplicate claim refused "..zone.Id..":"..step)
end
local ok,err=pcall(function()
 local legacy={Weapons={Fists=true},Receipts={existing=true}} X.Ensure(legacy)
 check(legacy.Expeditions.City.Kills==0 and legacy.Receipts.existing and legacy.Weapons.Fists,"Legacy profile adds dossiers without erasing other fields")
 local malformed={Expeditions={City={Kills=0/0,Claimed=math.huge,Seen={Bogus=true,Civilian=true}},FutureZone={Keep=true}}}
 X.Ensure(malformed)
 check(malformed.Expeditions.City.Kills==0 and malformed.Expeditions.City.Claimed==0 and not malformed.Expeditions.City.Seen.Bogus and malformed.Expeditions.FutureZone.Keep,"Malformed counters bounded; unrelated future zone retained")
 m.Expeditions={} m.Pets={Civilian=1} m.EquippedPet="Civilian" m.CoinBoostUntil=os.time()+600 m.XPBoostUntil=os.time()+600
 m.QuickContract={Index=3,Count=0,Seen={}}
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=1 p.leaderstats.Coins.Value=0 p.Progress.XP.Value=0
 p.Character:PivotTo(CFrame.new(0,5,220)) E.Refresh(p) E.Send(p) task.wait(.4)
 request("Claim","City:1") check(m.Expeditions.City.Claimed==0 and p.leaderstats.Coins.Value==0,"Early reward refused")
 request("ForgeKill","Harbor") check(m.Expeditions.Harbor.Kills==0,"Client cannot forge expedition kills")
 local before=m.Expeditions.Factory.Kills E.OnZombieKill(p,"Worker")
 check(m.Expeditions.Factory.Kills==before,"Inaccessible species does not advance dossier")
 local real for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")=="Civilian" and v.Humanoid.Health>0 then real=v break end end assert(real)
 real.Humanoid:SetAttribute("LastAttacker",p.UserId) real.Humanoid:SetAttribute("LastHitAt",os.clock()) real.Humanoid:TakeDamage(1000) task.wait(.2)
 check(m.Expeditions.City.Kills==1 and m.Expeditions.City.Seen.Civilian,"Real director death callback advances correct zone")
 for _=1,5 do E.OnZombieKill(p,"Civilian") end task.wait(.15)
 local coins=p.leaderstats.Coins.Value
 for _,key in {"City:01","City:1.0","City:4","City:2","Unknown:1","City:1:1"} do request("Claim",key) end
 request("Claim",{Zone="City",Coins=999999})
 check(m.Expeditions.City.Claimed==0 and p.leaderstats.Coins.Value==coins,"Malformed, forged and out-of-order claims refused")
 local city=W.Zones[1] claim(city,1)
 coins=p.leaderstats.Coins.Value request("Claim","City:2")
 check(m.Expeditions.City.Claimed==1 and p.leaderstats.Coins.Value==coins,"Species stage requires all three different species")
 E.OnZombieKill(p,"Runner") E.OnZombieKill(p,"Brute") task.wait(.15) claim(city,2)
 for _=1,10 do E.OnZombieKill(p,"Civilian") end task.wait(.15) claim(city,3)
 check(p:GetAttribute("CoinsMultiplier")>2 and p:GetAttribute("XPMultiplier")>2,"Reward checks ran with pet and time boosts active")
 local copy=game.HttpService:JSONDecode(game.HttpService:JSONEncode(m)) X.Ensure(copy)
 check(copy.Expeditions.City.Claimed==3 and copy.Expeditions.City.Kills==18,"JSON round trip preserves progress and claim receipts")
 for _=1,30 do X.OnKill(m,"Civilian") end
 check(m.Expeditions.City.Kills==18 and m.Expeditions.City.Claimed==3,"Completed dossier counters remain bounded")
 m.Daily.Day=math.floor(os.time()/86400)-1 E.Send(p)
 check(m.Expeditions.City.Claimed==3 and m.Expeditions.City.Kills==18,"Daily reset does not reset permanent dossier")
 for index=2,4 do
  local zone=W.Zones[index] p.leaderstats.Level.Value=zone.Level E.Refresh(p)
  for _=1,6 do E.OnZombieKill(p,zone.Types[1]) end task.wait(.15) claim(zone,1)
  E.OnZombieKill(p,zone.Types[2]) E.OnZombieKill(p,zone.Types[3]) task.wait(.15) claim(zone,2)
  for _=1,10 do E.OnZombieKill(p,zone.Types[1]) end task.wait(.15) claim(zone,3)
 end
 local stage=m.Expeditions.Harbor.Claimed m.Expeditions.Harbor.Claimed=0 p.leaderstats.Level.Value=19 coins=p.leaderstats.Coins.Value request("Claim","Harbor:1")
 check(m.Expeditions.Harbor.Claimed==0 and p.leaderstats.Coins.Value==coins,"Claim from locked zone refused even with completed counters") m.Expeditions.Harbor.Claimed=stage
 local count=m.Expeditions.City.Kills E.OnZombieKill(p,"Bogus") check(m.Expeditions.City.Kills==count,"Unknown species rejected")
end)
table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) p.Character:PivotTo(saved.CF) E.Refresh(p) E.Send(p)
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Rewards=totals,Error=not ok and tostring(err) or nil}) script:Destroy()
