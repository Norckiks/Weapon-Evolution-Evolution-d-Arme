-- Real director physical pursuit on an isolated temporary upper floor. Never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local c=p.Character local root=c.HumanoidRootPart local hum=c.Humanoid
local saved={CF=c:GetPivot(),Anchored=root.Anchored,Health=hum.Health,Level=p.leaderstats.Level.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name=script:GetAttribute("ResultName") or "NavigationDirectorQAResult" result.Value="Running" result.Parent=game.ServerStorage
local report={Samples={},Checks={},Label=script:GetAttribute("Label") or "Current"} local target local original
local arena=Instance.new("Folder") arena.Name="NavigationDirectorQA" arena.Parent=workspace
local function check(ok,name) assert(ok,name) table.insert(report.Checks,name) end
local ok,err=pcall(function()
 for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")=="Brute" and v:GetAttribute("ZoneId")=="City" and v.Humanoid.Health>0 then target=v break end end assert(target,"Brute not spawned")
 original={CF=target:GetPivot(),Anchored=target.HumanoidRootPart.Anchored}
 local home=target.HumanoidRootPart.Position local start=Vector3.new(home.X,64.05,home.Z) local goal=Vector3.new(home.X,63,home.Z+20)
 local floor=Instance.new("Part") floor.Name="UpperFloor" floor.Size=Vector3.new(80,1,80) floor.Position=Vector3.new(home.X,59.5,home.Z+5) floor.Anchored=true floor.Parent=arena
 local wall=Instance.new("Part") wall.Name="DetourWall" wall.Size=Vector3.new(28,12,2) wall.Position=Vector3.new(home.X,66,home.Z+10) wall.Anchored=true wall.Parent=arena
 task.wait(2)
 local path=game.PathfindingService:CreatePath({AgentRadius=1.6*1.35,AgentHeight=5.2*1.35,AgentCanJump=true,WaypointSpacing=5})
 local success=pcall(function() path:ComputeAsync(start,goal) end)
 check(success and path.Status==Enum.PathStatus.Success,"Temporary physical arena has a valid detour path")
 report.ProbeWaypoints=#path:GetWaypoints() report.ProbeY=path:GetWaypoints()[2] and path:GetWaypoints()[2].Position.Y
 path:Destroy()
 p.leaderstats.Level.Value=20 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) root.Anchored=true c:PivotTo(CFrame.new(goal))
 target.HumanoidRootPart.Anchored=false target:PivotTo(CFrame.new(start)) target.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero
 local began=os.clock() local previous=began local reached=false local idle=0 local signature=0 local minimum=math.huge local deviation=0
 while os.clock()-began<18 do
  task.wait(.2) local now=os.clock() local r=target.HumanoidRootPart local delta=goal-r.Position
  local distance=Vector3.new(delta.X,0,delta.Z).Magnitude local speed=Vector3.new(r.AssemblyLinearVelocity.X,0,r.AssemblyLinearVelocity.Z).Magnitude
  minimum=math.min(minimum,distance) deviation=math.max(deviation,math.abs(r.Position.X-home.X))
  local waypoint=target.Humanoid.WalkToPoint local offset=waypoint-r.Position local horizontal=Vector3.new(offset.X,0,offset.Z).Magnitude
  if distance>6 and speed<.5 then idle+=now-previous if horizontal<1.5 and math.abs(offset.Y)>3 then signature+=now-previous end end
  table.insert(report.Samples,{Time=now-began,X=r.Position.X,Y=r.Position.Y,Z=r.Position.Z,Distance=distance,Speed=speed,WaypointHorizontal=horizontal,WaypointVertical=math.abs(offset.Y),NavState=target:GetAttribute("NavigationState")})
  previous=now
  if distance<=6 then reached=true break end
 end
 report.Reached=reached report.Elapsed=os.clock()-began report.IdleSeconds=idle report.VerticalWaypointStallSeconds=signature report.MinimumDistance=minimum report.MaximumDetourX=deviation
 if script:GetAttribute("RequireArrival") then check(reached and deviation>14,"Real director physically navigates around the solid wall") end
end)
if target and target.Parent and original then target:PivotTo(original.CF) target.HumanoidRootPart.Anchored=original.Anchored target.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero end
arena:Destroy() c:PivotTo(saved.CF) root.Anchored=saved.Anchored hum.Health=math.min(saved.Health,hum.MaxHealth) p.leaderstats.Level.Value=saved.Level p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
report.Passed=ok report.Error=not ok and tostring(err) or nil result.Value=game.HttpService:JSONEncode(report) script:Destroy()
