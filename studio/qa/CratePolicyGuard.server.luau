-- Requires two isolated module fixtures prepared via MCP in Server Play; never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local checks={}
for _,name in {"CratePolicyRestrictedQA","CratePolicyUnknownQA"} do
 local module=game.ServerScriptService[name] local copy=require(module)
 local before=p.leaderstats.Coins.Value copy.Handle(p,"OpenCrate","Salvage")
 assert(p.leaderstats.Coins.Value==before,"Policy guard debited")
 table.insert(checks,name.." denies without debit") module:Destroy() task.wait(.2)
end
require(game.ServerScriptService.EconomyService).Send(p)
local result=Instance.new("StringValue") result.Name="CratePolicyGuardQAResult"
result.Value=game.HttpService:JSONEncode(checks) result.Parent=game.ServerStorage
script:Destroy()
