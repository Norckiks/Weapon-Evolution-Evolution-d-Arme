-- One-shot Edit pass: tint the new single-material meshes without changing geometry or collisions.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
assert(game.PlaceId == 89391796839094, "Wrong experience")
assert(not RunService:IsRunning(), "Stop Play before tinting presentation meshes")

local root = workspace:WaitForChild("PresentationV2")
local backupName = "BeforePresentationMeshTints_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup exists; inspect before retrying")
local targets = {
	root:WaitForChild("DetailedEnvironmentAssets"),
	root:WaitForChild("DetailedRefuge"),
}
local backup = Instance.new("Folder")
backup.Name = backupName
for _, target in ipairs(targets) do
	local copy = target:Clone()
	copy.Name = target.Name
	copy.Parent = backup
end
backup.Parent = ServerStorage

local palettes = {
	DetailedWreck = {Color3.fromRGB(171, 69, 56), Color3.fromRGB(77, 111, 79), Color3.fromRGB(154, 117, 56)},
	EvacuationWreck = {Color3.fromRGB(171, 69, 56), Color3.fromRGB(77, 111, 79), Color3.fromRGB(154, 117, 56)},
	ReclaimedGrass = {Color3.fromRGB(100, 140, 68), Color3.fromRGB(81, 119, 60), Color3.fromRGB(125, 145, 75)},
	ConcreteRubble = {Color3.fromRGB(131, 121, 100), Color3.fromRGB(105, 116, 111), Color3.fromRGB(143, 130, 103)},
	CanvasShelter = {Color3.fromRGB(133, 120, 79)},
	MilitaryWreck = {Color3.fromRGB(87, 109, 74)},
}
local nextColor, snapshots, partCount, modelCount = {}, {}, 0, 0
for _, target in ipairs(targets) do
	for _, model in ipairs(target:GetChildren()) do
		local palette = model:IsA("Model") and palettes[model.Name]
		if palette then
			nextColor[model.Name] = (nextColor[model.Name] or 0) % #palette + 1
			local color = palette[nextColor[model.Name]]
			local box, size = model:GetBoundingBox()
			local modelParts = 0
			for _, item in ipairs(model:GetDescendants()) do
				if item:IsA("MeshPart") then
					item.Color = color
					for _, surface in ipairs(item:GetChildren()) do
						if surface:IsA("SurfaceAppearance") then surface.Color = color end
					end
					modelParts += 1
				end
			end
			assert(modelParts > 0, "Expected imported mesh in " .. model:GetFullName())
			local afterBox, afterSize = model:GetBoundingBox()
			assert((box.Position - afterBox.Position).Magnitude < 0.001 and (size - afterSize).Magnitude < 0.001, "Tint changed geometry: " .. model.Name)
			table.insert(snapshots, {model = model, color = color, parts = modelParts})
			partCount += modelParts
			modelCount += 1
		end
	end
end
assert(modelCount >= 30 and partCount >= 100, "Unexpected presentation mesh inventory")
for _, snapshot in ipairs(snapshots) do
	for _, item in ipairs(snapshot.model:GetDescendants()) do
		if item:IsA("MeshPart") then assert(item.Color == snapshot.color, "Tint not applied: " .. item:GetFullName()) end
	end
end
return string.format("models=%d;meshes=%d;geometry=unchanged;backup=%s", modelCount, partCount, backup.Name)
