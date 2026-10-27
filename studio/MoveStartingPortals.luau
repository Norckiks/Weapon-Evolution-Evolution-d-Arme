-- One-time Edit operation; never install as a startup script.
local portals=workspace.ProgressionZones.RefugePortals
local city=portals.Travel_City local factory=portals.Travel_Factory
assert(city.Field.Position==Vector3.new(-32,4.5,208) and factory.Field.Position==Vector3.new(0,4.5,208),"Inspect existing portal positions before moving")
assert(not game.ServerStorage:FindFirstChild("BeforeStartingPortals"),"Backup already exists; inspect before retrying")
local backup=Instance.new("Folder") backup.Name="BeforeStartingPortals"
city:Clone().Parent=backup factory:Clone().Parent=backup backup.Parent=game.ServerStorage
city:PivotTo(CFrame.new(32,0,0)*city:GetPivot())
factory:PivotTo(CFrame.new(-32,0,0)*factory:GetPivot())
assert(city.Field.Position==Vector3.new(0,4.5,208) and factory.Field.Position==Vector3.new(-32,4.5,208),"Portal move failed")
return "City and Factory portals exchanged"
