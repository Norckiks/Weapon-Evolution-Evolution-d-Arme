-- One-time Edit repair: widen and brighten portal routes without changing travel fields or collision.
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
assert(game.PlaceId == 89391796839094 and not RunService:IsRunning(), "Run in the target place, Edit only")

local courtyard = workspace:WaitForChild("RefugeCourtyard")
local path = courtyard:WaitForChild("CentralPath")
local links = courtyard:WaitForChild("RefugeTierInfrastructure"):WaitForChild("PortalApproaches"):WaitForChild("AisleLinks")
local backupName = "BeforeRefugePortalRouteWidth_20261029"
assert(not ServerStorage:FindFirstChild(backupName), "Inspect the existing route width backup before rerunning")
assert(#links:GetChildren() == 24 and math.abs(path.Size.X - 24) < 0.05, "Portal route layout changed")

local backup = Instance.new("Folder")
backup.Name = backupName
links:Clone().Parent = backup
backup.Parent = ServerStorage

local routeColor = Color3.fromRGB(58, 75, 88)
local aisles, connectors = {}, {}
for _, part in ipairs(links:GetChildren()) do
	assert(part:IsA("BasePart") and part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery, "Route must stay decorative: " .. part.Name)
	if string.match(part.Name, "^TierAisle_") then
		assert(math.abs(part.Size.Z - 4) < 0.05, "Unexpected aisle width: " .. part.Name)
		part.Size = Vector3.new(part.Size.X, part.Size.Y, 8)
		aisles[(part:GetAttribute("Tier") or 0) .. "_" .. tostring(part:GetAttribute("Side"))] = part
	elseif string.match(part.Name, "^PortalConnector_") then
		assert(math.abs(part.Size.X - 3) < 0.05, "Unexpected connector width: " .. part.Name)
		part.Size = Vector3.new(8.5, part.Size.Y, part.Size.Z)
		table.insert(connectors, part)
	else
		error("Unknown route part: " .. part.Name)
	end
	part.Material, part.Color = Enum.Material.Slate, routeColor
end

assert(#connectors == 18, "Expected 18 portal connectors")
for _, connector in ipairs(connectors) do
	local side = connector.Position.X < 0 and "left" or "right"
	local aisle = aisles[(connector:GetAttribute("Tier") or 0) .. "_" .. side]
	assert(aisle, "Aisle missing for " .. connector.Name)
	local xOverlap = math.min(connector.Position.X + connector.Size.X / 2, aisle.Position.X + aisle.Size.X / 2) - math.max(connector.Position.X - connector.Size.X / 2, aisle.Position.X - aisle.Size.X / 2)
	local zOverlap = math.min(connector.Position.Z + connector.Size.Z / 2, aisle.Position.Z + aisle.Size.Z / 2) - math.max(connector.Position.Z - connector.Size.Z / 2, aisle.Position.Z - aisle.Size.Z / 2)
	assert(xOverlap > 0 and zOverlap > 0, "Route gap at " .. connector.Name)
	assert(connector.Size.X < 9.5, "Connector exceeds the 9.5-stud portal opening")
end
for _, aisle in pairs(aisles) do
	local pathEdge = math.sign(aisle.Position.X) * path.Size.X / 2
	local aisleInner = aisle.Position.X - math.sign(aisle.Position.X) * aisle.Size.X / 2
	assert(math.abs(pathEdge - aisleInner) <= 0.21, "Aisle no longer meets the central path: " .. aisle.Name)
	assert(aisle.Size.Z == 8 and aisle.Material == Enum.Material.Slate and aisle.Color == routeColor, "Aisle finish/width check failed")
end
return string.format("REFUGE_PORTAL_ROUTE_WIDTH_OK backup=%s aisles=6 width=8 connectors=18 width=8.5 connected=true decorative=true", backup.Name)
