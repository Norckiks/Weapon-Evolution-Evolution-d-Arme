-- Temporary SessionStudio regression; requires FirearmsQABridge and its client.
assert(game:GetService("RunService"):IsStudio())
local RS=game.ReplicatedStorage local p=game.Players:GetPlayers()[1]
assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService) local P=require(game.ServerScriptService.ProgressionService)
local C=require(RS.GameplayConfig) local Motion=require(RS.WeaponMotion)
local bridge=RS:WaitForChild("FirearmsQABridge") local m=P.GetMeta(p)
local saved=game.HttpService:JSONEncode(m)
local stats={Level=p.leaderstats.Level.Value,Coins=p.leaderstats.Coins.Value,XP=p.Progress.XP.Value,CF=p.Character:GetPivot(),Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Anchored=p.Character.HumanoidRootPart.Anchored}
local arena=Instance.new("Folder") arena.Name="CarbineQA" arena.Parent=workspace
local r=Instance.new("StringValue") r.Name="CarbineQAResult" r.Value="Running" r.Parent=game.ServerStorage
local checks={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function call(verb,id) task.wait(.2) E.Handle(p,verb,id) task.wait(.1) end
local function fire(verb,dir) bridge:InvokeClient(p,verb,dir) task.wait(.16) end
local function shot() task.wait(.25) fire("Shoot",Vector3.new(0,0,-1)) end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 p.Character.HumanoidRootPart.Anchored=true p.Character:PivotTo(CFrame.new(0,1000,0))
 m.Weapons={Fists=true} m.EquippedWeapon="Fists" p.leaderstats.Level.Value=21 p.leaderstats.Coins.Value=20000 E.Refresh(p)
 call("BuyWeapon","Carbine") check(not m.Weapons.Carbine and p.leaderstats.Coins.Value==20000,"Level 21 cannot buy carbine")
 call("EquipWeapon","Carbine") check(m.EquippedWeapon=="Fists","Unowned equip rejected")
 p.leaderstats.Level.Value=22 p.leaderstats.Coins.Value=100 call("BuyWeapon","Carbine")
 check(not m.Weapons.Carbine and p.leaderstats.Coins.Value==100,"Insufficient coins rejected")
 p.leaderstats.Coins.Value=20000 call("BuyWeapon","Carbine")
 check(m.Weapons.Carbine and m.EquippedWeapon=="Carbine" and p.leaderstats.Coins.Value==2000,"Remote UI purchase costs 18000 at level 22")
 call("BuyWeapon","Carbine") check(p.leaderstats.Coins.Value==2000,"Owned carbine cannot charge twice")
 check(p:GetAttribute("GunAmmo")==18 and p:GetAttribute("GunMagazine")==18,"Eighteen-round magazine")
 local visual=p.Character.EquippedWeaponVisual
 check(visual:FindFirstChild("Handguard") and visual:FindFirstChild("SightLens") and visual:FindFirstChild("Foregrip"),"Distinct carbine model")
 local motors=0 local safe=true
 for _,v in visual:GetDescendants() do
  if v:IsA("Motor6D") and v.Name=="WeaponMechanism" then motors+=1 end
  if v:IsA("BasePart") then safe=safe and v.Massless and not v.Anchored and not v.CanCollide and not v.CanQuery end
 end
 check(safe and motors==3,"Three animated mechanisms without mass or collisions")
 local d=Instance.new("Model") d.Name="CarbineTarget"
 local part=Instance.new("Part") part.Name="Torso" part.Size=Vector3.new(5,5,1) part.Anchored=true part.CanCollide=false part.Position=p.Character.Head.Position+Vector3.new(0,0,-160) part.Parent=d
 local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=1000 h.Health=1000 h.Parent=d d.PrimaryPart=part d.Parent=arena game.CollectionService:AddTag(d,"Zombie")
 shot() check(h.Health==962 and p:GetAttribute("GunAmmo")==17,"Real body shot at 160 studs deals 38")
 task.wait(.25) fire("ShootBurst",Vector3.new(0,0,-1))
 check(h.Health==924 and p:GetAttribute("GunAmmo")==16,"Five simultaneous requests consume one round")
 part.Name="Head" shot() check(h.Health==867,"Headshot deals 57")
 part.Position=p.Character.Head.Position+Vector3.new(0,0,-180) shot() check(h.Health==867,"Target beyond 175 studs is safe")
 part.Position=p.Character.Head.Position+Vector3.new(0,0,-50)
 local wall=Instance.new("Part") wall.Anchored=true wall.Size=Vector3.new(8,8,1) wall.Position=p.Character.Head.Position+Vector3.new(0,0,-25) wall.Parent=arena
 shot() check(h.Health==867,"Wall blocks carbine damage") wall:Destroy()
 local ammo=p:GetAttribute("GunAmmo") task.wait(.25) fire("Shoot",Vector3.zero) fire("Shoot","bad")
 check(p:GetAttribute("GunAmmo")==ammo and h.Health==867,"Invalid aim cannot spend ammunition or damage")
 fire("ReloadGun") check(p:GetAttribute("GunReloading") and p:GetAttribute("GunReloadDuration")==2.4,"Server starts 2.4-second reload")
 fire("Shoot",Vector3.new(0,0,-1)) check(p:GetAttribute("GunAmmo")==ammo,"Cannot fire during reload")
 task.wait(2.5) check(p:GetAttribute("GunAmmo")==18 and not p:GetAttribute("GunReloading"),"Reload refills eighteen rounds")
 shot() fire("ReloadGun") call("EquipWeapon","Fists") task.wait(2.5) call("EquipWeapon","Carbine")
 check(p:GetAttribute("GunAmmo")==17 and not p:GetAttribute("GunReloading"),"Switching cancels reload without free rounds")
 check(Motion.Reload(.5,1,"Carbine")~=Motion.Reload(.5,1,"Pistol"),"Dedicated reload pose")
 check(Motion.PartPose("Carbine","Magazine",.46,18,1).Position.Y<-.6,"Magazine drops during insertion sequence")
 check(Motion.PartPose("Carbine","BoltHandle",.89,18,1).Position.Z>.17,"Charging handle pulls at reload end")
 local finite=true
 for _,name in {"Magazine","MagazineBase","BoltHandle"} do for i=0,20 do
  for _,value in {Motion.PartPose("Carbine",name,i/20,18,i/60):GetComponents()} do finite=finite and value==value and math.abs(value)<math.huge end
 end end
 check(finite,"All new mechanism samples finite")
 check(C.NextWeapon({Fists=true})=="Pipe","First progression goal is the pipe")
 check(C.NextWeapon({Fists=true,LimitedBlade=true})=="Pipe","Premium item does not skip normal progression")
 check(C.NextWeapon({Shotgun=true})=="Carbine","Shotgun ownership leads to carbine goal")
 check(C.NextWeapon({Carbine=true})=="Marksman","Carbine now leads to marksman progression")
 check(C.NextWeapon({Marksman=true})=="LMG" and C.NextWeapon({LMG=true})==nil,"Marksman now leads to final LMG tier")
 check(C.Weapons.Pistol.Damage==24 and C.Weapons.Shotgun.Pellets==7 and C.MonetizationEnabled==false,"Existing gun rules and disabled payments preserved")
end)
arena:Destroy() table.clear(m) for k,v in game.HttpService:JSONDecode(saved) do m[k]=v end
p.leaderstats.Level.Value=stats.Level p.leaderstats.Coins.Value=stats.Coins p.Progress.XP.Value=stats.XP
p:SetAttribute("HasStarted",stats.Started) p:SetAttribute("InGameMenu",stats.Menu)
p.Character:PivotTo(stats.CF) p.Character.HumanoidRootPart.Anchored=stats.Anchored E.Refresh(p) E.Send(p)
r.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks}) script:Destroy()
