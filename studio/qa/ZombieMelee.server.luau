-- SessionStudio only. Temporary ordinary server Script, never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local SS=game.ServerScriptService local Http=game.HttpService local Config=require(game.ReplicatedStorage.WorldConfig)
local Melee=require(SS.ZombieMelee) local p=game.Players:GetPlayers()[1]
assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local c=p.Character local root=c.HumanoidRootPart local h=c.Humanoid
local saved={CF=c:GetPivot(),Anchored=root.Anchored,Health=h.Health,Level=p.leaderstats.Level.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="ZombieMeleeQAResult" result.Value="Running" result.Parent=game.ServerStorage
local arena=Instance.new("Folder") arena.Name="ZombieMeleeQA" arena.Parent=workspace
local checks,metrics={},{} local qaAccessory local current,controller local frozen local forcefield local damage={} local previous=h.Health
local connection=h.HealthChanged:Connect(function(value) if value<previous then table.insert(damage,{Amount=previous-value,At=workspace:GetServerTimeNow()}) end previous=value end)
local origin=Vector3.new(100,60,-120)
local function total() local n=0 for _,v in damage do n+=v.Amount end return n end
local function check(ok,name) assert(ok,name) table.insert(checks,name) script:SetAttribute("Checks",#checks) end
local function reset()
 if controller then controller:Destroy() controller=nil end if current then current:Destroy() current=nil end
 arena:ClearAllChildren() p:SetAttribute("HasStarted",true) p.leaderstats.Level.Value=20
 c:PivotTo(CFrame.new(origin)) root.Anchored=true h.Health=h.MaxHealth previous=h.Health damage={}
end
local function fixture(id,zone)
 current=game.ServerStorage.ZombieTemplates[id]:Clone() current.Name="Controlled_"..id
 current:PivotTo(CFrame.new(origin+Vector3.new(0,0,-3))) current.HumanoidRootPart.Anchored=true current.Parent=arena
 controller=Melee.new(current,Config.Zombies[id],zone or Config.Zones[1])
 return current,controller
end
local function waitStrike(z,extra) task.wait((z:GetAttribute("AttackWindup") or .45)+(extra or .12)) end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 local field=c:FindFirstChildOfClass("ForceField") if field then forcefield=field:Clone() field:Destroy() end
 -- Exercise every existing rig and its own damage/windup, including the titan.
 if not script:GetAttribute("SkipRigPass") then
 for _,zone in Config.Zones do for _,id in zone.Types do
  reset() local z,attack=fixture(id,Config.Zones[1]) local accepted=attack:TryAttack(c)
  check(accepted and z:GetAttribute("AttackPhase")=="Windup" and z.AttackWarning.Enabled and z.Humanoid.WalkSpeed==0 and total()==0,"Enabled warning, stopped movement, no immediate hit: "..id)
  local start=z:GetAttribute("AttackAt") local windup=z:GetAttribute("AttackWindup") waitStrike(z)
  local elapsed=damage[1] and damage[1].At-start or -1
  check(#damage==1 and math.abs(total()-Config.Zombies[id].Damage)<.01 and elapsed>=windup-.015 and z:GetAttribute("AttackOutcome")=="Hit","One delayed configured hit: "..id)
  metrics[id]={Windup=windup,ObservedDelay=elapsed,Damage=total()}
 end end
 end
 reset() local z,attack=fixture("Civilian") check(attack:TryAttack(c),"Ordinary attack accepted")
 local accepted,reason=attack:TryAttack(c) check(not accepted and reason=="Busy","Parallel attack rejected")
 waitStrike(z) accepted,reason=attack:TryAttack(c)
 check(not accepted and reason=="Busy" and not z.AttackWarning.Enabled,"Recovery blocks another swing and hides warning")
 task.wait(.3) accepted,reason=attack:TryAttack(c)
 check(not accepted and reason=="Cooldown","Idle cannot bypass start-to-start cooldown")
 task.wait(math.max(0,attack.NextAt-os.clock())+.02) check(attack:TryAttack(c),"Full cooldown rearms")
 reset() z,attack=fixture("Civilian") attack:TryAttack(c)
 local facing=z:GetAttribute("AttackFacing") c:PivotTo(CFrame.new(z.HumanoidRootPart.Position-facing*3)) waitStrike(z)
 check(total()==0 and z:GetAttribute("AttackOutcome")=="Miss","Sidestep behind committed direction dodges")
 reset() z,attack=fixture("Civilian") attack:TryAttack(c) c:PivotTo(CFrame.new(origin+Vector3.new(0,0,10))) waitStrike(z)
 check(total()==0,"Leaving melee range during windup dodges")
 reset() z,attack=fixture("Civilian") attack:TryAttack(c)
 local wall=Instance.new("Part") wall.Size=Vector3.new(10,10,.2) wall.Position=origin+Vector3.new(0,1,-2.5) wall.Anchored=true wall.Transparency=1 wall.Parent=arena
 qaAccessory=Instance.new("Folder") qaAccessory.Name="QAOcclusionFixture" qaAccessory.Parent=c
 local cosmetic=Instance.new("Accessory") cosmetic.Name="QAOcclusionAccessory" cosmetic.Parent=qaAccessory
 local handle=Instance.new("Part") handle.Name="Handle" handle.Size=Vector3.new(1,2,.1) handle.Position=origin+Vector3.new(0,2,-2.75) handle.Anchored=true handle.CanCollide=false handle.Parent=cosmetic
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={z}
 local raw=workspace:Raycast(z.Head.Position,root.Position-z.Head.Position,params)
 check(raw and raw.Instance==handle and not Melee.HasSight(z,c),"Protruding avatar accessory cannot hide a solid wall")
 waitStrike(z) check(total()==0 and z:GetAttribute("AttackOutcome")=="Miss","Solid transparent wall inserted during windup blocks hit") qaAccessory:Destroy() qaAccessory=nil
 reset() z,attack=fixture("Civilian")
 wall=Instance.new("Part") wall.Size=Vector3.new(10,10,.2) wall.Position=origin+Vector3.new(0,1,-2.5) wall.Anchored=true wall.CanCollide=false wall.Parent=arena
 check(attack:TryAttack(c),"Noncollidable trigger permits an attack") waitStrike(z) check(total()==4,"Noncollidable trigger permits impact")
 reset() z,attack=fixture("Civilian") attack:TryAttack(c) task.wait(.04)
 z:SetAttribute("StunnedUntil",workspace:GetServerTimeNow()+.06) task.wait(.02)
 check(not attack:IsBusy() and z:GetAttribute("AttackPhase")=="Idle" and not z.AttackWarning.Enabled,"Stun immediately cancels warning and windup")
 task.wait(.55) accepted,reason=attack:TryAttack(c)
 check(total()==0 and reason=="Cooldown" and z:GetAttribute("AttackOutcome")=="Cancelled","Expired short stun cannot resurrect delayed damage or bypass cooldown")
 reset() z,attack=fixture("Civilian") attack:TryAttack(c) z.Humanoid.Health=0 task.wait(.6)
 check(total()==0 and attack.Destroyed,"Attacker death cancels delayed hit")
 reset() z,attack=fixture("Civilian") attack:TryAttack(c) z.Parent=game.ServerStorage task.wait(.6)
 check(total()==0,"Removing attacker from world prevents delayed damage")
 reset() z,attack=fixture("Civilian") p:SetAttribute("HasStarted",false)
 accepted,reason=attack:TryAttack(c) check(not accepted and reason=="Target","Player before Start cannot be attacked")
 reset() origin=Vector3.new(620,60,-120) c:PivotTo(CFrame.new(origin)) z,attack=fixture("Worker",Config.Zones[2]) p.leaderstats.Level.Value=4
 accepted,reason=attack:TryAttack(c) check(not accepted and reason=="Zone" and Config.ZoneAt(root.Position)==Config.Zones[2],"Unauthorized Factory level refused before damage")
 reset() z,attack=fixture("Civilian",Config.Zones[1])
 accepted,reason=attack:TryAttack(c) check(not accepted and reason=="Zone","Cross-zone victim refused")
 origin=Vector3.new(100,60,-120) reset()
 -- Live director integration: pause both roots at height 60 within the original spawn leash.
 local real for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")=="Civilian" and v.Humanoid.Health>0 then real=v break end end assert(real)
 frozen={Model=real,CF=real:GetPivot(),Anchored=real.HumanoidRootPart.Anchored}
 local home=real.HumanoidRootPart.Position local position=Vector3.new(home.X,60,home.Z)
 real.HumanoidRootPart.Anchored=true real:PivotTo(CFrame.new(position)) c:PivotTo(CFrame.new(position+Vector3.new(0,0,3)))
 damage={} previous=h.Health local deadline=os.clock()+3
 while real:GetAttribute("AttackPhase")~="Windup" and os.clock()<deadline do task.wait(.01) end
 check(real:GetAttribute("AttackPhase")=="Windup" and real.AttackWarning.Enabled,"Real director begins new warning state")
 local first=real:GetAttribute("AttackAt") local direction=real:GetAttribute("AttackFacing") c:PivotTo(CFrame.new(position-direction*3))
 task.wait((real:GetAttribute("AttackWindup") or .45)+.12)
 check(total()==0 and real:GetAttribute("AttackOutcome")=="Miss" and real.HumanoidRootPart.CFrame.LookVector:Dot(direction)>.99,"Real director holds facing and misses a dodge")
 deadline=os.clock()+3
 while (real:GetAttribute("AttackAt")==first or real:GetAttribute("AttackPhase")~="Windup") and os.clock()<deadline do task.wait(.01) end
 check(real:GetAttribute("AttackPhase")=="Windup" and real:GetAttribute("AttackAt")>first,"Real director rearms after cooldown")
 real:SetAttribute("StunnedUntil",workspace:GetServerTimeNow()+.06) task.wait(.6)
 check(total()==0 and real:GetAttribute("AttackOutcome")=="Cancelled" and not real.AttackWarning.Enabled,"Real director cancels a windup even after short stun expires")
 real:PivotTo(frozen.CF) real.HumanoidRootPart.Anchored=frozen.Anchored frozen=nil
 -- Character replacement invalidates the captured target, rather than hurting the new character.
 reset() z,attack=fixture("Civilian") attack:TryAttack(c) p:LoadCharacterAsync() c=p.Character c:WaitForChild("HumanoidRootPart",5) h=c.Humanoid root=c.HumanoidRootPart task.wait(.6)
 check(z:GetAttribute("AttackOutcome")=="Miss" and h.Health>0,"Actual respawn invalidates old windup target")
end)
if qaAccessory then qaAccessory:Destroy() end
if controller then controller:Destroy() end if current then current:Destroy() end arena:Destroy() connection:Disconnect()
if frozen and frozen.Model.Parent then frozen.Model:PivotTo(frozen.CF) frozen.Model.HumanoidRootPart.Anchored=frozen.Anchored end
p.leaderstats.Level.Value=saved.Level p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character:PivotTo(saved.CF) p.Character.HumanoidRootPart.Anchored=saved.Anchored local hum=p.Character:FindFirstChildOfClass("Humanoid") if hum then hum.Health=math.min(hum.MaxHealth,saved.Health) end if forcefield and not p.Character:FindFirstChildOfClass("ForceField") then forcefield.Parent=p.Character end end
result.Value=Http:JSONEncode({Passed=ok,Checks=checks,Metrics=metrics,Error=not ok and tostring(err) or nil}) script:Destroy()
