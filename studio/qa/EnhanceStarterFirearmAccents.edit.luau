-- One-shot Edit repair: add clear, per-weapon accents to the two grayscale starter firearms.
assert(game.PlaceId == 89391796839094 and not game:GetService("RunService"):IsRunning(), "Run only in the target place in Edit")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local folder = RS:WaitForChild("WeaponModels")
local palette = {
	Pistol = {frame_geom = Color3.fromRGB(255, 190, 66), barrel_geom = Color3.fromRGB(43, 113, 128)},
	Revolver = {frame_geom = Color3.fromRGB(233, 151, 86), barrel_geom = Color3.fromRGB(78, 86, 112)},
}
local backupName = "BeforeStarterFirearmAccent_20261029"
assert(not SS:FindFirstChild(backupName), "Backup already exists; compare it before rerunning")
local plan = {}
for id, roles in pairs(palette) do
	local model = folder:FindFirstChild(id)
	assert(model and model:IsA("Model"), "Missing firearm model: " .. id)
	local parts = {}
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("MeshPart") then
			assert(part.TextureID == "", "Textured mesh needs a texture-aware palette: " .. part:GetFullName())
			if roles[part.Name] then parts[part.Name] = part end
		end
	end
	assert(parts.frame_geom and parts.barrel_geom, "Unexpected generated firearm structure: " .. id)
	table.insert(plan, {id = id, parts = parts, roles = roles, model = model})
end
local backup = Instance.new("Folder")
backup.Name = backupName
for _, item in ipairs(plan) do item.model:Clone().Parent = backup end
backup.Parent = SS
for _, item in ipairs(plan) do
	for role, color in pairs(item.roles) do
		local part = item.parts[role]
		part.Color = color
		part.Material = Enum.Material.Metal
		part.MaterialVariant = ""
	end
end
for _, item in ipairs(plan) do
	local colors = {}
	for _, part in ipairs(item.model:GetDescendants()) do if part:IsA("BasePart") then colors[part.Color] = true end end
	local count = 0 for _ in pairs(colors) do count += 1 end
	assert(count >= 3, "Weapon lacks distinct accent, steel, and grip colors: " .. item.id)
end
return "Pistol/Revolver recolored; backup=" .. backup:GetFullName()
