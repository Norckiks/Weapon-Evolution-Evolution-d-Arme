-- Temporary SessionStudio integration; real NPC deaths attributed by the fixture, not attacks.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService) local W=require(game.ReplicatedStorage.WorldConfig)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Health=p.Character.Humanoid.Health}
local result=Instance.new("StringValue") result.Name="CityContractPacingQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks,metrics={},{} local function check(v,name) assert(v,name) table.insert(checks,name) end
local function xp() local total=p.Progress.XP.Value for lv=1,p.leaderstats.Level.Value-1 do total+=W.RequiredXP(lv) end return total end
local function living()
 local a={} for _,v in workspace.LiveZombies:GetChildren() do local h=v:FindFirstChildOfClass("Humanoid") if v:GetAttribute("ZoneId")=="City" and h and h.Health>0 then table.insert(a,v) end end return a
end
local ok,err=pcall(function()
 m.QuickContract={Index=3,Count=0,Seen={},Multiplier=1} m.Pets={} m.EquippedPet="" m.CoinBoostUntil=0 m.XPBoostUntil=0
 p.leaderstats.Level.Value=1 p.Progress.XP.Value=0 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) E.Refresh(p)
 local initialCoins,initialXP=p.leaderstats.Coins.Value,xp() local coins,xpReward=0,0
 local deadline=os.clock()+10 repeat if #living()==6 then break end task.wait(.05) until os.clock()>deadline
 check(#living()==6,"City keeps six simultaneous zombies")
 for i=1,7 do
  local target local endAt=os.clock()+9 repeat target=living()[1] if target then break end task.wait(.05) until os.clock()>endAt
  assert(target,"No City respawn for seventh kill")
  coins+=target:GetAttribute("CoinsReward") xpReward+=target:GetAttribute("XPReward")
  local h=target.Humanoid h:SetAttribute("LastAttacker",p.UserId) h:SetAttribute("LastHitAt",os.clock()) h:TakeDamage(h.MaxHealth+1) task.wait(.12)
  if i==6 then check(m.QuickContract.Index==3 and m.QuickContract.Count==6,"Six kills preserve partial contract") end
 end
 check(m.QuickContract.Index==1 and m.QuickContract.Count==0,"Seventh credited death completes existing contract")
 check(p.leaderstats.Coins.Value==initialCoins+coins+100 and xp()==initialXP+xpReward+60,"Zombie and contract rewards remain exact")
 metrics={ZombieCoins=coins,ZombieXP=xpReward,ContractCoins=100,ContractXP=60}
end)
table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
E.Refresh(p) p.Character.Humanoid.Health=math.min(saved.Health,p.Character.Humanoid.MaxHealth) E.Send(p)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Metrics=metrics,Restored=true})
