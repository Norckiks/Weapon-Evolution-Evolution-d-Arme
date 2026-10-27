-- Snapshot UI en Play uniquement, après ouverture d'un onglet et stabilisation du simulateur.
local p=game.Players.LocalPlayer
local hud=p.PlayerGui:WaitForChild("SurvivalHUD")
local w=p.PlayerGui:WaitForChild("SurvivorHub").Window
assert(w.Visible,"Ouvrir un onglet avant le snapshot")
local checks=0
local function check(ok,message) assert(ok,message) checks+=1 end
check(hud.StatusPanel.Size==UDim2.fromOffset(232,114),"Dimensions du HUD compact")
local shortcuts=p.PlayerGui.SurvivorHub.QuickNavigation
local shop=shortcuts:FindFirstChildWhichIsA("TextButton")
check(shop and (game.UserInputService.TouchEnabled and shop.Text:match("^MENU")~=nil or not game.UserInputService.TouchEnabled and shop.Text=="BOUTIQUES [B]"),"Libellé boutique périmé après changement de périphérique")
for _,id in {"Health","Speed","Coins"} do
 local image=hud.StatusPanel:FindFirstChild(id.."Artwork",true)
 check(image and image.IsLoaded,"Image HUD non chargée : "..id)
end
local rows=0
for _,r in w.Catalog:GetChildren() do
 if r:IsA("Frame") then
  rows+=1
  for _,name in {"Name","Description"} do
   local label=r:FindFirstChild(name)
   if label then check(label.TextFits,r.Name.." : "..name) end
  end
  for _,b in r:GetChildren() do
   if b:IsA("TextButton") and b.Name=="Action" then
    check(b.TextFits,r.Name.." : texte action")
    check(b.Position.Y.Offset+b.Size.Y.Offset<=r.Size.Y.Offset,r.Name.." : action hors carte")
    if game.UserInputService.TouchEnabled then check(b.AbsoluteSize.Y>=43.9,r.Name.." : cible tactile <44px") end
   end
  end
 end
end
print(game.HttpService:JSONEncode({page=w.PageTitle.Text,viewport=tostring(workspace.CurrentCamera.ViewportSize),checks=checks,rows=rows}))
