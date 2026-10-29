-- Play client only: run immediately after clicking VOIR LE PROLOGUE. Never install in Edit.
local player = game.Players.LocalPlayer
local gui = player.PlayerGui.SurvivorHub
local art = gui.WelcomeIllustration
assert(art.Prologue.Visible and not gui.Welcome.Visible, "Prologue did not start")
local previous = player:GetAttribute("ReducedMotion")
local ok, err = pcall(function()
 player:SetAttribute("ReducedMotion", true)
 task.wait(.1)
 local pose = art.CurrentCamera.CFrame
 task.wait(.2)
 assert(art.CurrentCamera.CFrame == pose, "ReducedMotion camera moved")
 player:SetAttribute("ReducedMotion", false)
 task.wait(.1)
 pose = art.CurrentCamera.CFrame
 task.wait(.2)
 assert(art.CurrentCamera.CFrame ~= pose, "Camera did not move")
end)
player:SetAttribute("ReducedMotion", previous)
assert(ok, err)
print("MENU_PROLOGUE_MOTION_OK")
