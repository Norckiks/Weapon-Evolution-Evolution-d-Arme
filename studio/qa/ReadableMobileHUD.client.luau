-- Snapshot only; run as a temporary LocalScript in SessionStudio Play.
local p=game.Players.LocalPlayer assert(game:GetService("RunService"):IsStudio() and p:GetAttribute("PersistenceMode")=="SessionStudio")
local g=p.PlayerGui local hud=g.SurvivalHUD.StatusPanel local ability=g.AbilityHUD
local result=Instance.new("StringValue") result.Name="ReadableMobileHUDQAResult" result.Parent=g
local checks={} local function check(v,name) assert(v,name) table.insert(checks,name) end
local function overlaps(a,b)
 local x,y=a.AbsolutePosition,b.AbsolutePosition local s,t=a.AbsoluteSize,b.AbsoluteSize
 return x.X<y.X+t.X and y.X<x.X+s.X and x.Y<y.Y+t.Y and y.Y<x.Y+s.Y
end
local ok,err=pcall(function()
 check(game:GetService("UserInputService").TouchEnabled,"Touch simulation active")
 check(math.abs(hud.UIScale.Scale-.8)<.01 and not hud.ControlHints.Visible,"Readable scale and hidden decoration")
 check(hud.HealthCard.HealthValue.TextFits and hud.StaminaCard.StaminaValue.TextFits,"Values fit")
 for _,card in {hud.HealthCard,hud.StaminaCard,hud.CoinsCard} do
  for _,other in {ability.AbilityButton,ability.AbilitySelector,g.SurvivorHub.QuickNavigation} do
   if other.Visible then check(not overlaps(card,other),card.Name.." avoids "..other.Name) end
  end
  local cas=game:GetService("ContextActionService")
  local group=g:FindFirstChild("ContextActionGui") and g.ContextActionGui:FindFirstChild("ContextButtonFrame")
  if group and group.Visible then for _,name in {"SurvivalSprint","SurvivalVault","FistsPunch"} do
   local button=cas:GetAllBoundActionInfo()[name] and cas:GetButton(name)
   if button and button.Parent and button.Visible then check(not overlaps(card,button),card.Name.." avoids "..name) end
  end end
 end
 local admin=g:FindFirstChild("AdminPanel") local open=admin and admin:FindFirstChild("Open")
 if open and open.Visible then
  for _,other in {ability.AbilityButton,ability.AbilitySelector} do if other.Visible then check(not overlaps(open,other),"Admin avoids "..other.Name) end end
 end
end)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Viewport=tostring(workspace.CurrentCamera.ViewportSize)})
