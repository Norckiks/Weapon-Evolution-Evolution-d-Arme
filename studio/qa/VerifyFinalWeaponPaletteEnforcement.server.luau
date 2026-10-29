-- Temporary Play-only regression fixture; never install in Edit or at startup.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(game.PlaceId == 89391796839094 and RunService:IsRunning(), "Use the target place in Play")

local palettes = {
	ArcPike = {accent = Color3.fromRGB(255, 207, 25), hardware = Color3.fromRGB(42, 205, 225), core = Color3.fromRGB(99, 238, 255)},
	BlackoutEdge = {accent = Color3.fromRGB(24, 146, 255), hardware = Color3.fromRGB(255, 141, 73), core = Color3.fromRGB(255, 190, 74)},
	EclipseGlaive = {accent = Color3.fromRGB(164, 68, 255), hardware = Color3.fromRGB(255, 201, 84), core = Color3.fromRGB(255, 101, 216)},
}
local Visuals = require(ReplicatedStorage:WaitForChild("WeaponVisuals"))
local models = ReplicatedStorage:WaitForChild("WeaponModels")

local function checkBuild(id, sourceColor)
	local source = models:FindFirstChild(id)
	assert(source and source:IsA("Model"), "Missing source: " .. id)
	local saved, sourceParts = {}, {}
	for _, part in ipairs(source:GetDescendants()) do
		if part:IsA("BasePart") then
			if part:IsA("MeshPart") then
				assert(part.TextureID == "" and not part:FindFirstChildOfClass("SurfaceAppearance"), "Textured source needs a separate tint test: " .. id)
			end
			table.insert(sourceParts, part)
			table.insert(saved, {part, part.Color, part.Material, part.MaterialVariant})
		end
	end
	assert(#sourceParts >= 17, "Unexpected source geometry: " .. id)
	for index, part in ipairs(sourceParts) do
		part.Color = sourceColor == "gray" and Color3.fromRGB(118, 121, 128) or Color3.fromHSV((index - 1) / #sourceParts, 0.98, 0.94)
		part.Material, part.MaterialVariant = Enum.Material.SmoothPlastic, ""
	end

	local built
	local ok, result = pcall(function()
		local pieces
		built, pieces = Visuals.Build(id)
		assert(#pieces == #sourceParts, "Build changed piece count: " .. id)
		local found = {accent = 0, hardware = 0, core = 0}
		local colors, saturation, count = {}, 0, 0
		for _, part in ipairs(built:GetDescendants()) do
			if part:IsA("BasePart") then
				local name = string.lower(part.Name)
				if string.find(name, "silhouette", 1, true) then
					assert(part.Color == palettes[id].accent, id .. " accent palette not enforced")
					assert(part.Material == Enum.Material.Neon, id .. " accent is not emissive")
					found.accent += 1
				elseif string.find(name, "garde", 1, true) then
					assert(part.Color == palettes[id].hardware, id .. " hardware palette not enforced")
					found.hardware += 1
				elseif string.find(name, "noyau", 1, true) then
					assert(part.Color == palettes[id].core and part.Material == Enum.Material.Neon, id .. " core palette not enforced")
					found.core += 1
				end
				local _, sat = part.Color:ToHSV()
				saturation += sat
				count += 1
				colors[string.format("%d,%d,%d", math.round(part.Color.R * 255), math.round(part.Color.G * 255), math.round(part.Color.B * 255))] = true
				assert(part.Anchored and not part.CanCollide, id .. " produced unsafe physics")
			end
		end
		local unique = 0
		for _ in pairs(colors) do unique += 1 end
		assert(found.accent > 0 and found.hardware > 0 and found.core == 1, "Missing color roles: " .. id)
		assert(unique >= 5 and saturation / count >= 0.55, "Palette output is not visibly varied: " .. id)
		return {parts = count, uniqueColors = unique, saturationAverage = saturation / count, roles = found}
	end)
	if built then built:Destroy() end
	for _, item in ipairs(saved) do
		item[1].Color, item[1].Material, item[1].MaterialVariant = item[2], item[3], item[4]
	end
	assert(ok, id .. "/" .. sourceColor .. ": " .. tostring(result))
	for _, item in ipairs(saved) do
		assert(item[1].Color == item[2] and item[1].Material == item[3] and item[1].MaterialVariant == item[4], "Source not restored: " .. id)
	end
	return result
end

local ok, result = pcall(function()
	local cases = {}
	for id in pairs(palettes) do
		cases[id] = {gray = checkBuild(id, "gray"), saturatedImport = checkBuild(id, "saturated")}
	end
	return {status = "PASS", weapons = cases, sourceModelsRestored = true}
end)
local report = {status = ok and "PASS" or "FAIL", detail = ok and result or tostring(result)}
local previous = ServerStorage:FindFirstChild("FinalWeaponPaletteEnforcementResult")
if previous then previous:Destroy() end
local value = Instance.new("StringValue")
value.Name, value.Value, value.Parent = "FinalWeaponPaletteEnforcementResult", HttpService:JSONEncode(report), ServerStorage
script:Destroy()
