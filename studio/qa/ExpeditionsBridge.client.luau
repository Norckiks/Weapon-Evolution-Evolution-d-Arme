-- Temporary SessionStudio client bridge for real reward-claim requests.
assert(game:GetService("RunService"):IsStudio())
local r=game.ReplicatedStorage:WaitForChild("ExpeditionsQABridge",10) assert(r)
r.OnClientInvoke=function(action,id)
 if action=="Claim" then game.ReplicatedStorage.Remotes.GameAction:FireServer("ClaimExpedition",id)
 elseif action=="ForgeKill" then game.ReplicatedStorage.Remotes.GameAction:FireServer("ExpeditionKill",id)
 else error("Unknown expedition test action") end return true
end
