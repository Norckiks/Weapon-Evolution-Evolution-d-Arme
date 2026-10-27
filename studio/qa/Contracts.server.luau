assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService)
local P=require(game.ServerScriptService.ProgressionService)
local Q=require(game.ReplicatedStorage.QuickContracts)
local Http=game.HttpService local m=P.GetMeta(p) assert(m)
local saved=Http:JSONEncode(m) local coins,level,xp=p.leaderstats.Coins.Value,p.leaderstats.Level.Value,p.Progress.XP.Value
local checks={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local ok,err=pcall(function()
 m.QuickContract=nil
 E.OnZombieKill(p,"Civilian") E.OnZombieKill(p,"Civilian")
 check(p.leaderstats.Coins.Value==coins and m.QuickContract.Count==2,"No early payout")
 local restored=Http:JSONDecode(Http:JSONEncode(m)) local s=Q.Ensure(restored)
 check(s.Count==2 and s.Index==1,"Partial progress survives serialization")
 E.OnZombieKill(p,"Civilian")
 check(p.leaderstats.Coins.Value==coins+40 and m.QuickContract.Index==2,"First contract awards once and advances")
 E.OnZombieKill(p,"Civilian") E.OnZombieKill(p,"Civilian")
 check(m.QuickContract.Count==1 and p.leaderstats.Coins.Value==coins+40,"Variety requires distinct species")
 E.OnZombieKill(p,"Runner")
 check(p.leaderstats.Coins.Value==coins+100 and m.QuickContract.Index==3,"Variety payout")
 for _=1,7 do E.OnZombieKill(p,"Civilian") end
 check(p.leaderstats.Coins.Value==coins+200 and m.QuickContract.Index==1 and m.QuickContract.Count==0,"Cycle restarts without waiting")
 E.OnZombieKill(p,"Unknown")
 check(m.QuickContract.Count==0,"Unknown zombie cannot progress contracts")
end)
table.clear(m) for k,v in Http:JSONDecode(saved) do m[k]=v end
p.leaderstats.Coins.Value=coins p.leaderstats.Level.Value=level p.Progress.XP.Value=xp E.Refresh(p) E.Send(p)
local result=Instance.new("StringValue") result.Name="ContractsQAResult" result.Value=Http:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil}) result.Parent=game.ServerStorage script:Destroy()
