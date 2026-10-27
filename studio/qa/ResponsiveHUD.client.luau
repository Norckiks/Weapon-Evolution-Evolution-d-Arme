-- Temporary Play snapshot; start the game and settle the desired simulator mode first.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
task.wait(.35)
local g=p.PlayerGui:WaitForChild("AbilityHUD",5) assert(g)
local checks={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local touch=game.UserInputService.TouchEnabled local viewport=workspace.CurrentCamera.ViewportSize
check(p:GetAttribute("HasStarted")==true and not p:GetAttribute("GameMenuOpen") and not p:GetAttribute("OptionsOpen"),"Playing without menu")
check(g.AbilityButton.Visible,"Ability card remains visible")
check(g.AbilitySelector.Visible==touch,"Selector follows touch capability")
check(math.abs(g.AbilityButton.AbsoluteSize.X-(touch and 56 or 190))<3,"Correct card width")
local count=0
if touch then
 check(g.AbilitySelector.AbsoluteSize.X>=44 and g.AbilitySelector.AbsoluteSize.Y>=44,"Selector touch target at least 44")
 local context=p.PlayerGui:FindFirstChild("ContextActionGui") assert(context,"Missing ContextActionGui")
 for _,b in context:GetDescendants() do if b:IsA("ImageButton") and b:FindFirstChild("ActionTitle") then count+=1 end end
 check(count==7,"Exactly seven native action buttons")
end
local old=p.PlayerGui:FindFirstChild("ResponsiveHUDQAResult") if old then old:Destroy() end
local r=Instance.new("StringValue") r.Name="ResponsiveHUDQAResult" r.Value=game.HttpService:JSONEncode({Passed=true,Checks=checks,Touch=touch,Viewport=tostring(viewport),TouchButtons=count,Text=g.AbilityButton.Text}) r.Parent=p.PlayerGui
script:Destroy()
