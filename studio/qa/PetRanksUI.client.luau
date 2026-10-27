-- Snapshot after PreparePetRankUI; properties only, no rendered-image claim.
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local phase=p:GetAttribute("PetRanksQAPhase")
local row=p.PlayerGui.SurvivorHub.Window.Catalog.Pet_Civilian
local count=0 local function check(ok,message) assert(ok,message) count+=1 end
local rank=phase=="Max" and 3 or phase=="RankOnly" and 1 or 0
check(row.Description.Text:find("Rang "..rank.."/3",1,true),"Rank text")
check(row.Evolve.Text==(rank==3 and "MAX" or "EVOLUER"),"Evolution label")
check(row.Evolve.Active==(phase=="Ready"),"Evolution enable state")
check(row:FindFirstChild("PetsArtwork")~=nil,"Pet image")
if rank>0 then check(row:FindFirstChild("Name").Text:find(string.rep("★",rank),1,true),"Rank stars") end
local buttons={}
for _,v in row:GetChildren() do
 if v:IsA("TextButton") then
  table.insert(buttons,v)
  check(v.Position.X.Offset+v.Size.X.Offset<=670 and v.Position.Y.Offset+v.Size.Y.Offset<=row.Size.Y.Offset,"Action within row")
 end
end
check(#buttons==3,"Evolve, fuse and equip remain available")
table.sort(buttons,function(a,b) return a.Position.X.Offset<b.Position.X.Offset end)
for i=2,#buttons do check(buttons[i-1].Position.X.Offset+buttons[i-1].Size.X.Offset<=buttons[i].Position.X.Offset,"Actions do not overlap") end
return {Phase=phase,Checks=count,Rank=rank,Viewport=tostring(workspace.CurrentCamera.ViewportSize)}
