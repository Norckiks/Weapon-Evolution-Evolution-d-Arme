-- Temporary SessionStudio fixture for native portal interactions; restore before Stop.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local c=p.Character local h=c:WaitForChild("Humanoid")
local saved={Level=p.leaderstats.Level.Value,Coins=p.leaderstats.Coins.Value,XP=p.Progress.XP.Value,CF=c:GetPivot(),Health=h.Health,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local protection=Instance.new("ForceField") protection.Name="PortalWalkQATemporary" protection.Visible=false protection.Parent=c
local set=Instance.new("BindableFunction") set.Name="SetPortalWalkLevel" set.Parent=game.ServerStorage
set.OnInvoke=function(level) assert(level==1 or level==5) p.leaderstats.Level.Value=level E.Refresh(p) E.Send(p) return true end
local restore=Instance.new("BindableFunction") restore.Name="RestorePortalWalkQA" restore.Parent=game.ServerStorage
restore.OnInvoke=function()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Level.Value=saved.Level p.leaderstats.Coins.Value=saved.Coins p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) E.Refresh(p)
 if p.Character==c then c:PivotTo(saved.CF) h.Health=math.min(saved.Health,h.MaxHealth) end
 protection:Destroy() E.Send(p) return true
end
