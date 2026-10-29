-- One-shot Studio Edit visual pass. Never install as a startup script.
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local World = require(game:GetService("ReplicatedStorage"):WaitForChild("WorldConfig"))
local frames = workspace.ImportedEnvironmentModels.Refuge.PortalFrames
local travel = workspace.ProgressionZones.RefugePortals
local backupName = "BeforePortalGuidanceLighting_20261029"
assert(#World.Zones == 19 and #frames:GetChildren() == 19, "Expected 19 configured portal frames")

local accents = {
	City = Color3.fromRGB(255, 205, 75), Factory = Color3.fromRGB(255, 117, 47),
	Lab = Color3.fromRGB(68, 231, 222), Harbor = Color3.fromRGB(66, 158, 255),
	Power = Color3.fromRGB(255, 213, 66), Metro = Color3.fromRGB(190, 124, 255),
	Quarantine = Color3.fromRGB(151, 230, 91), Dam = Color3.fromRGB(54, 225, 190),
	Citadel = Color3.fromRGB(255, 93, 78), Crater = Color3.fromRGB(255, 119, 48),
	GlassSea = Color3.fromRGB(84, 223, 255), Skyline = Color3.fromRGB(255, 103, 198),
	OrbitalWreck = Color3.fromRGB(119, 179, 255), Depths = Color3.fromRGB(74, 209, 235),
	IronSanctum = Color3.fromRGB(255, 133, 69), LastConvoy = Color3.fromRGB(255, 200, 72),
	Gridfall = Color3.fromRGB(169, 237, 97), BlackoutCore = Color3.fromRGB(166, 120, 255),
	EclipseVault = Color3.fromRGB(213, 174, 255),
}

local plan, beforePrompts = {}, 0
for _, zone in ipairs(World.Zones) do
	local frame = frames:FindFirstChild("PortalFrame_" .. zone.Id)
	local gate = travel:FindFirstChild("Travel_" .. zone.Id)
	assert(frame and gate and accents[zone.Id], "Missing portal pair/accent: " .. zone.Id)
	local plate
	for _, item in ipairs(frame:GetDescendants()) do
		if item:IsA("BasePart") and string.lower(item.Name):match("_paint%.?%d*$") then plate = item; break end
	end
	local field = gate:FindFirstChild("Field", true)
	assert(plate and field and field:IsA("BasePart"), "Missing plate/field: " .. zone.Id)
	local prompts = {}
	for _, item in ipairs(gate:GetDescendants()) do if item:IsA("ProximityPrompt") then table.insert(prompts, item); beforePrompts += 1 end end
	assert(#prompts > 0, "Travel prompt missing: " .. zone.Id)
	table.insert(plan, { zone = zone, frame = frame, gate = gate, plate = plate, field = field, prompts = prompts })
end

local backup = ServerStorage:FindFirstChild(backupName)
if not backup then
	backup = Instance.new("Folder")
	backup.Name = backupName
	for _, item in ipairs(plan) do item.frame:Clone().Parent = backup end
	backup.Parent = ServerStorage
end

local lights = 0
for _, item in ipairs(plan) do
	local accent = accents[item.zone.Id]
	for _, part in ipairs(item.frame:GetDescendants()) do
		if part:IsA("BasePart") then
			local name = string.lower(part.Name)
			if name:match("_glow%.?%d*$") or name:match("_portal%.?%d*$") or name:match("_cyan%.?%d*$") or name:match("_red%.?%d*$") then
				part.Color, part.Material = accent, Enum.Material.Neon
			elseif name:match("_paint%.?%d*$") or name:match("_yellow%.?%d*$") then
				part.Color = accent:Lerp(Color3.fromRGB(255, 205, 110), 0.38)
			end
		end
	end
	local hue, saturation, value = accent:ToHSV()
	local light = item.plate:FindFirstChild("PortalGuidanceLight") or Instance.new("PointLight")
	light.Name = "PortalGuidanceLight"
	light.Color = Color3.fromHSV(hue, math.max(saturation, 0.78), math.max(value, 0.9))
	light.Brightness, light.Range, light.Shadows, light.Enabled = 0.55, 16, false, true
	light.Parent = item.plate
	lights += 1
end

local afterPrompts, fieldsChanged = 0, 0
for _, item in ipairs(plan) do
	local field = item.gate:FindFirstChild("Field", true)
	if field ~= item.field then fieldsChanged += 1 end
	for _, itemPrompt in ipairs(item.gate:GetDescendants()) do if itemPrompt:IsA("ProximityPrompt") then afterPrompts += 1 end end
	assert(item.plate:FindFirstChild("PortalGuidanceLight"), "Guidance light missing: " .. item.zone.Id)
end
assert(lights == 19 and afterPrompts == beforePrompts and fieldsChanged == 0, "Portal change affected travel setup")

local result = { status = "PORTAL_GUIDANCE_LIGHTING_APPLIED", portals = lights, promptsBefore = beforePrompts, promptsAfter = afterPrompts, fieldsChanged = fieldsChanged, backup = backup:GetFullName(), brightness = 0.55, range = 16, shadows = false }
local report = ServerStorage:FindFirstChild("PortalGuidanceLightingResult") or Instance.new("StringValue")
report.Name, report.Value, report.Parent = "PortalGuidanceLightingResult", HttpService:JSONEncode(result), ServerStorage
return report.Value
