-- Temporary Client Play fixture; do not install as a startup script.
local player=game.Players.LocalPlayer
local live=workspace:WaitForChild("LiveZombies")
local camera=workspace.CurrentCamera
local previous=player:GetAttribute("ReducedMotion")
local copies={} local result={} local poses={}
local function angle(cf) local _,a=cf:ToAxisAngle() return math.abs(a) end
local ok,err=pcall(function()
 for _,kind in {"Civilian","Runner","Brute"} do
  local source
  for _,m in live:GetChildren() do if m:GetAttribute("ZoneId")=="City" and m:GetAttribute("ZombieType")==kind then source=m break end end
  assert(source,"Missing spawned "..kind)
  local m=source:Clone() table.insert(copies,m) m.Name="QA_"..kind
  m:SetAttribute("AttackPhase","Idle") m:SetAttribute("Dead",false)
  m.Humanoid.Health=m.Humanoid.MaxHealth m.HumanoidRootPart.Anchored=true
  m:PivotTo(camera.CFrame*CFrame.new(0,0,-8)) m.Parent=live
  player:SetAttribute("ReducedMotion",false) task.wait(.5)
  local joint=m.Torso:FindFirstChild("Right Shoulder") assert(joint,"Missing shoulder")
  local idle=joint.Transform poses[kind]=idle
  m:SetAttribute("AttackWindup",.5) m:SetAttribute("AttackRecovery",.4)
  m:SetAttribute("AttackAt",workspace:GetServerTimeNow()-.48) m:SetAttribute("AttackPhase","Windup")
  task.wait(.25) local attack=joint.Transform
  local change=angle(idle:Inverse()*attack) local full=angle(attack)
  player:SetAttribute("ReducedMotion",true) task.wait(.35) local reduced=angle(joint.Transform)
  assert(change>.2 and reduced<full*.6,"Attack or reduced motion failed for "..kind)
  result[kind]={attackChange=change,full=full,reduced=reduced}
  m:Destroy()
 end
 assert(angle(poses.Civilian:Inverse()*poses.Runner)>.1 and angle(poses.Runner:Inverse()*poses.Brute)>.1,"Idle profiles are not distinct")
end)
for _,m in copies do m:Destroy() end player:SetAttribute("ReducedMotion",previous)
assert(ok,err)
print("City zombie animation fixture passed")
return game.HttpService:JSONEncode(result)
