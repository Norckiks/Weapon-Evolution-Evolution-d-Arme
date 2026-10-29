-- Client Play only; run once for each simulated viewport. Never install in Edit.
local gui=game.Players.LocalPlayer.PlayerGui:WaitForChild("SurvivorHub")
local viewport=workspace.CurrentCamera.ViewportSize
assert(gui.Welcome.Visible,"Open the welcome menu first")
assert(#gui.WelcomeIllustration.WorldModel.MenuQuarantine:GetChildren()==244,"Missing Blender scenery")
for _,name in {"Play","Options","WatchPrologue"} do
 local b=gui.Welcome[name]
 assert(b.AbsoluteSize.Y>=44,name.." target too small")
 assert(b.AbsolutePosition.X>=0 and b.AbsolutePosition.Y>=0
  and b.AbsolutePosition.X+b.AbsoluteSize.X<=viewport.X
  and b.AbsolutePosition.Y+b.AbsoluteSize.Y<=viewport.Y-game:GetService("GuiService"):GetGuiInset().Y,name.." clipped")
end
return "MENU_REDESIGN_LAYOUT_OK "..tostring(viewport)
