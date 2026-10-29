-- One-shot Edit adjustment to restore colored weapon/world accents under the night grade.
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

assert(not RunService:IsRunning(), "Stop Play before adjusting the persistent color grade")
assert(game.PlaceId == 89391796839094, "Unexpected place; refusing to adjust Lighting")

local grade = Lighting:FindFirstChild("SurvivalFilmGrade")
assert(grade and grade:IsA("ColorCorrectionEffect"), "SurvivalFilmGrade is missing")
assert(math.abs(grade.Saturation - (-0.2)) < 0.001, "Color grade changed; inspect it before editing")

local backupName = "BeforeWeaponColorGrade_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect it before rerunning")
local backup = Instance.new("Folder")
backup.Name = backupName
grade:Clone().Parent = backup
backup.Parent = ServerStorage

grade.Saturation = -0.05
assert(math.abs(grade.Saturation - (-0.05)) < 0.001, "Saturation update failed")

local result = {
	status = "WEAPON_COLOR_GRADE_ADJUSTED",
	backup = backup:GetFullName(),
	before = -0.2,
	after = grade.Saturation,
	brightness = grade.Brightness,
	contrast = grade.Contrast,
	tint = grade.TintColor,
	globalLightingUnchanged = true,
}
local marker = Instance.new("StringValue")
marker.Name = "WeaponColorGradeEditResult"
marker.Value = HttpService:JSONEncode(result)
marker.Parent = ServerStorage
return marker.Value
