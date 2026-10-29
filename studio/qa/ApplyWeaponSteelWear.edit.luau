-- Superseded: the generated variant dulled the final-weapon palette; do not reapply it.
-- One-shot Edit material pass for the three final imported weapons.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MaterialService = game:GetService("MaterialService")
assert(game.PlaceId == 89391796839094, "Unexpected place")
assert(not RunService:IsRunning(), "Stop Play before applying weapon materials")

local variantName = "WeaponSteelWear_20261029"
local variant
for _, item in ipairs(MaterialService:GetDescendants()) do
	if item:IsA("MaterialVariant") and item.Name == variantName then variant = item; break end
end
assert(variant and variant.BaseMaterial == Enum.Material.Metal, "Generated metal variant is missing")
local models = ReplicatedStorage:WaitForChild("WeaponModels")
local ids = { "ArcPike", "BlackoutEdge", "EclipseGlaive" }
local backupName = "BeforeWeaponSteelWear_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect before rerunning")
local plan = {}
for _, id in ipairs(ids) do
	local model = models:FindFirstChild(id)
	assert(model and model:IsA("Model"), "Missing weapon: " .. id)
	local meshCount, targetCount = 0, 0
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("MeshPart") then
			meshCount += 1
			if part.Material == Enum.Material.Metal or string.sub(part.Name, 1, 11) == "Silhouette." then
				assert(part.MaterialVariant == "", "Weapon already has a custom variant: " .. id .. "/" .. part.Name)
				targetCount += 1
			end
		end
	end
	assert(meshCount >= 17 and targetCount == 8, "Unexpected weapon geometry: " .. id)
	table.insert(plan, { id = id, model = model, meshCount = meshCount })
end

local backup = Instance.new("Folder")
backup.Name = backupName
for _, item in ipairs(plan) do item.model:Clone().Parent = backup end
backup.Parent = ServerStorage

local result = {}
for _, item in ipairs(plan) do
	local colors, textured = {}, 0
	for _, part in ipairs(item.model:GetDescendants()) do
		if part:IsA("BasePart") then colors[part] = part.Color end
		if part:IsA("MeshPart") and (part.Material == Enum.Material.Metal or string.sub(part.Name, 1, 11) == "Silhouette.") then
			part.Material = Enum.Material.Metal
			part.MaterialVariant = variantName
			textured += 1
		end
	end
	for part, color in pairs(colors) do assert(part.Color == color, "Weapon tint changed: " .. item.id) end
	assert(textured == 8, "Unexpected material assignment count: " .. item.id)
	result[item.id] = { meshParts = item.meshCount, texturedParts = textured }
end

local marker = Instance.new("StringValue")
marker.Name = "WeaponSteelWearEditResult"
marker.Value = game:GetService("HttpService"):JSONEncode({ backup = backup:GetFullName(), variant = variantName, weapons = result })
marker.Parent = ServerStorage
return marker.Value
