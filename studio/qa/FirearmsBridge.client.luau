-- Install only as a temporary LocalScript during Studio Play, before Firearms.server.
-- The test runner creates ReplicatedStorage.FirearmsQABridge (RemoteFunction).
assert(game:GetService("RunService"):IsStudio(), "Studio only")
local RS=game:GetService("ReplicatedStorage")
local bridge=RS:WaitForChild("FirearmsQABridge",10)
assert(bridge,"Create the temporary QA bridge first")
bridge.OnClientInvoke=function(name,direction)
 local remotes=RS.Remotes
 if name=="ShootBurst" then
  for _=1,5 do remotes.Shoot:FireServer(direction) end
 elseif name=="Shoot" or name=="Punch" then
  remotes[name]:FireServer(direction)
 elseif name=="ReloadGun" then
  remotes.ReloadGun:FireServer()
 else error("Invalid QA command") end
 return true
end
