-- One-time Edit repair: keep expedition boards within the imported frame rhythm.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local World = require(game:GetService("ReplicatedStorage"):WaitForChild("WorldConfig"))
assert(game.PlaceId == 89391796839094, "Unexpected place")
assert(not RunService:IsRunning(), "Stop Play before fitting portal boards")

local portals = workspace:WaitForChild("ProgressionZones"):WaitForChild("RefugePortals")
local frames = workspace:WaitForChild("ImportedEnvironmentModels"):WaitForChild("Refuge"):WaitForChild("PortalFrames")
local backupName = "BeforeRefugePortalSignFit_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup exists; inspect before retrying")

local plan, missing = {}, {}
for _, zone in ipairs(World.Zones) do
	local gate = portals:FindFirstChild("Travel_" .. zone.Id)
	local frame = frames:FindFirstChild("PortalFrame_" .. zone.Id)
	assert(gate and frame, "Missing portal or imported frame: " .. zone.Id)
	local sign = gate:FindFirstChild("ZoneSign", true)
	if sign then
		assert(sign:IsA("BasePart") and sign.CanCollide == false, "Unexpected sign physics: " .. zone.Id)
		local label = sign:FindFirstChildWhichIsA("SurfaceGui", true)
		assert(label, "Dynamic sign surface missing: " .. zone.Id)
		table.insert(plan, {zone = zone, gate = gate, sign = sign, width = zone.Id == "City" and 20 or 14})
	else
		local hasFrameLabel = false
		for _, item in ipairs(frame:GetDescendants()) do
			if item:IsA("MeshPart") and string.find(string.lower(item.Name), "label", 1, true) then hasFrameLabel = true end
		end
		assert(hasFrameLabel, "Portal has no dynamic or imported label: " .. zone.Id)
		table.insert(missing, zone.Id)
	end
end
assert(#plan == 16 and #missing == 3, "Unexpected sign inventory")

local backup = Instance.new("Folder")
backup.Name = backupName
for _, item in ipairs(plan) do
	local copy = item.sign:Clone()
	copy.Name = item.gate.Name .. "_ZoneSign"
	copy.Parent = backup
end
backup.Parent = ServerStorage

for _, item in ipairs(plan) do
	item.sign.Size = Vector3.new(item.width, item.sign.Size.Y, item.sign.Size.Z)
end

for _, item in ipairs(plan) do
	assert(item.sign.Size.X == item.width, "Sign width mismatch: " .. item.zone.Id)
	assert(item.sign.CanCollide == false and item.sign.CanQuery == false, "Sign blocks the portal: " .. item.zone.Id)
	assert(item.gate:FindFirstChild("Field", true):FindFirstChild("ZoneTravel"), "Prompt lost: " .. item.zone.Id)
end

local result = Instance.new("StringValue")
result.Name = "RefugePortalSignFitResult"
result.Value = string.format("fitted=%d; city=20; expedition=14; frameLabelOnly=%s; backup=%s", #plan, table.concat(missing, ","), backup.Name)
result.Parent = ServerStorage
return result.Value
