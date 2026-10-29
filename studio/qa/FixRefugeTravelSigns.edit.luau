-- One-shot Edit repair; run only after comparing the live refuge with Studio.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local World = require(game:GetService("ReplicatedStorage"):WaitForChild("WorldConfig"))
assert(game.PlaceId == 89391796839094, "Wrong experience")
assert(not RunService:IsRunning(), "Stop Play before repairing refuge signs")

local portals = workspace:WaitForChild("ProgressionZones"):WaitForChild("RefugePortals")
local backupName = "BeforeRefugeTravelSigns_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect it before retrying")
local changed, seen = {}, {}
for _, zone in ipairs(World.Zones) do
	local gate = portals:FindFirstChild("Travel_" .. zone.Id)
	assert(gate, "Missing travel gate: " .. zone.Id)
	local sign = gate:FindFirstChild("ZoneSign", true)
	if sign then
		assert(sign:IsA("BasePart"), "Unexpected sign type: " .. zone.Id)
		local labels = {}
		for _, item in ipairs(sign:GetDescendants()) do
			if item:IsA("TextLabel") then table.insert(labels, item) end
		end
		assert(#labels == 2, "Expected front and back labels: " .. zone.Id)
		local expected = zone.Name .. "\nNIVEAU " .. zone.Level
		local needsFix = sign.Size.X > 22
		if zone.Id ~= "City" then
			for _, label in ipairs(labels) do
				if label.Text ~= expected then needsFix = true end
			end
		end
		if needsFix then
			table.insert(changed, { sign = sign, labels = labels, text = expected })
		end
		table.insert(seen, zone.Id)
	end
end
assert(#seen == 16 and #changed == 13, "Unexpected refuge sign inventory; inspect before changing")

local backup = Instance.new("Folder")
backup.Name = backupName
for _, item in ipairs(changed) do
	local copy = item.sign:Clone()
	copy.Name = item.sign.Parent.Name .. "_ZoneSign"
	copy.Parent = backup
end
backup.Parent = ServerStorage

for _, item in ipairs(changed) do
	item.sign.Size = Vector3.new(22, 2.8, 0.5)
	for _, label in ipairs(item.labels) do label.Text = item.text end
end

for _, item in ipairs(changed) do
	assert(item.sign.Size.X <= 22, "Portal sign still spans neighboring columns")
	for _, label in ipairs(item.labels) do assert(label.Text == item.text, "Portal label mismatch") end
end

local result = Instance.new("StringValue")
result.Name = "RefugeTravelSignsFixResult"
result.Value = string.format("changed=%d; backedUp=%s; signs=%d", #changed, backup.Name, #seen)
result.Parent = ServerStorage
return result.Value
