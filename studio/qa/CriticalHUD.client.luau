-- Temporary SessionStudio LocalScript; fixture prepares/restores maximum upgrades.
local p=game.Players.LocalPlayer assert(game:GetService("RunService"):IsStudio() and p:GetAttribute("PersistenceMode")=="SessionStudio")
local c=p.Character local h=c:WaitForChild("Humanoid") local panel=p.PlayerGui.SurvivalHUD.StatusPanel
local health=panel.HealthCard local stamina=panel.StaminaCard
local result=Instance.new("StringValue") result.Name="CriticalHUDQAResult" result.Value="Running" result.Parent=p.PlayerGui
local saved={health=h.Health,stamina=c:GetAttribute("Stamina"),max=c:GetAttribute("MaxStamina"),exhausted=c:GetAttribute("SprintExhausted")}
local checks={} local function check(v,name) assert(v,name) table.insert(checks,name) end
local function observeStamina(value,exhausted,predicate)
 local deadline=os.clock()+.5
 repeat
  c:SetAttribute("Stamina",value) c:SetAttribute("SprintExhausted",exhausted) task.wait(.02)
  if predicate() then return true end
 until os.clock()>deadline
 return false
end
local ok,err=pcall(function()
 check(h.MaxHealth==300 and c:GetAttribute("MaxStamina")==200,"Maximum upgrade capacities active")
 check(health.HealthValue.TextFits and stamina.StaminaValue.TextFits,"Maximum values fit")
 h.Health=50 task.wait(.03)
 check(health.Title.Text=="VIE CRITIQUE" and health.Title.TextColor3==Color3.fromRGB(170,48,55),"Critical health is labeled and red")
 h.Health=300 task.wait(.03)
 check(health.Title.Text=="VIE" and health.Title.TextColor3==Color3.fromRGB(64,137,82),"Recovered health returns green label")
 check(observeStamina(10,true,function() return stamina.Title.Text=="RELACHE SPRINT" and stamina.Title.TextFits and stamina.Title.TextColor3==Color3.fromRGB(145,76,28) and stamina.StaminaValue.TextColor3==Color3.fromRGB(145,76,28) end),"Exhaustion explains release, fits and uses orange")
 check(observeStamina(200,false,function() return stamina.Title.Text=="ENDURANCE" and stamina.Title.TextColor3==Color3.fromRGB(42,125,164) end),"Recovered stamina returns blue label")
end)
h.Health=math.min(saved.health,h.MaxHealth) c:SetAttribute("Stamina",saved.stamina) c:SetAttribute("MaxStamina",saved.max) c:SetAttribute("SprintExhausted",saved.exhausted)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Restored=true})
