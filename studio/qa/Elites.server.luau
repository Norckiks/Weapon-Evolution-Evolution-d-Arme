-- Ordinary SessionStudio integration: real director deaths and respawns, no weapon claim.
assert(game.RunService:IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local W=require(game.ReplicatedStorage.WorldConfig) local bridge=game.ReplicatedStorage:WaitForChild("EliteQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),HP=p.Character.Humanoid.Health}
local result=Instance.new("StringValue",game.ServerStorage) result.Name="ElitesQAResult" result.Value="Running"
local checks={} local metrics={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function alive(zone,elite)
 local a={} for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZoneId")==zone and v.Humanoid.Health>0 and (elite==nil or v:GetAttribute("Elite")==elite) then table.insert(a,v) end end return a
end
local function waitUntil(fn,seconds) local finish=os.clock()+seconds repeat local v=fn() if v then return v end task.wait(.15) until os.clock()>finish error("Timed out waiting for real respawn") end
local function credit(target) target.Humanoid:SetAttribute("LastAttacker",p.UserId) target.Humanoid:SetAttribute("LastHitAt",os.clock()) target.Humanoid:TakeDamage(target.Humanoid.MaxHealth+1) task.wait(.08) end
local function xp() local total=p.Progress.XP.Value for lv=1,p.leaderstats.Level.Value-1 do total+=W.RequiredXP(lv) end return total end
local ok,err=pcall(function()
 for id,base in W.Zombies do
  local def=W.ZombieVariant(id,true)
  check(W.ZombieVariant(id,false)==base and def~=base and base.Health==W.Zombies[id].Health,"Normal definition unchanged: "..id)
  check(def.Health==math.floor(base.Health*1.8+.5) and def.Damage==math.floor(base.Damage*1.2+.5) and def.Coins==math.floor(base.Coins*2.5+.5) and def.XP==math.floor(base.XP*2.5+.5) and math.abs(def.Scale/base.Scale-1.1)<.0001,"Elite stats bounded and exact: "..id)
 end
 for _,zone in W.Zones do
  local list=alive(zone.Id) local low=#list==6
  for _,target in list do low=low and target.HumanoidRootPart.Position.Y<15 and W.ZoneAt(target.HumanoidRootPart.Position)==zone end
  check(low,"Six real spawns below roofs in "..zone.Id)
 end
 m.Pets={} m.EquippedPet="" m.CoinBoostUntil=0 m.XPBoostUntil=0 m.HealthLevel=10
 p.leaderstats.Level.Value=35 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) E.Refresh(p) E.Send(p)
 check(#alive("Factory",true)==0,"Factory begins with normal wave")
 for i=1,8 do
  for _,zone in {"City","Factory"} do
   local target=waitUntil(function() return alive(zone,false)[1] end,13) credit(target)
  end
  if i==7 then check(workspace.ProgressionZones.Factory:GetAttribute("EliteProgress")==7 and not workspace.ProgressionZones.Factory:GetAttribute("ElitePending"),"Seven credits do not queue an elite") end
 end
 check(workspace.ProgressionZones.Factory:GetAttribute("ElitePending")==true and workspace.ProgressionZones.Factory:GetAttribute("EliteProgress")==0,"Eighth credited kill queues elite and resets hunt")
 check(#alive("City",true)==0,"Eight city kills never create an elite")
 local elite=waitUntil(function() return alive("Factory",true)[1] end,13)
 local id=elite:GetAttribute("ZombieType") local def=W.ZombieVariant(id,true)
 check(#alive("Factory",true)==1 and #alive("City",true)==0 and not workspace.ProgressionZones.Factory:GetAttribute("ElitePending"),"Next respawn consumes one elite request, City stays normal")
 check(elite.Humanoid.MaxHealth==def.Health and elite:GetAttribute("CoinsReward")==def.Coins and elite:GetAttribute("XPReward")==def.XP and math.abs(elite:GetScale()-def.Scale)<.001,"Spawned elite owns scaled stats and rewards")
 local count,safe=0,true
 for _,v in elite:GetChildren() do if v.Name=="EliteCrown" then count+=1 safe=safe and v.Massless and not v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery end end
 check(count==3 and safe and elite:FindFirstChild("EliteOutline").DepthMode==Enum.HighlightDepthMode.Occluded,"Safe gold crown and occluded outline")
 check(elite.Head.ZombieHealth:FindFirstChild("Name").Text==def.Name and elite.Humanoid.DisplayName==def.Name,"Elite world labels reflect variant")
 local ui=bridge:InvokeClient(p,"Look",elite) check(ui.Visible and ui.Gold and ui.Name==def.Name,"Target card recognizes real elite")
 metrics.Type=id metrics.Health=def.Health metrics.Damage=def.Damage metrics.Coins=def.Coins metrics.XP=def.XP
 local normal=alive("Factory",false)[1] local ui=bridge:InvokeClient(p,"Look",normal)
 check(ui.Visible and not ui.Gold,"Target card resets when looking at normal zombie")
 m.QuickContract={Index=3,Count=0,Seen={}} local coins,experience=p.leaderstats.Coins.Value,xp() local kills=m.Daily.Kills
 credit(elite)
 check(p.leaderstats.Coins.Value==coins+def.Coins and xp()==experience+def.XP,"Real elite death pays exact variant rewards")
 check(m.Daily.Kills==kills+1 and m.QuickContract.Count==1 and m.Expeditions.Factory.Seen[id],"Elite counts once as its original species in missions and contracts")
 elite.Humanoid.Health=0 task.wait(.1) check(p.leaderstats.Coins.Value==coins+def.Coins,"Elite cannot pay twice")
 local progress=workspace.ProgressionZones.Factory:GetAttribute("EliteProgress") normal.Humanoid:SetAttribute("LastAttacker",nil) normal.Humanoid:SetAttribute("LastHitAt",nil) normal.Humanoid:TakeDamage(10000) task.wait(.1)
 check(workspace.ProgressionZones.Factory:GetAttribute("EliteProgress")==progress,"Uncredited death cannot advance elite hunt")
 bridge:InvokeClient(p,"Forge") task.wait(.2) check(not workspace.ProgressionZones.Factory:GetAttribute("ElitePending"),"Client cannot request an elite spawn")
 check(#alive("Factory",true)==0,"Killed elite leaves no duplicate elite")
 check(not require(game.ReplicatedStorage.GameplayConfig).MonetizationEnabled,"Robux remains disabled")
end)
bridge:InvokeClient(p,"Restore") table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
E.Refresh(p) p.Character.Humanoid.Health=math.min(saved.HP,p.Character.Humanoid.MaxHealth) E.Send(p)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Metrics=metrics,Restored=true})
