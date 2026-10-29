-- One-shot Edit palette repair. Clears the low-contrast experimental material variant and brightens the final three weapons.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Use the target place in Edit mode")

local module = ReplicatedStorage:WaitForChild("GameplayConfig")
local oldSource = module.Source
local replacements = {
	{
		' ArcPike={Name="Pique de la grille",ShortName="ORAGE",Cost=8200000,Level=230,Damage=1300,Range=16,Cooldown=.98,Color=Color3.fromRGB(193,177,103)},',
		' ArcPike={Name="Pique de la grille",ShortName="ORAGE",Cost=8200000,Level=230,Damage=1300,Range=16,Cooldown=.98,Color=Color3.fromRGB(255,207,25)},',
	},
	{
		' BlackoutEdge={Name="Trancheuse du blackout",ShortName="BLACKOUT",Cost=11000000,Level=250,Damage=1550,Range=17,Cooldown=1.12,Color=Color3.fromRGB(128,139,149)},',
		' BlackoutEdge={Name="Trancheuse du blackout",ShortName="BLACKOUT",Cost=11000000,Level=250,Damage=1550,Range=17,Cooldown=1.12,Color=Color3.fromRGB(24,146,255)},',
	},
	{
		' EclipseGlaive={Name="Glaive de l\'eclipse",ShortName="ECLIPSE",Cost=15000000,Level=270,Damage=1850,Range=17.5,Cooldown=1.06,Color=Color3.fromRGB(122,111,151)},',
		' EclipseGlaive={Name="Glaive de l\'eclipse",ShortName="ECLIPSE",Cost=15000000,Level=270,Damage=1850,Range=17.5,Cooldown=1.06,Color=Color3.fromRGB(164,68,255)},',
	},
}
local updatedSource = oldSource
local function replaceOnce(source, before, after)
	local first = string.find(source, before, 1, true)
	assert(first and not string.find(source, before, first + #before, true), "GameplayConfig source differs; compare before editing")
	return string.sub(source, 1, first - 1) .. after .. string.sub(source, first + #before)
end
for _, pair in ipairs(replacements) do
	updatedSource = replaceOnce(updatedSource, pair[1], pair[2])
end

local live = ReplicatedStorage:WaitForChild("WeaponModels")
local prototypes = ServerStorage:WaitForChild("ImportedModelPrototypes"):WaitForChild("Weapons")
local ids = { "ArcPike", "BlackoutEdge", "EclipseGlaive" }
local accents = {
	ArcPike = Color3.fromRGB(255, 207, 25),
	BlackoutEdge = Color3.fromRGB(24, 146, 255),
	EclipseGlaive = Color3.fromRGB(164, 68, 255),
}
local backupName = "BeforeFinalWeaponPaletteFix_Pass2_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Palette backup already exists; inspect it before rerunning")
local backup = Instance.new("Folder")
backup.Name = backupName
local configBackup = module:Clone(); configBackup.Name = "GameplayConfig"
configBackup.Parent = backup
local oldProperties = {}
local plan = {}
for _, id in ipairs(ids) do
	for _, model in ipairs({ live:FindFirstChild(id), prototypes:FindFirstChild(id) }) do
		assert(model and model:IsA("Model"), "Missing final weapon model: " .. id)
		local meshParts, coreCount, silhouetteCount = 0, 0, 0
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				oldProperties[part] = { part.Color, part.Material, part.MaterialVariant }
				local lower = string.lower(part.Name)
				if part:IsA("MeshPart") then meshParts += 1 end
				if string.find(lower, "noyau", 1, true) then coreCount += 1 end
				if string.find(lower, "silhouette", 1, true) then silhouetteCount += 1 end
			end
		end
		assert(meshParts >= 17 and coreCount > 0 and silhouetteCount > 0, "Unexpected final weapon structure: " .. id)
		local saved = model:Clone()
		saved.Name = saved.Name .. (model.Parent == live and "_Replicated" or "_Prototype")
		saved.Parent = backup
		table.insert(plan, { id = id, model = model, accent = accents[id] })
	end
end
backup.Parent = ServerStorage

local function recolor(model, accent)
	local hue = select(1, accent:ToHSV())
	local core = Color3.fromHSV(hue, 0.72, 0.98)
	local leather = accent:Lerp(Color3.fromRGB(39, 25, 23), 0.40)
	local steel = accent:Lerp(Color3.fromRGB(33, 43, 50), 0.58)
	local bronze = accent:Lerp(Color3.fromRGB(246, 217, 125), 0.28)
	local counts = { total = 0, core = 0, accent = 0, variantCleared = 0 }
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local name = string.lower(part.Name)
			local color, material
			if string.find(name, "noyau", 1, true) then color, material = core, Enum.Material.Neon; counts.core += 1
			elseif string.find(name, "silhouette", 1, true) or string.find(name, "pommeau", 1, true) or string.find(name, "ailette", 1, true) then color, material = accent, Enum.Material.SmoothPlastic; counts.accent += 1
			elseif string.find(name, "bande", 1, true) then color, material = leather, Enum.Material.Fabric
			elseif string.find(name, "manche", 1, true) then color, material = steel, Enum.Material.Metal
			elseif string.find(name, "collier", 1, true) or string.find(name, "garde", 1, true) or string.find(name, "rivet", 1, true) or string.find(name, "face", 1, true) or string.find(name, "tete", 1, true) then color, material = bronze, Enum.Material.Metal
			elseif string.find(name, "renfort", 1, true) then color, material = accent:Lerp(Color3.fromRGB(35, 43, 50), 0.34), Enum.Material.Metal
			else color, material = steel, Enum.Material.Metal end
			part.MaterialVariant = ""
			part.Color, part.Material = color, material
			counts.total += 1
			if part.MaterialVariant == "" then counts.variantCleared += 1 end
		end
	end
	local saturation, value = select(2, accent:ToHSV()), select(3, accent:ToHSV())
	assert(saturation >= 0.70 and value >= 0.98 and counts.core == 1 and counts.accent >= 1 and counts.variantCleared == counts.total, "Final weapon palette assertion failed: " .. model.Name)
	return counts
end

local ok, result = pcall(function()
	module.Source = updatedSource
	local applied = {}
	for _, item in ipairs(plan) do
		local counts = recolor(item.model, item.accent)
		applied[item.id .. "/" .. (item.model.Parent == live and "Replicated" or "Prototype")] = counts
	end
	return applied
end)
if not ok then
	module.Source = oldSource
	for part, state in pairs(oldProperties) do if part.Parent then part.Color, part.Material, part.MaterialVariant = state[1], state[2], state[3] end end
	error("Final weapon palette rolled back: " .. tostring(result))
end

local marker = Instance.new("StringValue")
marker.Name = "FinalWeaponPaletteFixEditResult"
marker.Value = HttpService:JSONEncode({ backup = backup:GetFullName(), weapons = result })
marker.Parent = ServerStorage
return marker.Value
