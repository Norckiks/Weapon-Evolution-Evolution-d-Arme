-- Temporary Play bridge; send the burst in one client callback.
assert(game.RunService:IsStudio())
local bridge=game.ReplicatedStorage:WaitForChild("LevelRewardsQABridge",10) assert(bridge)
bridge.OnClientInvoke=function(verb,id)
 if verb=="UpgradeBurst" then
  for _=1,5 do game.ReplicatedStorage.Remotes.GameAction:FireServer("UpgradePet",id) end
 else game.ReplicatedStorage.Remotes.GameAction:FireServer(verb,id) end
 return true
end
