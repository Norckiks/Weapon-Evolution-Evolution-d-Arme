local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("SprintConfig"))
local State=require(script.Parent:WaitForChild("SprintState"))
local remote=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Sprint")
local Gameplay=require(ReplicatedStorage:WaitForChild("GameplayConfig"))
local dashRemote=ReplicatedStorage.Remotes:WaitForChild("Dash")
local states={}
local Movement=require(script.Parent:WaitForChild("AdvancedMovement"))
local MoveConfig=require(ReplicatedStorage:WaitForChild("MovementConfig"))
local function abilityRemote(name)
 local r=ReplicatedStorage.Remotes:FindFirstChild(name) or Instance.new("RemoteEvent") r.Name=name r.Parent=ReplicatedStorage.Remotes return r
end
local useAbility=abilityRemote("UseAbility") abilityRemote("PulseFX") abilityRemote("AbilityFX")
local Pulse=require(script.Parent:WaitForChild("PulseAbility"))
useAbility.OnServerEvent:Connect(function(player,id,aimDirection) Pulse.Handle(player,states[player],id,aimDirection) end)
local movementRemote=ReplicatedStorage.Remotes:FindFirstChild("MovementAction") or Instance.new("RemoteEvent")
movementRemote.Name="MovementAction" movementRemote.Parent=ReplicatedStorage.Remotes
movementRemote.OnServerEvent:Connect(function(player,verb) local s=states[player] Movement.Handle(player,s,verb) end)
local function publish(character,s)
 character:SetAttribute("Stamina",math.floor(s.stamina*10+0.5)/10)
 character:SetAttribute("MaxStamina",s.maxStamina)
 character:SetAttribute("Sprinting",s.sprinting)
 character:SetAttribute("SprintExhausted",s.exhausted)
end
local function bind(player,character)
 if states[player] then Movement.Cancel(states[player]) end
 local s=State.new(Config)
 s.character=character s.lastRequest=-math.huge
 states[player]=s publish(character,s)
 Pulse.Bind(player,character)
 local humanoid=character:WaitForChild("Humanoid",10)
 if not humanoid or states[player]~=s then return end
 s.humanoid=humanoid s.baseSpeed=humanoid.WalkSpeed s.baseHipHeight=humanoid.HipHeight
end
local function setup(player)
 player.CharacterAdded:Connect(function(character) bind(player,character) end)
 if player.Character then task.spawn(bind,player,player.Character) end
end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) if states[player] then Movement.Cancel(states[player]) end states[player]=nil end)
for _,player in Players:GetPlayers() do setup(player) end
remote.OnServerEvent:Connect(function(player,wants)
 if typeof(wants)~="boolean" then return end
 local s=states[player]
 if not s or not s.humanoid or s.humanoid.Health<=0 then return end
 local now=os.clock()
 if wants and now-s.lastRequest<0.05 then return end
 s.lastRequest=now s.wants=wants
end)
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
 elapsed+=dt
 if elapsed<Config.ReplicationInterval then return end
 local step=elapsed elapsed=0
 for player,s in states do
  local h=s.humanoid
  local character=s.character
  if not h or character~=player.Character or not character.Parent then continue end
  local root=character:FindFirstChild("HumanoidRootPart")
  local inMenu=player:GetAttribute("HasStarted")~=true or player:GetAttribute("InGameMenu")==true
  local alive=h.Health>0 and not h.Sit and not h.PlatformStand and not inMenu
  local velocity=root and root.AssemblyLinearVelocity or Vector3.zero
  local moving=Vector3.new(velocity.X,0,velocity.Z).Magnitude>1.5
  local humanoidState=h:GetState()
  local canRun=humanoidState~=Enum.HumanoidStateType.Swimming and humanoidState~=Enum.HumanoidStateType.Climbing
  local maximum=player:GetAttribute("StaminaCapacity") or Config.MaxStamina
  if maximum~=s.maxStamina then
   -- Buying capacity adds only the new points, without refilling the old reserve.
   s.stamina=math.clamp(s.stamina+math.max(0,maximum-s.maxStamina),0,maximum)
   s.maxStamina=maximum
  end
  local special=Movement.Update(player,s,step,alive)
  State.step(s,Config,step,moving and canRun and not special,alive)
  local allowed=alive and canRun and not special and s.wants and not s.exhausted and s.stamina>0
  local walk=player:GetAttribute("BaseWalkSpeed") or s.baseSpeed
  local run=player:GetAttribute("SprintWalkSpeed") or Config.SprintSpeed
  local target=s.crouching and MoveConfig.CrouchSpeed or (allowed and math.max(walk,run) or walk)
  s.speed=s.speed or walk
  s.speed+=(target-s.speed)*(1-math.exp(-step*(target>s.speed and MoveConfig.Acceleration or MoveConfig.Braking)))
  h.WalkSpeed=not alive and 0 or s.speed
  h.JumpHeight=(inMenu or special) and 0 or 7.2
  h.JumpPower=(inMenu or special) and 0 or 50
  character:SetAttribute("MovementState",not alive and "Repos" or s.slideUntil and "Glissade" or s.vaultUntil and "Franchissement" or s.crouching and "Accroupi" or allowed and "Sprint" or moving and "Marche" or "Repos")
  publish(character,s)
 end
end)

dashRemote.OnServerEvent:Connect(function(player,direction)
 local s=states[player] local d=Gameplay.Dash
 if not s or not s.humanoid or s.humanoid.Health<=0 or player:GetAttribute("HasStarted")~=true or player:GetAttribute("InGameMenu") then return end
 if typeof(direction)~="Vector3" or direction~=direction or direction.Magnitude<0.1 or direction.Magnitude>1.5 then return end
 local root=s.character:FindFirstChild("HumanoidRootPart") if not root or root.Anchored or s.humanoid.Sit then return end
 local now=workspace:GetServerTimeNow()
 if Movement.Busy(s) or s.crouching then return end
 if now<(s.dashReadyAt or 0) or s.stamina<d.Cost then return end
 local flat=Vector3.new(direction.X,0,direction.Z) if flat.Magnitude<0.1 then return end flat=flat.Unit
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={s.character}
 local distance=d.Speed*d.Duration
 local hit=workspace:Blockcast(root.CFrame,Vector3.new(2,3,2),flat*distance,params)
 if hit then distance=math.max(0,hit.Distance-0.8) end if distance<1 then return end
 s.dashReadyAt=now+d.Cooldown s.stamina-=d.Cost s.rest=0
 if s.stamina<=0 then s.exhausted=true end
 s.character:SetAttribute("DashReadyAt",s.dashReadyAt) s.character:SetAttribute("DashUntil",now+d.Duration)
 publish(s.character,s)
 local a=Instance.new("Attachment") a.Name="DashAttachment" a.Parent=root
 local v=Instance.new("LinearVelocity") v.Name="DashVelocity" v.Attachment0=a v.RelativeTo=Enum.ActuatorRelativeTo.World
 v.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane v.PrimaryTangentAxis=Vector3.xAxis v.SecondaryTangentAxis=Vector3.zAxis
 v.PlaneVelocity=Vector2.new(flat.X,flat.Z)*(distance/d.Duration) v.ForceLimitsEnabled=false v.Parent=root
 game:GetService("Debris"):AddItem(v,d.Duration) game:GetService("Debris"):AddItem(a,d.Duration+0.05)
end)
