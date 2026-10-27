-- Temporary Studio Play only.
assert(game:GetService("RunService"):IsStudio())
local b=game.ReplicatedStorage:WaitForChild("StaminaUpgradeQABridge",10) assert(b)
b.OnClientInvoke=function(verb,id)
 if verb=="Dash" then game.ReplicatedStorage.Remotes.Dash:FireServer(Vector3.xAxis)
 else game.ReplicatedStorage.Remotes.GameAction:FireServer(verb,id) end
 return true
end
