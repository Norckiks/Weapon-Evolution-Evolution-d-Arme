-- Run only as a temporary Script in SessionStudio Play.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local model=workspace:WaitForChild("RefugeCourtyard") local W=require(game.ReplicatedStorage.WorldConfig)
local result=Instance.new("StringValue") result.Name="RefugeCourtyardQAResult" result.Parent=game.ServerStorage
local checks={}
local function check(value,name) assert(value,name) table.insert(checks,name) end
local ok,err=pcall(function()
 local ray=RaycastParams.new() ray.FilterType=Enum.RaycastFilterType.Include ray.FilterDescendantsInstances={model} ray.RespectCanCollide=true
 local overlap=OverlapParams.new() overlap.FilterType=Enum.RaycastFilterType.Include overlap.FilterDescendantsInstances={model}
 for _,z in {232,250,275,300,325,340} do
  local pos=Vector3.new(0,4,z) local h=workspace:Raycast(pos+Vector3.new(0,4,0),Vector3.new(0,-12,0),ray)
  check(h and h.Instance.Name=="CourtyardGround" and math.abs(h.Position.Y-.2)<.01 and not W.ZoneAt(pos),"Safe continuous ground at "..z)
  local clear=true for _,v in workspace:GetPartBoundsInBox(CFrame.new(0,4,z),Vector3.new(8,5,8),overlap) do if v.CanCollide then clear=false end end
  check(clear,"Central path clear at "..z)
 end
 local f=workspace.ProgressionZones.RefugePortals.Travel_City.Field
 check(f:GetAttribute("Destination")=="City" and f.ZoneTravel.Enabled,"City portal preserved")
 check(model.CourtyardGround.Size==Vector3.new(240,.2,132),"Courtyard footprint")
end)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks})
