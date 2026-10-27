-- Temporary SessionStudio bridge and feedback recorder; never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local RS=game.ReplicatedStorage local bridge=RS:WaitForChild("FirearmsQABridge") local feedback={}
RS.Remotes.PunchHit.OnClientEvent:Connect(function(critical,killed,amount,position,kind)
 table.insert(feedback,{Critical=critical,Killed=killed,Amount=amount,Kind=kind or "Body"})
end)
bridge.OnClientInvoke=function(name,direction)
 local remotes=RS.Remotes
 if name=="Probe" then local out=feedback feedback={} return out
 elseif name=="ShootBurst" then for _=1,5 do remotes.Shoot:FireServer(direction) end
 elseif name=="ForgedShoot" then remotes.Shoot:FireServer(direction,999999,true,"Headshot")
 elseif name=="Shoot" or name=="Punch" then remotes[name]:FireServer(direction)
 elseif name=="ReloadGun" then remotes.ReloadGun:FireServer()
 else error("Unknown QA command") end return true
end
