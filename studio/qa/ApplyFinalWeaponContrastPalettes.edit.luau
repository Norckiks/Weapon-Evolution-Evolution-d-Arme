-- One-time Edit pass: give the three endgame weapons unmistakable complementary accents.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Use the target place in Edit mode")

local live = ReplicatedStorage:WaitForChild("WeaponModels")
local prototypes = ServerStorage:WaitForChild("ImportedModelPrototypes"):WaitForChild("Weapons")
local palettes = {
	ArcPike = { primary = Color3.fromRGB(255, 207, 25), metal = Color3.fromRGB(42, 205, 225), core = Color3.fromRGB(99, 238, 255) },
	BlackoutEdge = { primary = Color3.fromRGB(24, 146, 255), metal = Color3.fromRGB(255, 141, 73), core = Color3.fromRGB(255, 190, 74) },
	EclipseGlaive = { primary = Color3.fromRGB(164, 68, 255), metal = Color3.fromRGB(255, 201, 84), core = Color3.fromRGB(255, 101, 216) },
}
local backupName = "BeforeFinalWeaponContrastPass_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Contrast backup already exists; inspect it before rerunning")

local backup = Instance.new("Folder")
backup.Name = backupName
for id in pairs(palettes) do
	for _, source in ipairs({ live:FindFirstChild(id), prototypes:FindFirstChild(id) }) do
		assert(source and source:IsA("Model"), "Missing final weapon model: " .. id)
		local clone = source:Clone()
		clone.Name = id .. (source.Parent == live and "_Replicated" or "_Prototype")
		clone.Parent = backup
	end
end
backup.Parent = ServerStorage

local results = {}
for id, palette in pairs(palettes) do
	for _, model in ipairs({ live:FindFirstChild(id), prototypes:FindFirstChild(id) }) do
		local counts = { primary = 0, metal = 0, core = 0, parts = 0 }
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				local name = string.lower(part.Name)
				local color, material
				if string.find(name, "noyau", 1, true) then color, material = palette.core, Enum.Material.Neon; counts.core += 1
				elseif string.find(name, "silhouette", 1, true) or string.find(name, "pommeau", 1, true) or string.find(name, "ailette", 1, true) then color, material = palette.primary, Enum.Material.SmoothPlastic; counts.primary += 1
				elseif string.find(name, "bande", 1, true) then color, material = palette.primary:Lerp(Color3.fromRGB(26, 32, 45), 0.44), Enum.Material.Fabric
				elseif string.find(name, "manche", 1, true) then color, material = palette.primary:Lerp(Color3.fromRGB(20, 27, 38), 0.50), Enum.Material.Metal
				elseif string.find(name, "collier", 1, true) or string.find(name, "garde", 1, true) or string.find(name, "rivet", 1, true) or string.find(name, "face", 1, true) or string.find(name, "tete", 1, true) then color, material = palette.metal, Enum.Material.Metal; counts.metal += 1
				elseif string.find(name, "renfort", 1, true) then color, material = palette.metal:Lerp(Color3.fromRGB(30, 39, 53), 0.30), Enum.Material.Metal
				else color, material = palette.primary:Lerp(Color3.fromRGB(30, 39, 53), 0.56), Enum.Material.Metal end
				part.MaterialVariant = ""
				part.Color, part.Material = color, material
				counts.parts += 1
			end
		end
		assert(counts.primary >= 2 and counts.metal >= 3 and counts.core == 1 and counts.parts >= 17, "Contrast palette incomplete: " .. id .. "/" .. model:GetFullName())
		results[id .. (model.Parent == live and "/Replicated" or "/Prototype")] = counts
	end
end

local marker = Instance.new("StringValue")
marker.Name = "FinalWeaponContrastPassEditResult"
marker.Value = HttpService:JSONEncode({ backup = backup:GetFullName(), weapons = results })
marker.Parent = ServerStorage
return marker.Value
