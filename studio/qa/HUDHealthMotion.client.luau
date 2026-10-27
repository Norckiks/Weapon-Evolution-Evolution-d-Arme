-- Temporary LocalScript for SessionStudio Play only; restore the character afterward.
local p=game.Players.LocalPlayer assert(game:GetService("RunService"):IsStudio() and p:GetAttribute("PersistenceMode")=="SessionStudio")
local h=p.Character:WaitForChild("Humanoid") local track=p.PlayerGui.SurvivalHUD.StatusPanel.HealthCard.Track
local result=Instance.new("StringValue") result.Name="HUDHealthMotionQAResult" result.Value="Running" result.Parent=p.PlayerGui
local saved={health=h.Health,max=h.MaxHealth,reduced=p:GetAttribute("ReducedMotion")}
local checks={} local function check(v,name) assert(v,name) table.insert(checks,name) end
local function close(a,b) return math.abs(a-b)<.03 end
local ok,err=pcall(function()
 p:SetAttribute("ReducedMotion",true) h.MaxHealth=200 h.Health=100 task.wait(.08)
 check(close(track.Fill.Size.X.Scale,.5) and close(track.DamageTrail.Size.X.Scale,.5),"Maximum change synchronizes both bars")
 h.Health=50 task.wait(.05)
 check(close(track.Fill.Size.X.Scale,.25) and close(track.DamageTrail.Size.X.Scale,.25),"Reduced motion shows damage immediately")
 h.Health=100 task.wait(.06) p:SetAttribute("ReducedMotion",false) h.Health=50 task.wait(.05)
 check(track.DamageTrail.Size.X.Scale>track.Fill.Size.X.Scale,"Normal damage retains animated trail")
 p:SetAttribute("ReducedMotion",true) task.wait(.05)
 check(close(track.Fill.Size.X.Scale,.25) and close(track.DamageTrail.Size.X.Scale,.25),"Enabling reduced motion cancels active animation")
end)
h.MaxHealth=saved.max h.Health=math.min(saved.health,saved.max) p:SetAttribute("ReducedMotion",saved.reduced)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Restored=true})
