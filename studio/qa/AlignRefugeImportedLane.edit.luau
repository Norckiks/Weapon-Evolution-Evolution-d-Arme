-- One-time Edit correction for the imported road offset. Never install at startup or run in Play.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Use the target place in Edit mode")

local source = workspace.ImportedEnvironmentModels.Refuge:FindFirstChild("Refuge_01_Sol_et_place")
local courtyard = workspace:FindFirstChild("RefugeCourtyard")
local path = courtyard and courtyard:FindFirstChild("CentralPath")
local backupName = "BeforeRefugeImportedLaneAlignment_20261029"
assert(source and path and math.abs(path.Position.X) < 0.05, "Refuge lane or central path is missing/moved")
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect before retrying")

local parts = {}
for _, suffix in ipairs({ "concrete", "yellow", "paint" }) do
	local part = source:FindFirstChild("Refuge_01_Sol_et_place_" .. suffix)
	assert(part and part:IsA("MeshPart") and math.abs(part.Position.X - 32) < 0.05, "Unexpected imported lane mesh: " .. suffix)
	assert(not part.CanCollide and not part.CanTouch and not part.CanQuery, "Lane mesh has unexpected interactions: " .. suffix)
	table.insert(parts, part)
end

local backup = Instance.new("Folder")
backup.Name = backupName
for _, part in ipairs(parts) do
	local copy = part:Clone()
	copy.Parent = backup
end
backup.Parent = ServerStorage

for _, part in ipairs(parts) do part.CFrame += Vector3.new(-32, 0, 0) end

local yellow = source:FindFirstChild("Refuge_01_Sol_et_place_yellow")
local nearestPortalInnerEdge = 28 - 12.2 / 2
local portalClearance = nearestPortalInnerEdge - (math.abs(yellow.Position.X) + yellow.Size.X / 2)
for _, part in ipairs(parts) do assert(math.abs(part.Position.X) < 0.05, "Lane mesh did not align to the central path: " .. part.Name) end
assert(portalClearance >= 7.7, "Imported lane markings are too close to portal frames")

return string.format("REFUGE_IMPORTED_LANE_ALIGNED backup=%s parts=%d centerX=0 portalClearance=%.3f", backup.Name, #parts, portalClearance)
