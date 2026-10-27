assert(game:GetService("RunService"):IsStudio(),"Studio only")
local bridge=game.ReplicatedStorage:WaitForChild("TerrainMovementQABridge",10) assert(bridge)
bridge.OnClientInvoke=function(action)
 if action=="Vault" then game.ReplicatedStorage.Remotes.MovementAction:FireServer("Vault")
 elseif action=="StopSprint" then game.ReplicatedStorage.Remotes.Sprint:FireServer(false)
 else error("Unknown terrain QA action") end
 return true
end
