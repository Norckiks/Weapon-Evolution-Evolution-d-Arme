-- Temporary Play-only structural checks; no screenshot or physical input proof.
assert(game.RunService:IsStudio())
local p=game.Players.LocalPlayer
local bridge=game.ReplicatedStorage:WaitForChild("IllustratedUIBridge",10) assert(bridge)
bridge.OnClientInvoke=function(page)
 local count=0
 local function check(ok,message) assert(ok,page..": "..message) count+=1 end
 local hud=p.PlayerGui.SurvivalHUD local w=p.PlayerGui.SurvivorHub.Window
 check(hud.StatusPanel.Size==UDim2.fromOffset(232,114),"compact HUD dimensions")
 check(hud.ProgressCard.Size==UDim2.fromOffset(320,58),"compact XP card")
 for _,id in {"Health","Speed","Coins","XP"} do
  local image=hud:FindFirstChild(id.."Artwork",true)
  check(image and image.ImageRectSize==Vector2.new(256,256),"atlas cell "..id)
 end
 check(w.Visible,"catalog open")
 local rows,images=0,0
 for _,row in w.Catalog:GetChildren() do
  if not row:IsA("Frame") then continue end
  rows+=1 local names={}
  for _,child in row:GetChildren() do
   if child:IsA("ImageLabel") then
    check(not names[child.Name],"duplicate artwork "..child.Name)
    names[child.Name]=true images+=1
    check(child.Position.X.Offset+child.Size.X.Offset<=670,"artwork within row")
   elseif child:IsA("TextButton") and child.Name=="Action" then
    check(child.Position.Y.Offset+child.Size.Y.Offset<=row.Size.Y.Offset,"action within row")
    if page=="Robux" then check(not child.Active,"Robux remains disabled") end
   end
  end
 end
 check(rows>0,"catalog populated")
 check(images>0 or page=="Weapons","illustrated catalog")
 return {Page=page,Checks=count,Rows=rows,Images=images,Viewport=tostring(workspace.CurrentCamera.ViewportSize)}
end
