-- Snapshot only; run temporarily in SessionStudio after the device has settled.
local p=game.Players.LocalPlayer assert(game:GetService("RunService"):IsStudio() and p:GetAttribute("PersistenceMode")=="SessionStudio")
local g=p.PlayerGui local q=g.SurvivorHub.QuickNavigation local touch=game:GetService("UserInputService").TouchEnabled
local result=Instance.new("StringValue") result.Name="ResponsiveShortcutsQAResult" result.Parent=g
local checks={} local function check(v,name) assert(v,name) table.insert(checks,name) end
local function overlaps(a,b)
 local x,y=a.AbsolutePosition,b.AbsolutePosition local s,t=a.AbsoluteSize,b.AbsoluteSize
 return x.X<y.X+t.X and y.X<x.X+s.X and x.Y<y.Y+t.Y and y.Y<x.Y+s.Y
end
local ok,err=pcall(function()
 local buttons={} for _,v in q:GetChildren() do if v:IsA("TextButton") and v.Visible then table.insert(buttons,v) end end
 check(q.Visible and #buttons==(touch and 1 or 3),"Correct number of visible shortcuts")
 for _,b in buttons do check(b.TextFits,"Shortcut text fits") end
 local movement=g:FindFirstChild("MovementHint",true)
 if movement and movement.Visible then for _,b in buttons do check(not overlaps(b,movement),"Shortcut avoids movement hint") end end
 local panel=g.SurvivalHUD.StatusPanel
 check(panel.HealthCard.HealthValue.TextFits and panel.StaminaCard.StaminaValue.TextFits,"Health and stamina values fit")
end)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Touch=touch,Viewport=tostring(workspace.CurrentCamera.ViewportSize)})
