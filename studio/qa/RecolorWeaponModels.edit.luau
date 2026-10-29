-- One-shot Studio Edit repair. Execute with the Studio DataModel bridge; never install as a game/startup Script.
assert(game.PlaceId == 89391796839094 and not game:GetService('RunService'):IsRunning(), 'Run on the target place in Edit only')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
-- Read Source directly; execute_luau can have a separate require cache from running game scripts.
local configSource = ReplicatedStorage:WaitForChild("GameplayConfig").Source
local function configColor(id)
	local start = string.find(configSource, id .. "={", 1, true)
	assert(start, "Weapon missing from GameplayConfig.Source: " .. id)
	local finish = string.find(configSource, "\n", start, true) or (#configSource + 1)
	local r, g, b = string.match(string.sub(configSource, start, finish - 1), "Color=Color3.fromRGB%((%d+),(%d+),(%d+)%)")
	assert(r and g and b, "Weapon color missing in GameplayConfig.Source: " .. id)
	return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
end
local ids = {"Hook", "Kris", "Spear", "Cleaver", "WarHammer", "Pike", "PhaseBlade", "MirrorAxe", "RelayLance", "OrbitalSpear", "RiftCleaver", "ForgeMaul", "ConvoyEdge", "ArcPike", "BlackoutEdge", "EclipseGlaive"}
local luminousCore = {ArcPike = true, BlackoutEdge = true, EclipseGlaive = true}
local contrastPalettes = {
	ArcPike = {metal = Color3.fromRGB(42, 205, 225), core = Color3.fromRGB(99, 238, 255)},
	BlackoutEdge = {metal = Color3.fromRGB(255, 141, 73), core = Color3.fromRGB(255, 190, 74)},
	EclipseGlaive = {metal = Color3.fromRGB(255, 201, 84), core = Color3.fromRGB(255, 101, 216)},
}
local models = ReplicatedStorage:FindFirstChild("WeaponModels")
assert(models, "ReplicatedStorage.WeaponModels is missing")

local function parts(model)
	local silhouette, core = {}, {}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			local name = string.lower(item.Name)
			if string.find(name, "silhouette", 1, true) then table.insert(silhouette, item) end
			if string.find(name, "noyau", 1, true) then table.insert(core, item) end
		end
	end
	return silhouette, core
end

local function recolor(model, accent)
	local count, roles = 0, {}
	local hue = select(1, accent:ToHSV())
	local contrast = contrastPalettes[model.Name]
	local core = contrast and contrast.core or (luminousCore[model.Name] and Color3.fromHSV(hue, 0.72, 0.98) or accent:Lerp(Color3.new(1, 1, 1), 0.34))
	local leather = accent:Lerp(Color3.fromRGB(39, 25, 23), 0.58)
	local steel = accent:Lerp(Color3.fromRGB(33, 43, 50), 0.70)
	local hardware = contrast and contrast.metal or accent:Lerp(Color3.fromRGB(229, 181, 99), 0.25)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			assert(not part:IsA("MeshPart") or part.TextureID == "", "Textured MeshPart needs texture-mask tinting: " .. part:GetFullName())
			part.MaterialVariant = ""
			local name = string.lower(part.Name)
			local color, material, role
			if string.find(name, "noyau", 1, true) then color, material, role = core, luminousCore[model.Name] and Enum.Material.Neon or Enum.Material.SmoothPlastic, "core"
			elseif string.find(name, "silhouette", 1, true) or string.find(name, "pommeau", 1, true) or string.find(name, "ailette", 1, true) then color, material, role = accent, Enum.Material.SmoothPlastic, "accent"
			elseif string.find(name, "bande", 1, true) then color, material, role = leather, Enum.Material.Fabric, "wrap"
			elseif string.find(name, "manche", 1, true) then color, material, role = steel, Enum.Material.Metal, "shaft"
			elseif string.find(name, "collier", 1, true) or string.find(name, "garde", 1, true) or string.find(name, "rivet", 1, true) or string.find(name, "face", 1, true) or string.find(name, "tete", 1, true) then color, material, role = hardware, Enum.Material.Metal, "hardware"
			elseif string.find(name, "renfort", 1, true) then color, material, role = hardware:Lerp(Color3.fromRGB(30, 39, 53), 0.30), Enum.Material.Metal, "reinforcement"
			else color, material, role = steel, Enum.Material.Metal, "fallback" end
			if role == "hardware" then local _, saturation = color:ToHSV(); assert(saturation >= 0.35, "Weapon hardware lost its accent: " .. part:GetFullName()) end
			part.Color, part.Material = color, material
			roles[role] = (roles[role] or 0) + 1
			count += 1
		end
	end
	return count, roles
end

local targets = {{folder = models, backupName = "ReplicatedStorage"}}
local prototypes = ServerStorage:FindFirstChild("ImportedModelPrototypes")
local prototypeFolder = prototypes and prototypes:FindFirstChild("Weapons")
if prototypeFolder then table.insert(targets, {folder = prototypeFolder, backupName = "ServerStorage"}) end

local plan = {}
for _, id in ipairs(ids) do
	local sourceColor = configColor(id)
	local model = models:FindFirstChild(id)
	assert(model and model:IsA("Model"), "Missing weapon model: " .. id)
	local silhouette, core = parts(model)
	assert(#silhouette > 0 and #core > 0, "Imported weapon parts are not named Silhouette/Noyau: " .. id)
	local hue, _, value = sourceColor:ToHSV()
	local accent = Color3.fromHSV(hue, 0.92, math.clamp(value, 0.72, 0.94))
	local prototype = prototypeFolder and prototypeFolder:FindFirstChild(id)
	if prototype then
		local prototypeSilhouette, prototypeCore = parts(prototype)
		assert(#prototypeSilhouette > 0 and #prototypeCore > 0, "Prototype weapon parts are not named Silhouette/Noyau: " .. id)
	end
	table.insert(plan, {id = id, accent = accent, model = model, prototype = prototype})
end

local backup = ServerStorage:FindFirstChild("BeforeWeaponPalettePass4_20261029")
if not backup then backup = Instance.new("Folder"); backup.Name = "BeforeWeaponPalettePass4_20261029"; backup.Parent = ServerStorage end
for _, target in ipairs(targets) do
	local targetBackup = backup:FindFirstChild(target.backupName)
	if not targetBackup then targetBackup = Instance.new("Folder"); targetBackup.Name = target.backupName; targetBackup.Parent = backup end
	for _, id in ipairs(ids) do
		local model = target.folder:FindFirstChild(id)
		if model and not targetBackup:FindFirstChild(id) then model:Clone().Parent = targetBackup end
	end
end

local changed, totalParts, fallbackParts = 0, 0, 0
for _, item in ipairs(plan) do
	local colored, roles = recolor(item.model, item.accent)
	local modelParts = 0 for _, part in ipairs(item.model:GetDescendants()) do if part:IsA("BasePart") then modelParts += 1 end end
	assert(colored == modelParts and (roles.accent or 0) + (roles.core or 0) > 0, "Imported weapon palette incomplete: " .. item.id)
	totalParts += colored
	if item.prototype then
		local prototypeColored = recolor(item.prototype, item.accent)
		local prototypeParts = 0 for _, part in ipairs(item.prototype:GetDescendants()) do if part:IsA("BasePart") then prototypeParts += 1 end end
		assert(prototypeColored == prototypeParts, "Prototype weapon palette incomplete: " .. item.id)
		totalParts += prototypeColored
	end
	changed += 1
end

local result = {status = "WEAPON_PALETTE_PASS4_APPLIED", models = changed, coloredParts = totalParts, backup = backup:GetFullName(), ids = ids, allMeshPartsColored = true, minimumHardwareSaturation = 0.35}
local value = ServerStorage:FindFirstChild("WeaponPalettePass4EditResult") or Instance.new("StringValue")
value.Name = "WeaponPalettePass4EditResult"; value.Value = HttpService:JSONEncode(result); value.Parent = ServerStorage
assert(changed == #ids and totalParts >= #ids * 2, "Weapon palette self-check failed")
return value.Value

