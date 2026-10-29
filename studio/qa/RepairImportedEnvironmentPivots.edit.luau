-- One-time Edit repair. Correct detached import pivots without moving mesh geometry.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
assert(not RunService:IsRunning(), "Run this repair in Studio Edit only")
assert(game.PlaceId == 89391796839094, "Unexpected place")

local backupName = "BeforeImportedEnvironmentPivotRepair_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Pivot backup already exists")
local imported = workspace:FindFirstChild("ImportedEnvironmentModels")
assert(imported, "ImportedEnvironmentModels missing")
local roots = {
	imported:FindFirstChild("City"),
	imported:FindFirstChild("Refuge"),
}
local models = {}
for _, root in ipairs(roots) do
	if root then
		for _, model in ipairs(root:GetDescendants()) do
			if model:IsA("Model") and not model.PrimaryPart then
				local bounds = model:GetBoundingBox()
				if (model:GetPivot().Position - bounds.Position).Magnitude > 50 then
					table.insert(models, model)
				end
			end
		end
	end
end
assert(#models == 17, "Unexpected detached pivot count: " .. #models)

local backup = Instance.new("Folder")
backup.Name = backupName
for index, model in ipairs(models) do
	local record = Instance.new("Folder")
	record.Name = string.format("%02d_%s", index, model.Name)
	record:SetAttribute("FullName", model:GetFullName())
	local value = Instance.new("CFrameValue")
	value.Name = "OriginalWorldPivot"
	value.Value = model.WorldPivot
	value.Parent = record
	record.Parent = backup
end
backup.Parent = ServerStorage

local movedParts, corrected = 0, 0
for _, model in ipairs(models) do
	local bounds, size = model:GetBoundingBox()
	local oldRotation = model.WorldPivot - model.WorldPivot.Position
	local snapshots = {}
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(snapshots, { Part = part, CFrame = part.CFrame, Size = part.Size })
		end
	end
	model.WorldPivot = CFrame.new(bounds.Position) * oldRotation
	local newBounds, newSize = model:GetBoundingBox()
	assert((model:GetPivot().Position - bounds.Position).Magnitude < 0.001, "Pivot not centered: " .. model.Name)
	assert((newBounds.Position - bounds.Position).Magnitude < 0.001 and (newSize - size).Magnitude < 0.001, "Bounds changed: " .. model.Name)
	for _, snapshot in ipairs(snapshots) do
		assert(snapshot.Part.CFrame == snapshot.CFrame and snapshot.Part.Size == snapshot.Size, "Geometry moved: " .. snapshot.Part:GetFullName())
		movedParts += 1
	end
	corrected += 1
end
return { corrected = corrected, verifiedUnmovedParts = movedParts, backup = backup:GetFullName() }
