-- One-shot Studio Edit repair. Never install as a game/startup Script.
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local frames = workspace.ImportedEnvironmentModels.Refuge.PortalFrames
local gates = workspace.ProgressionZones.RefugePortals
local zoneOrder = {
	"City", "Factory", "Lab", "Harbor", "Power", "Metro", "Quarantine",
	"Dam", "Citadel", "Crater", "GlassSea", "Skyline", "OrbitalWreck",
	"Depths", "IronSanctum", "LastConvoy", "Gridfall", "BlackoutCore", "EclipseVault",
}

assert(#frames:GetChildren() == #zoneOrder, "Expected 19 visual portal frames")
local plan = {}
for _, zone in ipairs(zoneOrder) do
	local frame = frames:FindFirstChild("PortalFrame_" .. zone)
	local gate = gates:FindFirstChild("Travel_" .. zone)
	assert(frame and gate, "Missing frame/gate pair: " .. zone)
	local field = gate:FindFirstChild("Field", true)
	assert(field and field:IsA("BasePart"), "Missing field: " .. zone)
	local pivot = frame:GetPivot()
	assert((Vector2.new(pivot.Position.X, pivot.Position.Z) - Vector2.new(field.Position.X, field.Position.Z)).Magnitude < 0.05,
		"Frame pivot does not match gate: " .. zone)
	local bounds = frame:GetBoundingBox()
	local parts = {}
	for _, item in ipairs(frame:GetDescendants()) do
		if item:IsA("BasePart") then table.insert(parts, item) end
	end
	assert(#parts > 0, "Frame has no geometry: " .. zone)
	table.insert(plan, { zone = zone, frame = frame, pivot = pivot.Position, bounds = bounds.Position, parts = parts })
end

local backup = ServerStorage:FindFirstChild("BeforePortalFrameGeometryFix_20261029")
assert(not backup, "Geometry-fix backup already exists; inspect it before rerunning")
backup = Instance.new("Folder")
backup.Name = "BeforePortalFrameGeometryFix_20261029"
for _, item in ipairs(plan) do item.frame:Clone().Parent = backup end
backup.Parent = ServerStorage

local movedParts, movedFrames = 0, 0
for _, item in ipairs(plan) do
	local offset = item.pivot - item.bounds
	if offset.Magnitude > 0.02 then
		for _, part in ipairs(item.parts) do part.CFrame += offset; movedParts += 1 end
		movedFrames += 1
	end
end

local worstOffset = 0
for _, item in ipairs(plan) do
	local bounds = item.frame:GetBoundingBox()
	local offset = (bounds.Position - item.frame:GetPivot().Position).Magnitude
	worstOffset = math.max(worstOffset, offset)
	assert(offset < 0.05, "Visual geometry still offset from pivot: " .. item.zone)
end

local result = {
	status = "PORTAL_FRAME_GEOMETRY_ALIGNED",
	frames = #plan,
	movedFrames = movedFrames,
	movedParts = movedParts,
	worstRemainingOffset = worstOffset,
	backup = backup:GetFullName(),
}
local value = ServerStorage:FindFirstChild("PortalFrameGeometryFixResult") or Instance.new("StringValue")
value.Name = "PortalFrameGeometryFixResult"
value.Value = HttpService:JSONEncode(result)
value.Parent = ServerStorage
return value.Value
