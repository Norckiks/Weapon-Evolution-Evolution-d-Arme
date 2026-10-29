-- One-shot Edit pass. Run only in the intended Studio place with Play stopped.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(not RunService:IsRunning(), "Stop Play before highlighting weapon cores")
assert(game.PlaceId == 89391796839094, "Unexpected place; refusing to recolor weapons")

local ids = {"ArcPike", "BlackoutEdge", "EclipseGlaive"}
local live = ReplicatedStorage:WaitForChild("WeaponModels")
local prototypes = ServerStorage:WaitForChild("ImportedModelPrototypes"):WaitForChild("Weapons")
local backupName = "BeforeFinalWeaponCoreGlow_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect it before rerunning")

local plan = {}
for _, id in ipairs(ids) do
	local models = {live:FindFirstChild(id), prototypes:FindFirstChild(id)}
	for _, model in ipairs(models) do
		assert(model and model:IsA("Model"), "Missing imported or prototype model: " .. id)
		local cores = {}
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") and string.find(string.lower(part.Name), "noyau", 1, true) then
				assert(not part:IsA("MeshPart") or part.TextureID == "", "Textured core needs texture-mask tinting: " .. part:GetFullName())
				table.insert(cores, part)
			end
		end
		assert(#cores > 0, "Missing named core: " .. model:GetFullName())
		local hue = select(1, cores[1].Color:ToHSV())
		table.insert(plan, {model = model, cores = cores, color = Color3.fromHSV(hue, 0.72, 0.98)})
	end
end

local backup = Instance.new("Folder")
backup.Name = backupName
for _, id in ipairs(ids) do
	live[id]:Clone().Parent = backup
	prototypes[id]:Clone().Parent = backup
end
backup.Parent = ServerStorage

local result = {status = "FINAL_WEAPON_CORES_LUMINOUS", weapons = {}, parts = 0, backup = backup:GetFullName()}
for _, item in ipairs(plan) do
	for _, part in ipairs(item.cores) do
		part.Color = item.color
		part.Material = Enum.Material.Neon
		local _, saturation, value = part.Color:ToHSV()
		assert(part.Material == Enum.Material.Neon and saturation >= 0.70 and value >= 0.97, "Core highlight failed: " .. part:GetFullName())
		result.parts += 1
	end
	table.insert(result.weapons, item.model.Name)
end

local output = ServerStorage:FindFirstChild("FinalWeaponCoreGlowEditResult") or Instance.new("StringValue")
output.Name = "FinalWeaponCoreGlowEditResult"
output.Value = HttpService:JSONEncode(result)
output.Parent = ServerStorage
assert(#result.weapons == 6 and result.parts >= 6, "Final weapon core self-check failed")
return output.Value
