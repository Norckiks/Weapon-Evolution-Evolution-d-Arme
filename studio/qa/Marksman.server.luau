-- Temporary SessionStudio test; requires FirearmsQABridge and FirearmsBridge.client.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService) local P=require(game.ServerScriptService.ProgressionService)
local C=require(game.ReplicatedStorage.GameplayConfig) local Motion=require(game.ReplicatedStorage.WeaponMotion)
local bridge=game.ReplicatedStorage:WaitForChild("FirearmsQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local c=p.Character local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),CF=c:GetPivot(),Anchored=c.HumanoidRootPart.Anchored}
local arena=Instance.new("Folder") arena.Name="MarksmanQA" arena.Parent=workspace
local result=Instance.new("StringValue") result.Name="MarksmanQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function call(verb,id) task.wait(.2) E.Handle(p,verb,id) task.wait(.1) end
local function fire(verb,direction) bridge:InvokeClient(p,verb,direction) task.wait(.17) end
local function shot() task.wait(1.1) fire("Shoot",Vector3.new(0,0,-1)) end
local function restore()
 arena:Destroy() table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
 c:PivotTo(saved.CF) c.HumanoidRootPart.Anchored=saved.Anchored E.Refresh(p) E.Send(p) return true
end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) c.HumanoidRootPart.Anchored=true c:PivotTo(CFrame.new(0,1000,0))
 m.Weapons={Fists=true} m.EquippedWeapon="Fists" p.leaderstats.Level.Value=27 p.leaderstats.Coins.Value=40000 E.Refresh(p)
 call("BuyWeapon","Marksman") check(not m.Weapons.Marksman and p.leaderstats.Coins.Value==40000,"Level 27 purchase refused")
 call("EquipWeapon","Marksman") check(m.EquippedWeapon=="Fists","Unowned equip refused")
 p.leaderstats.Level.Value=28 p.leaderstats.Coins.Value=100 call("BuyWeapon","Marksman")
 check(not m.Weapons.Marksman and p.leaderstats.Coins.Value==100,"Insufficient coins refused")
 p.leaderstats.Coins.Value=33000 call("BuyWeapon","Marksman")
 check(m.Weapons.Marksman and m.EquippedWeapon=="Marksman" and p.leaderstats.Coins.Value==1000,"Level 28 purchase costs exactly 32000")
 call("BuyWeapon","Marksman") check(p.leaderstats.Coins.Value==1000,"Duplicate purchase cannot charge twice")
 check(p:GetAttribute("GunAmmo")==6 and p:GetAttribute("GunMagazine")==6,"Six-round magazine")
 local model=c.EquippedWeaponVisual local motors,parts,safe=0,0,true
 for _,v in model:GetDescendants() do
  if v:IsA("Motor6D") and v.Name=="WeaponMechanism" then motors+=1 end
  if v:IsA("BasePart") then parts+=1 safe=safe and v.Massless and not v.Anchored and not v.CanCollide and not v.CanQuery end
 end
 check(model:FindFirstChild("LongBarrel") and model:FindFirstChild("DiopterTop") and model:FindFirstChild("BipodLeg") and parts>=30,"Distinct long rifle model")
 check(motors==4 and safe,"Four animated mechanisms without mass/collisions")
 local target=Instance.new("Model") target.Name="MarksmanTarget"
 local part=Instance.new("Part") part.Name="Torso" part.Size=Vector3.new(5,5,1) part.Anchored=true part.CanCollide=false part.Position=c.Head.Position+Vector3.new(0,0,-240) part.Parent=target
 local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=1000 h.Health=1000 h.Parent=target target.PrimaryPart=part target.Parent=arena game.CollectionService:AddTag(target,"Zombie")
 shot() check(h.Health==860 and p:GetAttribute("GunAmmo")==5,"Real body shot at 240 studs deals 140")
 task.wait(1.1) fire("ShootBurst",Vector3.new(0,0,-1))
 check(h.Health==720 and p:GetAttribute("GunAmmo")==4,"Five simultaneous requests consume one round")
 part.Name="Head" shot() check(h.Health==510,"Headshot deals 210")
 part.Position=c.Head.Position+Vector3.new(0,0,-270) shot() check(h.Health==510,"Beyond 260 studs no damage")
 part.Position=c.Head.Position+Vector3.new(0,0,-50)
 local wall=Instance.new("Part") wall.Anchored=true wall.Size=Vector3.new(8,8,1) wall.Position=c.Head.Position+Vector3.new(0,0,-25) wall.Parent=arena
 shot() check(h.Health==510,"Wall blocks damage") wall:Destroy()
 local ammo=p:GetAttribute("GunAmmo") task.wait(1.1) fire("Shoot",Vector3.zero) fire("Shoot","bad")
 check(p:GetAttribute("GunAmmo")==ammo and h.Health==510,"Invalid aim cannot spend ammo or damage")
 fire("ReloadGun") check(p:GetAttribute("GunReloading") and p:GetAttribute("GunReloadDuration")==3.1,"Server starts 3.1-second reload")
 fire("Shoot",Vector3.new(0,0,-1)) check(p:GetAttribute("GunAmmo")==ammo,"Cannot fire during reload")
 task.wait(3.2) check(p:GetAttribute("GunAmmo")==6 and not p:GetAttribute("GunReloading"),"Reload refills six rounds")
 shot() fire("ReloadGun") call("EquipWeapon","Fists") task.wait(3.2) call("EquipWeapon","Marksman")
 check(p:GetAttribute("GunAmmo")==5 and not p:GetAttribute("GunReloading"),"Switching cancels reload without free ammo")
 check(Motion.Reload(.5,1,"Marksman")~=Motion.Reload(.5,1,"Carbine"),"Dedicated reload pose")
 check(Motion.PartPose("Marksman","BoltHandle",nil,6,.45).Position.Z>.33,"Long delayed bolt stroke after shot")
 check(Motion.PartPose("Marksman","Magazine",.465,6,1).Position.Y<-.73,"Magazine insertion drop")
 check(Motion.PartPose("Marksman","DiopterTop",.5,6,.45)==CFrame.identity,"Non-mechanism parts remain rigid")
 local finite=true for _,name in {"Magazine","MagazineBase","BoltHandle","BoltStem"} do for i=0,30 do
  for _,v in {Motion.PartPose("Marksman",name,i/30,6,i/30):GetComponents()} do finite=finite and v==v and math.abs(v)<math.huge end
 end end check(finite,"All reload/bolt samples finite")
 check(Motion.PartPose("Marksman","BoltHandle",nil,6,1.1).Position.Magnitude<1e-6 and Motion.Reload(1,1,"Marksman")==CFrame.identity,"Motion settles after shot and reload")
 local profile=Motion.Get("Marksman") check(math.abs(profile.Windup+profile.Strike+profile.Recover-1.05)<1e-6,"Shot timeline matches weapon cadence")
 check(Motion.PartPose("Carbine","BoltHandle",nil,18,.065).Position.Z>.17 and not Motion.IsMechanism("Pistol","Magazine"),"Existing mechanism rules preserved")
 check(C.NextWeapon({Carbine=true})=="Marksman" and C.NextWeapon({Marksman=true})=="LMG" and C.NextWeapon({LMG=true})==nil,"Arsenal progression reaches new final tier")
 check(C.Weapons.Carbine.Damage==38 and C.Weapons.Shotgun.Pellets==7 and not C.MonetizationEnabled,"Old gun rules and disabled Robux preserved")
end)
restore() result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil,Restored=true})
local prep=Instance.new("BindableFunction") prep.Name="PrepareMarksmanUI" prep.Parent=game.ServerStorage
prep.OnInvoke=function(level)
 assert(level==27 or level==28) m.Weapons.Carbine=true m.Weapons.Marksman=nil m.EquippedWeapon="Carbine"
 p.leaderstats.Level.Value=level p.leaderstats.Coins.Value=40000 p:SetAttribute("HasStarted",true) E.Refresh(p) E.Send(p,nil,"Weapons") return true
end
local reset=Instance.new("BindableFunction") reset.Name="RestoreMarksmanQA" reset.Parent=game.ServerStorage reset.OnInvoke=function()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) E.Refresh(p) E.Send(p) return true
end
