-- Session-only integration test. Uses real UseAbility requests; module calls cover rejection reasons.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local RS=game.ReplicatedStorage local SS=game.ServerScriptService local CS=game:GetService("CollectionService")
local A=require(SS.PulseAbility) local E=require(SS.EconomyService) local P=require(SS.ProgressionService)
local bridge=RS:WaitForChild("PulseQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local c=p.Character local saved={CF=c:GetPivot(),Level=p.leaderstats.Level.Value,Coins=p.leaderstats.Coins.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="PulseQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={} local metrics={} local arena=Instance.new("Folder") arena.Name="PulseQAArena" arena.Parent=workspace
local runner local runnerAnchored
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function reject(s,reason,id)
 task.wait(.12) local ok,why=A.Handle(p,s,id or "Pulse") assert(not ok and why==reason,"Expected "..reason..", got "..tostring(ok)..":"..tostring(why)); table.insert(checks,"Refused: "..reason)
end
local function dummy(name,pos,tag,zone,anchored)
 local v=Instance.new("Model") v.Name=name
 local r=Instance.new("Part") r.Name="HumanoidRootPart" r.Size=Vector3.new(2,2,1) r.Position=pos r.Anchored=anchored==true r.CanCollide=anchored~=true r.Parent=v
 local head=Instance.new("Part") head.Name="Head" head.Size=Vector3.one head.Position=pos+Vector3.new(0,1.5,0) head.CanCollide=false head.Parent=v
 local w=Instance.new("WeldConstraint") w.Part0=r w.Part1=head w.Parent=head
 local h=Instance.new("Humanoid") h.MaxHealth=100 h.Health=100 h.WalkSpeed=0 h.AutoRotate=false h.Parent=v
 v.PrimaryPart=r v:SetAttribute("ZoneId",zone or "City") v.Parent=arena
 if tag~=false then CS:AddTag(v,"Zombie") end if not r.Anchored then r:SetNetworkOwner(nil) end return v
end
local ok,err=pcall(function()
 -- Repeated QA runs respect the live cooldown instead of resetting the server's private timer.
 while workspace:GetServerTimeNow()<(c:GetAttribute("PulseReadyAt") or 0)+.1 do task.wait(.1) end
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=5 p.leaderstats.Coins.Value=0 p.Progress.XP.Value=0
 local fxBaseline=bridge:InvokeClient(p,"Snapshot").Count
 m.Pets={} m.EquippedPet="" m.CoinBoostUntil=0 m.XPBoostUntil=0 m.QuickContract={Index=3,Count=0,Seen={}} E.Refresh(p)
 c:PivotTo(CFrame.new(0,5,-10)) task.wait(.8)
 local h=c.Humanoid local s={character=c,humanoid=h,stamina=100}
 reject(s,"Action","Invalid")
 p:SetAttribute("HasStarted",false) reject(s,"State") p:SetAttribute("HasStarted",true) task.wait(.35)
 p:SetAttribute("InGameMenu",true) reject(s,"State") p:SetAttribute("InGameMenu",false)
 p.leaderstats.Level.Value=4 reject(s,"Level") p.leaderstats.Level.Value=5
 s.stamina=29 reject(s,"Stamina") s.stamina=100
 s.crouching=true reject(s,"Busy") s.crouching=false
 s.slideUntil=workspace:GetServerTimeNow()+2 reject(s,"Busy") s.slideUntil=nil
 c:SetAttribute("DashUntil",workspace:GetServerTimeNow()+2) reject(s,"Busy") c:SetAttribute("DashUntil",0)
 p:SetAttribute("GunReloading",true) reject(s,"Busy") p:SetAttribute("GunReloading",false)
 c.HumanoidRootPart.Anchored=true reject(s,"Ground") c.HumanoidRootPart.Anchored=false
 c:PivotTo(CFrame.new(0,5,220)) task.wait(.4) reject(s,"Zone")
 c:PivotTo(CFrame.new(0,5,-10)) task.wait(.7)
 local front=dummy("Front",Vector3.new(0,3.5,-18))
 local side=dummy("Side",Vector3.new(8,3.5,-10))
 local blocked=dummy("Blocked",Vector3.new(-8,3.5,-10),true,"City",true)
 local wrong=dummy("WrongZone",Vector3.new(0,3.5,-16),true,"Lab",true)
 local far=dummy("Far",Vector3.new(0,3.5,-29),true,"City",true)
 local ordinary=dummy("NotZombie",Vector3.new(4,3.5,-10),false,"City",true)
 local wall=Instance.new("Part") wall.Name="TransparentSolidWall" wall.Size=Vector3.new(1,10,10) wall.Position=Vector3.new(-4,5,-10) wall.Anchored=true wall.Transparency=1 wall.Parent=arena
 local real
 for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")=="Civilian" and v.Humanoid.Health>0 then real=v break end end assert(real)
 real.HumanoidRootPart.Anchored=true real:PivotTo(CFrame.new(4,3.5,-14)) real.Humanoid.Health=20
 for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZombieType")=="Runner" and v.Humanoid.Health>0 then runner=v break end end assert(runner)
 runnerAnchored=runner.HumanoidRootPart.Anchored runner.HumanoidRootPart.Anchored=true runner:PivotTo(CFrame.new(7,3.5,-5))
 runner.Humanoid.Health=runner.Humanoid.MaxHealth
 task.wait(.2) local start=front.HumanoidRootPart.Position
 bridge:InvokeClient(p,"Options",false)
 local before=c:GetAttribute("Stamina") bridge:InvokeClient(p,"Cast") task.wait(.12)
 check((c:GetAttribute("PulseReadyAt") or 0)>workspace:GetServerTimeNow()+13,"Real remote starts fourteen-second cooldown")
 check(math.abs(before-c:GetAttribute("Stamina")-30)<.2,"Real SprintServer stamina charged exactly thirty")
 check(front.Humanoid.Health==80 and side.Humanoid.Health==80,"Nearby front and side zombies each take twenty damage")
 check(blocked.Humanoid.Health==100,"Transparent solid wall blocks pulse")
 check(wrong.Humanoid.Health==100 and far.Humanoid.Health==100 and ordinary.Humanoid.Health==100,"Wrong-zone, distant and untagged targets untouched")
 check(front.Humanoid:GetAttribute("LastAttacker")==p.UserId and (front:GetAttribute("StunnedUntil") or 0)>workspace:GetServerTimeNow(),"Pulse credits attacker and sets bounded stun")
 check(p.leaderstats.Coins.Value==8 and p.Progress.XP.Value==20 and real:GetAttribute("Rewarded"),"Pulse kill awards real director coins and XP")
 local stunDeadline=workspace:GetServerTimeNow()+.4
 while runner.Humanoid.WalkSpeed~=0 and workspace:GetServerTimeNow()<stunDeadline do task.wait(.02) end
 metrics.RunnerDuring={Health=runner.Humanoid.Health,Speed=runner.Humanoid.WalkSpeed,Remaining=(runner:GetAttribute("StunnedUntil") or 0)-workspace:GetServerTimeNow()}
 check(runner.Humanoid.Health==30 and runner.Humanoid.WalkSpeed==0,"Real zombie director stops a stunned runner in clear sight")
 local charged=c:GetAttribute("Stamina") bridge:InvokeClient(p,"Cast") task.wait(.12)
 check(c:GetAttribute("Stamina")==charged and front.Humanoid.Health==80,"Repeated remote cannot spend stamina or damage during cooldown")
 bridge:InvokeClient(p,"Invalid") task.wait(.15)
 check(front.Humanoid.Health==80,"Client-supplied damage/cost table rejected")
 metrics.KnockbackDistance=(front.HumanoidRootPart.Position-start).Magnitude
 check(metrics.KnockbackDistance>1,"Real impulse physically moves the target")
 task.wait(.15) metrics.NormalFX=bridge:InvokeClient(p,"Snapshot")
 check(metrics.NormalFX.Count==fxBaseline+1 and metrics.NormalFX.Last.Arcs==12 and metrics.NormalFX.Last.Sounds==1,"Accepted event renders twelve arcs and an enabled sound")
 task.wait(.8) check(runner.Humanoid.WalkSpeed==13,"Runner recovers its configured speed after stun")
 runner.HumanoidRootPart.Anchored=runnerAnchored runner=nil
 local deadline=c:GetAttribute("PulseReadyAt")
 p:LoadCharacterAsync() c=p.Character c:WaitForChild("HumanoidRootPart",5) task.wait(.6)
 check(c:GetAttribute("PulseReadyAt")==deadline,"Cooldown survives actual character respawn")
 c:PivotTo(CFrame.new(0,5,-10)) task.wait(.5)
 local fresh=c:GetAttribute("Stamina") bridge:InvokeClient(p,"Cast") task.wait(.15)
 check(c:GetAttribute("Stamina")==fresh,"Respawning cannot bypass ability cooldown")
 arena:ClearAllChildren()
 local capped={}
 for i=1,15 do local angle=i*math.pi*2/15 table.insert(capped,dummy("Cap"..i,Vector3.new(math.cos(angle)*8,3.5,-10+math.sin(angle)*8),true,"City",true)) end
 bridge:InvokeClient(p,"Options",true)
 while workspace:GetServerTimeNow()<deadline+.1 do task.wait(.1) end
 bridge:InvokeClient(p,"Cast") task.wait(.4)
 local damaged=0 for _,v in capped do if v.Humanoid.Health==80 then damaged+=1 end end
 check(damaged==12,"Pulse affects at most twelve of fifteen valid targets")
 metrics.ReducedFX=bridge:InvokeClient(p,"Snapshot")
 check(metrics.ReducedFX.Count==fxBaseline+2 and metrics.ReducedFX.Last.Arcs==6 and metrics.ReducedFX.Last.Sounds==0,"Reduced-motion effect uses six arcs and respects muted sound")
 check((c:GetAttribute("PulseReadyAt") or 0)>deadline+13,"Cooldown expires and rearms only after the full interval")
end)
bridge:InvokeClient(p,"Restore") arena:Destroy()
if runner and runner.Parent then runner.HumanoidRootPart.Anchored=runnerAnchored end
table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
p.leaderstats.Level.Value=saved.Level p.leaderstats.Coins.Value=saved.Coins p.Progress.XP.Value=saved.XP
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) p:SetAttribute("GunReloading",false)
E.Refresh(p) E.Send(p) if p.Character then p.Character:PivotTo(saved.CF) end
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Metrics=metrics,Error=not ok and tostring(err) or nil}) script:Destroy()
