-- Separate from synthetic death QA: real weapon requests damage each new rig.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local m=P.GetMeta(p) local old=game.HttpService:JSONEncode(m) local c=p.Character
local saved={CF=c:GetPivot(),Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),HP=c.Humanoid.Health}
local bridge=game.ReplicatedStorage:WaitForChild("PowerCombatQABridge",10) assert(bridge)
local checks={}
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=28
 m.Weapons.Carbine=true m.EquippedWeapon="Carbine" m.HealthLevel=10 E.Refresh(p) c.Humanoid.Health=300 task.wait(.4)
 for _,id in {"Lineman","SparkRunner","CoilGolem"} do
  local t for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")==id and v.Humanoid.Health>0 then t=v break end end assert(t,id)
  c:PivotTo(CFrame.new(t.HumanoidRootPart.Position+Vector3.new(0,0,24))) task.wait(.15)
  local before=t.Humanoid.Health local ammo=p:GetAttribute("GunAmmo")
  bridge:InvokeClient(p,(t.Torso.Position-c.Head.Position).Unit) task.wait(.3)
  assert(t.Humanoid.Health==before-38 and p:GetAttribute("GunAmmo")==ammo-1,"Real Carbine hit failed: "..id)
  table.insert(checks,"Real Carbine body hit 38 with one bullet: "..id)
 end
end)
table.clear(m) for k,v in game.HttpService:JSONDecode(old) do m[k]=v end
p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
E.Refresh(p) c.Humanoid.Health=math.min(saved.HP,c.Humanoid.MaxHealth) c:PivotTo(saved.CF) E.Send(p)
local result=Instance.new("StringValue") result.Name="PowerCombatQAResult" result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil,Restored=true}) result.Parent=game.ServerStorage
