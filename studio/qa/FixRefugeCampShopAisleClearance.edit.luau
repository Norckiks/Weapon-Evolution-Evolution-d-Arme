-- One-time Studio Edit fix for the camp mesh covering the right shop routes.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Use the target place in Edit mode")

local refuge = workspace:WaitForChild("ImportedEnvironmentModels"):WaitForChild("Refuge")
local camp = refuge:WaitForChild("Refuge_04_Vie_du_camp")
local courtyard = workspace:WaitForChild("RefugeCourtyard")
local ground = courtyard:WaitForChild("CourtyardGround")
local backupName = "BeforeRefugeCampShopAisleClearance_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Backup already exists; inspect it before rerunning")

local before, beforeSize = camp:GetBoundingBox()
assert(math.abs(before.Position.X - 160) < 0.1 and math.abs(before.Position.Z - 280) < 0.1, "Camp moved; inspect current placement")
assert(beforeSize.X > 75 and beforeSize.X < 77 and beforeSize.Z > 49 and beforeSize.Z < 51, "Camp bounds changed; inspect before scaling")
local parts = {}
for _, item in ipairs(camp:GetDescendants()) do if item:IsA("BasePart") then table.insert(parts, item) end end
assert(#parts == 4, "Expected the four imported camp meshes")
local factor = 0.85
local nextSize = beforeSize * factor
local target = Vector3.new(169.5, nextSize.Y / 2, 275)

local function separated(a, as, b, bs, gap)
	return a.X + as.X / 2 + gap <= b.X - bs.X / 2 or a.X - as.X / 2 - gap >= b.X + bs.X / 2
		or a.Z + as.Z / 2 + gap <= b.Z - bs.Z / 2 or a.Z - as.Z / 2 - gap >= b.Z + bs.Z / 2
end
local function check(object, name, margin)
	local cf, size
	if object:IsA("Model") then cf, size = object:GetBoundingBox()
	elseif object:IsA("BasePart") then cf, size = object.CFrame, object.Size
	else return end
	assert(separated(target, nextSize, cf.Position, size, margin), "Camp destination overlaps " .. name)
end

local groundMin, groundMax = ground.Position - ground.Size / 2, ground.Position + ground.Size / 2
assert(target.X - nextSize.X / 2 >= groundMin.X + 2 and target.X + nextSize.X / 2 <= groundMax.X - 2, "Camp destination too close to courtyard edge")
assert(target.Z - nextSize.Z / 2 >= groundMin.Z + 2 and target.Z + nextSize.Z / 2 <= groundMax.Z - 2, "Camp destination outside courtyard depth")
for _, segment in ipairs(courtyard:WaitForChild("ShopAccessWalkways"):GetDescendants()) do if segment:IsA("BasePart") then check(segment, segment:GetFullName(), 2) end end
for _, shop in ipairs(workspace:WaitForChild("RefugeShops"):GetChildren()) do check(shop, shop:GetFullName(), 2) end
for _, object in ipairs(workspace:WaitForChild("SurvivorArena"):GetDescendants()) do if object:IsA("BasePart") then check(object, object:GetFullName(), 2) end end
for _, object in ipairs(workspace:WaitForChild("ProgressionZones"):WaitForChild("RefugePortals"):GetChildren()) do check(object, object:GetFullName(), 1) end
for _, frame in ipairs(refuge:WaitForChild("PortalFrames"):GetChildren()) do if frame:IsA("Model") then check(frame, frame:GetFullName(), 1) end end
for _, object in ipairs(refuge:GetChildren()) do
	if object:IsA("Model") and object ~= camp and object.Name ~= "Refuge_01_Sol_et_place" then check(object, object:GetFullName(), 2) end
end
for _, object in ipairs(courtyard:GetChildren()) do
	if object:IsA("BasePart") and object ~= ground then check(object, object:GetFullName(), 1) end
end

local backup = Instance.new("Folder")
backup.Name = backupName
camp:Clone().Parent = backup
backup.Parent = ServerStorage
local previous = {}
local previousPivot = camp.WorldPivot
for _, part in ipairs(parts) do previous[part] = { part.Size, part.CFrame } end
local ok, result = pcall(function()
	for _, part in ipairs(parts) do
		local old = part.CFrame
		part.Size *= factor
		part.CFrame = CFrame.new(target + (old.Position - before.Position) * factor) * (old - old.Position)
		part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
	end
	camp.WorldPivot = CFrame.new(target)
	local after, afterSize = camp:GetBoundingBox()
	assert((after.Position - target).Magnitude < 0.05 and (afterSize - nextSize).Magnitude < 0.05, "Camp failed to reach its planned bounds")
	assert(math.abs(after.Position.Y - afterSize.Y / 2) < 0.05, "Camp is not resting on the courtyard floor")
	for _, part in ipairs(parts) do assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery, "Camp mesh became interactive") end
	return { status = "CAMP_SHOP_ROUTES_CLEARED", backup = backup:GetFullName(), scale = factor, center = { after.Position.X, after.Position.Y, after.Position.Z }, size = { afterSize.X, afterSize.Y, afterSize.Z }, routeMargin = 2 }
end)
if not ok then
	for part, state in pairs(previous) do if part.Parent then part.Size, part.CFrame = state[1], state[2] end end
	camp.WorldPivot = previousPivot
	error("Camp adjustment rolled back: " .. tostring(result))
end
local marker = Instance.new("StringValue")
marker.Name = "RefugeCampShopAisleClearanceResult"
marker.Value = HttpService:JSONEncode(result)
marker.Parent = ServerStorage
return marker.Value
