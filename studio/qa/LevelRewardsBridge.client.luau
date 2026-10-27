-- Temporary Play test bridge; never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local bridge=game.ReplicatedStorage:WaitForChild("LevelRewardsQABridge",10) assert(bridge)
bridge.OnClientInvoke=function(verb,id)
 game.ReplicatedStorage.Remotes.GameAction:FireServer(verb,id)
 return true
end
