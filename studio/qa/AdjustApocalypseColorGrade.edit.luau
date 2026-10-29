-- One-shot Edit adjustment; preserves dark exposure and backs up the existing effect.
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(not RunService:IsRunning(), "Stop Play before adjusting persistent color grading")
assert(game.PlaceId == 89391796839094, "Unexpected place; refusing to adjust Lighting")

local grade = Lighting:FindFirstChild("ApocalypseGrade")
local film = Lighting:FindFirstChild("SurvivalFilmGrade")
assert(grade and grade:IsA("ColorCorrectionEffect"), "ApocalypseGrade is missing")
assert(film and film:IsA("ColorCorrectionEffect"), "SurvivalFilmGrade is missing")
assert(math.abs(grade.Saturation - (-0.28)) < 0.001, "ApocalypseGrade changed; inspect before editing")
assert(math.abs(film.Saturation - (-0.05)) < 0.001, "SurvivalFilmGrade changed; inspect before editing")

local backupName = "BeforeApocalypseGradeColorPass_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect before rerunning")
local backup = Instance.new("Folder")
backup.Name = backupName
grade:Clone().Parent = backup
backup.Parent = ServerStorage

grade.Saturation = -0.05
assert(math.abs(grade.Saturation - (-0.05)) < 0.001, "Apocalypse saturation update failed")
local result = {
	status = "APOCALYPSE_GRADE_COLOR_PASS",
	backup = backup:GetFullName(),
	apocalypseSaturation = grade.Saturation,
	filmSaturation = film.Saturation,
	clockTime = Lighting.ClockTime,
	brightness = Lighting.Brightness,
	exposure = Lighting.ExposureCompensation,
}
local marker = Instance.new("StringValue")
marker.Name = "ApocalypseGradeColorPassResult"
marker.Value = HttpService:JSONEncode(result)
marker.Parent = ServerStorage
return marker.Value
