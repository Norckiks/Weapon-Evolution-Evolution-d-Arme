-- Temporary Studio Play test; requires FirearmsQABridge + FirearmsBridge.client.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService) local P=require(game.ServerScriptService.ProgressionService)
local bridge=game.ReplicatedStorage:WaitForChild("FirearmsQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={CF=p.Character:GetPivot(),Level=p.leaderstats.Level.Value,Coins=p.leaderstats.Coins.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="ShotgunKillQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={} local frozen={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=20 p.leaderstats.Coins.Value=20000 p.Progress.XP.Value=0
 m.Pets={} m.EquippedPet="" m.CoinBoostUntil=0 m.XPBoostUntil=0 m.QuickContract={Index=3,Count=0,Seen={}}
 m.Weapons={Fists=true} m.EquippedWeapon="Fists" E.Refresh(p) task.wait(.2) E.Handle(p,"BuyWeapon","Shotgun") task.wait(.2)
 check(p:GetAttribute("EquippedWeapon")=="Shotgun" and p.leaderstats.Coins.Value==8500,"Shotgun bought in test session")
 local target
 for _,v in workspace.LiveZombies:GetChildren() do
  if v:GetAttribute("ZoneId")=="City" and v.Humanoid.Health>0 then
   local r=v.HumanoidRootPart frozen[r]=r.Anchored r.Anchored=true
   if v:GetAttribute("ZombieType")=="Civilian" and not target then target=v end
  end
 end
 assert(target) local aim=target.VisualTorso
 p.Character:PivotTo(CFrame.lookAt(target.HumanoidRootPart.Position+Vector3.new(0,0,7),target.HumanoidRootPart.Position)) task.wait(.5)
 check(p:GetAttribute("CurrentZone")=="VILLE EN RUINE","Shooter remains in authorized City")
 local beforeCoins,beforeXP=p.leaderstats.Coins.Value,p.Progress.XP.Value
 local ammoBefore=p:GetAttribute("GunAmmo")
 bridge:InvokeClient(p,"Shoot",(aim.Position-p.Character.Head.Position).Unit) task.wait(.5)
 check(target.Humanoid.Health==0,"One actual shotgun shot kills real Civilian")
 check(p.leaderstats.Coins.Value==beforeCoins+8 and p.Progress.XP.Value==beforeXP+20,"One death awards exactly 8 coins and 20 XP")
 check(target:GetAttribute("Rewarded")==true and p:GetAttribute("GunAmmo")==ammoBefore-1,"Rewarded once; one shell consumed")

end)
for root,anchored in frozen do if root.Parent then root.Anchored=anchored end end
table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
p.leaderstats.Level.Value=saved.Level p.leaderstats.Coins.Value=saved.Coins p.Progress.XP.Value=saved.XP
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
E.Refresh(p) E.Send(p) p.Character:PivotTo(saved.CF)
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil})
script:Destroy()
