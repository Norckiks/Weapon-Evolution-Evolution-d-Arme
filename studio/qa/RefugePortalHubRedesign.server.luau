-- One-time Studio Edit repair. Never install as a startup script.
-- Recolors imported Refuge/City meshes and aligns all visual frames with their existing travel gates.
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local WorldConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("WorldConfig"))
local refuge = workspace.ImportedEnvironmentModels.Refuge
local city = workspace.ImportedEnvironmentModels.City
local travelFolder = workspace.ProgressionZones.RefugePortals
local courtyard = workspace.RefugeCourtyard
local backup = ServerStorage:FindFirstChild("BeforeRefugeHubRedesign_20261029")
assert(backup, "Run the backup step before applying this edit")
assert(refuge and city and travelFolder and courtyard, "Refuge hub source instances are missing")

local function color(r, g, b) return Color3.fromRGB(r, g, b) end
local zoneOrder = {
	"Factory", "Lab", "Harbor", "Power", "Metro", "Quarantine",
	"Dam", "Citadel", "Crater", "GlassSea", "Skyline", "OrbitalWreck",
	"Depths", "IronSanctum", "LastConvoy", "Gridfall", "BlackoutCore", "EclipseVault",
}
local accents = {
	Factory = color(227, 111, 43), Lab = color(46, 190, 204), Harbor = color(49, 122, 201),
	Power = color(239, 190, 58), Metro = color(156, 104, 207), Quarantine = color(116, 179, 83),
	Dam = color(50, 169, 157), Citadel = color(204, 71, 59), Crater = color(240, 123, 42),
	GlassSea = color(63, 194, 190), Skyline = color(217, 84, 166), OrbitalWreck = color(91, 145, 219),
	Depths = color(44, 162, 194), IronSanctum = color(196, 104, 51), LastConvoy = color(234, 177, 55),
	Gridfall = color(124, 193, 89), BlackoutCore = color(147, 100, 218), EclipseVault = color(204, 164, 255),
}

local function suffixOf(name)
	name = string.lower(name)
	for _, suffix in ipairs({ "concrete_dark", "asphalt", "concrete", "glass", "iron", "rust", "wood", "brick", "red", "cyan", "yellow", "paint", "glow", "portal", "label" }) do
		if name:match("_" .. suffix .. "%.?%d*$") then return suffix end
	end
	return ""
end

local function styleEnvironment(model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local suffix = suffixOf(part.Name)
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			if suffix == "asphalt" then part.Color, part.Material = color(31, 39, 39), Enum.Material.Asphalt
			elseif suffix == "concrete_dark" then part.Color, part.Material = color(42, 50, 49), Enum.Material.Slate
			elseif suffix == "concrete" then part.Color, part.Material = color(91, 91, 82), Enum.Material.Concrete
			elseif suffix == "glass" then part.Color, part.Material, part.Transparency = color(45, 114, 126), Enum.Material.Glass, 0.28
			elseif suffix == "iron" then part.Color, part.Material = color(79, 91, 89), Enum.Material.CorrodedMetal
			elseif suffix == "rust" then part.Color, part.Material = color(139, 72, 43), Enum.Material.CorrodedMetal
			elseif suffix == "wood" then part.Color, part.Material = color(102, 71, 48), Enum.Material.WoodPlanks
			elseif suffix == "brick" then part.Color, part.Material = color(111, 63, 53), Enum.Material.Brick
			elseif suffix == "red" then part.Color, part.Material = color(177, 54, 48), Enum.Material.Neon
			elseif suffix == "cyan" then part.Color, part.Material = color(51, 175, 195), Enum.Material.Neon
			elseif suffix == "yellow" or suffix == "paint" then part.Color, part.Material = color(211, 156, 59), Enum.Material.Metal
			elseif suffix == "glow" or suffix == "portal" then part.Color, part.Material = color(76, 187, 196), Enum.Material.Neon
			elseif suffix == "label" then part.Color, part.Material = color(221, 208, 165), Enum.Material.SmoothPlastic
			else part.Color, part.Material = color(71, 79, 75), Enum.Material.Concrete end
		end
	end
end

local function applyPortalGuidanceLight(plate, accent)
	local hue, saturation, value = accent:ToHSV()
	local light = plate:FindFirstChild("PortalGuidanceLight") or Instance.new("PointLight")
	light.Name = "PortalGuidanceLight"
	light.Color = Color3.fromHSV(hue, math.max(saturation, 0.78), math.max(value, 0.9))
	light.Brightness, light.Range, light.Shadows, light.Enabled = 0.55, 16, false, true
	light.Parent = plate
	return light
end

for _, model in ipairs(city:GetChildren()) do if model:IsA("Model") then styleEnvironment(model) end end
for _, model in ipairs(refuge:GetChildren()) do if model:IsA("Model") then styleEnvironment(model) end end

local portalFrames = refuge:FindFirstChild("PortalFrames")
if not portalFrames then
	portalFrames = Instance.new("Folder")
	portalFrames.Name = "PortalFrames"
	portalFrames.Parent = refuge
end
local sourceNames = {
	Factory = "Refuge_Portal_01_Usine_Niv5", Lab = "Refuge_Portal_02_Laboratoire_Niv12",
	Harbor = "Refuge_Portal_03_Port_Niv20", Power = "Refuge_Portal_04_Centrale_Niv28",
	Metro = "Refuge_Portal_05_Metro_Niv35", Quarantine = "Refuge_Portal_06_Quarantaine_Niv45",
	Dam = "Refuge_Portal_07_Barrage_Niv60", Citadel = "Refuge_Portal_08_Citadelle_Niv80",
}
local zoneInfo = {}
for _, zone in ipairs(WorldConfig.Zones) do zoneInfo[zone.Id] = zone end
local cityFrame = refuge:FindFirstChild("Refuge_02_Porte_Ville") or portalFrames:FindFirstChild("PortalFrame_City")
assert(cityFrame, "Imported City portal frame missing")
cityFrame.Name = "PortalFrame_City"
cityFrame.Parent = portalFrames
local template = refuge:FindFirstChild(sourceNames.Citadel) or portalFrames:FindFirstChild("PortalFrame_Citadel")
assert(template, "Imported portal frame template missing")
local frames = { City = cityFrame }
for _, zone in ipairs(zoneOrder) do
	local frame = portalFrames:FindFirstChild("PortalFrame_" .. zone)
	if not frame then
		local sourceName = sourceNames[zone]
		local source = sourceName and refuge:FindFirstChild(sourceName)
		frame = source or template:Clone()
		frame.Parent = portalFrames
	end
	frame.Name = "PortalFrame_" .. zone
	frame:SetAttribute("DestinationZone", zone)
	frames[zone] = frame
end

local gateXs = { -80, -52, -28, 28, 52, 80 }
local gateRows = { 260, 305, 350 }
for index, zone in ipairs(zoneOrder) do
	local travel = travelFolder:FindFirstChild("Travel_" .. zone)
	assert(travel and travel:IsA("Model"), "Missing functional travel model for " .. zone)
	local field = travel:FindFirstChild("Field", true)
	assert(field and field:IsA("BasePart"), "Missing portal field for " .. zone)
	local oldPivot = travel:GetPivot()
	local rotation = oldPivot - oldPivot.Position
	local column = ((index - 1) % 6) + 1
	local row = math.floor((index - 1) / 6) + 1
	local x, z = gateXs[column], gateRows[row]
	local fieldOffset = oldPivot.Position - field.Position
	travel:PivotTo(CFrame.new(Vector3.new(x, 4.5, z) + fieldOffset) * rotation)
	local frame = frames[zone]
	local framePivot = frame:GetPivot()
	frame:PivotTo(CFrame.new(x, 8.075, z) * (framePivot - framePivot.Position))
	-- Imported Models can retain a custom WorldPivot that is detached from their mesh bounds.
	local geometryOffset = frame:GetPivot().Position - frame:GetBoundingBox().Position
	for _, part in ipairs(frame:GetDescendants()) do
		if part:IsA("BasePart") then part.CFrame += geometryOffset end
	end
	for _, part in ipairs(frame:GetDescendants()) do
		if part:IsA("BasePart") then
			local suffix = suffixOf(part.Name)
			local accent = accents[zone]
			part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
			if suffix == "glow" or suffix == "portal" or suffix == "cyan" or suffix == "red" then
				part.Color, part.Material = accent, Enum.Material.Neon
			elseif suffix == "paint" or suffix == "yellow" then
				part.Color, part.Material = accent:Lerp(color(236, 190, 95), 0.42), Enum.Material.Metal
			elseif suffix == "label" then part.Color = color(236, 221, 178)
			elseif suffix == "concrete" then part.Color, part.Material = color(83, 87, 80), Enum.Material.Concrete
			elseif suffix == "concrete_dark" then part.Color, part.Material = color(34, 42, 43), Enum.Material.Slate
			elseif suffix == "iron" then part.Color, part.Material = color(77, 87, 86), Enum.Material.CorrodedMetal
			elseif suffix == "rust" then part.Color, part.Material = color(139, 72, 43), Enum.Material.CorrodedMetal
			end
		end
	end
	local portalPlate
	for _, part in ipairs(frame:GetDescendants()) do
		if part:IsA("BasePart") and suffixOf(part.Name) == "paint" then portalPlate = part; break end
	end
	assert(portalPlate, "Missing portal guidance plate: " .. zone)
	applyPortalGuidanceLight(portalPlate, accents[zone])
end
local portalLabels, hiddenBakedLabels = 0, 0
local function applyPortalLabel(plate, face, zone)
	local gui = plate:FindFirstChild("RefugeZoneLabel_" .. face.Name) or Instance.new("SurfaceGui")
	gui.Name, gui.Face = "RefugeZoneLabel_" .. face.Name, face
	gui.SizingMode, gui.CanvasSize = Enum.SurfaceGuiSizingMode.FixedSize, Vector2.new(940, 120)
	gui.LightInfluence, gui.AlwaysOnTop, gui.Parent = 0, false, plate
	local label = gui:FindFirstChild("Text") or Instance.new("TextLabel")
	label.Name, label.Size = "Text", UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = zone.Name .. "\nNIVEAU " .. zone.Level
	label.TextColor3, label.TextStrokeColor3, label.TextStrokeTransparency = color(255, 243, 215), color(12, 16, 18), 0.2
	label.Font, label.TextSize, label.TextScaled, label.TextWrapped = Enum.Font.GothamBlack, 34, true, true
	label.Parent = gui
end
for _, zone in ipairs(zoneOrder) do
	local frame, info = frames[zone], zoneInfo[zone]
	assert(info, "Missing configured portal label: " .. zone)
	local plate
	for _, part in ipairs(frame:GetDescendants()) do
		if part:IsA("BasePart") then
			local name = string.lower(part.Name)
			if string.find(name, "_paint", 1, true) then plate = part end
			if string.find(name, "_label", 1, true) then part.Transparency = 1; hiddenBakedLabels += 1 end
		end
	end
	assert(plate, "Missing portal sign plate: " .. zone)
	applyPortalLabel(plate, Enum.NormalId.Front, info)
	applyPortalLabel(plate, Enum.NormalId.Back, info)
	portalLabels += 1
end
local cityField = travelFolder.Travel_City:FindFirstChild("Field", true)
local cityPivot = cityFrame:GetPivot()
cityFrame:PivotTo(CFrame.new(0, 8.075, 208) * (cityPivot - cityPivot.Position))
local cityPlate
for _, part in ipairs(cityFrame:GetDescendants()) do
	if part:IsA("BasePart") and suffixOf(part.Name) == "paint" then cityPlate = part; break end
end
assert(cityPlate, "Missing City portal guidance plate")
applyPortalGuidanceLight(cityPlate, accents.City or zoneInfo.City.Color)

local ground = courtyard:FindFirstChild("CourtyardGround")
local path = courtyard:FindFirstChild("CentralPath")
assert(ground and path, "Courtyard floor or path missing")
ground.Size, ground.Position = Vector3.new(380, 0.2, 190), Vector3.new(16, 0.1, 295)
path.Size, path.Position, path.Color, path.Material = Vector3.new(24, 0.08, 170), Vector3.new(0, 0.24, 290), color(43, 54, 67), Enum.Material.Slate
local stripes = {}
for _, part in ipairs(courtyard:GetChildren()) do if part.Name == "PathStripe" then table.insert(stripes, part) end end
table.sort(stripes, function(a,b) return a.Position.Z < b.Position.Z end)
for i, part in ipairs(stripes) do part.Position = Vector3.new(0, 0.31, 226 + (i - 1) * 28) end
for _, x in ipairs({ -11.25, 11.25 }) do
	local edge = courtyard:FindFirstChild(x < 0 and "PathEdgeGuide_L" or "PathEdgeGuide_R")
	if not edge then edge = Instance.new("Part"); edge.Name = x < 0 and "PathEdgeGuide_L" or "PathEdgeGuide_R"; edge.Parent = courtyard end
	edge.Size, edge.Position = Vector3.new(0.14, 0.04, 166), Vector3.new(x, 0.31, 290)
	edge.Anchored, edge.CanCollide, edge.CanTouch, edge.CanQuery = true, false, false, false
	edge.Material, edge.Color, edge.Transparency = Enum.Material.Neon, color(55, 178, 170), 0.2
end

for _, part in ipairs(courtyard:GetChildren()) do
	if part:IsA("BasePart") then
		if part.Name == "SideFence" then
			part.Size = Vector3.new(1, 6, 190)
			part.Position = Vector3.new(part.Position.X < 0 and -174 or 206, 3, 295)
		elseif part.Name == "RearFence" then
			part.Size = Vector3.new(380, 6, 1); part.Position = Vector3.new(16, 3, 390)
		elseif part.Name == "LampPost" or part.Name == "Lamp" then
			local left = part.Position.X < 0
			local row = math.floor((part.Position.Z - 250) / 40 + 0.5)
			local z = 250 + math.clamp(row, 0, 2) * 50
			part.Position = Vector3.new(left and -105 or 112, part.Name == "Lamp" and 12 or 6, z)
		end
	end
end
local fencePosts, rearPosts = {}, {}
for _, part in ipairs(courtyard:GetChildren()) do
	if part.Name == "FencePost" then table.insert(fencePosts, part)
	elseif part.Name == "RearPost" then table.insert(rearPosts, part) end
end
table.sort(fencePosts, function(a, b) if a.Position.X == b.Position.X then return a.Position.Z < b.Position.Z end return a.Position.X < b.Position.X end)
for i, part in ipairs(fencePosts) do
	local sideIndex = math.floor((i - 1) / 5)
	local postIndex = ((i - 1) % 5) + 1
	part.Position = Vector3.new(sideIndex == 0 and -174 or 206, 4, 220 + (postIndex - 1) * 37.5)
end
table.sort(rearPosts, function(a, b) return a.Position.X < b.Position.X end)
for i, part in ipairs(rearPosts) do part.Position = Vector3.new(-174 + (i - 1) * 47.5, 4, 390) end

local seats = {}
for _, part in ipairs(courtyard:GetChildren()) do if part.Name == "BenchSeat" then table.insert(seats, part) end end
table.sort(seats, function(a,b) if a.Position.X == b.Position.X then return a.Position.Z < b.Position.Z end return a.Position.X < b.Position.X end)
local targets = {
	Vector3.new(-128, 2, 235), Vector3.new(-128, 2, 295), Vector3.new(-128, 2, 355),
	Vector3.new(160, 2, 235), Vector3.new(40, 2, 380), Vector3.new(160, 2, 355),
}
for _, seat in ipairs(seats) do
	local old = seat.Position
	local target = targets[_]
	local delta = target - old
	for _, part in ipairs(courtyard:GetChildren()) do
		if part:IsA("BasePart") and part.Name:match("^Bench") and (part.Position - old).Magnitude < 16 then part.Position += delta end
	end
end

local shelters = { "Refuge_Abri_01", "Refuge_Abri_02", "Refuge_Abri_03", "Refuge_Abri_04" }
local shelterPositions = { Vector3.new(-145, 0, 235), Vector3.new(177, 0, 235), Vector3.new(-145, 0, 365), Vector3.new(177, 0, 365) }
local refugeGeometryAligned = 0
local function alignGeometryAtBase(model, target)
	local bounds, size = model:GetBoundingBox()
	local delta = target + Vector3.new(0, size.Y / 2, 0) - bounds.Position
	for _, part in ipairs(model:GetDescendants()) do if part:IsA("BasePart") then part.CFrame += delta end end
	local corrected, correctedSize = model:GetBoundingBox()
	assert((corrected.Position - target - Vector3.new(0, correctedSize.Y / 2, 0)).Magnitude < 0.05, "Refuge model geometry did not align: " .. model.Name)
	refugeGeometryAligned += 1
end
for i, name in ipairs(shelters) do
	local model = refuge:FindFirstChild(name)
	if model then
		local cf = model:GetPivot()
		model:PivotTo(CFrame.new(shelterPositions[i]) * (cf - cf.Position))
		alignGeometryAtBase(model, shelterPositions[i])
	end
end
local terminal = refuge:FindFirstChild("Refuge_03_Terminal")
if terminal then
	local target = Vector3.new(-130, 0, 300)
	local cf = terminal:GetPivot()
	terminal:PivotTo(CFrame.new(target.X, cf.Position.Y, target.Z) * (cf - cf.Position))
	alignGeometryAtBase(terminal, target)
end

-- The imported camp is merged by material; move it as one group to clear the reorganized portal rows.
local camp = refuge:FindFirstChild("Refuge_04_Vie_du_camp")
assert(camp, "Imported camp model missing")
local campBounds, campSize = camp:GetBoundingBox()
assert(campSize.X > 175 and campSize.X < 185 and campSize.Z > 112 and campSize.Z < 124,
	"Unexpected camp footprint; inspect before moving")
local campParts = {}
for _, item in ipairs(camp:GetDescendants()) do if item:IsA("BasePart") then table.insert(campParts, item) end end
assert(#campParts == 4, "Unexpected camp mesh count; inspect before moving")
local campBackupName = "BeforeRefugeCampPortalClearance_20261029"
assert(not ServerStorage:FindFirstChild(campBackupName), "Camp backup already exists; inspect before rerunning")
local campBackup = Instance.new("Folder")
campBackup.Name = campBackupName
camp:Clone().Parent = campBackup
campBackup.Parent = ServerStorage
local campScale = 0.357
local campTarget = Vector3.new(169.5, campSize.Y * campScale / 2, 275)
for _, part in ipairs(campParts) do
	local oldCFrame = part.CFrame
	local targetPosition = campTarget + (oldCFrame.Position - campBounds.Position) * campScale
	part.Size *= campScale
	part.CFrame = CFrame.new(targetPosition) * (oldCFrame - oldCFrame.Position)
	part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
end
camp.WorldPivot = CFrame.new(campTarget)
local correctedCamp, correctedCampSize = camp:GetBoundingBox()
local campMinX, campMaxX = correctedCamp.Position.X - correctedCampSize.X / 2, correctedCamp.Position.X + correctedCampSize.X / 2
local campMinZ, campMaxZ = correctedCamp.Position.Z - correctedCampSize.Z / 2, correctedCamp.Position.Z + correctedCampSize.Z / 2
local campOverlaps = 0
for _, frame in ipairs(portalFrames:GetChildren()) do
	if frame:IsA("Model") then
		local cf, size = frame:GetBoundingBox()
		local separated = campMaxX <= cf.Position.X - size.X / 2 or campMinX >= cf.Position.X + size.X / 2
			or campMaxZ <= cf.Position.Z - size.Z / 2 or campMinZ >= cf.Position.Z + size.Z / 2
		if not separated then campOverlaps += 1 end
	end
end
assert(campOverlaps == 0, "Camp overlaps portal frames")
assert(math.abs(correctedCamp.Position.Y - correctedCampSize.Y / 2) < 0.05, "Camp is not resting on the courtyard floor")
local function separatedFrom(object, margin)
	local cf, size
	if object:IsA("Model") then cf, size = object:GetBoundingBox() else cf, size = object.CFrame, object.Size end
	return campMaxX + margin <= cf.Position.X - size.X / 2 or campMinX - margin >= cf.Position.X + size.X / 2
		or campMaxZ + margin <= cf.Position.Z - size.Z / 2 or campMinZ - margin >= cf.Position.Z + size.Z / 2
end
local shopAccess = courtyard:FindFirstChild("ShopAccessWalkways")
assert(shopAccess, "Shop access walkways are missing")
for _, segment in ipairs(shopAccess:GetDescendants()) do
	if segment:IsA("BasePart") then assert(separatedFrom(segment, 2), "Camp overlaps shop route " .. segment.Name) end
end
for _, shop in ipairs(workspace:WaitForChild("RefugeShops"):GetChildren()) do
	if shop:IsA("Model") then assert(separatedFrom(shop, 2), "Camp overlaps shop " .. shop.Name) end
end
local pvpAccess = courtyard:FindFirstChild("PVPAccessPath")
assert(pvpAccess and separatedFrom(pvpAccess, 2), "Camp overlaps PVP access path")
local arena = workspace:FindFirstChild("SurvivorArena")
for _, name in ipairs({ "ArenaFloor", "FightBounds" }) do
	local object = arena and arena:FindFirstChild(name)
	assert(object and separatedFrom(object, 2), "Camp overlaps PVP " .. name)
end

-- Move the sign to the entry edge so it remains readable before the first tier of gates.
local refugeSign = courtyard:FindFirstChild("RefugeSign")
if refugeSign then
	refugeSign.Position, refugeSign.Color, refugeSign.Material = Vector3.new(0, 10, 238), color(129, 91, 36), Enum.Material.Metal
	for _, label in ipairs(refugeSign:GetDescendants()) do
		if label:IsA("TextLabel") then label.TextColor3, label.TextStrokeColor3, label.TextStrokeTransparency = color(255, 213, 119), color(18, 22, 22), 0.25 end
	end
end
for _, p in ipairs(courtyard:GetChildren()) do
	if p.Name == "SignPost" then p.Position = Vector3.new(p.Position.X < 0 and -9 or 9, 4, 238) end
end

local tierSigns = {
	{ text = "EXPÉDITIONS I  ·  NIVEAUX 05–45", z = 247, accent = color(239, 145, 63) },
	{ text = "EXPÉDITIONS II  ·  NIVEAUX 60–160", z = 292, accent = color(82, 194, 183) },
	{ text = "EXPÉDITIONS III  ·  NIVEAUX 180–280", z = 337, accent = color(178, 143, 214) },
}
for index, tier in ipairs(tierSigns) do
	local sign = courtyard:FindFirstChild("RefugeTierSign_" .. index)
	if not sign then sign = Instance.new("Part"); sign.Name = "RefugeTierSign_" .. index; sign.Parent = courtyard end
	sign.Size, sign.Position = Vector3.new(160, 3.6, 0.8), Vector3.new(0, 18.5, tier.z)
	sign.Anchored, sign.CanCollide, sign.CanTouch, sign.CanQuery = true, false, false, false
	sign.Material, sign.Color = Enum.Material.CorrodedMetal, color(25, 32, 35)
	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local gui = sign:FindFirstChild("TierText_" .. face.Name) or Instance.new("SurfaceGui")
		gui.Name, gui.Face = "TierText_" .. face.Name, face
		gui.SizingMode, gui.CanvasSize = Enum.SurfaceGuiSizingMode.FixedSize, Vector2.new(1600, 36)
		gui.LightInfluence, gui.AlwaysOnTop, gui.Parent = 0, false, sign
		local label = gui:FindFirstChild("Title") or Instance.new("TextLabel")
		label.Name, label.Size, label.BackgroundTransparency = "Title", UDim2.fromScale(1, 1), 1
		label.Text, label.TextColor3 = tier.text, tier.accent
		label.TextStrokeColor3, label.TextStrokeTransparency = color(8, 12, 14), 0.2
		label.Font, label.TextSize, label.TextScaled = Enum.Font.GothamBlack, 24, false
		label.Parent = gui
	end
	local stripe = courtyard:FindFirstChild("RefugeTierAccent_" .. index)
	if not stripe then stripe = Instance.new("Part"); stripe.Name = "RefugeTierAccent_" .. index; stripe.Parent = courtyard end
	stripe.Size, stripe.Position = Vector3.new(160, 0.16, 0.82), sign.Position + Vector3.new(0, 1.88, 0)
	stripe.Anchored, stripe.CanCollide, stripe.CanTouch, stripe.CanQuery = true, false, false, false
	stripe.Material, stripe.Color = Enum.Material.Neon, tier.accent
end

-- Raised support frames keep the tier banners attached to the refuge architecture.
local infrastructure = courtyard:FindFirstChild("RefugeTierInfrastructure") or Instance.new("Folder")
infrastructure.Name, infrastructure.Parent = "RefugeTierInfrastructure", courtyard
local darkMetal, steel = color(31, 39, 42), color(74, 82, 79)
local function decorativePart(parent, name, size, position, tint, material, transparency)
	local part = parent:FindFirstChild(name) or Instance.new("Part")
	part.Name, part.Size, part.Position = name, size, position
	part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
	part.Material, part.Color, part.Transparency = material, tint, transparency or 0
	part.TopSurface, part.BottomSurface, part.Parent = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth, parent
	return part
end
for index, tier in ipairs(tierSigns) do
	local gate = infrastructure:FindFirstChild("TierGate_" .. index) or Instance.new("Model")
	gate.Name, gate.Parent = "TierGate_" .. index, infrastructure
	local z = tier.z + 0.65
	for _, x in ipairs({ -89, 89 }) do
		decorativePart(gate, "SupportColumn_" .. tostring(x), Vector3.new(1.8, 21, 1.8), Vector3.new(x, 10.7, z), darkMetal, Enum.Material.CorrodedMetal)
		decorativePart(gate, "FootPlate_" .. tostring(x), Vector3.new(3.2, 0.18, 3.2), Vector3.new(x, 0.29, z), steel, Enum.Material.Metal)
		decorativePart(gate, "TierLightBar_" .. tostring(x), Vector3.new(0.18, 13.5, 0.12), Vector3.new(x, 12.2, z - 1.02), tier.accent, Enum.Material.Neon, 0.08)
		local lamp = decorativePart(gate, "TierLamp_" .. tostring(x), Vector3.new(0.9, 0.55, 0.45), Vector3.new(x, 21.35, z - 1.05), tier.accent, Enum.Material.Neon)
		local light = lamp:FindFirstChild("TierLight") or Instance.new("PointLight")
		light.Name, light.Color, light.Brightness, light.Range, light.Shadows = "TierLight", tier.accent, 0.55, 16, false
		light.Parent = lamp
	end
	decorativePart(gate, "HeaderBeam", Vector3.new(180, 1.2, 1.5), Vector3.new(0, 21.35, z), darkMetal, Enum.Material.CorrodedMetal)
	decorativePart(gate, "SignBacking", Vector3.new(178, 0.65, 0.5), Vector3.new(0, 18.5, z + 1.15), steel, Enum.Material.Metal)
	decorativePart(gate, "LowerBrace", Vector3.new(180, 0.65, 1.1), Vector3.new(0, 16.35, z + 0.65), darkMetal, Enum.Material.CorrodedMetal)
	decorativePart(gate, "TierGlowRail", Vector3.new(160, 0.14, 0.12), Vector3.new(0, 21.35, z - 0.82), tier.accent, Enum.Material.Neon, 0.08)
end
local approaches = infrastructure:FindFirstChild("PortalApproaches") or Instance.new("Folder")
approaches.Name, approaches.Parent = "PortalApproaches", infrastructure
local gateColumns = { -80, -52, -28, 28, 52, 80 }
for index, zone in ipairs(zoneOrder) do
	local column = gateColumns[((index - 1) % 6) + 1]
	local row = math.floor((index - 1) / 6) + 1
	local landing = approaches:FindFirstChild("Approach_" .. zone) or Instance.new("Model")
	landing.Name, landing.Parent = "Approach_" .. zone, approaches
	local field = travelFolder:FindFirstChild("Travel_" .. zone):FindFirstChild("Field", true)
	local tint = tierSigns[row].accent
	decorativePart(landing, "Threshold", Vector3.new(22, 0.12, 11), Vector3.new(column, 0.26, field.Position.Z), color(27, 34, 38), Enum.Material.Asphalt)
	decorativePart(landing, "EntryStripe", Vector3.new(18, 0.06, 0.16), Vector3.new(column, 0.35, field.Position.Z - 5.25), tint, Enum.Material.Neon, 0.08)
	decorativePart(landing, "ExitStripe", Vector3.new(18, 0.06, 0.16), Vector3.new(column, 0.35, field.Position.Z + 5.25), tint, Enum.Material.Neon, 0.08)
end
local aisleLinks = approaches:FindFirstChild("AisleLinks") or Instance.new("Folder")
aisleLinks.Name, aisleLinks.Parent = "AisleLinks", approaches
for _, item in ipairs(aisleLinks:GetChildren()) do item:Destroy() end
local aisleEdge, outerThresholdEdge = path.Size.X / 2 - 0.2, gateColumns[#gateColumns] + 11 + 0.2
for row, tier in ipairs(tierSigns) do
	for _, side in ipairs({ -1, 1 }) do
		local innerEdge, outerEdge = side * aisleEdge, side * outerThresholdEdge
		decorativePart(aisleLinks, string.format("TierAisle_%d_%s", row, side < 0 and "Left" or "Right"), Vector3.new(math.abs(outerEdge - innerEdge), 0.12, 8), Vector3.new((innerEdge + outerEdge) / 2, 0.24, tier.z + 22), color(58, 75, 88), Enum.Material.Slate)
		for _, x in ipairs(gateColumns) do
			if (x < 0 and side < 0) or (x > 0 and side > 0) then
				decorativePart(aisleLinks, string.format("PortalConnector_%d_%d", row, math.abs(x)), Vector3.new(8.5, 0.12, 9), Vector3.new(x, 0.24, tier.z + 17.5), color(58, 75, 88), Enum.Material.Slate)
			end
		end
	end
end

local counts = { gates = 0, frames = 0, alignedGeometry = 0, refugeGeometryAligned = refugeGeometryAligned, campPortalOverlaps = campOverlaps, campScale = campScale, campSize = { correctedCampSize.X, correctedCampSize.Y, correctedCampSize.Z }, portalLabels = portalLabels, hiddenBakedLabels = hiddenBakedLabels, tierHeaders = #tierSigns, cityMeshParts = 0, cityDistinctColors = 0 }
local cityColors = {}
for _, model in ipairs(city:GetChildren()) do for _, part in ipairs(model:GetDescendants()) do
	if part:IsA("MeshPart") then counts.cityMeshParts += 1; cityColors[part.Color:ToHex()] = true end
end end
for _ in pairs(cityColors) do counts.cityDistinctColors += 1 end
for _, zone in ipairs(zoneOrder) do
	local travel = travelFolder:FindFirstChild("Travel_" .. zone)
	local frame = portalFrames:FindFirstChild("PortalFrame_" .. zone)
	assert(travel and frame, "Incomplete gate pairing for " .. zone)
	counts.gates += 1; counts.frames += 1
	local field = travel:FindFirstChild("Field", true)
	local index = table.find(zoneOrder, zone)
	local expectedX = gateXs[((index - 1) % 6) + 1]
	local expectedZ = gateRows[math.floor((index - 1) / 6) + 1]
	assert(math.abs(field.Position.X - expectedX) < 0.05 and math.abs(field.Position.Z - expectedZ) < 0.05, "Gate outside organized rows: " .. zone)
	assert((frame:GetBoundingBox().Position - frame:GetPivot().Position).Magnitude < 0.05, "Frame geometry offset from its pivot: " .. zone)
	counts.alignedGeometry += 1
end
assert(counts.gates == 18 and counts.frames == 18 and counts.alignedGeometry == 18 and counts.refugeGeometryAligned == 5 and counts.campPortalOverlaps == 0 and counts.cityMeshParts == 112 and counts.cityDistinctColors >= 7 and path.Size.X == 24, "Unexpected repair counts")
return HttpService:JSONEncode(counts)
