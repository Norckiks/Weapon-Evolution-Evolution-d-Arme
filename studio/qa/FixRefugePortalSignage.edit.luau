-- One-shot Studio Edit repair. Never install as a game/startup Script.
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local World = require(ReplicatedStorage:WaitForChild("WorldConfig"))
local frames = workspace.ImportedEnvironmentModels.Refuge.PortalFrames
local travel = workspace.ProgressionZones.RefugePortals
local courtyard = workspace.RefugeCourtyard
local accents = {
	Color3.fromRGB(239, 145, 63),
	Color3.fromRGB(82, 194, 183),
	Color3.fromRGB(178, 143, 214),
}
local tiers = {
	{ text = "EXPÉDITIONS I  ·  NIVEAUX 05–45", z = 247 },
	{ text = "EXPÉDITIONS II  ·  NIVEAUX 60–160", z = 292 },
	{ text = "EXPÉDITIONS III  ·  NIVEAUX 180–280", z = 337 },
}

local byId = {}
for _, zone in ipairs(World.Zones) do byId[zone.Id] = zone end
assert(#frames:GetChildren() == 19 and #World.Zones == 19, "Expected 19 configured portal destinations")
local plan = {}
for _, zone in ipairs(World.Zones) do
	if zone.Id ~= "City" then
		local frame = frames:FindFirstChild("PortalFrame_" .. zone.Id)
		local gate = travel:FindFirstChild("Travel_" .. zone.Id)
		assert(frame and gate, "Missing portal frame or travel gate: " .. zone.Id)
		local field = gate:FindFirstChild("Field", true)
		local paint
		for _, part in ipairs(frame:GetDescendants()) do
			if part:IsA("BasePart") and string.find(string.lower(part.Name), "_paint", 1, true) then paint = part; break end
		end
		assert(field and paint, "Missing field or sign plate: " .. zone.Id)
		assert((Vector2.new(frame:GetPivot().Position.X, frame:GetPivot().Position.Z) - Vector2.new(field.Position.X, field.Position.Z)).Magnitude < 0.05,
			"Portal frame pivot is misaligned: " .. zone.Id)
		table.insert(plan, { zone = zone, frame = frame, paint = paint })
	end
end

local backup = ServerStorage:FindFirstChild("BeforeRefugePortalSignage_20261029")
assert(not backup, "Signage backup already exists; inspect it before rerunning")
backup = Instance.new("Folder")
backup.Name = "BeforeRefugePortalSignage_20261029"
for _, item in ipairs(plan) do item.frame:Clone().Parent = backup end
for index = 1, #tiers do
	local existing = courtyard:FindFirstChild("RefugeTierSign_" .. index)
	assert(not existing, "Tier sign already exists: " .. index)
end
backup.Parent = ServerStorage

local function addLabel(plate, face, zone)
	local gui = plate:FindFirstChild("RefugeZoneLabel_" .. face.Name) or Instance.new("SurfaceGui")
	gui.Name = "RefugeZoneLabel_" .. face.Name
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	gui.CanvasSize = Vector2.new(940, 120)
	gui.LightInfluence = 0
	gui.AlwaysOnTop = false
	gui.Parent = plate
	local label = gui:FindFirstChild("Text") or Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = zone.Name .. "\nNIVEAU " .. zone.Level
	label.TextColor3 = Color3.fromRGB(255, 243, 215)
	label.TextStrokeColor3 = Color3.fromRGB(12, 16, 18)
	label.TextStrokeTransparency = 0.2
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 34
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
end

local labelsHidden, portalLabels = 0, 0
for _, item in ipairs(plan) do
	for _, part in ipairs(item.frame:GetDescendants()) do
		if part:IsA("BasePart") and string.find(string.lower(part.Name), "_label", 1, true) then
			part.Transparency = 1
			part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
			labelsHidden += 1
		end
	end
	addLabel(item.paint, Enum.NormalId.Front, item.zone)
	addLabel(item.paint, Enum.NormalId.Back, item.zone)
	portalLabels += 1
end

for index, tier in ipairs(tiers) do
	local sign = Instance.new("Part")
	sign.Name = "RefugeTierSign_" .. index
	sign.Size = Vector3.new(160, 3.6, 0.8)
	sign.Position = Vector3.new(0, 18.5, tier.z)
	sign.Anchored = true
	sign.CanCollide, sign.CanTouch, sign.CanQuery = false, false, false
	sign.Material = Enum.Material.CorrodedMetal
	sign.Color = Color3.fromRGB(25, 32, 35)
	sign.Parent = courtyard
	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local gui = Instance.new("SurfaceGui")
		gui.Name = "TierText_" .. face.Name
		gui.Face = face
		gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		gui.CanvasSize = Vector2.new(1600, 36)
		gui.LightInfluence = 0
		gui.AlwaysOnTop = false
		gui.Parent = sign
		local label = Instance.new("TextLabel")
		label.Name = "Title"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = tier.text
		label.TextColor3 = accents[index]
		label.TextStrokeColor3 = Color3.fromRGB(8, 12, 14)
		label.TextStrokeTransparency = 0.2
		label.Font = Enum.Font.GothamBlack
		label.TextSize = 24
		label.TextScaled = false
		label.TextWrapped = false
		label.Parent = gui
	end
	local stripe = Instance.new("Part")
	stripe.Name = "RefugeTierAccent_" .. index
	stripe.Size = Vector3.new(160, 0.16, 0.82)
	stripe.Position = sign.Position + Vector3.new(0, 1.88, 0)
	stripe.Anchored = true
	stripe.CanCollide, stripe.CanTouch, stripe.CanQuery = false, false, false
	stripe.Material = Enum.Material.Neon
	stripe.Color = accents[index]
	stripe.Parent = courtyard
end

for _, item in ipairs(plan) do
	assert(item.paint:FindFirstChild("RefugeZoneLabel_Front") and item.paint:FindFirstChild("RefugeZoneLabel_Back"),
		"Portal label not installed: " .. item.zone.Id)
	for _, part in ipairs(item.frame:GetDescendants()) do
		if part:IsA("BasePart") and string.find(string.lower(part.Name), "_label", 1, true) then
			assert(part.Transparency >= 1, "Baked label still visible: " .. item.zone.Id)
		end
	end
end

local result = {
	status = "REFUGE_PORTAL_SIGNAGE_FIXED",
	portalsRelabeled = portalLabels,
	obsoleteLabelMeshesHidden = labelsHidden,
	tierHeaders = #tiers,
	backup = backup:GetFullName(),
}
local value = ServerStorage:FindFirstChild("RefugePortalSignageFixResult") or Instance.new("StringValue")
value.Name = "RefugePortalSignageFixResult"
value.Value = HttpService:JSONEncode(result)
value.Parent = ServerStorage
return value.Value
