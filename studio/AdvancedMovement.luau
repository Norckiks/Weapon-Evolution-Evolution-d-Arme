local Config=require(game.ReplicatedStorage:WaitForChild("MovementConfig"))
local M={}
local function params(c)
 local p=RaycastParams.new() p.FilterType=Enum.RaycastFilterType.Exclude p.FilterDescendantsInstances={c} p.RespectCanCollide=true return p
end
function M.Cancel(s)
 if s.moveVelocity then s.moveVelocity:Destroy() s.moveVelocity=nil end
 if s.moveAttachment then s.moveAttachment:Destroy() s.moveAttachment=nil end
 s.slideUntil=nil s.vaultUntil=nil
end
function M.Busy(s)
 local now=workspace:GetServerTimeNow()
 return (s.slideUntil or 0)>now or (s.vaultUntil or 0)>now
end
local function planar(s,root,direction,speed)
 local a=Instance.new("Attachment") a.Name="MovementAttachment" a.Parent=root
 local v=Instance.new("LinearVelocity") v.Name="MovementVelocity" v.Attachment0=a v.RelativeTo=Enum.ActuatorRelativeTo.World
 v.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane v.PrimaryTangentAxis=Vector3.xAxis v.SecondaryTangentAxis=Vector3.zAxis
 v.PlaneVelocity=Vector2.new(direction.X,direction.Z)*speed v.ForceLimitsEnabled=false v.Parent=root
 s.moveAttachment=a s.moveVelocity=v s.moveDirection=direction
end
function M.Handle(player,s,verb)
 if typeof(verb)~="string" or (verb~="Crouch" and verb~="Vault") then return false end
 if not s or not s.humanoid or s.humanoid.Health<=0 or player:GetAttribute("HasStarted")~=true or player:GetAttribute("InGameMenu") then return false end
 local h,c=s.humanoid,s.character local root=c:FindFirstChild("HumanoidRootPart")
 if not root or root.Anchored or h.Sit or h.PlatformStand then return false end
 local now=workspace:GetServerTimeNow()
 if now-(s.lastMovementRequest or 0)<.15 or (c:GetAttribute("DashUntil") or 0)>now or M.Busy(s) then return false end
 s.lastMovementRequest=now
 local vel=root.AssemblyLinearVelocity local flat=Vector3.new(vel.X,0,vel.Z)
 local direction=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
 if direction.Magnitude<.01 then return false end direction=direction.Unit
 if verb=="Crouch" then
  if not s.crouching and s.wants and flat.Magnitude>=Config.SlideMinSpeed and h.FloorMaterial~=Enum.Material.Air and now>=(s.slideReadyAt or 0) and s.stamina>=Config.SlideCost then
   direction=flat.Unit
   if workspace:Blockcast(root.CFrame,Vector3.new(2,2,2),direction*3,params(c)) then return false end
   s.stamina-=Config.SlideCost s.rest=0 s.slideStarted=now s.slideUntil=now+Config.SlideDuration s.slideReadyAt=now+Config.SlideCooldown
   planar(s,root,direction,Config.SlideSpeed) c:SetAttribute("SlideReadyAt",s.slideReadyAt)
  else s.crouching=not s.crouching end
  return true
 end
 if s.crouching or h.FloorMaterial==Enum.Material.Air or now<(s.vaultReadyAt or 0) or s.stamina<Config.VaultCost then return false end
 local p=params(c)
 local ground=workspace:Raycast(root.Position,Vector3.new(0,-8,0),p)
 if not ground then return false end
 local lowOrigin=Vector3.new(root.Position.X,ground.Position.Y+.9,root.Position.Z)
 local low=workspace:Raycast(lowOrigin,direction*Config.VaultRange,p)
 if not low or not low.Instance.Anchored then return false end
 local top=workspace:Raycast(low.Position+direction*.5+Vector3.new(0,5,0),Vector3.new(0,-7,0),p)
 if not top or not ground or top.Normal.Y<.7 then return false end
 local height=top.Position.Y-ground.Position.Y
 if height<.6 or height>Config.VaultMaxHeight then return false end
 local lift=Vector3.new(0,4,0)
 local travel=Config.VaultForwardSpeed*Config.VaultDuration+.5
 if workspace:Blockcast(root.CFrame,Vector3.new(2,2,2),lift,p) or workspace:Blockcast(root.CFrame+lift,Vector3.new(2,2,2),direction*travel,p) then return false end
 local landing=workspace:Raycast(root.Position+direction*travel+lift,Vector3.new(0,-10,0),p)
 if not landing or landing.Normal.Y<.65 or landing.Position.Y<ground.Position.Y-3 then return false end
 s.stamina-=Config.VaultCost s.rest=0 s.vaultUntil=now+Config.VaultDuration s.vaultReadyAt=now+Config.VaultCooldown
 planar(s,root,direction,Config.VaultForwardSpeed)
 root.AssemblyLinearVelocity=direction*Config.VaultForwardSpeed+Vector3.new(0,Config.VaultUpSpeed,0)
 h:ChangeState(Enum.HumanoidStateType.Jumping) c:SetAttribute("VaultReadyAt",s.vaultReadyAt)
 -- The owning client must leave its grounded controller before applying the accepted launch.
 local event=game.ReplicatedStorage.Remotes:FindFirstChild("MovementAction")
 if event then event:FireClient(player,"VaultAccepted",c,s.vaultUntil,direction) end
 return true
end
function M.Update(player,s,dt,alive)
 local c,h=s.character,s.humanoid local root=c:FindFirstChild("HumanoidRootPart") local now=workspace:GetServerTimeNow()
 if not alive or not root then M.Cancel(s) s.crouching=false end
 if s.slideUntil then
  if now>=s.slideUntil or (root and workspace:Blockcast(root.CFrame,Vector3.new(2,2,2),s.moveDirection*math.max(2,Config.SlideSpeed*dt),params(c))) then M.Cancel(s)
  elseif s.moveVelocity then
   local a=math.clamp((now-s.slideStarted)/Config.SlideDuration,0,1)
   s.moveVelocity.PlaneVelocity=Vector2.new(s.moveDirection.X,s.moveDirection.Z)*(Config.SlideSpeed+(Config.SlideEndSpeed-Config.SlideSpeed)*a)
  end
 end
 if s.vaultUntil and now>=s.vaultUntil then M.Cancel(s) end
 c:SetAttribute("Crouching",s.crouching==true) c:SetAttribute("Sliding",s.slideUntil~=nil) c:SetAttribute("Vaulting",s.vaultUntil~=nil)
 h.HipHeight=math.max(0,(s.baseHipHeight or h.HipHeight)-((s.crouching or s.slideUntil) and .65 or 0))
 if M.Busy(s) then s.rest=0 end
 return s.crouching==true or M.Busy(s)
end
return M
