-- Temporary LocalScript in Play only, before starting the game.
local player=game.Players.LocalPlayer
local gui=player.PlayerGui:WaitForChild("SurvivorHub")
local menu=gui:WaitForChild("Welcome")
local viewport=gui:WaitForChild("WelcomeIllustration")
assert(viewport:IsA("ViewportFrame") and viewport.CurrentCamera)
assert(viewport.WorldModel:FindFirstChild("CivilianBody"))
for _,name in {"Brand","Subtitle","Warning","Play","Options","StartHint"} do
 local label=menu:FindFirstChild(name)
 assert(label and label.Visible and label.TextFits,name.." does not fit")
end
local previous=player:GetAttribute("ReducedMotion")
player:SetAttribute("ReducedMotion",true)
task.wait(.15)
local still=viewport.CurrentCamera.CFrame
task.wait(.3)
assert((still.Position-viewport.CurrentCamera.CFrame.Position).Magnitude<.001,"Reduced motion camera moved")
player:SetAttribute("ReducedMotion",previous)
print("Horror start menu QA passed")
script:Destroy()
