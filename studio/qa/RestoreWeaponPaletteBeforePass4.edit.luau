-- Restore the original bright imported weapon palette after the stale-cache palette pass.
assert(game.PlaceId == 89391796839094 and not game:GetService("RunService"):IsRunning(), "Run on the target place in Edit only")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local ids = {"Hook", "Kris", "Spear", "Cleaver", "WarHammer", "Pike", "PhaseBlade", "MirrorAxe", "RelayLance", "OrbitalSpear", "RiftCleaver", "ForgeMaul", "ConvoyEdge", "ArcPike", "BlackoutEdge", "EclipseGlaive"}
local sourceBackup = SS:WaitForChild("BeforeWeaponPalettePass4_20261029")
local backupName = "BeforeWeaponPaletteCacheRollback_20261029"
assert(not SS:FindFirstChild(backupName), "Rollback backup already exists; inspect before rerunning")
local rollbackBackup = Instance.new("Folder")
rollbackBackup.Name = backupName
local configCopy = RS:WaitForChild("GameplayConfig"):Clone()
configCopy.Parent = rollbackBackup
local live = RS:WaitForChild("WeaponModels")
local prototypeFolder = SS:WaitForChild("ImportedModelPrototypes"):WaitForChild("Weapons")
local liveCopy = Instance.new("Folder")
liveCopy.Name = "ReplicatedStorage"
liveCopy.Parent = rollbackBackup
local prototypeCopy = Instance.new("Folder")
prototypeCopy.Name = "ServerStorage"
prototypeCopy.Parent = rollbackBackup
for _, id in ipairs(ids) do
	live:WaitForChild(id):Clone().Parent = liveCopy
	prototypeFolder:WaitForChild(id):Clone().Parent = prototypeCopy
end
rollbackBackup.Parent = SS

local function restore(target, saved)
	local currentParts = target:GetDescendants()
	local savedParts = saved:GetDescendants()
	assert(#currentParts == #savedParts, "Palette structure changed: " .. target.Name)
	local changed = 0
	for index, current in ipairs(currentParts) do
		local before = savedParts[index]
		assert(current.Name == before.Name and current.ClassName == before.ClassName, "Palette structure order changed: " .. target.Name)
		if current:IsA("BasePart") then
			current.Color, current.Material, current.MaterialVariant = before.Color, before.Material, before.MaterialVariant
			assert(current.Color == before.Color and current.Material == before.Material and current.MaterialVariant == before.MaterialVariant, "Restore failed: " .. current:GetFullName())
			changed += 1
		end
	end
	return changed
end

local restored, parts = 0, 0
for _, id in ipairs(ids) do
	parts += restore(live:WaitForChild(id), sourceBackup.ReplicatedStorage:WaitForChild(id))
	parts += restore(prototypeFolder:WaitForChild(id), sourceBackup.ServerStorage:WaitForChild(id))
	restored += 1
end
local marker = SS:FindFirstChild("WeaponPalettePass4EditResult")
if marker then marker:Destroy() end
local result = {status="ORIGINAL_WEAPON_PALETTE_RESTORED", models=restored, restoredParts=parts, backup=rollbackBackup:GetFullName(), source=sourceBackup:GetFullName()}
local value = Instance.new("StringValue")
value.Name, value.Value, value.Parent = "WeaponPaletteRollbackEditResult", HttpService:JSONEncode(result), SS
assert(restored == #ids and parts >= #ids * 2, "Weapon palette rollback self-check failed")
return value.Value
