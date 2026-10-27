-- Focused native Path.Blocked observation; no fallback polling movement.
assert(game:GetService("RunService"):IsStudio())
assert(game.Players:GetPlayers()[1]:GetAttribute("PersistenceMode")=="SessionStudio")
local Nav=require(game.ServerScriptService.ZombieNavigation) local def=require(game.ReplicatedStorage.WorldConfig).Zombies.Civilian
local result=Instance.new("StringValue") result.Name="NavigationBlockedQAResult" result.Value="Running" result.Parent=game.ServerStorage
local arena=Instance.new("Folder") arena.Name="NavigationBlockedQA" arena.Parent=workspace local c local report={}
local ok,err=pcall(function()
 local floor=Instance.new("Part") floor.Size=Vector3.new(100,1,80) floor.Position=Vector3.new(0,159.5,0) floor.Anchored=true floor.Parent=arena
 local door=Instance.new("Part") door.Name="Door" door.Size=Vector3.new(2,10,24) door.Position=Vector3.new(0,165,0) door.Anchored=true door.CanCollide=false door.Parent=arena task.wait(2)
 local m=game.ServerStorage.ZombieTemplates.Civilian:Clone() m:PivotTo(CFrame.new(-30,163,0)) m.Parent=arena
 for _,v in m:GetDescendants() do if v:IsA("BasePart") then v.CollisionGroup="LiveZombies" end end pcall(function() m.HumanoidRootPart:SetNetworkOwner(nil) end)
 c=Nav.new(m,def) local goal=Vector3.new(30,163,0) c:Move(goal,false)
 local deadline=os.clock()+5 while not c.Points and os.clock()<deadline do task.wait(.05) end
 assert(c.Points,"Initial native path missing") report.InitialRevision=c.Revision report.InitialWaypoints=#c.Points
 door.CanCollide=true local began=os.clock() deadline=began+8
 -- No Move calls here: physical-stall recovery must not consume the path first.
 while c.BlockedEvents==0 and os.clock()<deadline do task.wait(.05) end
 report.Waited=os.clock()-began report.Events=c.BlockedEvents report.StallRecoveries=c.StuckRecoveries
 report.Status=c.BlockedEvents>0 and "Observed" or "NotObserved"
 if c.BlockedEvents>0 then
  deadline=os.clock()+5 while c.Revision==report.InitialRevision and os.clock()<deadline do task.wait(.05) end
  report.Replanned=c.Revision>report.InitialRevision report.FinalRevision=c.Revision
  assert(report.Replanned and c.StuckRecoveries==0,"Native blocked callback did not replace the path")
 end
end)
if c then c:Destroy() end arena:Destroy()
report.FixtureCompleted=ok report.Error=not ok and tostring(err) or nil result.Value=game.HttpService:JSONEncode(report) script:Destroy()
