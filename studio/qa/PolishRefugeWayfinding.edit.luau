-- One-shot Studio Edit repair. Never install this as a startup script or run it during Play.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Use the target place in Edit mode")

local frames = workspace.ImportedEnvironmentModels.Refuge.PortalFrames
local portals = workspace.ProgressionZones.RefugePortals
local courtyard = workspace.RefugeCourtyard
local arena = workspace:FindFirstChild("SurvivorArena")
local weaponModels = ReplicatedStorage:FindFirstChild("WeaponModels")
local machete = weaponModels and weaponModels:FindFirstChild("Machete")
local blade = machete and machete:FindFirstChild("blade_geom", true)
local surface = blade and blade:FindFirstChildOfClass("SurfaceAppearance")
local path = courtyard:FindFirstChild("CentralPath")
local ground = courtyard:FindFirstChild("CourtyardGround")
local arenaFloor = arena and arena:FindFirstChild("ArenaFloor", true)
local tier3 = courtyard:FindFirstChild("RefugeTierSign_3")
local backupName = "BeforeRefugeWayfindingPolish_20261029"
assert(frames and portals and arena and machete and surface and path and ground and arenaFloor and tier3, "Required refuge/weapon geometry is missing")
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect it before rerunning")
assert(#frames:GetChildren() == 19, "Expected 19 portal frames")
assert(surface.ColorMap ~= "", "Machete blade has no color map to tint")
local oldBladeTint = Color3.fromRGB(164, 209, 193)
assert(math.abs(surface.Color.R - oldBladeTint.R) < 0.01 and math.abs(surface.Color.G - oldBladeTint.G) < 0.01 and math.abs(surface.Color.B - oldBladeTint.B) < 0.01, "Machete blade palette changed since inspection")
assert(math.abs(arenaFloor.Position.X - 48) < 0.1 and math.abs(arenaFloor.Position.Z - 326) < 0.1, "PvP arena changed since inspection")

local zoneOrder = {
	"Factory", "Lab", "Harbor", "Power", "Metro", "Quarantine", "Dam", "Citadel", "Crater",
	"GlassSea", "Skyline", "OrbitalWreck", "Depths", "IronSanctum", "LastConvoy", "Gridfall",
	"BlackoutCore", "EclipseVault",
}
local oldXs, newXs, rowZ = { -72, -48, -20, 20, 48, 72 }, { -80, -52, -28, 28, 52, 80 }, { 260, 305, 350 }
local plan, promptCount = {}, 0
for index, zone in ipairs(zoneOrder) do
	local col, row = ((index - 1) % 6) + 1, math.floor((index - 1) / 6) + 1
	local travel = portals:FindFirstChild("Travel_" .. zone)
	local frame = frames:FindFirstChild("PortalFrame_" .. zone)
	local field = travel and travel:FindFirstChild("Field", true)
	local count = 0
	if travel then for _, item in ipairs(travel:GetDescendants()) do if item:IsA("ProximityPrompt") and item.Name == "ZoneTravel" then count += 1 end end end
	assert(travel and frame and field and count == 1, "Incomplete portal pair or prompt: " .. zone)
	assert(math.abs(field.Position.X - oldXs[col]) < 0.05 and math.abs(field.Position.Z - rowZ[row]) < 0.05, "Unexpected portal placement: " .. zone)
	local bounds = frame:GetBoundingBox()
	assert(math.abs(bounds.Position.X - oldXs[col]) < 0.05 and math.abs(bounds.Position.Z - rowZ[row]) < 0.05, "Frame is not aligned with travel field: " .. zone)
	promptCount += count
	table.insert(plan, { zone = zone, travel = travel, frame = frame, field = field, x = newXs[col], z = rowZ[row] })
end
local city = portals:FindFirstChild("Travel_City")
assert(city and city:FindFirstChild("Field", true), "City portal is missing")
for _, item in ipairs(city:GetDescendants()) do if item:IsA("ProximityPrompt") and item.Name == "ZoneTravel" then promptCount += 1 end end
assert(promptCount == 19, "Expected all 19 travel prompts")

local function cloneInto(item, parent, suffix)
	local copy = item:Clone()
	copy.Name = item.Name .. suffix
	copy.Parent = parent
end
local backup = Instance.new("Folder")
backup.Name = backupName
for _, item in ipairs(plan) do cloneInto(item.travel, backup, "_Before"); cloneInto(item.frame, backup, "_Before") end
cloneInto(city, backup, "_Before")
cloneInto(frames:FindFirstChild("PortalFrame_City"), backup, "_Before")
cloneInto(arena, backup, "_Before")
cloneInto(tier3, backup, "_Before")
cloneInto(path, backup, "_Before")
for _, name in ipairs({ "PathEdgeGuide_L", "PathEdgeGuide_R" }) do local item = courtyard:FindFirstChild(name); if item then cloneInto(item, backup, "_Before") end end
cloneInto(machete, backup, "_Before")
backup.Parent = ServerStorage

for _, item in ipairs(plan) do
	local delta = Vector3.new(item.x - item.field.Position.X, 0, item.z - item.field.Position.Z)
	item.travel:PivotTo(item.travel:GetPivot() + delta)
	local bounds = item.frame:GetBoundingBox()
	local frameDelta = Vector3.new(item.x - bounds.Position.X, 0, item.z - bounds.Position.Z)
	item.frame:PivotTo(item.frame:GetPivot() + frameDelta)
end

local arenaDelta = Vector3.new(130 - arenaFloor.Position.X, 0, 0)
arena:PivotTo(arena:GetPivot() + arenaDelta)
local tint = Color3.fromRGB(52, 220, 174)
surface.Color = tint

local function addPath(name, size, position, material, color, transparency)
	local item = Instance.new("Part")
	item.Name, item.Size, item.Position = name, size, position
	item.Anchored = true
	item.CanCollide, item.CanTouch, item.CanQuery = false, false, false
	item.Material, item.Color, item.Transparency = material, color, transparency or 0
	item.TopSurface, item.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	item.Parent = courtyard
	return item
end
assert(not courtyard:FindFirstChild("PVPAccessPath"), "PVP access path already exists")
addPath("PVPAccessPath", Vector3.new(110, path.Size.Y, 10), Vector3.new(55, path.Position.Y, 326), path.Material, path.Color)
addPath("PVPPathGuide_L", Vector3.new(90, 0.04, 0.14), Vector3.new(61, 0.31, 321), Enum.Material.Neon, Color3.fromRGB(55, 178, 170), 0.2)
addPath("PVPPathGuide_R", Vector3.new(90, 0.04, 0.14), Vector3.new(61, 0.31, 331), Enum.Material.Neon, Color3.fromRGB(55, 178, 170), 0.2)

local function separatedXZ(a, as, b, bs, gap)
	return math.abs(a.X - b.X) >= (as.X + bs.X) / 2 + gap or math.abs(a.Z - b.Z) >= (as.Z + bs.Z) / 2 + gap
end
local minPathClearance = math.huge
local minPortalGap = math.huge
local bounds = {}
for _, item in ipairs(plan) do
	local field = item.travel:FindFirstChild("Field", true)
	local center, size = item.frame:GetBoundingBox()
	assert(math.abs(field.Position.X - item.x) < 0.05 and math.abs(field.Position.Z - item.z) < 0.05, "Travel field translation failed: " .. item.zone)
	assert(math.abs(center.Position.X - item.x) < 0.05 and math.abs(center.Position.Z - item.z) < 0.05, "Frame translation failed: " .. item.zone)
	assert(center.Position.X - size.X / 2 >= ground.Position.X - ground.Size.X / 2 and center.Position.X + size.X / 2 <= ground.Position.X + ground.Size.X / 2, "Frame outside refuge: " .. item.zone)
	local laneClearance = math.abs(item.x) - size.X / 2 - path.Size.X / 2
	minPathClearance = math.min(minPathClearance, laneClearance)
	table.insert(bounds, { p = center.Position, s = size, name = item.zone })
end
for i = 1, #bounds do for j = i + 1, #bounds do
	local a, b = bounds[i], bounds[j]
	if math.abs(a.p.Z - b.p.Z) < (a.s.Z + b.s.Z) / 2 then minPortalGap = math.min(minPortalGap, math.abs(a.p.X - b.p.X) - (a.s.X + b.s.X) / 2) end
end end
local arenaPos, arenaSize = arena:GetBoundingBox()
local tierPos, tierSize = tier3.Position, tier3.Size
assert(separatedXZ(arenaPos.Position, arenaSize, tierPos, tierSize, 1), "PvP arena still overlaps the tier-three sign")
assert(minPathClearance >= 8, "Portal row still crowds the central aisle")
assert(minPortalGap >= 10, "Portal models are too close to one another")
for _, item in ipairs(bounds) do assert(separatedXZ(arenaPos.Position, arenaSize, item.p, item.s, 2), "PvP arena overlaps portal frame: " .. item.name) end
assert(courtyard:FindFirstChild("PVPAccessPath") and courtyard:FindFirstChild("PVPPathGuide_L") and courtyard:FindFirstChild("PVPPathGuide_R"), "PVP walkway incomplete")
assert(math.abs(arenaFloor.Position.X - 130) < 0.05, "PvP arena floor missed its side-court target")
assert(math.abs(surface.Color.G - tint.G) < 0.01 and math.abs(surface.Color.R - tint.R) < 0.01, "Machete tint was not applied")

return string.format("REFUGE_POLISHED backup=%s portals=%d prompts=%d laneClearance=%.1f minPortalGap=%.1f arenaFloorX=%.1f tier3ArenaOverlap=false pvpWalkway=110x10 macheteBladeTint=%s", backup:GetFullName(), #plan + 1, promptCount, minPathClearance, minPortalGap, arenaFloor.Position.X, tostring(surface.Color))
