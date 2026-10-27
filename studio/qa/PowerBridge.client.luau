-- Temporary Studio Play bridge, not a runtime script.
assert(game:GetService("RunService"):IsStudio())
local b=game.ReplicatedStorage:WaitForChild("PowerQABridge",10) assert(b)
b.OnClientInvoke=function(verb,id)
 if verb=="ReadGuide" then
  local g=game.Players.LocalPlayer.PlayerGui:FindFirstChild("ZoneUnlockGuide")
  return g and {Zone=g:GetAttribute("DestinationZone"),Stage=g:GetAttribute("GuidanceStage")}
 end
 game.ReplicatedStorage.Remotes.GameAction:FireServer(verb,id) return true
end
