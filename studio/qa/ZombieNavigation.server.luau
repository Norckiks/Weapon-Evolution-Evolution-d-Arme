-- Real PathfindingService and physics, temporary server Play fixture only.
assert(game:GetService("RunService"):IsStudio())
local player=game.Players:GetPlayers()[1] assert(player:GetAttribute("PersistenceMode")=="SessionStudio")
local Nav=require(game.ServerScriptService.ZombieNavigation) local World=require(game.ReplicatedStorage.WorldConfig)
local result=Instance.new("StringValue") result.Name="ZombieNavigationQAResult" result.Value="Running" result.Parent=game.ServerStorage
local arena=Instance.new("Folder") arena.Name="ZombieNavigationQA" arena.Parent=workspace
local controllers={} local checks={} local metrics={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) script:SetAttribute("Checks",#checks) end
local function spawn(position,anchored)
 local m=game.ServerStorage.ZombieTemplates.Civilian:Clone() m.Name="NavigationFixture" m:PivotTo(CFrame.new(position)) m.Parent=arena
 for _,v in m:GetDescendants() do if v:IsA("BasePart") then v.CollisionGroup="LiveZombies" end end
 m.HumanoidRootPart.Anchored=anchored==true if not anchored then pcall(function() m.HumanoidRootPart:SetNetworkOwner(nil) end) end
 local c=Nav.new(m,World.Zombies.Civilian) table.insert(controllers,{Navigation=c,Model=m}) return c,m
end
local function planar(v) return Vector3.new(v.X,0,v.Z).Magnitude end
local function drive(c,m,goal,direct,seconds)
 local began=os.clock() local maxY=m.HumanoidRootPart.Position.Y local maxZ=0 local startZ=m.HumanoidRootPart.Position.Z
 while os.clock()-began<seconds do
  c:Move(goal,direct) task.wait(.1) local p=m.HumanoidRootPart.Position maxY=math.max(maxY,p.Y) maxZ=math.max(maxZ,math.abs(p.Z-startZ))
  if planar(p-goal)<2.5 then return {Reached=true,Seconds=os.clock()-began,MaximumY=maxY,MaximumDeviationZ=maxZ} end
 end
 return {Reached=false,Seconds=os.clock()-began,MaximumY=maxY,MaximumDeviationZ=maxZ,Position=tostring(m.HumanoidRootPart.Position),State=m:GetAttribute("NavigationState"),Stuck=c.StuckRecoveries,Revision=c.Revision,JumpRequests=c.JumpRequests,Error=c.LastError}
end
local function dispose(c,m) c:Destroy() m:Destroy() end
local ok,err=pcall(function()
 local floor=Instance.new("Part") floor.Name="Floor" floor.Size=Vector3.new(180,1,180) floor.Position=Vector3.new(0,119.5,0) floor.Anchored=true floor.Parent=arena task.wait(2)
 local before=Nav.Stats() local c,m=spawn(Vector3.new(-40,123,-65))
 metrics.Direct=drive(c,m,Vector3.new(-20,123,-65),true,6)
 check(metrics.Direct.Reached,"Direct route physically reaches goal")
 check(Nav.Stats().Started==before.Started,"Clear direct route schedules no path computation") dispose(c,m)
 c,m=spawn(Vector3.new(-40,123,-65)) c:Move(Vector3.new(20,123,-65),true) task.wait(.7)
 local stopAt=m.HumanoidRootPart.Position c:Pause() task.wait(.8) metrics.PausedTravel=planar(m.HumanoidRootPart.Position-stopAt)
 check(metrics.PausedTravel<.8,"Pause physically stops the current MoveTo command")
 c:Move(Vector3.new(20,123,-65),true) task.wait(.7) stopAt=m.HumanoidRootPart.Position c:Destroy() task.wait(.8) metrics.DestroyedTravel=planar(m.HumanoidRootPart.Position-stopAt)
 check(metrics.DestroyedTravel<.8,"Controller destruction physically stops an existing direct pursuit") dispose(c,m)
 -- Two workers, mutable queued goal and stale results after pause/destroy/direct.
 local batch={} before=Nav.Stats()
 for i=1,6 do local n,z=spawn(Vector3.new(-40,123,-35+(i-1)*10)) n:Move(Vector3.new(40,123,-35+(i-1)*10),false) table.insert(batch,{n=n,z=z}) end
 local queued=Nav.Stats()
 check(queued.Running==2 and queued.Queued>=3,"Actual compute workers bounded to two with queued agents")
 local latest=Vector3.new(-60,123,15) batch[6].n:Move(latest,false)
 check(Nav.Stats().Queued==queued.Queued,"Updating queued destination does not duplicate work")
 batch[1].n:Pause() batch[2].n:Destroy() batch[3].n:Move(Vector3.new(40,123,-15),true)
 local deadline=os.clock()+8 while (Nav.Stats().Running>0 or Nav.Stats().Queued>0) and os.clock()<deadline do task.wait(.05) end
 local after=Nav.Stats() metrics.Queue=after
 check(after.Running==0 and after.Queued==0 and after.MaxRunning==2,"Queue drains while respecting worker limit")
 check(batch[1].n.Mode=="Paused" and not batch[1].n.Points,"Paused in-flight result cannot resume movement")
 check(batch[2].n.Destroyed and not batch[2].n.Points,"Destroyed in-flight result cannot install a route")
 check(batch[3].n.Mode=="Direct" and not batch[3].n.Points,"Queued stale route cannot override direct movement")
 check(batch[6].n.PathGoal and (batch[6].n.PathGoal-latest).Magnitude<.1,"Queued replacement uses the latest actual goal")
 check(after.Discarded>=before.Discarded+2,"Cancelled in-flight computations discarded when they return")
 for _,v in batch do dispose(v.n,v.z) end
 c,m=spawn(Vector3.new(-40,123,-35)) local oldGoal=Vector3.new(40,123,-35) local newGoal=Vector3.new(-60,123,-35)
 c:Move(oldGoal,false) check(c.ComputingJob~=nil,"Fresh path computation is live before replacement")
 c:Move(newGoal,false) deadline=os.clock()+6
 while not c.PathGoal and os.clock()<deadline do c:Move(newGoal,false) task.wait(.1) end
 check(c.PathGoal and (c.PathGoal-newGoal).Magnitude<.1,"Moving target invalidates old in-flight destination")
 c:Pause() task.wait(1.4) local recoveries=c.StuckRecoveries c:Move(newGoal,true)
 check(c.Mode=="Direct" and c.StuckRecoveries==recoveries and not c.ForcedRoute,"Intentional pause does not cause a false stuck recovery")
 local accepted=c:Move(Vector3.new(0/0,0,0),false) check(not accepted and c.Mode=="Paused","Non-finite destination rejected without a path") dispose(c,m)
 -- Low barrier is below sight line but blocks a humanoid body: direct mode must recover.
 local barrier=Instance.new("Part") barrier.Name="LowBarrier" barrier.Size=Vector3.new(2,2.8,30) barrier.Position=Vector3.new(0,121.4,50) barrier.Anchored=true barrier.Parent=arena task.wait(.5)
 c,m=spawn(Vector3.new(-20,123,50)) metrics.LowBarrier=drive(c,m,Vector3.new(20,123,50),true,14)
 metrics.LowBarrier.Recoveries=c.StuckRecoveries metrics.LowBarrier.JumpRequests=c.JumpRequests
 check(metrics.LowBarrier.Reached and c.StuckRecoveries>=1,"Blocked direct pursuit recovers and physically reaches beyond low cover")
 check(c.JumpRequests>=1 and metrics.LowBarrier.MaximumY>125,"Real jump waypoint produces an actual vertical crossing") dispose(c,m) barrier:Destroy()
 -- Block an already installed route with a new tall obstacle.
 c,m=spawn(Vector3.new(-30,123,-40)) local goal=Vector3.new(30,123,-40) c:Move(goal,false) deadline=os.clock()+5
 while not c.Points and os.clock()<deadline do c:Move(goal,false) task.wait(.05) end
 check(c.Points~=nil,"Initial physical route installed before obstruction") local revision=c.Revision
 local wall=Instance.new("Part") wall.Name="NewWall" wall.Size=Vector3.new(2,10,24) wall.Position=Vector3.new(0,125,-40) wall.Anchored=true wall.Parent=arena
 metrics.Dynamic=drive(c,m,goal,false,16) metrics.Dynamic.BlockedEvents=c.BlockedEvents metrics.Dynamic.Recoveries=c.StuckRecoveries metrics.Dynamic.Revisions=c.Revision
 check(metrics.Dynamic.Reached and c.Revision>revision and metrics.Dynamic.MaximumDeviationZ>12,"Inserted obstruction replans and is physically bypassed")
 check(c.BlockedEvents>0 or c.StuckRecoveries>0,"Obstruction recovery observed via blocked event or measured stall") dispose(c,m) wall:Destroy()
 c,m=spawn(Vector3.new(-40,123,0)) local unreachable=Vector3.new(500,300,0) before=Nav.Stats() c:Move(unreachable,false) deadline=os.clock()+5
 while c.ComputingJob or c.QueuedJob do assert(os.clock()<deadline,"Unreachable compute still pending") task.wait(.05) end
 check(not c.Points and m:GetAttribute("NavigationState")=="NoPath","Unreachable destination fails safely")
 local started=Nav.Stats().Started for _=1,4 do c:Move(unreachable,false) task.wait(.1) end
 check(Nav.Stats().Started==started,"Failed path retry is throttled") dispose(c,m)
end)
for _,v in controllers do v.Navigation:Destroy() if v.Model.Parent then v.Model:Destroy() end end arena:Destroy()
metrics.FinalStats=Nav.Stats()
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Metrics=metrics,Error=not ok and tostring(err) or nil}) script:Destroy()
