local Players=game:GetService("Players")
local CollectionService=game:GetService("CollectionService")
local PhysicsService=game:GetService("PhysicsService")
local Debris=game:GetService("Debris")
local Config=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local Progression=require(script.Parent:WaitForChild("ProgressionService"))
local Economy=require(script.Parent:WaitForChild("EconomyService"))
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
local NPCPresentation=require(script.Parent:WaitForChild("NPCPresentation"))
local ZombieMelee=require(script.Parent:WaitForChild("ZombieMelee"))
local Navigation=require(script.Parent:WaitForChild("ZombieNavigation"))
local active={} local eliteProgress={} local elitePending={}
local function publishHunt(zone)
 local node=workspace.ProgressionZones:FindFirstChild(zone.Id)
 if node then node:SetAttribute("EliteProgress",eliteProgress[zone.Id] or 0) node:SetAttribute("ElitePending",elitePending[zone.Id]==true) end
end
local function healthbar(m,h,def)
 local b=Instance.new("BillboardGui") b.Name="ZombieHealth" b.Size=UDim2.fromOffset(144,34) b.StudsOffsetWorldSpace=Vector3.new(0,0.95*def.Scale,0) b.MaxDistance=38 b.AlwaysOnTop=false b.Parent=m.Head
 local function label(name,text,y,height,color)
  local t=Instance.new("TextLabel") t.Name=name t.Size=UDim2.new(1,0,0,height) t.Position=UDim2.fromOffset(0,y) t.BackgroundTransparency=1 t.Text=text t.Font=Enum.Font.GothamBold t.TextSize=10 t.TextColor3=color t.TextStrokeTransparency=0.7 t.Parent=b return t
 end
 label("Name",def.Name,0,18,m:GetAttribute("Elite") and Color3.fromRGB(255,209,81) or Color3.fromRGB(243,225,190))
 local loot=label("Loot","+"..def.Coins.." pieces  |  +"..def.XP.." XP",35,16,Color3.fromRGB(238,200,101)) loot.Visible=false
 local track=Instance.new("Frame") track.Name="Track" track.Size=UDim2.new(1,-20,0,4) track.Position=UDim2.fromOffset(10,23) track.BorderSizePixel=0 track.BackgroundColor3=Color3.fromRGB(44,35,32) track.Parent=b
 local fill=Instance.new("Frame") fill.Name="Fill" fill.Size=UDim2.fromScale(1,1) fill.BorderSizePixel=0 fill.BackgroundColor3=m:GetAttribute("Elite") and Color3.fromRGB(238,178,59) or Color3.fromRGB(197,82,61) fill.Parent=track
 local connection=h.HealthChanged:Connect(function() fill.Size=UDim2.fromScale(math.clamp(h.Health/h.MaxHealth,0,1),1) end)
 return connection
end
local function clearSight(m,target)
 return ZombieMelee.HasSight(m,target)
end
local function spawnZombie(zone,slot,index)
 local id=zone.Types[(index-1)%#zone.Types+1]
 local elite=zone.Level>=Config.Elites.MinLevel and elitePending[zone.Id]==true
 local def=Config.ZombieVariant(id,elite)
 if elite then elitePending[zone.Id]=nil end publishHunt(zone)
 local m=templates[id]:Clone() m.Name=def.Name m:SetAttribute("ZoneId",zone.Id)
 m:SetAttribute("Elite",elite) m:SetAttribute("CoinsReward",def.Coins) m:SetAttribute("XPReward",def.XP)
 if elite then
  m:ScaleTo(def.Scale)
  local highlight=Instance.new("Highlight",m) highlight.Name="EliteOutline" highlight.Adornee=m highlight.DepthMode=Enum.HighlightDepthMode.Occluded highlight.FillColor=Color3.fromRGB(255,188,61) highlight.FillTransparency=.9 highlight.OutlineColor=Color3.fromRGB(255,214,99) highlight.OutlineTransparency=.15
  local head=m.Head
  for i=-1,1 do
   local p=Instance.new("Part") p.Name="EliteCrown" p.Size=Vector3.new(.25,.38,.18)*def.Scale p.CFrame=head.CFrame*CFrame.new(i*.55*def.Scale,head.Size.Y/2+.38*def.Scale,-.55*def.Scale)*CFrame.Angles(0,0,math.pi/4)
   p.Color=Color3.fromRGB(255,205,76) p.Material=Enum.Material.Metal p.Massless=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Parent=m
   local weld=Instance.new("WeldConstraint",p) weld.Part0=head weld.Part1=p
  end
 end
 local h=m.Humanoid local r=m.HumanoidRootPart h.MaxHealth=def.Health h.Health=def.Health h.DisplayName=def.Name
 local rayParams=RaycastParams.new() rayParams.FilterType=Enum.RaycastFilterType.Exclude local exclude={folder} for _,player in Players:GetPlayers() do if player.Character then table.insert(exclude,player.Character) end end
 rayParams.FilterDescendantsInstances=exclude rayParams.RespectCanCollide=true
 -- Spawn points mark the walkable floor; casting from above the canopy picked its roof.
 local hit=workspace:Raycast(slot.position+Vector3.new(0,6,0),Vector3.new(0,-70,0),rayParams)
 local y=hit and hit.Position.Y or 0
 local home=Vector3.new(slot.position.X,y+3*def.Scale,slot.position.Z)
 m:PivotTo(CFrame.new(home))
 for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.CollisionGroup="LiveZombies" end end
 m.Parent=folder
 for _,p in m:GetDescendants() do if p:IsA("BasePart") and not p.Anchored then pcall(function() p:SetNetworkOwner(nil) end) end end
 CollectionService:AddTag(m,"Zombie")
 local s={model=m,humanoid=h,root=r,zone=zone,def=def,home=home,attackAt=0,phase=math.random()*6,joints={},slot=slot}
 s.melee=ZombieMelee.new(m,def,zone) s.navigator=Navigation.new(m,def)
 active[m]=s slot.model=m
 local barConnection=healthbar(m,h,def)
 local paid=false
 h.Died:Connect(function()
  if paid then return end paid=true
  s.melee:Destroy() s.navigator:Destroy()
  m:SetAttribute("Rewarded",true) CollectionService:RemoveTag(m,"Zombie")
  local userId=h:GetAttribute("LastAttacker")
  local time=h:GetAttribute("LastHitAt")
  local attacker=typeof(userId)=="number" and Players:GetPlayerByUserId(userId)
  if attacker and typeof(time)=="number" and os.clock()-time<=Config.KillCreditSeconds and Zones.CanAccess(attacker,zone) then
   if Progression.AddRewards(attacker,def.Coins,def.XP,def.Name,true) then
    Economy.OnZombieKill(attacker,id)
    if zone.Level>=Config.Elites.MinLevel then
     eliteProgress[zone.Id]=(eliteProgress[zone.Id] or 0)+1
     if eliteProgress[zone.Id]>=Config.Elites.Every then
      eliteProgress[zone.Id]=0 elitePending[zone.Id]=true
      Economy.Send(attacker,"Un elite arrive bientot : "..zone.Name.." !")
     end
     publishHunt(zone)
    end
   end
  end
  barConnection:Disconnect()
  active[m]=nil slot.model=nil slot.nextSpawn=os.clock()+(zone.RespawnDelay or Config.RespawnDelay)
  NPCPresentation.Ragdoll(m)
  Debris:AddItem(m,6)
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
  if r and h and h.Health>0 and p:GetAttribute("HasStarted")==true and Zones.CanAccess(p,s.zone) and Config.ZoneAt(r.Position)==s.zone and (r.Position-s.home).Magnitude<=Config.LeashRange then
   local d=(r.Position-s.root.Position).Magnitude if d<distance then best=c distance=d end
  end
 end
 return best,distance
end
local think=0
while true do
 local dt=task.wait(0.12) think+=dt
 for m,s in active do
  if not m:IsDescendantOf(folder) then s.melee:Destroy() s.navigator:Destroy() active[m]=nil s.slot.model=nil s.slot.nextSpawn=os.clock()+(s.zone.RespawnDelay or Config.RespawnDelay) continue end
  -- Smooth joint animation is performed by each client.
 end
 if think<0.3 then continue end
 think=0
 for _,slot in slots do if not slot.model and os.clock()>=slot.nextSpawn then spawnZombie(slot.zone,slot,slot.index) end end
 for m,s in active do
  if s.humanoid.Health<=0 then continue end
  if (m:GetAttribute("StunnedUntil") or 0)>workspace:GetServerTimeNow() then
   s.humanoid.WalkSpeed=0 s.navigator:Pause() s.humanoid:Move(Vector3.zero) continue
  end
  if s.melee:IsBusy() then s.humanoid.WalkSpeed=0 s.navigator:Pause() continue end
  s.humanoid.WalkSpeed=s.def.Speed
  NPCPresentation.Voice(s)
  local target,distance=nearest(s)
  if target then
   local sight=clearSight(m,target)
   if distance<=Config.AttackRange and sight then
    s.navigator:Pause()
    local targetPosition=target.HumanoidRootPart.Position
    local flat=Vector3.new(targetPosition.X-s.root.Position.X,0,targetPosition.Z-s.root.Position.Z)
    if flat.Magnitude>0.1 then s.root.CFrame=s.root.CFrame:Lerp(CFrame.lookAt(s.root.Position,s.root.Position+flat),0.5) end
    s.melee:TryAttack(target)
   else s.navigator:Move(target.HumanoidRootPart.Position,sight) end
  else
   if (s.root.Position-s.home).Magnitude>4 then s.navigator:Move(s.home,false) else s.navigator:Pause() end
  end
 end
end
