-- Temporary ordinary Play Script. Shared sight and damage regression.
assert(game.RunService:IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local A=require(game.ServerScriptService.PulseAbility) local Motion=require(game.ReplicatedStorage.WeaponMotion)
local c=p.Character local h=c.Humanoid local root=c.HumanoidRootPart
local saved={CF=c:GetPivot(),Health=h.Health,Level=p.leaderstats.Level.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Guard=c:GetAttribute("GuardUntil"),Ability=c:GetAttribute("AbilityId"),At=c:GetAttribute("AbilityAt")}
local arena=Instance.new("Folder",workspace) arena.Name="ArcRegressionArena"
local result=Instance.new("StringValue",game.ServerStorage) result.Name="ArcRegressionResult" result.Value="Running"
local checks={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local ok,err=pcall(function()
 local origin=Vector3.new(100,60,-120) local floor=Instance.new("Part",arena) floor.Anchored=true floor.Size=Vector3.new(40,1,40) floor.Position=origin-Vector3.new(0,4,0)
 c:PivotTo(CFrame.lookAt(origin,origin-Vector3.zAxis)) task.wait(.7)
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=28
 local model=Instance.new("Model",arena) model.Name="RegressionZombie" model:SetAttribute("ZoneId","City")
 local r=Instance.new("Part",model) r.Name="HumanoidRootPart" r.Size=Vector3.new(2,2,1) r.Position=origin-Vector3.new(0,0,6) r.Anchored=true r.CanCollide=false
 local enemy=Instance.new("Humanoid",model) enemy.MaxHealth=1000 enemy.Health=1000 model.PrimaryPart=r game.CollectionService:AddTag(model,"Zombie")
 local state={character=c,humanoid=h,stamina=100}
 for _,test in {{"Frost",30},{"Slam",34},{"Pulse",20}} do
  state.stamina=100 task.wait(.15) local before=enemy.Health
  local accepted,hits=A.Handle(p,state,test[1],Vector3.new(0,0,-1))
  check(accepted and hits==1 and enemy.Health==before-test[2],test[1].." retains exact damage through shared pipeline")
 end
 state.stamina=100 task.wait(.15) local accepted=A.Handle(p,state,"Aegis") check(accepted and c:GetAttribute("GuardUntil")>workspace:GetServerTimeNow()+3,"Aegis still grants server guard")
 h.Health=50 state.stamina=100 task.wait(.15) local accepted,heal=A.Handle(p,state,"SecondSouffle") check(accepted and heal==35 and h.Health==85,"Second souffle still heals 35 percent")
 for i=0,60 do
  local pose,weight,body=Motion.Ability("Arc",i/60,1)
  for _,v in {pose:GetComponents()} do assert(v==v and math.abs(v)<math.huge) end
  assert(weight==weight and body==body and math.abs(weight)<math.huge and math.abs(body)<math.huge)
 end
 check(Motion.Ability("Arc",1,1)==CFrame.identity,"All Arc pose components finite and settled")
end)
arena:Destroy() c:PivotTo(saved.CF) h.Health=saved.Health p.leaderstats.Level.Value=saved.Level
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) c:SetAttribute("GuardUntil",saved.Guard) c:SetAttribute("AbilityId",saved.Ability) c:SetAttribute("AbilityAt",saved.At)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Restored=true})
