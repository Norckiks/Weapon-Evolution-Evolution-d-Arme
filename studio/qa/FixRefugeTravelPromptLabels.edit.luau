-- One-shot Edit repair; prompt names come from the active WorldConfig.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local World = require(game:GetService("ReplicatedStorage"):WaitForChild("WorldConfig"))
assert(game.PlaceId == 89391796839094, "Unexpected place")
assert(not RunService:IsRunning(), "Stop Play before changing portal prompt labels")

local gates = workspace:WaitForChild("ProgressionZones"):WaitForChild("RefugePortals")
local backupName = "BeforeRefugeTravelPromptLabels_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect before rerunning")
local plan = {}
for _, zone in ipairs(World.Zones) do
	local gate = gates:FindFirstChild("Travel_" .. zone.Id)
	assert(gate, "Missing gate: " .. zone.Id)
	local field = gate:FindFirstChild("Field", true)
	local prompt = field and field:FindFirstChild("ZoneTravel")
	assert(prompt and prompt:IsA("ProximityPrompt"), "Missing travel prompt: " .. zone.Id)
	table.insert(plan, { zone = zone, prompt = prompt, text = zone.Name .. " - NIV. " .. zone.Level })
end
assert(#plan == 19, "Expected 19 configured destinations")

local backup = Instance.new("Folder")
backup.Name = backupName
for _, item in ipairs(plan) do
	local copy = item.prompt:Clone()
	copy.Name = item.zone.Id .. "_ZoneTravel"
	copy:SetAttribute("OriginalObjectText", item.prompt.ObjectText)
	copy.Parent = backup
end
backup.Parent = ServerStorage

for _, item in ipairs(plan) do item.prompt.ObjectText = item.text end
for _, item in ipairs(plan) do
	assert(item.prompt.ObjectText == item.text, "Prompt label mismatch: " .. item.zone.Id)
end

local result = Instance.new("StringValue")
result.Name = "RefugeTravelPromptLabelsFixResult"
result.Value = string.format("updated=%d; backup=%s", #plan, backup.Name)
result.Parent = ServerStorage
return result.Value
