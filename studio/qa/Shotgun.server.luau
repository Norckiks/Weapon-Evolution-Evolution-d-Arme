-- Temporary SessionStudio harness; never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local RS=game.ReplicatedStorage local SS=game.ServerScriptService local Http=game.HttpService
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(SS.EconomyService) local P=require(SS.ProgressionService) local B=require(RS.FirearmBallistics) local C=require(RS.GameplayConfig)
local bridge=RS:WaitForChild("FirearmsQABridge") local m=P.GetMeta(p)
local saved=Http:JSONEncode(m) local coins,level,xp=p.leaderstats.Coins.Value,p.leaderstats.Level.Value,p.Progress.XP.Value
local cf=p.Character:GetPivot() local started,menu=p:GetAttribute("HasStarted"),p:GetAttribute("InGameMenu")
local root=p.Character.HumanoidRootPart local anchored=root.Anchored
local report={} local result=Instance.new("StringValue") result.Name="ShotgunQAResult" result.Value="Running" result.Parent=game.ServerStorage
local arena=Instance.new("Folder") arena.Name="ShotgunQA" arena.Parent=workspace
local function check(ok,name) assert(ok,name) table.insert(report,name) end
local function call(verb,id) task.wait(.18) E.Handle(p,verb,id) task.wait(.1) end
local function fire(name,dir) bridge:InvokeClient(p,name,dir) task.wait(.18) end
local function shoot() task.wait(.96) fire("Shoot",Vector3.new(0,0,-1)) end
local function dummy(offset,size)
 local d=Instance.new("Model") d.Name="ShotgunDummy"
 local part=Instance.new("Part") part.Name="Torso" part.Size=size part.Position=p.Character.Head.Position+offset part.Anchored=true part.CanCollide=false part.Parent=d
 local h=Instance.new("Humanoid") h.MaxHealth=2000 h.Health=2000 h.RequiresNeck=false h.Parent=d
 d.PrimaryPart=part game.CollectionService:AddTag(d,"Zombie") d.Parent=arena return d,h
end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 root.Anchored=true p.Character:PivotTo(CFrame.new(0,1000,0)) task.wait(.2)
 m.Weapons={Fists=true} m.EquippedWeapon="Fists" p.leaderstats.Coins.Value=20000 p.leaderstats.Level.Value=15 E.Refresh(p) E.Send(p)
 call("BuyWeapon","Shotgun") check(not m.Weapons.Shotgun and p.leaderstats.Coins.Value==20000,"Level 15 refused")
 p.leaderstats.Level.Value=16 p.leaderstats.Coins.Value=100
 call("BuyWeapon","Shotgun") check(not m.Weapons.Shotgun and p.leaderstats.Coins.Value==100,"Insufficient funds refused")
 p.leaderstats.Coins.Value=20000 call("BuyWeapon","Shotgun")
 check(m.Weapons.Shotgun and p:GetAttribute("EquippedWeapon")=="Shotgun" and p.leaderstats.Coins.Value==8500,"Purchase from remote arena costs 11500")
 call("BuyWeapon","Shotgun") check(p.leaderstats.Coins.Value==8500,"Duplicate purchase free")
 check(p:GetAttribute("GunAmmo")==5 and p:GetAttribute("GunMagazine")==5,"Five shells equipped")
 local v=p.Character:FindFirstChild("EquippedWeaponVisual") check(v and v:FindFirstChild("Foreend") and v:FindFirstChild("MagazineTube") and not v:FindFirstChild("Cylinder"),"Distinct shotgun world model")
 local rays=B.Directions(Vector3.new(0,0,-1),C.Weapons.Shotgun)
 check(#rays==7 and #B.Directions(Vector3.new(0,0,-1),C.Weapons.Pistol)==1,"Seven pellets; pistol remains single ray")
 for _,r in rays do check(math.abs(r.Magnitude-1)<1e-5 and math.deg(math.acos(math.clamp(r:Dot(Vector3.new(0,0,-1)),-1,1)))<4.501,"Unit direction within spread") end
 local again=B.Directions(Vector3.new(0,0,-1),C.Weapons.Shotgun) local same=true for i,r in rays do same=same and (r-again[i]).Magnitude<1e-6 end check(same,"Deterministic server spread")
 local d,h=dummy(Vector3.new(0,0,-10),Vector3.new(4,4,1)) local changes=0 h.HealthChanged:Connect(function() changes+=1 end)
 shoot() check(h.Health==1860 and p:GetAttribute("GunAmmo")==4,"Seven pellets aggregate to 140; one shell")
 check(changes==1 and h:GetAttribute("LastAttacker")==p.UserId,"One health change and attacker attribution per target")
 d:Destroy()
 local left,lh=dummy(Vector3.new(-1.57,0,-20),Vector3.new(.6,4,1))
 local right,rh=dummy(Vector3.new(1.57,0,-20),Vector3.new(.6,4,1))
 shoot() check(lh.Health<2000 and rh.Health<2000 and 4000-lh.Health-rh.Health<=140,"One shot damages two spread targets within total budget") left:Destroy() right:Destroy()
 d,h=dummy(Vector3.new(0,0,-10),Vector3.new(4,4,1))
 local wall=Instance.new("Part") wall.Size=Vector3.new(12,12,1) wall.Position=p.Character.Head.Position+Vector3.new(0,0,-5) wall.Anchored=true wall.Transparency=1 wall.Parent=arena
 shoot() check(h.Health==2000,"Transparent solid wall blocks all pellets")
 wall.CanCollide=false shoot() check(h.Health==1860,"Noncollidable trigger passes all pellets") wall:Destroy() d:Destroy()
 d,h=dummy(Vector3.new(0,0,-80),Vector3.new(20,20,1))
 shoot() check(h.Health==2000,"Beyond 75 studs misses") d:Destroy()
 task.wait(.2) check(p:GetAttribute("GunReloading"),"Last shell triggers automatic reload")
 fire("Shoot",Vector3.new(0,0,-1)) check(p:GetAttribute("GunAmmo")==0,"Reload blocks shooting")
 task.wait(3) check(p:GetAttribute("GunAmmo")==5 and not p:GetAttribute("GunReloading"),"Reload fills five shells atomically")
 task.wait(.96) fire("ShootBurst",Vector3.new(0,0,-1)) check(p:GetAttribute("GunAmmo")==4,"Burst spam consumes one shell")
 fire("ReloadGun") check(p:GetAttribute("GunReloading") and p:GetAttribute("GunReloadDuration")==2.9,"Reload duration 2.9 seconds")
 call("EquipWeapon","Fists") task.wait(3) call("EquipWeapon","Shotgun") check(p:GetAttribute("GunAmmo")==4 and not p:GetAttribute("GunReloading"),"Switch cancels reload without granting shells")
 d,h=dummy(Vector3.new(0,0,-10),Vector3.new(4,4,1)) d:SetAttribute("ZoneId","Harbor") shoot() check(h.Health==2000,"Wrong zone blocks damage") d:Destroy()
 local motion=require(RS.WeaponMotion)
 check(motion.PartPose("Shotgun","Foreend",nil,4,.435).Position.Z>.21 and motion.PartPose("Shotgun","Foreend",nil,4,.9)==CFrame.identity,"Pump cycle moves and returns")
 check(motion.Reload(.5,1,"Shotgun")~=motion.Reload(.5,1,"Pistol"),"Dedicated reload pose")
end)
arena:Destroy() table.clear(m) for k,v in Http:JSONDecode(saved) do m[k]=v end
p.leaderstats.Coins.Value=coins p.leaderstats.Level.Value=level p.Progress.XP.Value=xp
p:SetAttribute("HasStarted",started) p:SetAttribute("InGameMenu",menu) p.Character:PivotTo(cf) root.Anchored=anchored E.Refresh(p) E.Send(p)
result.Value=Http:JSONEncode({Passed=ok,Checks=report,Error=not ok and tostring(err) or nil}) script:Destroy()
