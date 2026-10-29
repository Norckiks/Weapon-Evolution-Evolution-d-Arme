-- One-shot Studio Edit repair. Never install as a startup Script or run in Play.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(not RunService:IsRunning(), "Stop Play before reorganizing the refuge")

local ConfigModule = ReplicatedStorage:WaitForChild("GameplayConfig")
local Config = require(ConfigModule)
local oldShops = {
	Upgrades = Vector3.new(-26, 0, 191), Weapons = Vector3.new(26, 0, 191),
	Pets = Vector3.new(-43, 0, 186), Robux = Vector3.new(39, 0, 172),
}
local newShops = {
	Upgrades = Vector3.new(-110, 0, 225), Weapons = Vector3.new(110, 0, 225),
	Pets = Vector3.new(-110, 0, 247), Robux = Vector3.new(110, 0, 247),
}
local visualNames = {
	Upgrades = "Refuge_Boutique_01_ATELIER", Weapons = "Refuge_Boutique_02_ARMURERIE",
	Pets = "Refuge_Boutique_03_PETS", Robux = "Refuge_Boutique_04_BOUTIQUE",
}
local currentArenaZ, targetArenaZ = 333, 326
local backupName = "BeforeRefugeEntryLayout_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup exists; inspect it before rerunning")
assert(game.PlaceId == 89391796839094, "Unexpected place; refusing to move the refuge")

for id, old in pairs(oldShops) do
	assert(Config.Shops[id] and (Config.Shops[id] - old).Magnitude < 0.01, "Unexpected shop config: " .. id)
end
local courtyard = workspace:WaitForChild("RefugeCourtyard")
local ground = courtyard:WaitForChild("CourtyardGround")
local path = courtyard:WaitForChild("CentralPath")
assert((path.Position - Vector3.new(0, 0.24, 292)).Magnitude < 0.02 and (path.Size - Vector3.new(12, 0.08, 155)).Magnitude < 0.02, "Unexpected central path; inspect before moving")
local shops = workspace:WaitForChild("RefugeShops")
local refuge = workspace:WaitForChild("ImportedEnvironmentModels"):WaitForChild("Refuge")
local portalFrames = refuge:WaitForChild("PortalFrames")
assert(#portalFrames:GetChildren() == 19, "Expected 19 portal frames")
local arena = workspace:WaitForChild("SurvivorArena")
local arenaPivot = arena:GetPivot()
local arenaBounds, arenaSize = arena:GetBoundingBox()
assert(math.abs(arenaBounds.Position.Z - currentArenaZ) < 0.1 and math.abs(arenaSize.Z - 32) < 0.1, "Unexpected PvP arena; inspect before moving")

local models, parts, oldPivots = {}, {}, {}
local function snapshotModel(model)
	if oldPivots[model] then return end
	oldPivots[model] = model:GetPivot()
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			parts[item] = { CFrame = item.CFrame, Size = item.Size }
		end
	end
	table.insert(models, model)
end

local moves = {}
for id, target in pairs(newShops) do
	local stand = shops:FindFirstChild(id)
	local shell = refuge:FindFirstChild(visualNames[id])
	assert(stand and stand:IsA("Model") and shell and shell:IsA("Model"), "Missing shop/visual: " .. id)
	local prompt = stand:FindFirstChildWhichIsA("ProximityPrompt", true)
	assert(prompt and prompt:GetAttribute("ShopPage") == id, "Shop prompt is not mapped: " .. id)
	local standBounds, standSize = stand:GetBoundingBox()
	local shellBounds, shellSize = shell:GetBoundingBox()
	assert(math.abs(standBounds.Position.X - oldShops[id].X) < 0.1 and math.abs(standBounds.Position.Z - oldShops[id].Z) < 0.1, "Shop stand moved since audit: " .. id)
	assert(math.abs(shellBounds.Position.X - oldShops[id].X) < 0.1 and math.abs(shellBounds.Position.Z - oldShops[id].Z) < 0.1, "Imported shop geometry moved since audit: " .. id)
	assert((standSize - Vector3.new(13.8, 7.9, 10.55)).Magnitude < 0.2, "Unexpected shop footprint: " .. id)
	snapshotModel(stand)
	snapshotModel(shell)
	table.insert(moves, { id = id, target = target, stand = stand, shell = shell, prompt = prompt, standSize = standSize, shellSize = shellSize })
end
snapshotModel(arena)
parts[path] = { CFrame = path.CFrame, Size = path.Size }
local configBackup = ConfigModule:Clone()

local backup = Instance.new("Folder")
backup.Name = backupName
local configFolder = Instance.new("Folder")
configFolder.Name = "Before"
configFolder.Parent = backup
for _, model in ipairs(models) do model:Clone().Parent = configFolder end
path:Clone().Parent = configFolder
configBackup.Parent = configFolder
backup.Parent = ServerStorage

local sourceBefore = ConfigModule.Source
local oldLine = "C.Shops={Upgrades=Vector3.new(-26,0,191),Weapons=Vector3.new(26,0,191),Robux=Vector3.new(39,0,172),Pets=Vector3.new(-43,0,186)}"
local newLine = "C.Shops={Upgrades=Vector3.new(-110,0,225),Weapons=Vector3.new(110,0,225),Robux=Vector3.new(110,0,247),Pets=Vector3.new(-110,0,247)}"
local sourceAt = string.find(sourceBefore, oldLine, 1, true)
assert(sourceAt and not string.find(sourceBefore, oldLine, sourceAt + #oldLine, true), "Studio GameplayConfig differs; compare source before editing")

local function bounds(model)
	local cf, size = model:GetBoundingBox()
	return cf.Position, size
end
local function separatedXZ(a, aSize, b, bSize, clearance)
	return math.abs(a.X - b.X) >= (aSize.X + bSize.X) / 2 + clearance
		or math.abs(a.Z - b.Z) >= (aSize.Z + bSize.Z) / 2 + clearance
end
local targets = {}
local blockers = {
	refuge:WaitForChild("Refuge_03_Terminal"), refuge:WaitForChild("Refuge_04_Vie_du_camp"),
	refuge:WaitForChild("Refuge_Abri_01"), refuge:WaitForChild("Refuge_Abri_02"),
	refuge:WaitForChild("Refuge_Abri_03"), refuge:WaitForChild("Refuge_Abri_04"),
}
for _, move in ipairs(moves) do
	local size = move.standSize
	local p = move.target
	assert(p.X - size.X / 2 >= ground.Position.X - ground.Size.X / 2 and p.X + size.X / 2 <= ground.Position.X + ground.Size.X / 2, "Shop outside courtyard on X: " .. move.id)
	assert(p.Z - size.Z / 2 >= ground.Position.Z - ground.Size.Z / 2 and p.Z + size.Z / 2 <= ground.Position.Z + ground.Size.Z / 2, "Shop outside courtyard on Z: " .. move.id)
	for _, other in ipairs(targets) do assert(separatedXZ(p, size, other.p, other.size, 2), "Shop stalls too close: " .. move.id .. " / " .. other.id) end
	for _, frame in ipairs(portalFrames:GetChildren()) do
		if frame:IsA("Model") then local fp, fs = bounds(frame); assert(separatedXZ(p, size, fp, fs, 2), "Shop overlaps portal: " .. move.id .. " / " .. frame.Name) end
	end
	for _, blocker in ipairs(blockers) do local bp, bs = bounds(blocker); assert(separatedXZ(p, size, bp, bs, 2), "Shop overlaps refuge model: " .. move.id .. " / " .. blocker.Name) end
	table.insert(targets, { id = move.id, p = p, size = size })
end

local deltaArena = Vector3.new(0, 0, targetArenaZ - arenaBounds.Position.Z)
local ok, failure = pcall(function()
	for _, move in ipairs(moves) do
		local delta = Vector3.new(move.target.X - oldShops[move.id].X, 0, move.target.Z - oldShops[move.id].Z)
		move.stand:PivotTo(move.stand:GetPivot() + delta)
		local oldShellPivot = move.shell:GetPivot()
		for _, part in ipairs(move.shell:GetDescendants()) do if part:IsA("BasePart") then part.CFrame += delta end end
		move.shell.WorldPivot = CFrame.new(move.target) * (oldShellPivot - oldShellPivot.Position)
	end
	for _, part in ipairs(arena:GetDescendants()) do if part:IsA("BasePart") then part.CFrame += deltaArena end end
	arena.WorldPivot = arenaPivot + deltaArena
	path.Size = Vector3.new(12, 0.08, 170)
	path.Position = Vector3.new(0, 0.24, 290)
	ConfigModule.Source = string.sub(sourceBefore, 1, sourceAt - 1) .. newLine .. string.sub(sourceBefore, sourceAt + #oldLine)

	local newArenaBounds, newArenaSize = arena:GetBoundingBox()
	assert(math.abs(newArenaBounds.Position.Z - targetArenaZ) < 0.05 and math.abs(newArenaSize.Z - arenaSize.Z) < 0.05, "PvP arena shift failed")
	for _, frame in ipairs(portalFrames:GetChildren()) do
		if frame:IsA("Model") then local fp, fs = bounds(frame); assert(separatedXZ(newArenaBounds.Position, newArenaSize, fp, fs, 2), "PvP arena overlaps portal: " .. frame.Name) end
	end
	for _, move in ipairs(moves) do
		local standPos = bounds(move.stand)
		local shellPos, shellSize = bounds(move.shell)
		assert(math.abs(standPos.X - move.target.X) < 0.05 and math.abs(standPos.Z - move.target.Z) < 0.05, "Shop stand geometry missed target: " .. move.id)
		assert(math.abs(shellPos.X - move.target.X) < 0.05 and math.abs(shellPos.Z - move.target.Z) < 0.05, "Imported shop geometry missed target: " .. move.id)
		assert(math.abs(move.shellSize.X - shellSize.X) < 0.001, "Imported shell dimensions changed: " .. move.id)
		assert(move.prompt:GetAttribute("ShopPage") == move.id, "Shop prompt mapping changed: " .. move.id)
	end
	assert(ConfigModule.Source:find(newLine, 1, true), "GameplayConfig source did not update")
	assert(math.abs(path.Position.Z - 290) < 0.01 and math.abs(path.Size.Z - 170) < 0.01, "Entry path did not extend to the City portal")
end)

if not ok then
	for part, state in pairs(parts) do if part.Parent then part.CFrame, part.Size = state.CFrame, state.Size end end
	for model, pivot in pairs(oldPivots) do if model.Parent then model.WorldPivot = pivot end end
	ConfigModule.Source = sourceBefore
	error("Refuge layout failed and was rolled back; backup: " .. backup:GetFullName() .. " | " .. tostring(failure))
end

local result = {
	status = "REFUGE_ENTRY_REORGANIZED",
	backup = backup:GetFullName(),
	shops = { Upgrades = {-110, 0, 225}, Weapons = {110, 0, 225}, Pets = {-110, 0, 247}, Robux = {110, 0, 247} },
	shopPromptsPreserved = #moves,
	importedShellPivotsRepaired = #moves,
	portalFrames = #portalFrames:GetChildren(),
	path = { centerZ = path.Position.Z, length = path.Size.Z },
	arena = { centerZ = targetArenaZ, zMin = targetArenaZ - arenaSize.Z / 2, zMax = targetArenaZ + arenaSize.Z / 2 },
	portalArenaOverlaps = 0,
	config = newLine,
}
local resultValue = Instance.new("StringValue")
resultValue.Name = "RefugeEntryLayoutEditResult"
resultValue.Value = HttpService:JSONEncode(result)
resultValue.Parent = ServerStorage
return resultValue.Value
