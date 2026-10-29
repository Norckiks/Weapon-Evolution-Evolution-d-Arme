-- Temporary Server Play fixture; do not install as a startup script.
assert(game:GetService("RunService"):IsStudio())
local storage=game:GetService("ServerStorage")
local output=Instance.new("StringValue") output.Name="CityZombieReworkQA" output.Parent=storage
local ok,result=pcall(function()
 local ballistics=require(game.ReplicatedStorage.FirearmBallistics)
 local live=workspace:WaitForChild("LiveZombies") local found={} local counts={}
 for _,m in live:GetChildren() do
  local kind=m:GetAttribute("ZombieType")
  if m:GetAttribute("ZoneId")=="City" and (kind=="Civilian" or kind=="Runner" or kind=="Brute") then
   counts[kind]=(counts[kind] or 0)+1 found[kind]=m
  end
 end
 local results={counts=counts}
 for _,kind in {"Civilian","Runner","Brute"} do
  local m=assert(found[kind],"Missing "..kind) assert(counts[kind]==2,"Wrong spawn count "..kind)
  assert(m:GetAttribute("CitySculptV2")==true,"Old model "..kind)
  for _,name in {"VisualHead","VisualTorso","VisualLeftArm","VisualRightArm","VisualLeftLeg","VisualRightLeg"} do
   local part=m:FindFirstChild(name) assert(part and part:IsA("MeshPart") and part.CanQuery and not part.CanCollide,"Missing mesh "..name)
   local weld=part:FindFirstChildOfClass("WeldConstraint") assert(weld and weld.Part0 and weld.Part1==part,"Missing weld "..name)
  end
  local head=m.VisualHead local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Include params.FilterDescendantsInstances={head}
  local look=head.CFrame.LookVector local hit=workspace:Raycast(head.Position+look*6,-look*12,params)
  assert(hit and hit.Instance==head,"Head ray missed "..kind)
  local damage,critical=ballistics.HitDamage({Damage=20},hit.Instance,m,1.5)
  assert(damage==30 and critical,"Headshot regression "..kind)
  local normal,isHead=ballistics.HitDamage({Damage=20},m.VisualTorso,m,1.5)
  assert(normal==20 and not isHead,"Torso damage regression "..kind)
  results[kind]={health=m.Humanoid.MaxHealth,headshot=damage,torso=normal}
 end
 return game.HttpService:JSONEncode(results)
end)
output.Value=ok and result or "ERROR: "..tostring(result)
script:Destroy()
