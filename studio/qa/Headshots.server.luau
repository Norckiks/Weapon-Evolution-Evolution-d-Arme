-- Temporary Play integration test, real Shoot client remotes, SessionStudio only.
assert(game:GetService("RunService"):IsStudio())
local RS=game.ReplicatedStorage local SS=game.ServerScriptService local Http=game.HttpService
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(SS.EconomyService) local P=require(SS.ProgressionService) local C=require(RS.GameplayConfig)
local bridge=RS:WaitForChild("FirearmsQABridge") local m=P.GetMeta(p)
local saved={Meta=Http:JSONEncode(m),Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,CF=p.Character:GetPivot(),Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Anchored=p.Character.HumanoidRootPart.Anchored}
local result=Instance.new("StringValue") result.Name="HeadshotsQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={} local arena=Instance.new("Folder") arena.Name="HeadshotsQA" arena.Parent=workspace local frozen={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function ready() local deadline=os.clock()+5 while p:GetAttribute("GunReloading") and os.clock()<deadline do task.wait(.05) end assert(not p:GetAttribute("GunReloading"),"Reload timeout") end
local function equip(id) task.wait(.18) E.Handle(p,"EquipWeapon",id) task.wait(.12) ready() end
local function fire(direction,forged)
 ready() task.wait(.96) bridge:InvokeClient(p,"Probe")
 bridge:InvokeClient(p,forged and "ForgedShoot" or "Shoot",direction) task.wait(.2)
 return bridge:InvokeClient(p,"Probe")
end
local function dummy(name,offset,size)
 local z=Instance.new("Model") z.Name="HeadshotFixture"
 local part=Instance.new("Part") part.Name=name part.Size=size part.Position=p.Character.Head.Position+offset part.Anchored=true part.CanCollide=false part.Parent=z
 local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=2000 h.Health=2000 h.Parent=z
 z.PrimaryPart=part game.CollectionService:AddTag(z,"Zombie") z.Parent=arena return z,h,part
end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=20 p.leaderstats.Coins.Value=100000 p.Progress.XP.Value=0
 m.Weapons={Fists=true,Pistol=true,SMG=true,Revolver=true,Shotgun=true} m.Pets={} m.EquippedPet="" m.XPBoostUntil=0 m.CoinBoostUntil=0 m.QuickContract={Index=3,Count=0,Seen={}}
 p.Character.HumanoidRootPart.Anchored=true p.Character:PivotTo(CFrame.new(0,1000,0)) E.Refresh(p) E.Send(p) task.wait(.2) equip("Pistol")
 local z,h=dummy("Torso",Vector3.new(0,0,-10),Vector3.new(4,4,1))
 local feedback=fire(Vector3.new(0,0,-1),true)
 check(h.Health==1976,"Forged critical flag and damage ignored; body stays 24")
 check(#feedback==1 and not feedback[1].Critical and feedback[1].Kind=="Body" and feedback[1].Amount==24,"One ordinary body feedback event") z:Destroy()
 z,h=dummy("Head",Vector3.new(0,0,-10),Vector3.new(4,4,1))
 local ammo=p:GetAttribute("GunAmmo") feedback=fire(Vector3.new(0,0,-1))
 check(h.Health==1964 and p:GetAttribute("GunAmmo")==ammo-1,"Legacy Head deals 36 and costs one round")
 check(#feedback==1 and feedback[1].Critical and feedback[1].Kind=="Headshot" and feedback[1].Amount==36,"Server sends one explicit headshot feedback") z:Destroy()
 z,h=dummy("Helmet",Vector3.new(0,0,-10),Vector3.new(4,4,1))
 fire(Vector3.new(0,0,-1)) check(h.Health==1976,"Accessory is not a canonical head") z:Destroy()
 for _,id in {"SMG","Revolver","Shotgun"} do
  equip(id) z,h=dummy("VisualHead",Vector3.new(0,0,-10),Vector3.new(4,4,1))
  local changes=0 h.HealthChanged:Connect(function() changes+=1 end)
  feedback=fire(Vector3.new(0,0,-1)) local expected=C.Weapons[id].Damage*(C.Weapons[id].Pellets or 1)*1.5
  check(h.Health==2000-expected,id.." exact critical damage "..expected)
  check(changes==1 and #feedback==1 and feedback[1].Amount==expected and feedback[1].Kind=="Headshot",id.." groups pellets into one damage/feedback") z:Destroy()
 end
 equip("Shotgun") z,h=dummy("Head",Vector3.new(0,0,-10),Vector3.new(.4,.4,1))
 local torso=Instance.new("Part") torso.Name="Torso" torso.Size=Vector3.new(4,2,1) torso.Position=z.Head.Position+Vector3.new(0,-1.2,0) torso.Anchored=true torso.CanCollide=false torso.Parent=z
 feedback=fire(Vector3.new(0,0,-1)) check(h.Health==1930 and #feedback==1 and feedback[1].Amount==70,"Mixed pellets: one head + two body = 70 grouped") z:Destroy()
 equip("Pistol") z,h=dummy("Head",Vector3.new(0,0,-10),Vector3.new(4,4,1))
 local wall=Instance.new("Part") wall.Size=Vector3.new(10,10,1) wall.Position=p.Character.Head.Position+Vector3.new(0,0,-5) wall.Transparency=1 wall.Anchored=true wall.Parent=arena
 feedback=fire(Vector3.new(0,0,-1)) check(h.Health==2000 and #feedback==0,"Transparent solid wall blocks critical and feedback") wall:Destroy() z:Destroy()
 z,h=dummy("Head",Vector3.new(0,0,-10),Vector3.new(4,4,1)) z:SetAttribute("ZoneId","City")
 feedback=fire(Vector3.new(0,0,-1)) check(h.Health==2000 and #feedback==0,"Wrong zone rejects headshot damage") z:Destroy()
 -- Use the real twelve upgraded meshes, not replacement boxes.
 equip("Pistol")
 local templateCount=0
 for _,template in game.ServerStorage.ZombieTemplates:GetChildren() do if template:IsA("Model") and template:FindFirstChild("VisualHead") then
  local clone=template:Clone() clone.Name="Mesh_"..template.Name clone:SetAttribute("ZoneId",nil)
  for _,part in clone:GetDescendants() do if part:IsA("BasePart") then part.Anchored=true end end
  local hum=clone:FindFirstChildOfClass("Humanoid") hum.MaxHealth=2000 hum.Health=2000
  clone:PivotTo(clone:GetPivot()+(p.Character.Head.Position+Vector3.new(0,0,-20)-clone.VisualHead.Position))
  game.CollectionService:AddTag(clone,"Zombie") clone.Parent=arena
  feedback=fire(Vector3.new(0,0,-1))
  check(hum.Health==1964 and #feedback==1 and feedback[1].Kind=="Headshot","Actual visual mesh head ray: "..template.Name)
  clone:Destroy() templateCount+=1
 end end
 check(templateCount==12,"All twelve visual-head templates exercised")
 -- A real director-owned death checks the reward path and headshot amount together.
 local target
 for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZoneId")=="City" and v.Humanoid.Health>0 then
  frozen[v.HumanoidRootPart]=v.HumanoidRootPart.Anchored v.HumanoidRootPart.Anchored=true
  if v:GetAttribute("ZombieType")=="Civilian" and not target then target=v end
 end end
 assert(target,"Real Civilian missing") p.Character.HumanoidRootPart.Anchored=false
 p.Character:PivotTo(CFrame.lookAt(target.HumanoidRootPart.Position+Vector3.new(0,0,10),target.HumanoidRootPart.Position)) task.wait(.4)
 local coins,xp=p.leaderstats.Coins.Value,p.Progress.XP.Value
 feedback=fire((target.VisualHead.Position-p.Character.Head.Position).Unit)
 check(target.Humanoid.Health==0 and target:GetAttribute("Rewarded"),"One headshot kills real 35 HP Civilian")
 check(p.leaderstats.Coins.Value==coins+8 and p.Progress.XP.Value==xp+20,"Headshot kill awards one normal 8 coins/20 XP reward")
 check(#feedback==1 and feedback[1].Amount==36 and feedback[1].Killed and feedback[1].Kind=="Headshot","Real death sends one 36-damage headshot confirmation")
end)
arena:Destroy() for root,anchored in frozen do if root.Parent then root.Anchored=anchored end end
table.clear(m) for k,v in Http:JSONDecode(saved.Meta) do m[k]=v end
p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) p.Character:PivotTo(saved.CF) p.Character.HumanoidRootPart.Anchored=saved.Anchored E.Refresh(p) E.Send(p)
result.Value=Http:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil}) script:Destroy()
