-- One-time Edit operation; never install as a startup script.
local root=workspace.ProgressionZones
local sign=root.RefugePortals.Travel_City.ZoneSign
local prompts={} local labels={}
for _,v in root:GetDescendants() do
 if v:IsA("ProximityPrompt") and v.Name=="ZoneTravel" then
  assert(v.MaxActivationDistance==10 and math.abs(v.HoldDuration-.35)<.001,"Inspect changed prompt before continuing")
  table.insert(prompts,v)
 end
end
for _,v in sign:GetDescendants() do if v:IsA("TextLabel") then assert(v.Text=="VILLE EN RUINE\nNIVEAU 1") table.insert(labels,v) end end
assert(#prompts==11 and #labels==2,"Inspect portal scene before continuing")
assert(not game.ServerStorage:FindFirstChild("BeforePortalSigns"),"Backup already exists")
local backup=Instance.new("Folder") backup.Name="BeforePortalSigns"
sign:Clone().Parent=backup
for _,v in prompts do local item=v:Clone() item:SetAttribute("OriginalPath",v:GetFullName()) item.Parent=backup end
backup.Parent=game.ServerStorage
for _,v in labels do v.Text="NIVEAU 1\nVILLE EN RUINE" end
for _,v in prompts do v.MaxActivationDistance=14 v.ActionText=v.ActionText=="Entrer" and "Maintenir pour entrer" or "Maintenir pour revenir" end
return {Prompts=#prompts,Labels=#labels}
