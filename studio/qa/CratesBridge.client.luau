-- Temporary SessionStudio bridge. Install only in Client PlayerScripts during Play.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local packets={} local state
game.ReplicatedStorage.Remotes.GameState.OnClientEvent:Connect(function(v)
 if v.Kind=="State" then state=v.Data else table.insert(packets,v) end
end)
game.ReplicatedStorage:WaitForChild("CrateQABridge").OnClientInvoke=function(cmd,a,b,c)
 if cmd=="Action" then game.ReplicatedStorage.Remotes.GameAction:FireServer(a,b,c) return true end
 if cmd=="Probe" then local out={Packets=packets,State=state} packets={} return out end
 error("Unknown crate QA command")
end
game.ReplicatedStorage.Remotes.GameAction:FireServer("Sync")
