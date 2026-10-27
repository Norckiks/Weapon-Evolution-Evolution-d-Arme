-- Temporary server Script in Studio Play; changes session data and respawns the test character.
assert(game:GetService("RunService"):IsStudio(),"Studio only")
local p=game.Players:GetPlayers()[1]
assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio","SessionStudio required")
local E=require(game.ServerScriptService.EconomyService)
local P=require(game.ServerScriptService.ProgressionService)
local C=require(game.ReplicatedStorage.GameplayConfig)
local Http=game:GetService("HttpService")
local m=P.GetMeta(p) assert(m)
local meta=Http:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,CF=p.Character:GetPivot(),Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Best=p:GetAttribute("BestKillChain") or 0}
local result=Instance.new("StringValue") result.Name="KillChainsQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={}
local function check(value,name) assert(value,name) table.insert(checks,name) end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 m.QuickContract={Index=3,Count=0,Seen={}}
 E.OnZombieKill(p,"Civilian")
 check(p:GetAttribute("KillChain")==1,"First elimination starts a chain")
 local firstDeadline=p:GetAttribute("KillChainUntil")
 check(math.abs(firstDeadline-workspace:GetServerTimeNow()-C.KillChain.Window)<.25,"Eight second server deadline")
 E.OnZombieKill(p,"Unknown") E.OnZombieKill(p,"Buddy")
 check(p:GetAttribute("KillChain")==1,"Unknown species and reward-only Buddy cannot extend a chain")
 task.wait(C.KillChain.Window/2)
 E.OnZombieKill(p,"Runner")
 check(p:GetAttribute("KillChain")==2 and p:GetAttribute("KillChainUntil")>firstDeadline,"Second elimination extends the deadline")
 task.wait(C.KillChain.Window/2+.25)
 check(p:GetAttribute("KillChain")==2,"Old expiration cannot clear a newer chain")
 task.wait(C.KillChain.Window/2+.1)
 check(p:GetAttribute("KillChain")==0 and p:GetAttribute("KillChainUntil")==0,"Idle chain expires and clears deadline")
 check(p:GetAttribute("BestKillChain")>=2,"Session record survives expiry")
 E.OnZombieKill(p,"Civilian")
 check(p:GetAttribute("KillChain")==1,"Next elimination starts at one")
 E.OnZombieKill(p,"Runner")
 local beforeDeath=p:GetAttribute("BestKillChain")
 p.Character.Humanoid.Health=0
 task.wait(.2)
 check(p:GetAttribute("KillChain")==0,"Death immediately clears chain")
 E.OnZombieKill(p,"Civilian")
 check(p:GetAttribute("KillChain")==0,"Posthumous elimination cannot start a chain")
 p:LoadCharacterAsync()
 task.wait(.4)
 check(p:GetAttribute("KillChain")==0 and p:GetAttribute("BestKillChain")==beforeDeath,"Respawn clears chain and retains session record")
end)
table.clear(m) for k,v in Http:JSONDecode(meta) do m[k]=v end
p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) p:SetAttribute("BestKillChain",saved.Best)
if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character:PivotTo(saved.CF) end
E.Refresh(p) E.Send(p)
result.Value=Http:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil})
script:Destroy()
