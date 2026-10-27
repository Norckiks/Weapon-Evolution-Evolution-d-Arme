-- Studio-only regression harness for Pistol, SMG and Revolver.
assert(game:GetService("RunService"):IsStudio(),"Studio only")
local Http=game:GetService("HttpService")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local SS=game:GetService("ServerScriptService")
local CollectionService=game:GetService("CollectionService")

local p=Players:GetPlayers()[1]
assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio","SessionStudio required")

local E=require(SS.EconomyService)
local P=require(SS.ProgressionService)
local C=require(RS.GameplayConfig)
local remotes=RS.Remotes
local shootRemote=remotes:WaitForChild("Shoot")
local reloadRemote=remotes:WaitForChild("ReloadGun")
local punchRemote=remotes:WaitForChild("Punch")
-- Temporary client bridge must be installed in Studio Play before this harness.
local bridge=RS:WaitForChild("FirearmsQABridge",10) assert(bridge,"QA client bridge missing")
local function fire(remote,direction) bridge:InvokeClient(p,remote.Name,direction) end

local m=P.GetMeta(p) assert(m,"Runtime profile missing")
local originalMeta=Http:JSONEncode(m)
local savedStats={
 Coins=p.leaderstats.Coins.Value,
 Level=p.leaderstats.Level.Value,
 XP=p.Progress.XP.Value,
 CF=p.Character:GetPivot(),
 Started=p:GetAttribute("HasStarted"),
 Menu=p:GetAttribute("InGameMenu"),
 Equipped=p:GetAttribute("EquippedWeapon")
}

local report={}
local result=game.ServerStorage:FindFirstChild("FirearmsQAResult") or Instance.new("StringValue")
result.Name="FirearmsQAResult" result.Value="Running" result.Parent=game.ServerStorage

local function check(cond,name)
 assert(cond,name)
 table.insert(report,name)
end

local function call(verb,id)
 task.wait(0.16)
 E.Handle(p,verb,tostring(id))
end

local arena=Instance.new("Folder") arena.Name="FirearmsQAArena" arena.Parent=workspace

local function createDummy(pos)
 local d=Instance.new("Model") d.Name="QAZombieDummy"
 local root=Instance.new("Part") root.Name="HumanoidRootPart" root.Size=Vector3.new(2,2,1) root.Position=pos root.Anchored=true root.CanCollide=false root.Parent=d
 local head=Instance.new("Part") head.Name="Head" head.Size=Vector3.new(1.2,1.2,1.2) head.Position=pos+Vector3.new(0,1.5,0) head.Anchored=true head.CanCollide=false head.Parent=d
 local hum=Instance.new("Humanoid") hum.MaxHealth=1000 hum.Health=1000 hum.Parent=d
 d.PrimaryPart=root
 CollectionService:AddTag(d,"Zombie")
 d.Parent=arena
 return d,hum,head
end

local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true)
 p:SetAttribute("InGameMenu",false)

 -- Baseline reset
 m.Weapons={Fists=true} m.EquippedWeapon="Fists"
 p.leaderstats.Coins.Value=10000 p.leaderstats.Level.Value=1 p.Progress.XP.Value=0
 E.Refresh(p) E.Send(p)

 -- Check 1: Level 1 player cannot buy Pistol (requires level 3)
 call("BuyWeapon","Pistol")
 check(not m.Weapons.Pistol and p.leaderstats.Coins.Value==10000,"Pistol level gate (requires level 3)")

 -- Check 2: Level 3 player buys Pistol (costs 1400)
 p.leaderstats.Level.Value=3
 call("BuyWeapon","Pistol")
 check(m.Weapons.Pistol==true and p.leaderstats.Coins.Value==8600 and m.EquippedWeapon=="Pistol","Pistol purchase and coin deduction")

 -- Check 3: Duplicate purchase does not deduct coins
 call("BuyWeapon","Pistol")
 check(p.leaderstats.Coins.Value==8600,"Duplicate Pistol purchase rejected without charge")

 -- Check 4: Equip Pistol initializes attributes (Ammo 12, Magazine 12)
 task.wait(0.1)
 check(p:GetAttribute("EquippedWeapon")=="Pistol" and p:GetAttribute("GunAmmo")==12 and p:GetAttribute("GunMagazine")==12,"Pistol equipped with 12 ammo")

 -- Check 5: Invalid directions rejected
 local head=p.Character and p.Character:FindFirstChild("Head")
 assert(head,"Player head required")
 local dummy,dummyHum,dummyHead=createDummy(head.Position+Vector3.new(0,0,-20))

 local ammoBefore=p:GetAttribute("GunAmmo")
 fire(shootRemote,Vector3.zero)
 fire(shootRemote,Vector3.new(0,0,-0.1)) -- magnitude < 0.5
 fire(shootRemote,Vector3.new(0,0,-5))   -- magnitude > 1.5
 task.wait(0.15)
 check(p:GetAttribute("GunAmmo")==ammoBefore,"Invalid shoot directions rejected without consuming ammo")

 -- Check 6: Valid shot consumes 1 ammo
 fire(shootRemote,Vector3.new(0,0,-1))
 task.wait(0.15)
 check(p:GetAttribute("GunAmmo")==ammoBefore-1,"Valid shot consumes 1 ammo")

 -- Check 7: Rapid spam is rate-limited (Pistol cooldown is 0.28s)
 task.wait(.3)
 bridge:InvokeClient(p,"ShootBurst",Vector3.new(0,0,-1))
 task.wait(0.15)
 check(p:GetAttribute("GunAmmo")==ammoBefore-2,"Rapid burst rate-limited to single shot within cooldown")

 -- Check 8: Level 3 player cannot buy SMG (requires level 7)
 call("BuyWeapon","SMG")
 check(not m.Weapons.SMG and p.leaderstats.Coins.Value==8600,"SMG level gate (requires level 7)")

 -- Check 9: Level 7 player buys SMG (costs 4200)
 p.leaderstats.Level.Value=7
 call("BuyWeapon","SMG")
 check(m.Weapons.SMG==true and p.leaderstats.Coins.Value==4400 and m.EquippedWeapon=="SMG","SMG purchase and coin deduction")

 -- Check 10: Equip SMG initializes 24 magazine
 task.wait(0.1)
 check(p:GetAttribute("EquippedWeapon")=="SMG" and p:GetAttribute("GunAmmo")==24 and p:GetAttribute("GunMagazine")==24,"SMG equipped with 24 ammo")

 -- Check 11: Wall obstruction blocks raycast damage
 local wall=Instance.new("Part") wall.Name="QAWall" wall.Size=Vector3.new(10,10,1) wall.Position=head.Position+Vector3.new(0,0,-10) wall.Anchored=true wall.Parent=arena
 task.wait(0.15)
 local healthBefore=dummyHum.Health
 fire(shootRemote,Vector3.new(0,0,-1))
 task.wait(0.15)
 check(dummyHum.Health==healthBefore,"Wall obstruction blocks gunshot damage")
 wall.Transparency=1
 task.wait(.15)
 fire(shootRemote,Vector3.new(0,0,-1))
 task.wait(.15)
 check(dummyHum.Health==healthBefore,"Transparent solid wall still blocks damage")
 wall.CanCollide=false
 task.wait(.15)
 fire(shootRemote,Vector3.new(0,0,-1))
 task.wait(.15)
 check(dummyHum.Health==healthBefore-14,"Noncollidable trigger permits damage")
 healthBefore=dummyHum.Health
 wall:Destroy()

 -- Check 12: Clear line of fire deals damage (SMG does 14 damage)
 task.wait(0.15)
 fire(shootRemote,Vector3.new(0,0,-1))
 task.wait(0.15)
 check(dummyHum.Health==healthBefore-14 and dummyHum:GetAttribute("LastAttacker")==p.UserId,"Direct gunshot deals damage and credits attacker")

 -- Check 13: Melee punch remote rejected while firearm equipped
 healthBefore=dummyHum.Health
 fire(punchRemote,Vector3.new(0,0,-1))
 task.wait(0.15)
 check(dummyHum.Health==healthBefore,"Melee punch rejected while firearm is equipped")

 -- Check 14: Reload starts and sets reloading attribute
 fire(reloadRemote)
 task.wait(0.1)
 check(p:GetAttribute("GunReloading")==true and math.abs(p:GetAttribute("GunReloadDuration")-2.1)<0.05,"Reload starts with GunReloading=true and 2.1s duration")

 -- Check 15: Shooting blocked while reloading
 local ammoMidReload=p:GetAttribute("GunAmmo")
 fire(shootRemote,Vector3.new(0,0,-1))
 task.wait(0.1)
 check(p:GetAttribute("GunAmmo")==ammoMidReload,"Shooting blocked during reload")

 -- Check 16: Weapon switch cancels ongoing reload without grant
 call("EquipWeapon","Pistol")
 task.wait(0.1)
 check(p:GetAttribute("GunReloading")==false,"Switching weapon cancels ongoing reload")
 call("EquipWeapon","SMG")
 task.wait(0.1)

 -- Check 17: Full reload refills magazine
 fire(reloadRemote)
 task.wait(2.25)
 check(p:GetAttribute("GunReloading")==false and p:GetAttribute("GunAmmo")==24,"Full reload refilled SMG magazine to 24")

 -- Late-game revolver: purchase from anywhere, exact damage, cadence and reload cancellation.
 p.leaderstats.Coins.Value=10000 p.leaderstats.Level.Value=11
 call("BuyWeapon","Revolver")
 check(not m.Weapons.Revolver and p.leaderstats.Coins.Value==10000,"Revolver level 12 gate")
 p.leaderstats.Level.Value=12 p.leaderstats.Coins.Value=1000
 call("BuyWeapon","Revolver")
 check(not m.Weapons.Revolver and p.leaderstats.Coins.Value==1000,"Revolver insufficient funds refused")
 p.leaderstats.Coins.Value=10000
 call("BuyWeapon","Revolver")
 check(m.Weapons.Revolver and m.EquippedWeapon=="Revolver" and p.leaderstats.Coins.Value==3200,"Revolver purchase deducts exactly 6800")
 call("BuyWeapon","Revolver")
 check(p.leaderstats.Coins.Value==3200,"Duplicate revolver purchase does not charge")
 task.wait(.1)
 check(p:GetAttribute("GunAmmo")==6 and p:GetAttribute("GunMagazine")==6,"Revolver equipped with six chambers")
 local visual=p.Character:FindFirstChild("EquippedWeaponVisual")
 check(visual and visual:FindFirstChild("Cylinder") and visual:FindFirstChild("Hammer") and not visual:FindFirstChild("Magazine"),"Revolver distinct world model")
 healthBefore=dummyHum.Health
 fire(shootRemote,Vector3.new(0,0,-1)) task.wait(.15)
 check(dummyHum.Health==healthBefore-72 and p:GetAttribute("GunAmmo")==5,"Revolver deals 72 damage and consumes one round")
 task.wait(.75)
 bridge:InvokeClient(p,"ShootBurst",Vector3.new(0,0,-1)) task.wait(.15)
 check(p:GetAttribute("GunAmmo")==4,"Revolver spam limited to one shot")
 fire(reloadRemote) task.wait(.1)
 check(p:GetAttribute("GunReloading")==true and p:GetAttribute("GunReloadDuration")==2.6,"Revolver reload starts with 2.6 second duration")
 fire(shootRemote,Vector3.new(0,0,-1)) task.wait(.1)
 check(p:GetAttribute("GunAmmo")==4,"Revolver cannot shoot during reload")
 call("EquipWeapon","Pistol") task.wait(2.7)
 call("EquipWeapon","Revolver") task.wait(.1)
 check(not p:GetAttribute("GunReloading") and p:GetAttribute("GunAmmo")==4,"Cancelled revolver reload grants no ammunition")
 fire(reloadRemote) task.wait(2.75)
 check(not p:GetAttribute("GunReloading") and p:GetAttribute("GunAmmo")==6,"Revolver full reload refills six chambers")
 local motion=require(RS.WeaponMotion)
 local middle=motion.PartPose("Revolver","Cylinder",.5,4)
 check(middle.Position.Magnitude>.1 and motion.PartPose("Revolver","Cylinder",1,6)==CFrame.identity,"Cylinder opens mid reload and returns at completion")
 check(motion.Reload(.5,1,"Revolver")~=motion.Reload(.5,1,"Pistol"),"Revolver reload pose differs from pistol")
end)

-- Cleanup
arena:Destroy()
table.clear(m)
for k,v in Http:JSONDecode(originalMeta) do m[k]=v end
p.leaderstats.Coins.Value=savedStats.Coins
p.leaderstats.Level.Value=savedStats.Level
p.Progress.XP.Value=savedStats.XP
p:SetAttribute("HasStarted",savedStats.Started)
p:SetAttribute("InGameMenu",savedStats.Menu)
p:SetAttribute("EquippedWeapon",savedStats.Equipped)
p.Character:PivotTo(savedStats.CF)
E.Refresh(p) E.Send(p)

result.Value=Http:JSONEncode({Passed=ok,Checks=report,Error=not ok and tostring(err) or nil})
script:Destroy()
