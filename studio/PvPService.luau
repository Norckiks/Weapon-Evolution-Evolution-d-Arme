local Players=game:GetService("Players")
local Service={}

function Service.Contains(position)
	if typeof(position)~="Vector3" then return false end
	local arena=workspace:FindFirstChild("SurvivorArena")
	local bounds=arena and arena:FindFirstChild("FightBounds")
	if not bounds or not bounds:IsA("BasePart") then return false end
	local point=bounds.CFrame:PointToObjectSpace(position)
	local half=bounds.Size*.5
	return math.abs(point.X)<=half.X and math.abs(point.Y)<=half.Y and math.abs(point.Z)<=half.Z
end

function Service.CanEngage(attackerInArena,targetInArena,attackerOptedIn,targetOptedIn)
	if attackerInArena~=targetInArena then return false end
	return attackerInArena or attackerOptedIn==true and targetOptedIn==true
end

function Service.CanDamage(attacker,target)
	if not attacker or not target or attacker==target or not attacker:IsA("Player") or not target:IsA("Player") then return false end
	if attacker.Parent~=Players or target.Parent~=Players or attacker:GetAttribute("HasStarted")~=true or target:GetAttribute("HasStarted")~=true or attacker:GetAttribute("InGameMenu") or target:GetAttribute("InGameMenu") then return false end
	local a,b=attacker.Character,target.Character
	if not a or not b then return false end
	local ah,bh=a:FindFirstChildOfClass("Humanoid"),b:FindFirstChildOfClass("Humanoid")
	local ar,br=a:FindFirstChild("HumanoidRootPart"),b:FindFirstChild("HumanoidRootPart")
	if not ah or not bh or ah.Health<=0 or bh.Health<=0 or not ar or not br or b:FindFirstChildOfClass("ForceField") or (b:GetAttribute("GuardUntil") or 0)>workspace:GetServerTimeNow() then return false end
	return Service.CanEngage(Service.Contains(ar.Position),Service.Contains(br.Position),attacker:GetAttribute("PvPEnabled"),target:GetAttribute("PvPEnabled"))
end

return Service
