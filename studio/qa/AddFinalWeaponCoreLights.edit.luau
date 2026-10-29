-- One-shot Edit pass: colored Neon cores do not illuminate nearby weapon meshes.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Use the target place in Edit mode")

local ids = {"ArcPike", "BlackoutEdge", "EclipseGlaive"}
local live = ReplicatedStorage:WaitForChild("WeaponModels")
local prototypes = ServerStorage:WaitForChild("ImportedModelPrototypes"):WaitForChild("Weapons")
local backupName = "BeforeFinalWeaponCorePointLights_20261029"
assert(not ServerStorage:FindFirstChild("FinalWeaponCorePointLightsEditResult"), "Result marker exists; inspect it before rerunning")

local plan = {}
for _, id in ipairs(ids) do
	for _, model in ipairs({live:FindFirstChild(id), prototypes:FindFirstChild(id)}) do
		assert(model and model:IsA("Model"), "Missing weapon model: " .. id)
		local cores = {}
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") and string.find(string.lower(part.Name), "noyau", 1, true) then table.insert(cores, part) end
		end
		assert(#cores == 1, "Expected one named core in " .. model:GetFullName())
		local core = cores[1]
		local _, saturation, value = core.Color:ToHSV()
		assert(core.Material == Enum.Material.Neon and saturation >= 0.55 and value >= 0.95, "Unexpected core palette in " .. core:GetFullName())
		assert(not core:FindFirstChild("WeaponCoreGlow"), "Weapon core light already exists in " .. core:GetFullName())
		table.insert(plan, {model = model, core = core})
	end
end
assert(#plan == 6, "Expected three replicated and three prototype weapon cores")

local backup = ServerStorage:FindFirstChild(backupName)
if backup then
	local liveBackup, prototypeBackup = backup:FindFirstChild("Replicated"), backup:FindFirstChild("Prototypes")
	assert(liveBackup and prototypeBackup, "Existing backup is incomplete; inspect it before rerunning")
	for _, id in ipairs(ids) do
		for _, model in ipairs({liveBackup:FindFirstChild(id), prototypeBackup:FindFirstChild(id)}) do
			assert(model and model:IsA("Model"), "Existing backup is missing " .. id)
			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") and string.find(string.lower(part.Name), "noyau", 1, true) then
					assert(not part:FindFirstChild("WeaponCoreGlow"), "Existing backup is not a pre-light snapshot")
				end
			end
		end
	end
else
	backup = Instance.new("Folder")
	backup.Name = backupName
	local liveBackup, prototypeBackup = Instance.new("Folder"), Instance.new("Folder")
	liveBackup.Name, prototypeBackup.Name = "Replicated", "Prototypes"
	liveBackup.Parent, prototypeBackup.Parent = backup, backup
	for _, id in ipairs(ids) do
		live[id]:Clone().Parent = liveBackup
		prototypes[id]:Clone().Parent = prototypeBackup
	end
	backup.Parent = ServerStorage
end

local created = {}
local ok, failure = pcall(function()
	for _, item in ipairs(plan) do
		local light = Instance.new("PointLight")
		light.Name = "WeaponCoreGlow"
		light.Color = item.core.Color
		light.Brightness = 0.65
		light.Range = 6
		light.Shadows = false
		light.Parent = item.core
		table.insert(created, light)
		assert(light.Enabled and light.Color == item.core.Color and light.Range == 6 and math.abs(light.Brightness - 0.65) < 0.01 and not light.Shadows, "Core light configuration failed")
	end
end)
if not ok then
	for _, light in ipairs(created) do if light.Parent then light:Destroy() end end
	error("Core-light pass rolled back: " .. tostring(failure))
end

local result = {status = "FINAL_WEAPON_CORE_LIGHTS_ADDED", backup = backup:GetFullName(), liveModels = 3, prototypeModels = 3, lights = #created, brightness = 0.65, range = 6, shadows = false}
local marker = Instance.new("StringValue")
marker.Name = "FinalWeaponCorePointLightsEditResult"
marker.Value = HttpService:JSONEncode(result)
marker.Parent = ServerStorage
return marker.Value
