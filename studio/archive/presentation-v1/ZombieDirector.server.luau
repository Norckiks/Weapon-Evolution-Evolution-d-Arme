local Players=game:GetService("Players")
local CollectionService=game:GetService("CollectionService")
local PathfindingService=game:GetService("PathfindingService")
local PhysicsService=game:GetService("PhysicsService")
local Debris=game:GetService("Debris")
local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local Progression=require(script.Parent:WaitForChild("ProgressionService"))
local Zones=require(script.Parent:WaitForChild("ZoneService"))
Progression.Init()
Zones.Init()
pcall(function() PhysicsService:RegisterCollisionGroup("LiveZombies") end)
pcall(function() PhysicsService:RegisterCollisionGroup("Survivors") end)
PhysicsService:CollisionGroupSetCollidable("LiveZombies","LiveZombies",false)
PhysicsService:CollisionGroupSetCollidable("LiveZombies","Survivors",false)
local function playerPhysics(character)
 local function apply(p) if p:IsA("BasePart") then p.CollisionGroup="Survivors" end end
 for _,p in character:GetDescendants() do apply(p) end character.DescendantAdded:Connect(apply)
end
local function playerAdded(p) p.CharacterAdded:Connect(playerPhysics) if p.Character then playerPhysics(p.Character) end end
Players.PlayerAdded:Connect(playerAdded) for _,p in Players:GetPlayers() do playerAdded(p) end
local folder=Instance.new("Folder") folder.Name="LiveZombies" folder.Parent=workspace
local templates=game.ServerStorage:WaitForChild("ZombieTemplates")
local active={}
local function healthbar(m,h,def)
 local b=Instance.new("BillboardGui") b.Name="ZombieHealth" b.Size=UDim2.fromOffset(180,54) b.StudsOffsetWorldSpace=Vector3.new(0,2.1*def.Scale,0) b.MaxDistance=65 b.AlwaysOnTop=false b.Parent=m.Head
 local function label(name,text,y,height,color)
  local t=Instance.new("TextLabel") t.Name=name t.Size=UDim2.new(1,0,0,height) t.Position=UDim2.fromOffset(0,y) t.BackgroundTransparency=1 t.Text=text t.Font=Enum.Font.GothamBold t.TextSize=12 t.TextColor3=color t.TextStrokeTransparency=0.4 t.Parent=b return t
 end
 label("Name",def.Name,0,18,Color3.fromRGB(243,225,190))
 label("Loot","+"..def.Coins.." pieces  |  +"..def.XP.." XP",35,16,Color3.fromRGB(238,200,101))
 local track=Instance.new("Frame") track.Name="Track" track.Size=UDim2.new(1,-20,0,8) track.Position=UDim2.fromOffset(10,23) track.BorderSizePixel=0 track.BackgroundColor3=Color3.fromRGB(44,35,32) track.Parent=b
 local fill=Instance.new("Frame") fill.Name="Fill" fill.Size=UDim2.fromScale(1,1) fill.BorderSizePixel=0 fill.BackgroundColor3=Color3.fromRGB(197,82,61) fill.Parent=track
 local connection=h.HealthChanged:Connect(function() fill.Size=UDim2.fromScale(math.clamp(h.Health/h.MaxHealth,0,1),1) end)
 return connection
end
local function clearSight(m,target)
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={m}
 local from=m.Head.Position local result=workspace:Raycast(from,target.HumanoidRootPart.Position-from,params)
 return not result or result.Instance:IsDescendantOf(target)
end
local function spawnZombie(zone,slot,index)
 local id=zone.Types[(index-1)%#zone.Types+1]
 local def=Config.Zombies[id]
 local m=templates[id]:Clone() m.Name=def.Name m:SetAttribute("ZoneId",zone.Id)
 local h=m.Humanoid local r=m.HumanoidRootPart
 local rayParams=RaycastParams.new() rayParams.FilterType=Enum.RaycastFilterType.Exclude rayParams.FilterDescendantsInstances={folder}
 local hit=workspace:Raycast(slot.position+Vector3.new(0,45,0),Vector3.new(0,-70,0),rayParams)
 local y=hit and hit.Position.Y or 0
 local home=Vector3.new(slot.position.X,y+3*def.Scale,slot.position.Z)
 m:PivotTo(CFrame.new(home))
 for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.CollisionGroup="LiveZombies" end end
 m.Parent=folder
 for _,p in m:GetDescendants() do if p:IsA("BasePart") and not p.Anchored then pcall(function() p:SetNetworkOwner(nil) end) end end
 CollectionService:AddTag(m,"Zombie")
 local s={model=m,humanoid=h,root=r,zone=zone,def=def,home=home,attackAt=0,pathAt=-math.huge,pathBusy=false,phase=math.random()*6,joints={},slot=slot}
 for _,name in {"Left Shoulder","Right Shoulder","Left Hip","Right Hip","Neck"} do local j=m.Torso:FindFirstChild(name) if j then s.joints[name]={joint=j,base=j.C0} end end
 active[m]=s slot.model=m
 local barConnection=healthbar(m,h,def)
 local paid=false
 h.Died:Connect(function()
  if paid then return end paid=true
  m:SetAttribute("Rewarded",true) CollectionService:RemoveTag(m,"Zombie")
  local userId=h:GetAttribute("LastAttacker")
  local time=h:GetAttribute("LastHitAt")
  local attacker=typeof(userId)=="number" and Players:GetPlayerByUserId(userId)
  if attacker and typeof(time)=="number" and os.clock()-time<=Config.KillCreditSeconds and Zones.CanAccess(attacker,zone) then
   Progression.AddRewards(attacker,def.Coins,def.XP,def.Name)
  end
  barConnection:Disconnect()
  active[m]=nil slot.model=nil slot.nextSpawn=os.clock()+Config.RespawnDelay
  for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false end end
  r.Anchored=true m:PivotTo(m:GetPivot()*CFrame.Angles(math.rad(78),0,0))
  Debris:AddItem(m,2.5)
 end)
end
local slots={}
for _,zone in Config.Zones do
 for i,pos in zone.Spawns do table.insert(slots,{zone=zone,index=i,position=pos,nextSpawn=os.clock()+i*0.18}) end
end
local function nearest(s)
 local best,distance=nil,Config.AggroRange
 for _,p in Players:GetPlayers() do
  local c=p.Character local r=c and c:FindFirstChild("HumanoidRootPart") local h=c and c:FindFirstChildOfClass("Humanoid")
  if r and h and h.Health>0 and Zones.CanAccess(p,s.zone) and Config.ZoneAt(r.Position)==s.zone and (r.Position-s.home).Magnitude<=Config.LeashRange then
   local d=(r.Position-s.root.Position).Magnitude if d<distance then best=c distance=d end
  end
 end
 return best,distance
end
local function requestPath(s,destination)
 if s.pathBusy or os.clock()-s.pathAt<1.7 then return end
 s.pathAt=os.clock() s.pathBusy=true
 task.spawn(function()
  local path=PathfindingService:CreatePath({AgentRadius=1.6*s.def.Scale,AgentHeight=5.2*s.def.Scale,AgentCanJump=true,WaypointSpacing=5})
  local ok=pcall(function() path:ComputeAsync(s.root.Position,destination) end)
  if active[s.model]==s then
   if ok and path.Status==Enum.PathStatus.Success then s.waypoints=path:GetWaypoints() s.waypoint=2 else s.waypoints=nil end
   s.pathBusy=false
  end
 end)
end
local function move(s,destination,direct)
 if direct then s.waypoints=nil s.humanoid:MoveTo(destination) return end
 requestPath(s,destination)
 local points=s.waypoints local i=s.waypoint
 if points and points[i] then
  if (points[i].Position-s.root.Position).Magnitude<3 then i+=1 s.waypoint=i end
  local point=points[i]
  if point then if point.Action==Enum.PathWaypointAction.Jump then s.humanoid.Jump=true end s.humanoid:MoveTo(point.Position) return end
 end
 s.humanoid:MoveTo(destination)
end
local function pose(s,dt)
 local speed=Vector3.new(s.root.AssemblyLinearVelocity.X,0,s.root.AssemblyLinearVelocity.Z).Magnitude
 s.phase+=dt*math.min(speed*0.75,11)
 local swing=speed>1 and math.sin(s.phase)*0.65 or 0
 local attack=os.clock()-s.attackAt<0.3
 for name,item in s.joints do
  local angle=0
  if name=="Left Hip" then angle=swing elseif name=="Right Hip" then angle=-swing
  elseif name=="Left Shoulder" then angle=-0.75-swing*0.45-(attack and 0.7 or 0)
  elseif name=="Right Shoulder" then angle=-0.75+swing*0.45-(attack and 0.7 or 0)
  elseif name=="Neck" then angle=0.12 end
  item.joint.C0=item.base*CFrame.Angles(angle,0,0)
 end
end
local think=0
while true do
 local dt=task.wait(0.12) think+=dt
 for m,s in active do
  if not m.Parent then active[m]=nil s.slot.model=nil s.slot.nextSpawn=os.clock()+Config.RespawnDelay continue end
  pose(s,dt)
 end
 if think<0.3 then continue end
 think=0
 for _,slot in slots do if not slot.model and os.clock()>=slot.nextSpawn then spawnZombie(slot.zone,slot,slot.index) end end
 for m,s in active do
  if s.humanoid.Health<=0 then continue end
  local target,distance=nearest(s)
  if target then
   local sight=clearSight(m,target)
   if distance<=Config.AttackRange and sight then
    s.humanoid:MoveTo(s.root.Position)
    if os.clock()-s.attackAt>=Config.AttackCooldown then
     s.attackAt=os.clock()
     local h=target:FindFirstChildOfClass("Humanoid")
     if h and h.Health>0 then h:TakeDamage(s.def.Damage) end
    end
   else move(s,target.HumanoidRootPart.Position,sight) end
  else
   if (s.root.Position-s.home).Magnitude>4 then move(s,s.home,false) else s.humanoid:MoveTo(s.root.Position) end
  end
 end
end
