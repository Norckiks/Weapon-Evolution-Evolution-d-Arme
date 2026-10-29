-- One-time Studio Edit repair. Keep the imported camp intact, but move its merged meshes out of the portal grid.
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local refuge = workspace:WaitForChild("ImportedEnvironmentModels"):WaitForChild("Refuge")
local camp = refuge:WaitForChild("Refuge_04_Vie_du_camp")
local frames = refuge:WaitForChild("PortalFrames")
local gates = workspace:WaitForChild("ProgressionZones"):WaitForChild("RefugePortals")
local courtyard = workspace:WaitForChild("RefugeCourtyard")
local ground = courtyard:WaitForChild("CourtyardGround")
local backupName = "BeforeRefugeCampPortalClearance_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect it before rerunning")

local oldBounds, oldSize = camp:GetBoundingBox()
local oldCenter = oldBounds.Position
local parts = {}
for _, item in ipairs(camp:GetDescendants()) do
	if item:IsA("BasePart") then table.insert(parts, item) end
end
assert(#parts == 4, "Unexpected camp mesh count; inspect before moving")
assert(oldSize.X > 175 and oldSize.X < 185 and oldSize.Z > 112 and oldSize.Z < 124,
	"Unexpected camp footprint; inspect before moving")

local backup = Instance.new("Folder")
backup.Name = backupName
camp:Clone().Parent = backup
backup.Parent = ServerStorage

local scale = 0.42
local targetCenter = Vector3.new(135, oldSize.Y * scale / 2, 310)
for _, part in ipairs(parts) do
	local oldCFrame = part.CFrame
	local targetPosition = targetCenter + (oldCFrame.Position - oldCenter) * scale
	part.Size *= scale
	part.CFrame = CFrame.new(targetPosition) * (oldCFrame - oldCFrame.Position)
	part.Anchored = true
	part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
end
camp.WorldPivot = CFrame.new(targetCenter)

local bounds, size = camp:GetBoundingBox()
local minX, maxX = bounds.Position.X - size.X / 2, bounds.Position.X + size.X / 2
local minY = bounds.Position.Y - size.Y / 2
local minZ, maxZ = bounds.Position.Z - size.Z / 2, bounds.Position.Z + size.Z / 2
assert(math.abs(bounds.Position.X - 135) < 0.05 and math.abs(bounds.Position.Z - 310) < 0.05,
	"Camp geometry did not reach its target")
assert(math.abs(minY) < 0.05, "Camp geometry is not resting on the floor")
assert(minX >= ground.Position.X - ground.Size.X / 2 and maxX <= ground.Position.X + ground.Size.X / 2,
	"Camp escaped the refuge ground on X")
assert(minZ >= ground.Position.Z - ground.Size.Z / 2 and maxZ <= ground.Position.Z + ground.Size.Z / 2,
	"Camp escaped the refuge ground on Z")

local overlaps = {}
for _, frame in ipairs(frames:GetChildren()) do
	if frame:IsA("Model") then
		local frameBounds, frameSize = frame:GetBoundingBox()
		local separated = maxX <= frameBounds.Position.X - frameSize.X / 2
			or minX >= frameBounds.Position.X + frameSize.X / 2
			or maxZ <= frameBounds.Position.Z - frameSize.Z / 2
			or minZ >= frameBounds.Position.Z + frameSize.Z / 2
		if not separated then table.insert(overlaps, frame.Name) end
	end
end
assert(#overlaps == 0, "Camp still overlaps portal frames: " .. table.concat(overlaps, ", "))

local arena = workspace:FindFirstChild("SurvivorArena")
local fightBounds = arena and arena:FindFirstChild("FightBounds")
if fightBounds then
	local separated = maxX <= fightBounds.Position.X - fightBounds.Size.X / 2
		or minX >= fightBounds.Position.X + fightBounds.Size.X / 2
		or maxZ <= fightBounds.Position.Z - fightBounds.Size.Z / 2
		or minZ >= fightBounds.Position.Z + fightBounds.Size.Z / 2
	assert(separated, "Camp overlaps the active PVP arena")
end

local result = {
	status = "REFUGE_CAMP_MOVED_CLEAR_OF_PORTALS",
	backup = backup:GetFullName(),
	parts = #parts,
	scale = scale,
	center = { bounds.Position.X, bounds.Position.Y, bounds.Position.Z },
	size = { size.X, size.Y, size.Z },
	baseY = minY,
	portalOverlaps = #overlaps,
	pvpOverlap = false,
}
local value = ServerStorage:FindFirstChild("RefugeCampPortalClearanceResult") or Instance.new("StringValue")
value.Name = "RefugeCampPortalClearanceResult"
value.Value = HttpService:JSONEncode(result)
value.Parent = ServerStorage
return value.Value
