-- Play-only ordinary fixture for client GameAction purchase and catalog states.
assert(game.RunService:IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService) local m=require(game.ServerScriptService.ProgressionService).GetMeta(p)
local original=game.HttpService:JSONEncode(m)
local level,coins=p.leaderstats.Level.Value,p.leaderstats.Coins.Value
local started,menu=p:GetAttribute("HasStarted"),p:GetAttribute("InGameMenu")
local prepare=Instance.new("BindableFunction",game.ServerStorage) prepare.Name="PrepareLMGCatalog"
prepare.OnInvoke=function(l)
 assert(l==34 or l==35) m.Weapons.Marksman=true m.Weapons.LMG=nil m.EquippedWeapon="Marksman"
 p.leaderstats.Level.Value=l p.leaderstats.Coins.Value=60000 p:SetAttribute("HasStarted",true)
 E.Refresh(p) E.Send(p,nil,"Weapons") return true
end
local read=Instance.new("BindableFunction",game.ServerStorage) read.Name="ReadLMGCatalog"
read.OnInvoke=function() return game.HttpService:JSONEncode({Owned=m.Weapons.LMG==true,Equipped=m.EquippedWeapon,Coins=p.leaderstats.Coins.Value}) end
local reset=Instance.new("BindableFunction",game.ServerStorage) reset.Name="RestoreLMGCatalog"
reset.OnInvoke=function()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Level.Value=level p.leaderstats.Coins.Value=coins p:SetAttribute("HasStarted",started) p:SetAttribute("InGameMenu",menu) E.Refresh(p) E.Send(p) return true
end
