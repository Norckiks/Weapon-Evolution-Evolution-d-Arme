-- Studio-only regression harness. Install temporarily as a Script, never in a live place.
assert(game:GetService("RunService"):IsStudio(),"Studio only")
local Http=game:GetService("HttpService")
local p=game.Players:GetPlayers()[1]
assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio","No live data writes allowed")
local E=require(game.ServerScriptService.EconomyService)
local P=require(game.ServerScriptService.ProgressionService)
local C=require(game.ReplicatedStorage.GameplayConfig)
local m=P.GetMeta(p) assert(m,"Runtime profile missing")
local original=Http:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,CF=p.Character:GetPivot(),Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local report={}
local result=game.ServerStorage:FindFirstChild("ExpansionQAResult") or Instance.new("StringValue") result.Name="ExpansionQAResult" result.Value="Running" result.Parent=game.ServerStorage
local function check(condition,name) assert(condition,name) table.insert(report,name) end
local function call(verb,id) task.wait(0.17) E.Handle(p,verb,tostring(id)) end
local function at(id) p.Character:PivotTo(CFrame.new(C.Shops[id]+Vector3.new(0,4,5))) end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 m.HealthLevel=0 m.SpeedLevel=0 m.Weapons={Fists=true} m.EquippedWeapon="Fists" m.Pets={} m.Fragments={} m.EquippedPet="" m.XPBoostUntil=0 m.CoinBoostUntil=0
 m.Daily={Day=math.floor(os.time()/86400),Seconds=0,Kills=0,Claimed={},Missions={}}
 p.leaderstats.Coins.Value=10000 p.leaderstats.Level.Value=1 p.Progress.XP.Value=0 E.Refresh(p)
 p.Character:PivotTo(CFrame.new(0,4,250))
 p.leaderstats.Coins.Value=0 call("Upgrade","Health") check(m.HealthLevel==0,"Insufficient coins refused away from shop")
 p.leaderstats.Coins.Value=10000 call("Upgrade","Health") check(m.HealthLevel==1 and p.Character.Humanoid.MaxHealth==120 and p.leaderstats.Coins.Value==9900,"Health purchase and price")
 call("Upgrade","Speed") check(m.SpeedLevel==1 and math.abs(p:GetAttribute("BaseWalkSpeed")-(require(game.ReplicatedStorage.SprintConfig).WalkSpeed+.8))<0.001 and p.leaderstats.Coins.Value==9750,"Speed affects walking and sprint")
 call("BuyWeapon","Pipe") check(m.Weapons.Pipe and m.EquippedWeapon=="Pipe" and p.leaderstats.Coins.Value==9600 and p.Character:FindFirstChild("EquippedWeaponVisual"),"Weapon purchase from menu away from shop, equip and model")
 call("BuyWeapon","Pipe") check(p.leaderstats.Coins.Value==9600,"Owned weapon cannot be charged twice")
 call("BuyWeapon","Katana") check(not m.Weapons.Katana and p.leaderstats.Coins.Value==9600,"Weapon level gate")
 call("EquipWeapon","Katana") check(m.EquippedWeapon=="Pipe","Unowned weapon equip refused")
 m.Fragments.Civilian=2 call("Fuse","Civilian") check(not m.Pets.Civilian and m.Fragments.Civilian==2,"Fusion requires three matching fragments")
 m.Fragments.Civilian=3 call("Fuse","Civilian") check(m.Pets.Civilian==1 and m.Fragments.Civilian==0 and m.EquippedPet=="Civilian","Fusion consumes fragments and creates pet")
 call("Fuse","Civilian") check(m.Pets.Civilian==1,"Duplicate fusion request refused")
 local before=p.leaderstats.Coins.Value P.AddRewards(p,100,100,"QA",true)
 check(p.leaderstats.Coins.Value==before+110 and p.leaderstats.Level.Value==2 and p.Progress.XP.Value==25,"Pet coin XP multipliers")
 m.Daily.Seconds=290 call("ClaimTime",1) check(m.XPBoostUntil==0,"Early time claim refused")
 m.Daily.Seconds=300 call("ClaimTime",1) local expiry=m.XPBoostUntil check(expiry>=os.time()+590,"Five minute x2 XP boost")
 call("ClaimTime",1) check(m.XPBoostUntil==expiry,"Time reward cannot be claimed twice")
 call("ClaimTime","01") call("ClaimTime","1.0") check(m.XPBoostUntil==expiry,"Alternate time reward IDs cannot bypass claim history")
 m.Daily.Seconds=1800 call("ClaimTime",5) check(m.Pets.Buddy==1,"Thirty minute free pet")
 call("EquipPet","Buddy") check(math.abs(p:GetAttribute("XPMultiplier")-2.2)<0.001 and math.abs(p:GetAttribute("BaseWalkSpeed")-((require(game.ReplicatedStorage.SprintConfig).WalkSpeed+.8)*1.03))<0.001,"Pet and timed boost compose")
 m.Daily.Kills=10 before=p.leaderstats.Coins.Value call("ClaimMission",1) call("ClaimMission",1) call("ClaimMission","01") check(p.leaderstats.Coins.Value==before+120,"Daily mission claim once including alternate IDs")
 before=p.leaderstats.Coins.Value call("Robux","CoinsSmall") check(p.leaderstats.Coins.Value==before and C.MonetizationEnabled==false,"Robux shop disabled")
 local invoked=false local granted=P.GrantReceipt(p,"qa-receipt",function() invoked=true end) check(not granted and not invoked,"Receipt cannot grant against nonpersistent profile")
 m.Daily.Kills=0
 local expectedKills=0
 for _,id in C.PetOrder do if id~="Buddy" then for _=1,3 do E.OnZombieKill(p,id) expectedKills+=1 end end end
 check(m.Daily.Kills==expectedKills,"All configured zombie types feed daily progression")
 for id,count in m.Fragments do check(C.Pets[id]~=nil and count>=0,"Valid fragment inventory: "..id) end
end)
table.clear(m) for k,v in Http:JSONDecode(original) do m[k]=v end
p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
E.Refresh(p) p.Character.Humanoid.Health=p.Character.Humanoid.MaxHealth p.Character:PivotTo(saved.CF) E.Send(p)
result.Value=Http:JSONEncode({Passed=ok,Checks=report,Error=not ok and tostring(err) or nil})
script:Destroy()
