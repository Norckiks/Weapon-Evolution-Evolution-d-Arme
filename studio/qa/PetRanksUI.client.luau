-- Snapshot after PreparePetRankUI; properties only, no rendered-image claim.
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local C=require(game.ReplicatedStorage.GameplayConfig)
local phase=p:GetAttribute("PetRanksQAPhase")
local row=p.PlayerGui.SurvivorHub.Window.Catalog.Pet_Civilian
local count=0 local function check(ok,message) assert(ok,message) count+=1 end
local rank=phase=="TechnicalLimit" and 1000000000 or phase=="BeyondCap" and 4 or phase=="RankOnly" and 1 or 0
local needed=rank<1000000000 and C.PetRankCost(rank) or nil
check(row.Description.Text:find("Rang "..string.format("%.0f",rank),1,true),"Rank text")
check(row.Evolve.Text==(needed and "EVOLUER" or "LIMITE TECH."),"Evolution label")
check(row.Evolve.Active==(phase=="Ready"),"Evolution enable state")
check(row:FindFirstChild("PetsArtwork")~=nil,"Pet image")
check(row:FindFirstChild("Name").Text=="Mini Rodeur","Rank number remains compact at high levels")
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
