-- Bounded server navigation. ComputeAsync cannot be cancelled: revisions discard stale results.
local PathfindingService=game:GetService("PathfindingService")
local N={} local Controller={} Controller.__index=Controller
local MAX_RUNNING,MAX_QUEUED=2,64
local queue={} local running=0
local totals={Started=0,Completed=0,Discarded=0,Failed=0,MaxRunning=0,MaxQueued=0}
local pump
local function alive(self)
 return not self.Destroyed and self.Model:IsDescendantOf(workspace) and self.Root:IsDescendantOf(self.Model) and self.Humanoid.Health>0
end
local function state(self,value)
 if self.Model.Parent and self.Model:GetAttribute("NavigationState")~=value then self.Model:SetAttribute("NavigationState",value) end
end
local function planar(v) return Vector3.new(v.X,0,v.Z).Magnitude end
local function removeQueued(self)
 local job=self.QueuedJob if not job then return end
 for i,v in queue do if v==job then table.remove(queue,i) break end end
 self.QueuedJob=nil
end
local function clearPath(self)
 if self.BlockedConnection then self.BlockedConnection:Disconnect() self.BlockedConnection=nil end
 if self.Path then self.Path:Destroy() self.Path=nil end
 self.Points=nil self.Index=2 self.PathGoal=nil self.JumpedIndex=nil
end
function Controller:_invalidate()
 self.Token+=1 self.Dirty=false removeQueued(self) clearPath(self)
end
function Controller:Pause()
 if self.Destroyed then return end
 if self.Mode~="Paused" then self.Mode="Paused" self:_invalidate() self.ForcedRoute=false end
 self.ProgressAt=os.clock() self.ProgressPosition=self.Root.Position
 if self.Root.Parent then self.Humanoid:MoveTo(self.Root.Position) end state(self,"Paused")
end
function Controller:Destroy()
 if self.Destroyed then return end
 self:_invalidate()
 if self.Root.Parent and self.Humanoid.Parent and self.Humanoid.Health>0 then self.Humanoid:MoveTo(self.Root.Position) end
 self.Destroyed=true self.Mode="Dead"
 for _,v in self.Connections do v:Disconnect() end table.clear(self.Connections) state(self,"Dead")
end
function Controller:_request(force)
 if not alive(self) or self.Mode~="Path" or not self.Goal then return false end
 if self.ComputingJob then self.Dirty=true return false end
 if self.QueuedJob then self.QueuedJob.Goal=self.Goal return true end
 local now=os.clock()
 if now<(self.RetryAt or 0) or now-self.LastCompute<(force and .35 or 1.2) or #queue>=MAX_QUEUED then return false end
 self.Token+=1 local job={Navigation=self,Token=self.Token,Goal=self.Goal}
 self.QueuedJob=job table.insert(queue,job) totals.MaxQueued=math.max(totals.MaxQueued,#queue)
 state(self,"Queued") pump() return true
end
pump=function()
 while running<MAX_RUNNING and #queue>0 do
  local job=table.remove(queue,1) local self=job.Navigation
  if self.QueuedJob~=job then continue end self.QueuedJob=nil
  if not alive(self) or self.Mode~="Path" or self.Token~=job.Token then continue end
  self.ComputingJob=job self.LastCompute=os.clock() running+=1 totals.Started+=1 totals.MaxRunning=math.max(totals.MaxRunning,running) state(self,"Computing")
  task.spawn(function()
   local path local points
   local ok=pcall(function()
    path=PathfindingService:CreatePath({AgentRadius=1.6*self.Scale,AgentHeight=5.2*self.Scale,AgentCanJump=true,WaypointSpacing=5})
    path:ComputeAsync(self.Root.Position,job.Goal)
    if path.Status==Enum.PathStatus.Success then points=path:GetWaypoints() end
   end)
   local finalized,finalError=pcall(function()
   local current=alive(self) and self.Mode=="Path" and self.Token==job.Token
   if self.ComputingJob==job then self.ComputingJob=nil end
   if current and ok and points and #points>=2 then
    clearPath(self) self.Path=path self.Points=points self.Index=2 self.PathGoal=job.Goal self.RetryAt=0 self.Dirty=false
    self.Revision+=1 self.Model:SetAttribute("NavigationRevision",self.Revision) state(self,"Following") totals.Completed+=1
    self.BlockedConnection=path.Blocked:Connect(function(index)
     if not alive(self) or self.Path~=path or index<self.Index or self.Mode~="Path" then return end
     self.BlockedEvents+=1 self.ForcedRoute=true self:_invalidate() self:_request(true)
    end)
   else
    if path then path:Destroy() end
    if not current then totals.Discarded+=1
    else totals.Failed+=1 self.RetryAt=os.clock()+1.4 state(self,"NoPath") end
   end
   end)
   if not finalized then
    totals.Failed+=1 self.LastError=tostring(finalError) self.RetryAt=os.clock()+1.4
    if self.ComputingJob==job then self.ComputingJob=nil end
    if path then pcall(function() path:Destroy() end) end
   end
   running-=1
   if alive(self) and self.Mode=="Path" and self.Dirty then self.Dirty=false self:_request(true) end
   pump()
  end)
 end
end
function Controller:_progress()
 local now=os.clock() local position=self.Root.Position
 -- Waiting for a scheduled engine computation is not a physical blockage.
 if self.Mode=="Path" and not self.Points then self.ProgressAt=now self.ProgressPosition=position return end
 if planar(self.Goal-position)<2.5 or planar(position-self.ProgressPosition)>=.6 then
  self.ProgressAt=now self.ProgressPosition=position return
 end
 if now-self.ProgressAt>=1.2 then
  self.StuckRecoveries+=1 self.ForcedRoute=true self.ProgressAt=now self.ProgressPosition=position self:_invalidate()
 end
end
function Controller:_follow()
 local points=self.Points if not points then self.Humanoid:MoveTo(self.Root.Position) return end
 local threshold=math.max(1.5,1.6*self.Scale)
 while points[self.Index] do
  local point=points[self.Index]
  if point.Action==Enum.PathWaypointAction.Jump and self.JumpedIndex~=self.Index then
   self.JumpedIndex=self.Index self.JumpRequests+=1 self.Humanoid.Jump=true
   if self.Humanoid.FloorMaterial~=Enum.Material.Air then self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
  end
  local offset=point.Position-self.Root.Position
  -- Path waypoints are on the floor; a tall rig's root never reaches them in 3D.
  if planar(offset)>threshold or math.abs(offset.Y)>3*self.Scale+3 then self.Humanoid:MoveTo(point.Position) return end
  self.Index+=1
 end
 self.ForcedRoute=false clearPath(self) self.Humanoid:MoveTo(self.Goal) state(self,"Arrived")
end
function Controller:Move(goal,direct)
 if not alive(self) then return false end
 if typeof(goal)~="Vector3" or goal~=goal or goal.Magnitude>1e7 then self:Pause() return false end
 if self.Mode=="Paused" or self.Mode=="Idle" then self.ProgressAt=os.clock() self.ProgressPosition=self.Root.Position end
 self.Goal=goal self:_progress()
 local wantsPath=not direct or self.ForcedRoute
 if not wantsPath then
  if self.Mode~="Direct" then self:_invalidate() self.Mode="Direct" end
  self.Humanoid:MoveTo(goal) state(self,"Direct") return true
 end
 self.Mode="Path"
 if self.PathGoal and (goal-self.PathGoal).Magnitude>=6 then self:_invalidate() end
 local job=self.ComputingJob
 if job and (goal-job.Goal).Magnitude>=6 then if job.Token==self.Token then self.Token+=1 end self.Dirty=true end
 if self.QueuedJob then self.QueuedJob.Goal=goal end
 if not self.Points and not self.QueuedJob and not self.ComputingJob then self:_request(self.ForcedRoute) end
 self:_follow() return true
end
function N.new(model,def)
 local root=assert(model:FindFirstChild("HumanoidRootPart")) local humanoid=assert(model:FindFirstChildOfClass("Humanoid"))
 local self=setmetatable({Model=model,Root=root,Humanoid=humanoid,Scale=def.Scale or 1,Mode="Idle",Token=0,Revision=0,LastCompute=-math.huge,ProgressAt=os.clock(),ProgressPosition=root.Position,ForcedRoute=false,Dirty=false,Destroyed=false,StuckRecoveries=0,BlockedEvents=0,JumpRequests=0,Connections={}},Controller)
 state(self,"Idle")
 table.insert(self.Connections,humanoid.Died:Connect(function() self:Destroy() end))
 table.insert(self.Connections,model.Destroying:Connect(function() self:Destroy() end))
 return self
end
function N.Stats()
 local out=table.clone(totals) out.Running=running out.Queued=#queue out.Limit=MAX_RUNNING out.QueueLimit=MAX_QUEUED return out
end
return N
