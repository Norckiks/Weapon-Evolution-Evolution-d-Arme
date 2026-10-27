-- Temporary SessionStudio fixture; invoke RestoreMaximumHUD before stopping.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local c=p.Character local h=c:WaitForChild("Humanoid")
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,CF=c:GetPivot(),Health=h.Health,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local ff=Instance.new("ForceField") ff.Name="MaximumHUDQAForceField" ff.Visible=false ff.Parent=c
local prepare=Instance.new("BindableFunction") prepare.Name="PrepareMaximumHUD" prepare.Parent=game.ServerStorage
prepare.OnInvoke=function(critical)
 m.HealthLevel=10 m.StaminaLevel=5 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 c:PivotTo(CFrame.new(0,5,300)) E.Refresh(p) h.Health=critical and 60 or h.MaxHealth E.Send(p) return true
end
local restore=Instance.new("BindableFunction") restore.Name="RestoreMaximumHUD" restore.Parent=game.ServerStorage
restore.OnInvoke=function()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
 E.Refresh(p) if p.Character==c then c:PivotTo(saved.CF) h.Health=math.min(saved.Health,h.MaxHealth) end ff:Destroy() E.Send(p) return true
end
