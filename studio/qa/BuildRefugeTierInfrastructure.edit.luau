-- One-time Edit presentation pass for portal row structure and floor wayfinding.
assert(game.PlaceId == 89391796839094 and not game:GetService("RunService"):IsRunning(), "Run in the target place, Edit only")

local ServerStorage = game:GetService("ServerStorage")
local courtyard = workspace:FindFirstChild("RefugeCourtyard")
local portals = workspace:FindFirstChild("ProgressionZones") and workspace.ProgressionZones:FindFirstChild("RefugePortals")
local frames = workspace:FindFirstChild("ImportedEnvironmentModels") and workspace.ImportedEnvironmentModels:FindFirstChild("Refuge") and workspace.ImportedEnvironmentModels.Refuge:FindFirstChild("PortalFrames")
local ground = courtyard and courtyard:FindFirstChild("CourtyardGround")
local path = courtyard and courtyard:FindFirstChild("CentralPath")
local rows = {
	{ z = 247, color = Color3.fromRGB(239, 145, 63) },
	{ z = 292, color = Color3.fromRGB(82, 194, 183) },
	{ z = 337, color = Color3.fromRGB(178, 143, 214) },
}
local columns = { -80, -52, -28, 28, 52, 80 }
local zones = {
	"Factory", "Lab", "Harbor", "Power", "Metro", "Quarantine",
	"Dam", "Citadel", "Crater", "GlassSea", "Skyline", "OrbitalWreck",
	"Depths", "IronSanctum", "LastConvoy", "Gridfall", "BlackoutCore", "EclipseVault",
}
local backupName = "BeforeRefugeTierInfrastructure_20261029"
assert(courtyard and ground and path and portals and frames, "Refuge layout is incomplete")
assert(not courtyard:FindFirstChild("RefugeTierInfrastructure"), "Tier infrastructure already exists")
assert(not ServerStorage:FindFirstChild(backupName), "Inspect the existing backup before rerunning")
assert(#frames:GetChildren() == 19 and #portals:GetChildren() == 20, "Expected 19 frame pairs and one sign")
assert(math.abs(ground.Size.X - 380) < 0.05 and math.abs(ground.Size.Z - 190) < 0.05, "Courtyard ground bounds changed")

for row = 1, 3 do
	local sign = courtyard:FindFirstChild("RefugeTierSign_" .. row)
	local accent = courtyard:FindFirstChild("RefugeTierAccent_" .. row)
	assert(sign and accent and math.abs(sign.Position.Z - rows[row].z) < 0.05, "Tier sign is missing or moved")
end
for index, zone in ipairs(zones) do
	local column = columns[((index - 1) % 6) + 1]
	local row = math.floor((index - 1) / 6) + 1
	local travel = portals:FindFirstChild("Travel_" .. zone)
	local frame = frames:FindFirstChild("PortalFrame_" .. zone)
	local field = travel and travel:FindFirstChild("Field", true)
	assert(field and frame and math.abs(field.Position.X - column) < 0.05 and math.abs(field.Position.Z - (rows[row].z + 13)) < 0.05, "Portal placement changed: " .. zone)
	assert(math.abs(frame:GetBoundingBox().Position.X - column) < 0.05, "Portal frame is offset: " .. zone)
end

local backup = Instance.new("Folder")
backup.Name = backupName
local saved = courtyard:Clone()
saved.Name = "RefugeCourtyard_Before"
saved.Parent = backup
backup.Parent = ServerStorage

local infrastructure = Instance.new("Folder")
infrastructure.Name = "RefugeTierInfrastructure"
infrastructure.Parent = courtyard
local function part(parent, name, size, position, color, material, transparency)
	local p = Instance.new("Part")
	p.Name, p.Size, p.Position = name, size, position
	p.Anchored = true
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p.CastShadow = true
	p.Material, p.Color, p.Transparency = material, color, transparency or 0
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local darkMetal = Color3.fromRGB(31, 39, 42)
local steel = Color3.fromRGB(74, 82, 79)
local padDark = Color3.fromRGB(27, 34, 38)
local routeStone = Color3.fromRGB(58, 75, 88)
for row, tier in ipairs(rows) do
	local gate = Instance.new("Model")
	gate.Name = "TierGate_" .. row
	gate:SetAttribute("Tier", row)
	gate.Parent = infrastructure
	local z = tier.z + 0.65
	for _, x in ipairs({ -89, 89 }) do
		part(gate, "SupportColumn", Vector3.new(1.8, 21, 1.8), Vector3.new(x, 10.7, z), darkMetal, Enum.Material.CorrodedMetal)
		part(gate, "FootPlate", Vector3.new(3.2, 0.18, 3.2), Vector3.new(x, 0.29, z), steel, Enum.Material.Metal)
		part(gate, "TierLightBar", Vector3.new(0.18, 13.5, 0.12), Vector3.new(x, 12.2, z - 1.02), tier.color, Enum.Material.Neon, 0.08)
	end
	part(gate, "HeaderBeam", Vector3.new(180, 1.2, 1.5), Vector3.new(0, 21.35, z), darkMetal, Enum.Material.CorrodedMetal)
	part(gate, "SignBacking", Vector3.new(178, 0.65, 0.5), Vector3.new(0, 18.5, z + 1.15), steel, Enum.Material.Metal)
	part(gate, "LowerBrace", Vector3.new(180, 0.65, 1.1), Vector3.new(0, 16.35, z + 0.65), darkMetal, Enum.Material.CorrodedMetal)
	part(gate, "TierGlowRail", Vector3.new(160, 0.14, 0.12), Vector3.new(0, 21.35, z - 0.82), tier.color, Enum.Material.Neon, 0.08)
	for _, x in ipairs({ -84, 84 }) do
		local lamp = part(gate, "TierLamp", Vector3.new(0.9, 0.55, 0.45), Vector3.new(x, 21.35, z - 1.05), tier.color, Enum.Material.Neon)
		local light = Instance.new("PointLight")
		light.Name = "TierLight"
		light.Color, light.Brightness, light.Range, light.Shadows = tier.color, 0.55, 16, false
		light.Parent = lamp
	end
end

local approach = Instance.new("Folder")
approach.Name = "PortalApproaches"
approach.Parent = infrastructure
for index, zone in ipairs(zones) do
	local x = columns[((index - 1) % 6) + 1]
	local row = math.floor((index - 1) / 6) + 1
	local z = rows[row].z + 13
	local pad = Instance.new("Model")
	pad.Name = "Approach_" .. zone
	pad:SetAttribute("DestinationZone", zone)
	pad.Parent = approach
	part(pad, "Threshold", Vector3.new(22, 0.12, 11), Vector3.new(x, 0.26, z), padDark, Enum.Material.Asphalt)
	part(pad, "EntryStripe", Vector3.new(18, 0.06, 0.16), Vector3.new(x, 0.35, z - 5.25), rows[row].color, Enum.Material.Neon, 0.08)
	part(pad, "ExitStripe", Vector3.new(18, 0.06, 0.16), Vector3.new(x, 0.35, z + 5.25), rows[row].color, Enum.Material.Neon, 0.08)
end

local aisleLinks = Instance.new("Folder")
aisleLinks.Name = "AisleLinks"
aisleLinks.Parent = approach
for row, tier in ipairs(rows) do
	for _, side in ipairs({ -1, 1 }) do
		local direction = side < 0 and "Left" or "Right"
		local innerEdge, outerEdge = side * (path.Size.X / 2 - 0.2), side * (columns[#columns] + 11 + 0.2)
		part(aisleLinks, string.format("TierAisle_%d_%s", row, direction), Vector3.new(math.abs(outerEdge - innerEdge), 0.12, 8), Vector3.new((innerEdge + outerEdge) / 2, 0.24, tier.z + 22), routeStone, Enum.Material.Slate)
		for _, column in ipairs(columns) do
			if (column < 0 and side < 0) or (column > 0 and side > 0) then
				part(aisleLinks, string.format("PortalConnector_%d_%d", row, math.abs(column)), Vector3.new(8.5, 0.12, 9), Vector3.new(column, 0.24, tier.z + 17.5), routeStone, Enum.Material.Slate)
			end
		end
	end
end

local total = 0
for _, item in ipairs(infrastructure:GetDescendants()) do
	if item:IsA("BasePart") then
		total += 1
		assert(item.Anchored and not item.CanCollide and not item.CanTouch and not item.CanQuery, "Infrastructure must remain decorative: " .. item:GetFullName())
	end
end
local approachCount, aisleCount, connectorCount = 0, 0, 0
for _, item in ipairs(approach:GetChildren()) do
	if item:IsA("Model") and string.match(item.Name, "^Approach_") then approachCount += 1
	end
for _, item in ipairs(aisleLinks:GetChildren()) do
	if item:IsA("BasePart") and string.match(item.Name, "^TierAisle_") then aisleCount += 1
	elseif item:IsA("BasePart") and string.match(item.Name, "^PortalConnector_") then connectorCount += 1 end
end
assert(approachCount == 18 and aisleCount == 6 and connectorCount == 18 and #infrastructure:FindFirstChild("TierGate_1"):GetChildren() >= 10, "Wayfinding build incomplete")
assert(89 + 0.9 < ground.Position.X + ground.Size.X / 2 and rows[3].z < ground.Position.Z + ground.Size.Z / 2, "New structure exceeds courtyard bounds")
assert(28 - 11 - path.Size.X / 2 >= 4, "Portal approaches encroach on the central lane")

return string.format("REFUGE_TIER_INFRASTRUCTURE_OK backup=%s tierGates=3 approaches=18 rowWalkways=6 decorativeParts=%d laneClearance=5.0 groundContained=true", backup.Name, total)
