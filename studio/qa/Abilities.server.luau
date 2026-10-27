-- SessionStudio only. Temporary server Script; pair with PulseBridge.client.luau.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local RS=game.ReplicatedStorage local SS=game.ServerScriptService local CS=game:GetService("CollectionService")
local Config=require(RS.WorldConfig) local Melee=require(SS.ZombieMelee)
local c=p.Character local h=c:FindFirstChildOfClass("Humanoid") local root=c:FindFirstChild("HumanoidRootPart")
local oldField=c:FindFirstChildOfClass("ForceField") if oldField then oldField=oldField:Clone() c:FindFirstChildOfClass("ForceField"):Destroy() end
local saved={CF=c:GetPivot(),Level=p.leaderstats.Level.Value,Health=h.Health,WalkSpeed=h.WalkSpeed,Stamina=c:GetAttribute("Stamina"),GuardUntil=c:GetAttribute("GuardUntil"),Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Ready=p:GetAttribute("ProgressReady"),ForceField=oldField}
local previousResult=game.ServerStorage:FindFirstChild("AbilitiesQAResult") if previousResult then previousResult:Destroy() end
local previousControl=RS:FindFirstChild("AbilitiesQAControl") if previousControl then previousControl:Destroy() end
local result=Instance.new("StringValue") result.Name="AbilitiesQAResult" result.Value="Running" result.Parent=game.ServerStorage
local origin=Vector3.new(100,60,-120) local checks={} local metrics={} local arena=Instance.new("Folder") arena.Name="AbilitiesQAArena" arena.Parent=workspace
local control=Instance.new("StringValue") control.Name="AbilitiesQAControl" control.Value="ReadyFrost" control.Parent=RS
local tagged={} local controller local zombie
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function fixture(name,pos)
 local m=Instance.new("Model") m.Name=name
 local r=Instance.new("Part") r.Name="HumanoidRootPart" r.Size=Vector3.new(2,2,1) r.Position=pos r.Anchored=true r.CanCollide=false r.Parent=m
 local head=Instance.new("Part") head.Name="Head" head.Size=Vector3.one head.Position=pos+Vector3.new(0,1.5,0) head.CanCollide=false head.Parent=m
 local weld=Instance.new("WeldConstraint") weld.Part0=r weld.Part1=head weld.Parent=head
 local hum=Instance.new("Humanoid") hum.MaxHealth=100 hum.Health=100 hum.WalkSpeed=0 hum.AutoRotate=false hum.Parent=m
 m.PrimaryPart=r m:SetAttribute("ZoneId","City") m.Parent=arena CS:AddTag(m,"Zombie") table.insert(tagged,m) return m
end
local function waitUntil(fn,seconds)
 local deadline=os.clock()+seconds while not fn() and os.clock()<deadline do task.wait(.03) end return fn()
end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p:SetAttribute("ProgressReady",true) p.leaderstats.Level.Value=20
 local floor=Instance.new("Part") floor.Name="TestFloor" floor.Size=Vector3.new(90,1,180) floor.Position=origin-Vector3.new(0,5,0) floor.Anchored=true floor.Parent=arena
 c:PivotTo(CFrame.lookAt(origin,origin+Vector3.new(0,0,-1))) h.WalkSpeed=0 task.wait(.55)
 root=c:FindFirstChild("HumanoidRootPart") h=c:FindFirstChildOfClass("Humanoid") assert(root and h.FloorMaterial~=Enum.Material.Air,"Player did not settle on QA floor")
 local far=fixture("CryoAt58",origin+Vector3.new(0,0,-58))
 local side=fixture("CryoOutsideWidth",origin+Vector3.new(9,0,-54))
 local outOfRange=fixture("CryoOutsideRange",origin+Vector3.new(0,0,-72))
 local stamina=c:GetAttribute("Stamina")
 check(waitUntil(function() return far.Humanoid.Health<100 end,12),"Client remote launches real cryo ability and hits at 58 studs")
 check(far.Humanoid.Health==70 and (far:GetAttribute("StunnedUntil") or 0)>workspace:GetServerTimeNow(),"Long-range lance deals 30 and applies its stun")
 check(side.Humanoid.Health==100 and outOfRange.Humanoid.Health==100,"Lance rejects targets outside its narrow 4.5-stud path and 70-stud range")
 check((c:GetAttribute("Stamina") or 0)<=stamina-31.8,"Server charges cryo stamina")
 check((c:GetAttribute("FrostReadyAt") or 0)>workspace:GetServerTimeNow()+17,"Frost cooldown is owned by the server")
 local data=CS:GetTagged("Zombie") local keep={} for _,v in data do keep[v]=true end
 local attacker=game.ServerStorage.ZombieTemplates.Civilian:Clone() attacker.Name="AegisQAAttacker" attacker:PivotTo(CFrame.new(root.Position+Vector3.new(0,0,-3))) attacker.HumanoidRootPart.Anchored=true attacker.Parent=arena attacker:SetAttribute("ZoneId","City") zombie=attacker
 controller=Melee.new(attacker,Config.Zombies.Civilian,Config.Zones[1])
 control.Value="ReadyAegis"
 check(waitUntil(function() return (c:GetAttribute("GuardUntil") or 0)>workspace:GetServerTimeNow()+2 end,15),"Client remote activates server-owned astral guard")
 local accepted,reason=controller:TryAttack(c)
 check(not accepted and reason=="Guarded" and math.abs(h.Health-saved.Health)<.01,"Guard rejects zombie melee before damage")
 check((c:GetAttribute("AegisReadyAt") or 0)>workspace:GetServerTimeNow()+23,"Aegis cooldown is owned by the server")
 local guardUntil=c:GetAttribute("GuardUntil")
 check(waitUntil(function() return workspace:GetServerTimeNow()>guardUntil+.05 end,3.5),"Guard expires at its configured duration")
 check(controller:TryAttack(c),"Melee is re-enabled once the astral guard expires")
 task.wait((attacker:GetAttribute("AttackWindup") or .45)+.12)
 check(h.Health<saved.Health,"Zombie's ordinary delayed melee damage resumes after guard ends")
 metrics.GuardRemaining=guardUntil-workspace:GetServerTimeNow()+3.2
 control.Value="Complete"
end)
if controller then controller:Destroy() end
for _,m in tagged do CS:RemoveTag(m,"Zombie") end
arena:Destroy()
if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
 c=p.Character h=c:FindFirstChildOfClass("Humanoid") root=c:FindFirstChild("HumanoidRootPart")
 c:PivotTo(saved.CF) if h then h.WalkSpeed=saved.WalkSpeed h.Health=math.min(h.MaxHealth,saved.Health) end
 c:SetAttribute("Stamina",saved.Stamina) c:SetAttribute("GuardUntil",saved.GuardUntil)
end
p.leaderstats.Level.Value=saved.Level p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) p:SetAttribute("ProgressReady",saved.Ready)
if saved.ForceField and p.Character and not p.Character:FindFirstChildOfClass("ForceField") then saved.ForceField.Parent=p.Character end
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Metrics=metrics,Error=not ok and tostring(err) or nil}) script:Destroy()
