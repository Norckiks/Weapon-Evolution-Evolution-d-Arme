-- Temporary server Play test. Synthetic lethal damage tests the real director's reward callback.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local SS=game.ServerScriptService local RS=game.ReplicatedStorage local Http=game.HttpService
local P=require(SS.ProgressionService) local E=require(SS.EconomyService) local Z=require(SS.ZoneService)
local W=require(RS.WorldConfig) local C=require(RS.GameplayConfig) local CS=game:GetService("CollectionService")
local zone for _,z in W.Zones do if z.Id=="Harbor" then zone=z end end assert(zone)
local m=P.GetMeta(p) local original=Http:JSONEncode(m)
local c=p.Character local saved={CF=c:GetPivot(),Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Health=c.Humanoid.Health}
local result=Instance.new("StringValue") result.Name="HarborQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={} local metrics={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function call(verb,id) task.wait(.17) E.Handle(p,verb,id) end
local function live(id)
 local list={} for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZoneId")=="Harbor" and v:GetAttribute("ZombieType")==id and v.Humanoid.Health>0 then table.insert(list,v) end end return list
end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 m.Pets={} m.Fragments={} m.EquippedPet="" m.XPBoostUntil=0 m.CoinBoostUntil=0 m.SpeedLevel=0
 m.QuickContract={Index=3,Count=0,Seen={}} E.Refresh(p)
 check(#W.Zones>=4 and zone.Level==20,"Harbor still configured and requires level 20")
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={workspace.LiveZombies,c}
 for _,pos in {zone.Arrival,table.unpack(zone.Spawns)} do
  local hit=workspace:Raycast(pos+Vector3.new(0,40,0),Vector3.new(0,-55,0),params)
  check(hit and hit.Instance.CanCollide and hit.Position.Y<1 and W.ZoneAt(pos)==zone,"Clear arrival/spawn ground: "..tostring(pos))
 end
 local distinguishing={Drowned="LifeVest",Raider="HarpoonShaft",AnchorTitan="AnchorStem"}
 for _,id in zone.Types do
  local template=game.ServerStorage.ZombieTemplates[id] local meshes,motors,anchored=0,0,0
  for _,v in template:GetDescendants() do if v:IsA("MeshPart") then meshes+=1 end if v:IsA("Motor6D") then motors+=1 end if v:IsA("BasePart") and v.Anchored then anchored+=1 end end
  check(meshes==6 and motors==6 and anchored==0 and template:FindFirstChild(distinguishing[id]),"Distinct complete moving rig: "..id)
  local list=live(id) check(#list==2 and list[1].Humanoid.MaxHealth==W.Zombies[id].Health and CS:HasTag(list[1],"Zombie"),"Two live configured spawns: "..id)
 end
 p.leaderstats.Level.Value=19 check(not Z.CanAccess(p,zone),"Level 19 access denied")
 c:PivotTo(CFrame.new(zone.Arrival)) task.wait(.6)
 check(W.ZoneAt(c.HumanoidRootPart.Position)~=zone,"Unauthorized direct entry returned to refuge")
 p.leaderstats.Level.Value=20 check(Z.CanAccess(p,zone),"Level 20 access granted")
 c:PivotTo(CFrame.new(zone.Arrival)) task.wait(.5)
 check(W.ZoneAt(c.HumanoidRootPart.Position)==zone,"Authorized character remains in Harbor")
 p.leaderstats.Coins.Value=0 p.Progress.XP.Value=0
 local totalCoins,totalXP=0,0 local killed={}
 for _,id in zone.Types do
  local target=live(id)[1] table.insert(killed,target)
  target.Humanoid:SetAttribute("LastAttacker",p.UserId) target.Humanoid:SetAttribute("LastHitAt",os.clock())
  target.Humanoid:TakeDamage(target.Humanoid.MaxHealth+1) task.wait(.15)
  totalCoins+=W.Zombies[id].Coins totalXP+=W.Zombies[id].XP
  check(target:GetAttribute("Rewarded")==true,"Director rewarded real spawned death: "..id)
 end
 local expectedLevel,expectedXP=20,totalXP
 while expectedXP>=W.RequiredXP(expectedLevel) do expectedXP-=W.RequiredXP(expectedLevel) expectedLevel+=1 end
 check(p.leaderstats.Coins.Value==totalCoins and p.leaderstats.Level.Value==expectedLevel and p.Progress.XP.Value==expectedXP,"Exact Harbor rewards and XP level rollover")
 metrics.Coins=totalCoins metrics.XP=totalXP metrics.Level=expectedLevel metrics.RemainderXP=expectedXP
 local before=p.leaderstats.Coins.Value for _,v in killed do if v.Parent then v.Humanoid.Health=0 end end task.wait(.15)
 check(p.leaderstats.Coins.Value==before,"Dead zombies cannot reward twice")
 for _,id in zone.Types do
  for _=1,45 do E.OnZombieKill(p,id) end
  check((m.Fragments[id] or 0)>0,"Fragment drops use new species id: "..id)
  m.Pets[id]=nil m.Fragments[id]=2 call("Fuse",id)
  check(not m.Pets[id] and m.Fragments[id]==2,"Two fragments refused: "..id)
  m.Fragments[id]=3 call("Fuse",id)
  check(m.Pets[id]==1 and m.Fragments[id]==0,"Three fragments fuse: "..id)
  call("EquipPet",id)
  check(m.EquippedPet==id and math.abs(p:GetAttribute("CoinsMultiplier")-(1+C.Pets[id].Coins))<.001 and math.abs(p:GetAttribute("XPMultiplier")-(1+C.Pets[id].XP))<.001 and math.abs(p:GetAttribute("BaseWalkSpeed")-require(RS.SprintConfig).WalkSpeed*(1+C.Pets[id].Speed))<.001,"Pet coin/XP/speed bonuses: "..id)
 end
 local deadline=os.clock()+12
 while os.clock()<deadline do local n=0 for _,id in zone.Types do n+=#live(id) end if n==6 then break end task.wait(.2) end
 for _,id in zone.Types do check(#live(id)==2,"Respawn restores two living "..id) end
end)
table.clear(m) for k,v in Http:JSONDecode(original) do m[k]=v end
p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
E.Refresh(p) c.Humanoid.Health=math.min(saved.Health,c.Humanoid.MaxHealth) c:PivotTo(saved.CF) E.Send(p)
result.Value=Http:JSONEncode({Passed=ok,Checks=checks,Metrics=metrics,Error=not ok and tostring(err) or nil})
script:Destroy()
