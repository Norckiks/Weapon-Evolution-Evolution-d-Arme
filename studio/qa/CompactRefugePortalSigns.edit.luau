-- One-shot Edit repair; compact visual signs and keep them out of collision/raycast results.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
assert(game.PlaceId == 89391796839094, "Wrong experience")
assert(not RunService:IsRunning(), "Stop Play before compacting refuge signs")

local portals = workspace:WaitForChild("ProgressionZones"):WaitForChild("RefugePortals")
local backupName = "BeforeRefugeSignClearance_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect before retrying")
local expected = {
	City = Vector3.new(0, 4.5, 208),
	Factory = Vector3.new(-80, 4.5, 260), Lab = Vector3.new(-52, 4.5, 260),
	Harbor = Vector3.new(-28, 4.5, 260), Power = Vector3.new(28, 4.5, 260), Metro = Vector3.new(52, 4.5, 260), Quarantine = Vector3.new(80, 4.5, 260),
	Dam = Vector3.new(-80, 4.5, 305), Citadel = Vector3.new(-52, 4.5, 305), Crater = Vector3.new(-28, 4.5, 305),
	GlassSea = Vector3.new(28, 4.5, 305), Skyline = Vector3.new(52, 4.5, 305), OrbitalWreck = Vector3.new(80, 4.5, 305),
	Depths = Vector3.new(-80, 4.5, 350), IronSanctum = Vector3.new(-52, 4.5, 350), LastConvoy = Vector3.new(-28, 4.5, 350),
	Gridfall = Vector3.new(28, 4.5, 350), BlackoutCore = Vector3.new(52, 4.5, 350), EclipseVault = Vector3.new(80, 4.5, 350),
}
local changes, prompts, counts = {}, {}, {}
for id, position in pairs(expected) do
	local gate = portals:FindFirstChild("Travel_" .. id)
	assert(gate and gate:IsA("Model"), "Missing travel gate: " .. id)
	local field = gate:FindFirstChild("Field", true)
	local prompt = field and field:FindFirstChild("ZoneTravel")
	assert(field and field:IsA("BasePart") and prompt and prompt:IsA("ProximityPrompt"), "Missing travel field/prompt: " .. id)
	assert((field.Position - position).Magnitude < 0.05, "Portal layout changed: " .. id)
	table.insert(prompts, { instance = prompt, hold = prompt.HoldDuration, distance = prompt.MaxActivationDistance, action = prompt.ActionText, object = prompt.ObjectText })
	local sign = gate:FindFirstChild("ZoneSign", true)
	if sign then
		assert(sign:IsA("BasePart"), "Unexpected sign type: " .. id)
		assert(sign.Size.X == 15 or sign.Size.X == 22, "Unexpected sign width: " .. id)
		local labels = {}
		for _, item in ipairs(sign:GetDescendants()) do if item:IsA("TextLabel") then table.insert(labels, item) end end
		assert(#labels == 2, "Expected front/back text: " .. id)
		counts[sign.Size.X] = (counts[sign.Size.X] or 0) + 1
		table.insert(changes, { id = id, gate = gate, sign = sign, field = field, position = sign.Position, labels = labels, texts = { labels[1].Text, labels[2].Text } })
	end
end
assert(#changes == 16 and #prompts == 19 and counts[15] == 3 and counts[22] == 13, "Unexpected portal sign inventory")

local backup = Instance.new("Folder")
backup.Name = backupName
for _, item in ipairs(changes) do
	local copy = item.sign:Clone()
	copy.Name = item.gate.Name .. "_ZoneSign"
	copy.Parent = backup
end
backup.Parent = ServerStorage

for _, item in ipairs(changes) do
	item.sign.Size = Vector3.new(18, item.sign.Size.Y, item.sign.Size.Z)
	item.sign.CanCollide, item.sign.CanTouch, item.sign.CanQuery = false, false, false
end

local rowSigns = {}
for _, item in ipairs(changes) do
	local z = item.field.Position.Z
	if z > 230 then
		rowSigns[z] = rowSigns[z] or {}
		table.insert(rowSigns[z], item)
	end
	assert((item.sign.Position - item.position).Magnitude < 0.001, "Sign moved: " .. item.id)
	assert(item.sign.Size.X == 18 and not item.sign.CanCollide and not item.sign.CanTouch and not item.sign.CanQuery, "Sign still blocks gameplay queries: " .. item.id)
	for index, label in ipairs(item.labels) do assert(label.Text == item.texts[index], "Sign text changed: " .. item.id) end
end
for z, row in pairs(rowSigns) do
	for i = 1, #row do
		for j = i + 1, #row do
			local gap = math.abs(row[i].sign.Position.X - row[j].sign.Position.X) - (row[i].sign.Size.X + row[j].sign.Size.X) / 2
			assert(gap >= 5.99, string.format("Portal signs overlap or are too close in row %.0f", z))
		end
	end
end
for _, item in ipairs(prompts) do
	local prompt = item.instance
	assert(prompt.HoldDuration == item.hold and prompt.MaxActivationDistance == item.distance and prompt.ActionText == item.action and prompt.ObjectText == item.object, "Portal prompt changed")
end
return string.format("signs=16;wideBefore=13;smallBefore=3;newWidth=18;minGap>=6;nonblocking=16/16;prompts=19;backup=%s", backup.Name)
