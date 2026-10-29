-- One-time Edit layout repair. Never install as a startup script.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Use the target place in Edit mode")

local refuge = workspace:FindFirstChild("ImportedEnvironmentModels") and workspace.ImportedEnvironmentModels:FindFirstChild("Refuge")
local frames = refuge and refuge:FindFirstChild("PortalFrames")
local travelFolder = workspace:FindFirstChild("ProgressionZones") and workspace.ProgressionZones:FindFirstChild("RefugePortals")
local courtyard = workspace:FindFirstChild("RefugeCourtyard")
local backupName = "BeforeRefugePortalSpacing_20261029"
assert(refuge and frames and travelFolder and courtyard, "Refuge portal scene is incomplete")
assert(not ServerStorage:FindFirstChild(backupName), "Portal spacing backup already exists; inspect before rerunning")

local zoneOrder = {
	"Factory", "Lab", "Harbor", "Power", "Metro", "Quarantine", "Dam", "Citadel", "Crater",
	"GlassSea", "Skyline", "OrbitalWreck", "Depths", "IronSanctum", "LastConvoy", "Gridfall",
	"BlackoutCore", "EclipseVault",
}
local gateXs, gateRows = { -80, -52, -28, 28, 52, 80 }, { 260, 305, 350 }
local gateModels, frameModels, fields, prompts = {}, {}, {}, 0
for index, zone in ipairs(zoneOrder) do
	local travel = travelFolder:FindFirstChild("Travel_" .. zone)
	local frame = frames:FindFirstChild("PortalFrame_" .. zone)
	assert(travel and travel:IsA("Model") and frame and frame:IsA("Model"), "Incomplete travel/frame pair: " .. zone)
	local field = travel:FindFirstChild("Field", true)
	assert(field and field:IsA("BasePart"), "Missing travel field: " .. zone)
	local oldColumn = ((index - 1) % 6) + 1
	local oldRow = math.floor((index - 1) / 6) + 1
	local oldXs, oldZs = { -75, -45, -15, 15, 45, 75 }, { 260, 305, 350 }
	assert(math.abs(field.Position.X - oldXs[oldColumn]) < 0.05 and math.abs(field.Position.Z - oldZs[oldRow]) < 0.05, "Travel layout changed since inspection: " .. zone)
	local count = 0
	for _, item in ipairs(travel:GetDescendants()) do if item:IsA("ProximityPrompt") and item.Name == "ZoneTravel" then count += 1 end end
	assert(count == 1, "Unexpected travel prompt count: " .. zone)
	prompts += count
	local col, row = ((index - 1) % 6) + 1, math.floor((index - 1) / 6) + 1
	table.insert(gateModels, travel)
	table.insert(frameModels, frame)
	fields[zone] = { part = field, x = gateXs[col], z = gateRows[row] }
end
assert(prompts == 18, "Expected 18 functional expedition prompts")

local path = courtyard:FindFirstChild("CentralPath")
assert(path and path:IsA("BasePart"), "Missing central courtyard path")
local stripes = {}
for _, item in ipairs(courtyard:GetChildren()) do if item.Name == "PathStripe" and item:IsA("BasePart") then table.insert(stripes, item) end end
table.sort(stripes, function(a, b) return a.Position.Z < b.Position.Z end)

local backup = Instance.new("Folder")
backup.Name = backupName
for _, model in ipairs(gateModels) do local copy = model:Clone(); copy.Name = model.Name .. "_Backup"; copy.Parent = backup end
for _, model in ipairs(frameModels) do local copy = model:Clone(); copy.Parent = backup end
path:Clone().Parent = backup
for index, stripe in ipairs(stripes) do local copy = stripe:Clone(); copy.Name = "PathStripe_" .. index; copy.Parent = backup end
for _, name in ipairs({ "PathEdgeGuide_L", "PathEdgeGuide_R" }) do
	local existing = courtyard:FindFirstChild(name)
	if existing then existing:Clone().Parent = backup end
end
backup.Parent = ServerStorage

for zone, target in pairs(fields) do
	local travel = travelFolder:FindFirstChild("Travel_" .. zone)
	local oldPivot = travel:GetPivot()
	local rotation = oldPivot - oldPivot.Position
	local offset = oldPivot.Position - target.part.Position
	travel:PivotTo(CFrame.new(Vector3.new(target.x, 4.5, target.z) + offset) * rotation)
	local frame = frames:FindFirstChild("PortalFrame_" .. zone)
	local framePivot = frame:GetPivot()
	frame:PivotTo(CFrame.new(target.x, 8.075, target.z) * (framePivot - framePivot.Position))
	local bounds = frame:GetBoundingBox()
	local geometryOffset = frame:GetPivot().Position - bounds.Position
	for _, part in ipairs(frame:GetDescendants()) do if part:IsA("BasePart") then part.CFrame += geometryOffset end end
end

path.Size, path.Position = Vector3.new(24, 0.08, 170), Vector3.new(0, 0.24, 290)
path.Color, path.Material, path.CanCollide, path.CanTouch, path.CanQuery = Color3.fromRGB(43, 54, 67), Enum.Material.Slate, false, false, false
for index, stripe in ipairs(stripes) do stripe.Position = Vector3.new(0, 0.31, 226 + (index - 1) * 28) end
for _, x in ipairs({ -11.25, 11.25 }) do
	local name = x < 0 and "PathEdgeGuide_L" or "PathEdgeGuide_R"
	local edge = courtyard:FindFirstChild(name) or Instance.new("Part")
	edge.Name = name
	edge.Size, edge.Position = Vector3.new(0.14, 0.04, 166), Vector3.new(x, 0.31, 290)
	edge.Anchored, edge.CanCollide, edge.CanTouch, edge.CanQuery = true, false, false, false
	edge.Material, edge.Color, edge.Transparency = Enum.Material.Neon, Color3.fromRGB(55, 178, 170), 0.2
	edge.Parent = courtyard
end

local frameBounds = {}
for _, zone in ipairs(zoneOrder) do
	local target = fields[zone]
	local travel = travelFolder:FindFirstChild("Travel_" .. zone)
	local frame = frames:FindFirstChild("PortalFrame_" .. zone)
	local field = travel:FindFirstChild("Field", true)
	assert((field.Position - Vector3.new(target.x, 4.5, target.z)).Magnitude < 0.05, "Travel field misaligned: " .. zone)
	assert((frame:GetBoundingBox().Position - Vector3.new(target.x, 8.075, target.z)).Magnitude < 0.05, "Frame geometry misaligned: " .. zone)
	local p, size = frame:GetBoundingBox()
	table.insert(frameBounds, { zone = zone, p = p, size = size })
end
local overlaps = 0
for i = 1, #frameBounds do for j = i + 1, #frameBounds do
	local a, b = frameBounds[i], frameBounds[j]
	local x = math.abs(a.p.X - b.p.X) < (a.size.X + b.size.X) / 2
	local z = math.abs(a.p.Z - b.p.Z) < (a.size.Z + b.size.Z) / 2
	if x and z then overlaps += 1 end
end end
assert(overlaps == 0 and path.Size.X == 24 and #stripes >= 5, "Portal rows overlap or path layout incomplete")
return HttpService:JSONEncode({ backup = backup:GetFullName(), gates = #gateModels, frames = #frameModels, prompts = prompts, overlaps = overlaps, path = { width = path.Size.X, length = path.Size.Z }, guides = 2, minimumFrameGap = 11.8 })
