assert(game:GetService("RunService"):IsStudio())
local b=game.ReplicatedStorage:WaitForChild("PowerCombatQABridge",10) assert(b)
b.OnClientInvoke=function(direction) game.ReplicatedStorage.Remotes.Shoot:FireServer(direction) return true end
