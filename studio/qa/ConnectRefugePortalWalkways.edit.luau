-- One-time Edit route fix: put row aisles behind portal frames and connect each landing.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Run in the target place, Edit only")

local courtyard = workspace:WaitForChild("RefugeCourtyard")
local path = courtyard:WaitForChild("CentralPath")
local approaches = courtyard:WaitForChild("RefugeTierInfrastructure"):WaitForChild("PortalApproaches")
local oldLinks = approaches:WaitForChild("AisleLinks")
local backupName = "BeforeRefugePortalWalkwayRouteFix_20261029"
local routeColor = Color3.fromRGB(58, 75, 88)
assert(not ServerStorage:FindFirstChild(backupName), "Inspect the existing route-fix backup before rerunning")
assert(math.abs(path.Position.X) < 0.05 and math.abs(path.Size.X - 24) < 0.05, "Central aisle changed")

local rows = {}
for _, model in ipairs(approaches:GetChildren()) do
	if model:IsA("Model") then
		local threshold = model:FindFirstChild("Threshold")
		assert(threshold and threshold:IsA("BasePart"), "Portal threshold missing: " .. model.Name)
		local z = math.round(threshold.Position.Z)
		local row = rows[z] or { xs = {}, sample = threshold }
		rows[z] = row
		table.insert(row.xs, threshold.Position.X)
	end
end
local rowZs = {}
for z, row in pairs(rows) do
	table.insert(rowZs, z)
	table.sort(row.xs)
	assert(#row.xs == 6, "Expected six portal landings at row Z " .. z)
end
table.sort(rowZs)
assert(#rowZs == 3, "Expected three portal rows")

local backup = Instance.new("Folder")
backup.Name = backupName
local savedLinks = oldLinks:Clone()
savedLinks.Name = "AisleLinks_BeforeRouteFix"
savedLinks.Parent = backup
backup.Parent = ServerStorage

local links = Instance.new("Folder")
links.Name = "AisleLinks"
local function asphalt(name, size, position, rowIndex, side, zoneX)
	local source = rows[rowZs[rowIndex]].sample
	local part = Instance.new("Part")
	part.Name, part.Size, part.Position = name, size, position
	part.Anchored = true
	part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = false, false, false, false
	part.Material, part.Color, part.Transparency = Enum.Material.Slate, routeColor, 0
	part:SetAttribute("Tier", rowIndex)
	part:SetAttribute("Side", side)
	if zoneX then part:SetAttribute("PortalX", zoneX) end
	part.Parent = links
	return part
end

local depth = 8
local aisleOffset = 9
local connectorWidth = 8.5
for rowIndex, z in ipairs(rowZs) do
	local row = rows[z]
	local surfaceY = row.sample.Position.Y
	for _, side in ipairs({ -1, 1 }) do
		local edgeA = side * (path.Size.X / 2 - 0.2)
		local edgeB = side * (math.max(math.abs(row.xs[1]), math.abs(row.xs[#row.xs])) + row.sample.Size.X / 2 + 0.2)
		local aisle = asphalt(string.format("TierAisle_%d_%s", rowIndex, side < 0 and "Left" or "Right"), Vector3.new(math.abs(edgeB - edgeA), 0.12, depth), Vector3.new((edgeA + edgeB) / 2, surfaceY - 0.02, z + aisleOffset), rowIndex, side < 0 and "left" or "right")
		assert(aisle.Size.X > 0 and math.abs(aisle.Position.Z - z - aisleOffset) < 0.01, "Aisle geometry invalid")
		for _, x in ipairs(row.xs) do
			if math.sign(x) == side then
				local connector = asphalt(string.format("PortalConnector_%d_%d", rowIndex, math.abs(x)), Vector3.new(connectorWidth, 0.12, aisleOffset), Vector3.new(x, surfaceY - 0.02, z + aisleOffset / 2), rowIndex, side < 0 and "left" or "right", x)
				assert(connector.Position.Z + connector.Size.Z / 2 >= aisle.Position.Z - aisle.Size.Z / 2 - 0.01, "Connector misses aisle")
				assert(connector.Size.X < row.sample.Size.X and connector.Size.X >= 8, "Connector must fit the portal opening")
			end
		end
	end
end

oldLinks:Destroy()
links.Parent = approaches
local aisleCount, connectorCount = 0, 0
for _, part in ipairs(links:GetChildren()) do
	assert(part:IsA("BasePart") and not part.CanCollide and not part.CanTouch and not part.CanQuery, "Routes must remain decorative")
	if string.match(part.Name, "^TierAisle_") then aisleCount += 1 end
	if string.match(part.Name, "^PortalConnector_") then connectorCount += 1 end
end
assert(aisleCount == 6 and connectorCount == 18 and #links:GetChildren() == 24, "Portal route build incomplete")
return string.format("REFUGE_PORTAL_ROUTES_OK backup=%s rows=3 aisles=6 connectors=18 decorative=true", backup.Name)
