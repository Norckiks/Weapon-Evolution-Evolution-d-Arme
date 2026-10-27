-- Ordinary temporary SessionStudio Script. Respect the real 20s cooldown.
assert(game.RunService:IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local A=require(game.ServerScriptService.PulseAbility) local C=require(game.ReplicatedStorage.GameplayConfig)
local Motion=require(game.ReplicatedStorage.WeaponMotion) local CS=game.CollectionService
local bridge=game.ReplicatedStorage:WaitForChild("ArcQABridge",10) assert(bridge)
local c=p.Character local root=c.HumanoidRootPart local h=c.Humanoid
local saved={CF=c:GetPivot(),Level=p.leaderstats.Level.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Guard=c:GetAttribute("GuardUntil"),Ability=c:GetAttribute("AbilityId"),At=c:GetAttribute("AbilityAt")}
local arena=Instance.new("Folder",workspace) arena.Name="ArcQAArena"
local result=Instance.new("StringValue",game.ServerStorage) result.Name="ArcQAResult" result.Value="Running"
local checks={} local samples={} local function check(ok,message) assert(ok,message) table.insert(checks,message) end
local origin=Vector3.new(100,60,-120)
local function dummy(name,offset,zone,tag,dead)
 local model=Instance.new("Model") model.Name=name
 local r=Instance.new("Part",model) r.Name="HumanoidRootPart" r.Size=Vector3.new(2,2,1) r.Anchored=true r.CanCollide=false r.Position=origin+offset
 local head=Instance.new("Part",model) head.Name="Head" head.Size=Vector3.one head.Position=r.Position+Vector3.new(0,1.5,0) head.Anchored=true head.CanCollide=false
 local enemy=Instance.new("Humanoid",model) enemy.MaxHealth=1000 enemy.Health=dead and 0 or 1000 enemy.WalkSpeed=0
 model.PrimaryPart=r model:SetAttribute("ZoneId",zone or "City") model.Parent=arena
 if tag~=false then CS:AddTag(model,"Zombie") end return model
end
local function cooldown() while workspace:GetServerTimeNow()<(c:GetAttribute("ArcReadyAt") or 0)+.15 do task.wait(.15) end end
local ok,err=pcall(function()
 local floor=Instance.new("Part",arena) floor.Size=Vector3.new(80,1,150) floor.Position=origin-Vector3.new(0,4,15) floor.Anchored=true
 c:PivotTo(CFrame.lookAt(origin,origin-Vector3.zAxis)) task.wait(.8) assert(h.FloorMaterial~=Enum.Material.Air)
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=24
 local s={character=c,humanoid=h,stamina=100}
 local function reject(reason)
  task.wait(.12) local before=s.stamina local accepted,why=A.Handle(p,s,"Arc") check(not accepted and why==reason and s.stamina==before,"Rejected without cost: "..reason)
 end
 p.leaderstats.Level.Value=23 reject("Level") p.leaderstats.Level.Value=24
 s.stamina=37 reject("Stamina") s.stamina=100
 s.crouching=true reject("Busy") s.crouching=nil
 p:SetAttribute("InGameMenu",true) reject("State") p:SetAttribute("InGameMenu",false)
 root.Anchored=true reject("Ground") root.Anchored=false
 check(C.Abilities.Arc.Level==24 and C.Abilities.Arc.Cost==38 and C.Abilities.Arc.MaxTargets==4,"Configured unlock, stamina and target cap")
 local targets={} for i=1,5 do targets[i]=dummy("Chain"..i,Vector3.new(0,0,-10*i)) end
 local wrong=dummy("WrongZone",Vector3.new(0,0,-12),"Lab") local ordinary=dummy("Untagged",Vector3.new(1,0,-11),nil,false)
 local behind=dummy("Behind",Vector3.new(0,0,10)) local dead=dummy("Dead",Vector3.new(1,0,-15),nil,true,true)
 cooldown() bridge:InvokeClient(p,"Cast") task.wait(.18)
 check(targets[1].Humanoid.Health==958 and targets[2].Humanoid.Health==968 and targets[3].Humanoid.Health==976 and targets[4].Humanoid.Health==982,"Four real remote hits deal 42/32/24/18")
 check(targets[5].Humanoid.Health==1000 and wrong.Humanoid.Health==1000 and ordinary.Humanoid.Health==1000 and behind.Humanoid.Health==1000,"Cap, zone, tag and initial facing respected")
 check(targets[1].Humanoid:GetAttribute("LastAttacker")==p.UserId and targets[1]:GetAttribute("StunnedUntil")>workspace:GetServerTimeNow(),"Attacker attribution and stun")
 check((c:GetAttribute("Stamina") or 100)<=62.5 and c:GetAttribute("ArcReadyAt")>workspace:GetServerTimeNow()+19,"Real stamina and cooldown charged")
 samples.Normal=bridge:InvokeClient(p,"Snapshot")
 check(samples.Normal.Hits==4 and #samples.Normal.Path==5,"Server transmits only selected chain path")
 check(samples.Normal.Bolts==12 and samples.Normal.Sounds==1 and samples.Normal.Safe,"Twelve safe bolt segments and one sound instance")
 reject("Cooldown") local deadline=c:GetAttribute("ArcReadyAt") A.Bind(p,c) check(c:GetAttribute("ArcReadyAt")==deadline,"Rebinding preserves cooldown")
 local wall=Instance.new("Part",arena) wall.Name="HopWall" wall.Size=Vector3.new(8,12,1) wall.Anchored=true wall.Position=origin+Vector3.new(0,0,-25) wall.Transparency=1
 cooldown() bridge:InvokeClient(p,"Cast") task.wait(.18)
 check(targets[1].Humanoid.Health==916 and targets[2].Humanoid.Health==936 and targets[3].Humanoid.Health==976,"Solid wall blocks bounce beyond second target")
 wall:Destroy()
 cooldown() bridge:InvokeClient(p,"Reduced") task.wait(.18)
 samples.Reduced=bridge:InvokeClient(p,"Snapshot")
 check(targets[1].Humanoid.Health==874 and targets[4].Humanoid.Health==964,"Reduced visuals preserve real damage")
 check(samples.Reduced.Bolts==4 and samples.Reduced.Sounds==0 and samples.Reduced.Safe,"Reduced mode has four static links and muted audio")
 for i=0,30 do local pose,weight,body=Motion.Ability("Arc",i/30,1) for _,v in {pose:GetComponents()} do assert(v==v and math.abs(v)<math.huge) end assert(weight==weight and body==body and math.abs(weight)<math.huge and math.abs(body)<math.huge) end
 check(Motion.Ability("Arc",1,1)==CFrame.identity,"Dedicated ability pose settles")
 check(C.Abilities.Frost.Damage==30 and C.Pulse.Damage==20 and not C.MonetizationEnabled,"Existing abilities and disabled Robux preserved")
end)
bridge:InvokeClient(p,"Restore") arena:Destroy() c:PivotTo(saved.CF)
p.leaderstats.Level.Value=saved.Level p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
c:SetAttribute("GuardUntil",saved.Guard) c:SetAttribute("AbilityId",saved.Ability) c:SetAttribute("AbilityAt",saved.At)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Samples=samples,Restored=true})
