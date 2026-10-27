-- Temporary Play fixture for HubStatus.client; no production data writes.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService)
local E=require(game.ServerScriptService.EconomyService)
local m=P.GetMeta(p) local old=game.HttpService:JSONEncode(m)
local level=p.leaderstats.Level.Value local started,menu=p:GetAttribute("HasStarted"),p:GetAttribute("InGameMenu")
local b=Instance.new("BindableFunction") b.Name="RestoreHubStatusQA" b.Parent=game.ServerStorage
b.OnInvoke=function()
 table.clear(m) for k,v in game.HttpService:JSONDecode(old) do m[k]=v end
 p.leaderstats.Level.Value=level p:SetAttribute("HasStarted",started) p:SetAttribute("InGameMenu",menu)
 E.Refresh(p) E.Send(p) return true
end
m.LevelRewards={} m.Daily.Seconds=300 m.Daily.Claimed={} m.XPBoostUntil=os.time()+600
p.leaderstats.Level.Value=2 p:SetAttribute("HasStarted",true) E.Refresh(p) E.Send(p,nil,"Time")
