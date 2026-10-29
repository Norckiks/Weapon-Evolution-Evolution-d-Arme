-- One-time Studio Edit repair after checking the refuge layout. Never install at startup.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
assert(not RunService:IsRunning() and game.PlaceId == 89391796839094, "Run only in the expected Studio Edit place")
local refuge = workspace:WaitForChild("ImportedEnvironmentModels"):WaitForChild("Refuge")
local camp = refuge:WaitForChild("Refuge_04_Vie_du_camp")
local courtyard = workspace:WaitForChild("RefugeCourtyard")
local backup = ServerStorage:WaitForChild("BeforeRefugeCampArenaClearance_20261029")
local center, size = camp:GetBoundingBox()
assert(math.abs(center.X - 160) < 0.1 and math.abs(center.Z - 270) < 0.1, "Unexpected camp position; inspect before rerunning")
assert(size.X > 75 and size.X < 77 and size.Z > 49 and size.Z < 51, "Unexpected camp bounds")

-- Preflight the camp destination and the single bench that currently occupies it.
local targetCamp = Vector3.new(160, center.Y, 280)
local targetBench = Vector3.new(40, 2, 380)
local movingBench = {}
for _, part in ipairs(courtyard:GetChildren()) do
	if part:IsA("BasePart") and ((part.Name == "BenchSeat" and part.Position.X == 160 and part.Position.Z == 295)
		or (part.Name == "BenchBack" and part.Position.X == 160 and part.Position.Z == 296.25)
		or (part.Name == "BenchLeg" and part.Position.Z == 295 and (part.Position.X == 156 or part.Position.X == 164))) then
		table.insert(movingBench, part)
	end
end
assert(#movingBench == 4, "Expected one four-piece bench group")
local function overlaps(ax, az, as, part)
	return math.abs(ax - part.Position.X) < (as.X + part.Size.X) / 2
		and math.abs(az - part.Position.Z) < (as.Z + part.Size.Z) / 2
end
for _, part in ipairs(movingBench) do
	local destination = targetBench + Vector3.new(part.Position.X - 160, part.Position.Y - 2, part.Position.Z - 295)
	for _, root in ipairs({ courtyard, workspace.ImportedEnvironmentModels, workspace.ProgressionZones, workspace.SurvivorArena }) do
		for _, other in ipairs(root:GetDescendants()) do
			if other:IsA("BasePart") and not table.find(movingBench, other) and other.Name ~= "CourtyardGround" then
				assert(not overlaps(destination.X, destination.Z, part.Size, other), "Bench destination blocked by " .. other:GetFullName())
			end
		end
	end
end
for _, root in ipairs({ courtyard, workspace.ImportedEnvironmentModels, workspace.ProgressionZones, workspace.SurvivorArena }) do
	for _, part in ipairs(root:GetDescendants()) do
		if part:IsA("BasePart") and not part:IsDescendantOf(camp) and not table.find(movingBench, part)
			and part.Name ~= "CourtyardGround" and not part.Name:find("Refuge_01_Sol_et_place") then
			assert(not overlaps(targetCamp.X, targetCamp.Z, size, part), "Camp destination blocked by " .. part:GetFullName())
		end
	end
end

local benchOrigin = Vector3.new(160, 2, 295)
for _, part in ipairs(movingBench) do
	part.Position += targetBench - benchOrigin
end
camp:PivotTo(camp:GetPivot() + (targetCamp - center.Position))

local corrected, correctedSize = camp:GetBoundingBox()
assert((corrected.Position - targetCamp).Magnitude < 0.05, "Camp failed to reach destination")
assert(math.abs(corrected.Position.Y - correctedSize.Y / 2) < 0.05, "Camp is not resting on the courtyard ground")
local pvpPath = courtyard:WaitForChild("PVPAccessPath")
local function separated(object, margin)
	local cf, objectSize
	if object:IsA("Model") then cf, objectSize = object:GetBoundingBox() else cf, objectSize = object.CFrame, object.Size end
	local minX, maxX = corrected.Position.X - correctedSize.X / 2, corrected.Position.X + correctedSize.X / 2
	local minZ, maxZ = corrected.Position.Z - correctedSize.Z / 2, corrected.Position.Z + correctedSize.Z / 2
	return maxX + margin <= cf.Position.X - objectSize.X / 2 or minX - margin >= cf.Position.X + objectSize.X / 2
		or maxZ + margin <= cf.Position.Z - objectSize.Z / 2 or minZ - margin >= cf.Position.Z + objectSize.Z / 2
end
assert(separated(pvpPath, 2), "Camp overlaps the PVP access path")
local arena = workspace:WaitForChild("SurvivorArena")
for _, name in ipairs({ "ArenaFloor", "FightBounds" }) do assert(separated(arena:WaitForChild(name), 2), "Camp overlaps PVP " .. name) end
for _, frame in ipairs(refuge:WaitForChild("PortalFrames"):GetChildren()) do
	if frame:IsA("Model") then assert(separated(frame, 1), "Camp overlaps portal " .. frame.Name) end
end
assert(backup:FindFirstChild("Refuge_04_Vie_du_camp"), "Original camp backup is missing")
return "Camp moved clear of PvP and portals; one bench moved; original backup preserved."
