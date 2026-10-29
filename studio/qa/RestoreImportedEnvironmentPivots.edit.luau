-- Restore imported model pivots from the Edit repair backup; geometry is untouched.
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Run this restore in Studio Edit only")
local backup = game.ServerStorage:FindFirstChild("BeforeImportedEnvironmentPivotRepair_20261029")
assert(backup, "Pivot backup missing")
local function resolve(fullName)
	local current = game
	for segment in string.gmatch(fullName, "[^%.]+") do
		if segment ~= "game" then
			current = current and current:FindFirstChild(segment)
		end
	end
	return current
end
local restored = 0
for _, record in ipairs(backup:GetChildren()) do
	local target = resolve(record:GetAttribute("FullName"))
	local pivot = record:FindFirstChild("OriginalWorldPivot")
	assert(target and target:IsA("Model") and not target.PrimaryPart and pivot and pivot:IsA("CFrameValue"), "Invalid pivot backup: " .. record.Name)
	target.WorldPivot = pivot.Value
	restored += 1
end
assert(restored == 17, "Unexpected restore count: " .. restored)
return { restored = restored, backup = backup:GetFullName() }
