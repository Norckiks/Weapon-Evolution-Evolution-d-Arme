-- Ordinary temporary Script in Play; pair with IllustratedUI.client.
assert(game.RunService:IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService)
local started,menu=p:GetAttribute("HasStarted"),p:GetAttribute("InGameMenu")
local result=Instance.new("StringValue",game.ServerStorage) result.Name="IllustratedUIResult" result.Value="Running"
local pages={}
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true)
 for _,page in {"Upgrades","Weapons","Pets","Time","Missions","Robux","Options","Crates"} do
  E.Send(p,nil,page) task.wait(.6)
  table.insert(pages,game.ReplicatedStorage.IllustratedUIBridge:InvokeClient(p,page))
 end
end)
p:SetAttribute("HasStarted",started) p:SetAttribute("InGameMenu",menu) E.Send(p)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Pages=pages,Restored=true})
