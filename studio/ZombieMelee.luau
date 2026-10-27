-- Server-owned, interruptible enemy attacks. No client attack/damage remote.
local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local Zones=require(script.Parent:WaitForChild("ZoneService"))
local Presentation=require(script.Parent:WaitForChild("NPCPresentation"))
local M={} local Controller={} Controller.__index=Controller
function M.HasSight(model,target)
 local head=model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
 local root=target and target:FindFirstChild("HumanoidRootPart") if not head or not root then return false end
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude local exclude={model}
 for _=1,32 do
  params.FilterDescendantsInstances=exclude
  local hit=workspace:Raycast(head.Position,root.Position-head.Position,params)
  if not hit then return true end
  if hit.Instance:IsDescendantOf(target) then
   -- Avatar hair/tools may protrude through a wall; they are not a body hit.
   local cosmetic=hit.Instance:FindFirstAncestorOfClass("Accessory") or hit.Instance:FindFirstAncestorOfClass("Tool")
   if not cosmetic then return true end
   table.insert(exclude,cosmetic)
  elseif hit.Instance.CanCollide then return false
  else table.insert(exclude,hit.Instance) end
 end
 return false
end
local function phase(self,value,outcome)
 if self.Model.Parent then self.Model:SetAttribute("AttackPhase",value) if outcome then self.Model:SetAttribute("AttackOutcome",outcome) end end
 if self.Warning.Parent then self.Warning.Enabled=value=="Windup" end
 if value~="Windup" then
  for _,v in self.Root:GetChildren() do if v:IsA("Sound") and v.Name=="ZombieWindup" then v:Stop() v:Destroy() end end
 end
end
function Controller:IsBusy() return not self.Destroyed and self.Busy end
function Controller:Cancel()
 self.Token+=1
 local wasBusy=self.Busy self.Busy=false
 phase(self,"Idle",wasBusy and "Cancelled" or nil)
end
function Controller:Destroy()
 if self.Destroyed then return end
 self:Cancel() self.Destroyed=true
 for _,connection in self.Connections do connection:Disconnect() end table.clear(self.Connections)
 if self.Warning.Parent then self.Warning:Destroy() end
end
function Controller:CanHit(target,facing,margin)
 if self.Destroyed or not self.Model:IsDescendantOf(workspace) or not self.Root:IsDescendantOf(self.Model) or self.Humanoid.Health<=0 then return false,"Attacker" end
 if (self.Model:GetAttribute("StunnedUntil") or 0)>workspace:GetServerTimeNow() then return false,"Stunned" end
 local player=target and Players:GetPlayerFromCharacter(target)
 local root=target and target:FindFirstChild("HumanoidRootPart") local humanoid=target and target:FindFirstChildOfClass("Humanoid")
 if not player or player.Character~=target or not target:IsDescendantOf(workspace) or not root or not humanoid or humanoid.Health<=0 or player:GetAttribute("HasStarted")~=true then return false,"Target" end
 if (target:GetAttribute("GuardUntil") or 0)>workspace:GetServerTimeNow() then return false,"Guarded" end
 if Config.ZoneAt(root.Position)~=self.Zone or not Zones.CanAccess(player,self.Zone) then return false,"Zone" end
 local offset=root.Position-self.Root.Position
 if offset.Magnitude>Config.AttackRange+(margin or 0) then return false,"Range" end
 if facing then
  local flat=Vector3.new(offset.X,0,offset.Z)
  if flat.Magnitude>.1 and flat.Unit:Dot(facing)<math.cos(math.rad(Config.AttackArc/2)) then return false,"Facing" end
 end
 if not M.HasSight(self.Model,target) then return false,"Wall" end
 return true,humanoid
end
function Controller:TryAttack(target)
 if self.Destroyed then return false,"Attacker" end
 if self.Busy then return false,"Busy" end
 if os.clock()<self.NextAt then return false,"Cooldown" end
 local canHit,reason=self:CanHit(target) if not canHit then return false,reason end
 local windup=math.clamp(self.Def.AttackWindup or Config.AttackWindup,.18,1.5)
 local recovery=math.clamp(self.Def.AttackRecovery or Config.AttackRecovery,.15,.8)
 local delta=target.HumanoidRootPart.Position-self.Root.Position local flat=Vector3.new(delta.X,0,delta.Z)
 local facing=flat.Magnitude>.1 and flat.Unit or self.Root.CFrame.LookVector*Vector3.new(1,0,1)
 if facing.Magnitude<.1 then facing=Vector3.new(0,0,-1) else facing=facing.Unit end
 self.Token+=1 local token=self.Token self.Busy=true self.NextAt=os.clock()+math.max(Config.AttackCooldown,windup+recovery)
 self.Root.CFrame=CFrame.lookAt(self.Root.Position,self.Root.Position+facing)
 self.Humanoid.WalkSpeed=0 self.Humanoid:MoveTo(self.Root.Position)
 self.Model:SetAttribute("AttackWindup",windup) self.Model:SetAttribute("AttackRecovery",recovery) self.Model:SetAttribute("AttackFacing",facing)
 phase(self,"Windup","Pending") Presentation.Attack(self.Model)
 task.delay(windup,function()
  if self.Destroyed or self.Token~=token then return end
  local accepted,humanoid=self:CanHit(target,facing,.3)
  local outcome="Miss"
  if accepted then local before=humanoid.Health humanoid:TakeDamage(self.Def.Damage) outcome=humanoid.Health<before and "Hit" or "Blocked" end
  phase(self,"Recovery",outcome) Presentation.Swipe(self.Model)
  task.delay(recovery,function()
   if not self.Destroyed and self.Token==token then self.Busy=false phase(self,"Idle") end
  end)
 end)
 return true
end
function M.new(model,def,zone)
 local self=setmetatable({Model=model,Humanoid=assert(model:FindFirstChildOfClass("Humanoid")),Root=assert(model:FindFirstChild("HumanoidRootPart")),Def=def,Zone=zone,Token=0,NextAt=-math.huge,Busy=false,Destroyed=false,Connections={}},Controller)
 local warning=Instance.new("Highlight") warning.Name="AttackWarning" warning.Adornee=model warning.DepthMode=Enum.HighlightDepthMode.Occluded warning.FillColor=Color3.fromRGB(255,179,62) warning.OutlineColor=Color3.fromRGB(255,224,120) warning.FillTransparency=.88 warning.OutlineTransparency=.1 warning.Enabled=false warning.Parent=model self.Warning=warning
 phase(self,"Idle")
 table.insert(self.Connections,model:GetAttributeChangedSignal("StunnedUntil"):Connect(function() if (model:GetAttribute("StunnedUntil") or 0)>workspace:GetServerTimeNow() then self:Cancel() end end))
 table.insert(self.Connections,self.Humanoid.Died:Connect(function() self:Destroy() end))
 table.insert(self.Connections,model.Destroying:Connect(function() self:Destroy() end))
 return self
end
return M
