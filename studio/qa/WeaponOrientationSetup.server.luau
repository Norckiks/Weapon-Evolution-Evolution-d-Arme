-- Temporary SessionStudio fixture. Invoke Restore before stopping Play; never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local m=P.GetMeta(p) local saved=game.HttpService:JSONEncode(m)
local started,menu=p:GetAttribute("HasStarted"),p:GetAttribute("InGameMenu")
local level=p.leaderstats.Level.Value local coins=p.leaderstats.Coins.Value
local bf=Instance.new("BindableFunction") bf.Name="WeaponOrientationControlQA" bf.Parent=game.ServerStorage
bf.OnInvoke=function(id)
 if id=="Restore" then
  table.clear(m) for k,v in game.HttpService:JSONDecode(saved) do m[k]=v end
  p.leaderstats.Level.Value=level p.leaderstats.Coins.Value=coins
  E.Refresh(p) E.Send(p) p:SetAttribute("HasStarted",started) p:SetAttribute("InGameMenu",menu)
  bf:Destroy() script:Destroy() return true
 end
 assert(require(game.ReplicatedStorage.GameplayConfig).Weapons[id])
 m.Weapons[id]=true m.EquippedWeapon=id E.Refresh(p) E.Send(p) return p:GetAttribute("EquippedWeapon")
end
p.leaderstats.Level.Value=20 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
m.Weapons.Pipe=true m.EquippedWeapon="Pipe" E.Refresh(p) E.Send(p)
