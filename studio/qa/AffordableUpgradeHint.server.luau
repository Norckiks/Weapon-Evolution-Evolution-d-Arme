-- Temporary SessionStudio fixture; invoke RestoreAffordableUpgradeHint before stopping.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Health=p.Character.Humanoid.Health}
local set=Instance.new("BindableFunction") set.Name="SetAffordableUpgradeHint" set.Parent=game.ServerStorage
set.OnInvoke=function(mode)
 m.HealthLevel=0 m.SpeedLevel=0 m.StaminaLevel=0
 if mode=="Low" then p.leaderstats.Coins.Value=99
 elseif mode=="Exact" then p.leaderstats.Coins.Value=100
 elseif mode=="Stamina" then m.HealthLevel=10 m.SpeedLevel=8 p.leaderstats.Coins.Value=250
 elseif mode=="Maxed" then m.HealthLevel=10 m.SpeedLevel=8 m.StaminaLevel=5 p.leaderstats.Coins.Value=100000
 else error("Unknown mode") end
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) E.Refresh(p) E.Send(p)
 return true
end
local restore=Instance.new("BindableFunction") restore.Name="RestoreAffordableUpgradeHint" restore.Parent=game.ServerStorage
restore.OnInvoke=function()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) E.Refresh(p) p.Character.Humanoid.Health=math.min(saved.Health,p.Character.Humanoid.MaxHealth) E.Send(p)
 return true
end
