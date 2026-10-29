-- One-time Edit repair for imported Refuge models whose WorldPivot moved while their mesh parts stayed behind.
-- Never install as a game/startup script.
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local refuge = workspace:WaitForChild("ImportedEnvironmentModels"):WaitForChild("Refuge")
local rows = {
	{ name = "Refuge_Abri_01", x = -145, z = 235 },
	{ name = "Refuge_Abri_02", x = 177, z = 235 },
	{ name = "Refuge_Abri_03", x = -145, z = 365 },
	{ name = "Refuge_Abri_04", x = 177, z = 365 },
	{ name = "Refuge_03_Terminal", x = -130, z = 300 },
}
local plan = {}
for _, row in ipairs(rows) do
	local model = refuge:FindFirstChild(row.name)
	assert(model and model:IsA("Model"), "Missing refuge model: " .. row.name)
	local bounds, size = model:GetBoundingBox()
	local pivot = model:GetPivot().Position
	assert(math.abs(pivot.X - row.x) < 0.05 and math.abs(pivot.Z - row.z) < 0.05, "Model pivot moved since the refuge layout: " .. row.name)
	local base = Vector3.new(row.x, 0, row.z)
	local desiredCenter = base + Vector3.new(0, size.Y / 2, 0)
	table.insert(plan, { model = model, base = base, desiredCenter = desiredCenter, delta = desiredCenter - bounds.Position, size = size })
end

local backup = ServerStorage:FindFirstChild("BeforeRefugeGeometryPass2_20261029")
if not backup then
	backup = Instance.new("Folder")
	backup.Name = "BeforeRefugeGeometryPass2_20261029"
	backup.Parent = ServerStorage
end
for _, item in ipairs(plan) do
	if not backup:FindFirstChild(item.model.Name) then item.model:Clone().Parent = backup end
end

local result = { status = "REFUGE_DISCONNECTED_MODELS_FIXED", models = {}, translatedParts = 0, backup = backup:GetFullName() }
for _, item in ipairs(plan) do
	local moved = 0
	for _, part in ipairs(item.model:GetDescendants()) do
		if part:IsA("BasePart") then part.CFrame += item.delta; moved += 1 end
	end
	local bounds, size = item.model:GetBoundingBox()
	local actualBase = Vector3.new(bounds.Position.X, bounds.Position.Y - size.Y / 2, bounds.Position.Z)
	local errorStuds = (actualBase - item.base).Magnitude
	assert(errorStuds < 0.05 and math.abs(size.Y - item.size.Y) < 0.001, "Refuge model failed base-position check: " .. item.model.Name)
	result.translatedParts += moved
	table.insert(result.models, { name = item.model.Name, parts = moved, baseErrorStuds = errorStuds, size = { size.X, size.Y, size.Z } })
end

local value = ServerStorage:FindFirstChild("RefugeGeometryPass2Result") or Instance.new("StringValue")
value.Name = "RefugeGeometryPass2Result"
value.Value = HttpService:JSONEncode(result)
value.Parent = ServerStorage
assert(#result.models == 5, "Expected five corrected refuge models")
return value.Value
