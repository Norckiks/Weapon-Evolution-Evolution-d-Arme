-- Temporary SessionStudio regression; requires FirearmsQABridge and its client.
assert(game:GetService("RunService"):IsStudio())
local RS=game.ReplicatedStorage local p=game.Players:GetPlayers()[1]
assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService) local P=require(game.ServerScriptService.ProgressionService)
local C=require(RS.GameplayConfig) local Motion=require(RS.WeaponMotion)
local bridge=RS:WaitForChild("FirearmsQABridge") local m=P.GetMeta(p)
local saved=game.HttpService:JSONEncode(m)
local stats={Level=p.leaderstats.Level.Value,Coins=p.leaderstats.Coins.Value,XP=p.Progress.XP.Value,CF=p.Character:GetPivot(),Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Anchored=p.Character.HumanoidRootPart.Anchored}
local arena=Instance.new("Folder") arena.Name="LMGQA" arena.Parent=workspace
local r=Instance.new("StringValue") r.Name="LMGQAResult" r.Value="Running" r.Parent=game.ServerStorage
local checks={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function call(verb,id) task.wait(.2) E.Handle(p,verb,id) task.wait(.1) end
local function fire(verb,dir) bridge:InvokeClient(p,verb,dir) task.wait(.16) end
local function shot() task.wait(.25) fire("Shoot",Vector3.new(0,0,-1)) end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 p.Character.HumanoidRootPart.Anchored=true p.Character:PivotTo(CFrame.new(0,1000,0))
 m.Weapons={Fists=true} m.EquippedWeapon="Fists" p.leaderstats.Level.Value=34 p.leaderstats.Coins.Value=56000 E.Refresh(p)
 call("BuyWeapon","LMG") check(not m.Weapons.LMG and p.leaderstats.Coins.Value==56000,"Level 34 cannot buy mitrailleuse")
 call("EquipWeapon","LMG") check(m.EquippedWeapon=="Fists","Unowned equip rejected")
 p.leaderstats.Level.Value=35 p.leaderstats.Coins.Value=100 call("BuyWeapon","LMG")
 check(not m.Weapons.LMG and p.leaderstats.Coins.Value==100,"Insufficient coins rejected")
 p.leaderstats.Coins.Value=56000 call("BuyWeapon","LMG")
 check(m.Weapons.LMG and m.EquippedWeapon=="LMG" and p.leaderstats.Coins.Value==2000,"Remote UI purchase costs 54000 at level 35")
 call("BuyWeapon","LMG") check(p.leaderstats.Coins.Value==2000,"Owned mitrailleuse cannot charge twice")
 check(p:GetAttribute("GunAmmo")==48 and p:GetAttribute("GunMagazine")==48,"Forty-eight-round magazine")
 local visual=p.Character.EquippedWeaponVisual
 check(visual:FindFirstChild("HeavyHandguard") and visual:FindFirstChild("RearSight") and visual:FindFirstChild("CarryHandleTop"),"Distinct mitrailleuse model")
 local motors=0 local safe=true
 for _,v in visual:GetDescendants() do
  if v:IsA("Motor6D") and v.Name=="WeaponMechanism" then motors+=1 end
  if v:IsA("BasePart") then safe=safe and v.Massless and not v.Anchored and not v.CanCollide and not v.CanQuery end
 end
 check(safe and motors==4,"Four animated mechanisms without mass or collisions")
 local d=Instance.new("Model") d.Name="LMGTarget"
 local part=Instance.new("Part") part.Name="Torso" part.Size=Vector3.new(5,5,1) part.Anchored=true part.CanCollide=false part.Position=p.Character.Head.Position+Vector3.new(0,0,-140) part.Parent=d
 local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=1000 h.Health=1000 h.Parent=d d.PrimaryPart=part d.Parent=arena game.CollectionService:AddTag(d,"Zombie")
 shot() check(h.Health==972 and p:GetAttribute("GunAmmo")==47,"Real body shot at 140 studs deals 28")
 task.wait(.25) fire("ShootBurst",Vector3.new(0,0,-1))
 check(h.Health==944 and p:GetAttribute("GunAmmo")==46,"Five simultaneous requests consume one round")
 part.Name="Head" shot() check(h.Health==902,"Headshot deals 42")
 part.Position=p.Character.Head.Position+Vector3.new(0,0,-170) shot() check(h.Health==902,"Target beyond 160 studs is safe")
 part.Position=p.Character.Head.Position+Vector3.new(0,0,-50)
 local wall=Instance.new("Part") wall.Anchored=true wall.Size=Vector3.new(8,8,1) wall.Position=p.Character.Head.Position+Vector3.new(0,0,-25) wall.Parent=arena
 shot() check(h.Health==902,"Wall blocks mitrailleuse damage") wall:Destroy()
 local ammo=p:GetAttribute("GunAmmo") task.wait(.25) fire("Shoot",Vector3.zero) fire("Shoot","bad")
 check(p:GetAttribute("GunAmmo")==ammo and h.Health==902,"Invalid aim cannot spend ammunition or damage")
 local beforeBurst,ammoBefore=h.Health,p:GetAttribute("GunAmmo")
 for _=1,8 do task.wait(.13) fire("Shoot",Vector3.new(0,0,-1)) end
 check(h.Health==beforeBurst-8*42 and p:GetAttribute("GunAmmo")==ammoBefore-8,"Eight sustained real requests respect head damage and ammo")
 ammo=p:GetAttribute("GunAmmo")
 fire("ReloadGun") check(p:GetAttribute("GunReloading") and p:GetAttribute("GunReloadDuration")==3.8,"Server starts 3.8-second reload")
 fire("Shoot",Vector3.new(0,0,-1)) check(p:GetAttribute("GunAmmo")==ammo,"Cannot fire during reload")
 task.wait(3.9) check(p:GetAttribute("GunAmmo")==48 and not p:GetAttribute("GunReloading"),"Reload refills forty-eight rounds")
 shot() fire("ReloadGun") call("EquipWeapon","Fists") task.wait(3.9) call("EquipWeapon","LMG")
 check(p:GetAttribute("GunAmmo")==47 and not p:GetAttribute("GunReloading"),"Switching cancels reload without free rounds")
 check(Motion.Reload(.5,1,"LMG")~=Motion.Reload(.5,1,"Pistol"),"Dedicated reload pose")
 check(Motion.PartPose("LMG","Magazine",.465,48,1).Position.Y<-.8,"Magazine drops during insertion sequence")
 check(Motion.PartPose("LMG","BoltHandle",.89,48,1).Position.Z>.15,"Charging handle pulls at reload end")
 local finite=true
 for _,name in {"Magazine","MagazineBase","BoltHandle","FeedCover"} do for i=0,20 do
  for _,value in {Motion.PartPose("LMG",name,i/20,48,i/60):GetComponents()} do finite=finite and value==value and math.abs(value)<math.huge end
 end end
 check(finite,"All new mechanism samples finite")
 check(C.NextWeapon({Fists=true})=="Pipe","First progression goal remains pipe")
 check(C.NextWeapon({LimitedBlade=true,Fists=true})=="Pipe","Premium does not skip progression")
 check(C.NextWeapon({Carbine=true})=="Marksman","Carbine still leads to marksman")
 check(C.NextWeapon({Marksman=true})=="LMG" and C.NextWeapon({LMG=true})==nil,"LMG is the new last normal tier")
 check(Motion.PartPose("LMG","FeedCover",.49,48,1):ToAxisAngle()~=nil,"Feed cover has dedicated hinge pose")
 local _,coverAngle=Motion.PartPose("LMG","FeedCover",.49,48,1):ToAxisAngle()
 check(math.abs(coverAngle)>1.09 and Motion.PartPose("LMG","FeedCover",1,48,1).Position.Magnitude<1e-6,"Feed cover opens and closes around hinge")
 check(Motion.PartPose("Carbine","BoltHandle",nil,18,.065).Position.Z>.17 and C.Weapons.Marksman.Damage==140 and C.MonetizationEnabled==false,"Old weapons and disabled payments preserved")
end)
arena:Destroy() table.clear(m) for k,v in game.HttpService:JSONDecode(saved) do m[k]=v end
p.leaderstats.Level.Value=stats.Level p.leaderstats.Coins.Value=stats.Coins p.Progress.XP.Value=stats.XP
p:SetAttribute("HasStarted",stats.Started) p:SetAttribute("InGameMenu",stats.Menu)
p.Character:PivotTo(stats.CF) p.Character.HumanoidRootPart.Anchored=stats.Anchored E.Refresh(p) E.Send(p)
r.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks}) script:Destroy()
