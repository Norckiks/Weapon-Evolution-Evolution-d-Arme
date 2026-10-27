-- Temporary SessionStudio test. Lethal damage tests director callbacks, not weapon accuracy.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local SS,RS=game.ServerScriptService,game.ReplicatedStorage
local P=require(SS.ProgressionService) local E=require(SS.EconomyService) local Z=require(SS.ZoneService)
local W=require(RS.WorldConfig) local C=require(RS.GameplayConfig) local X=require(RS.Expeditions)
local SC=require(RS.SprintConfig) local CS=game:GetService("CollectionService")
local bridge=RS:WaitForChild("PowerQABridge",10) assert(bridge)
local zone for _,z in W.Zones do if z.Id=="Power" then zone=z end end assert(zone)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local c=p.Character local saved={CF=c:GetPivot(),Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),HP=c.Humanoid.Health}
local result=Instance.new("StringValue") result.Name="PowerQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={} local metrics={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function request(verb,id) task.wait(.17) bridge:InvokeClient(p,verb,id) task.wait(.18) end
local function live(id)
 local r={} for _,v in workspace.LiveZombies:GetChildren() do if v:GetAttribute("ZoneId")=="Power" and v:GetAttribute("ZombieType")==id and v.Humanoid.Health>0 then table.insert(r,v) end end return r
end
local function restore()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
 E.Refresh(p) c.Humanoid.Health=math.min(saved.HP,c.Humanoid.MaxHealth) c:PivotTo(saved.CF) E.Send(p) return true
end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 m.Pets={} m.Fragments={} m.EquippedPet="" m.XPBoostUntil=0 m.CoinBoostUntil=0 m.SpeedLevel=0 m.HealthLevel=10
 m.QuickContract={Index=3,Count=0,Seen={}} E.Refresh(p) c.Humanoid.Health=300
 check(#W.Zones>=5 and zone.Level==28,"Power remains available at level 28")
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={workspace.LiveZombies,c}
 for _,pos in {zone.Arrival,table.unpack(zone.Spawns)} do
  local hit=workspace:Raycast(pos+Vector3.new(0,40,0),Vector3.new(0,-55,0),params)
  check(hit and hit.Instance.CanCollide and hit.Position.Y<.4 and W.ZoneAt(pos)==zone,"Clear arrival/spawn ground: "..tostring(pos))
 end
 local distinguishing={Lineman="RepairRod",SparkRunner="DischargeFin",CoilGolem="CopperCoil"}
 for _,id in zone.Types do
  local t=game.ServerStorage.ZombieTemplates[id] local meshes,motors,anchored=0,0,0
  for _,v in t:GetDescendants() do if v:IsA("MeshPart") then meshes+=1 end if v:IsA("Motor6D") then motors+=1 end if v:IsA("BasePart") and v.Anchored then anchored+=1 end end
  check(meshes==6 and motors==6 and anchored==0 and t:FindFirstChild(distinguishing[id]),"Distinct complete rig: "..id)
  local a=live(id) check(#a==2 and a[1].Humanoid.MaxHealth==W.Zombies[id].Health and CS:HasTag(a[1],"Zombie"),"Two live configured spawns: "..id)
 end
 p.leaderstats.Level.Value=27 c:PivotTo(CFrame.new(0,5,220)) task.wait(.3)
 check(not Z.CanAccess(p,zone),"Level 27 access denied")
 c:PivotTo(CFrame.new(zone.Arrival)) task.wait(.5)
 check(W.ZoneAt(c.HumanoidRootPart.Position)~=zone,"Unauthorized direct entry returns to refuge")
 p.leaderstats.Level.Value=28 task.wait(.3)
 local guide=bridge:InvokeClient(p,"ReadGuide") check(guide and guide.Zone=="Power","Level 28 unlock points to Power portal")
 check(Z.CanAccess(p,zone),"Level 28 access granted")
 c:PivotTo(CFrame.new(zone.Arrival)) task.wait(.4)
 check(W.ZoneAt(c.HumanoidRootPart.Position)==zone,"Authorized player remains in Power")
 local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=3,AgentHeight=11,AgentCanJump=true})
 path:ComputeAsync(zone.Arrival,zone.Spawns[6]) check(path.Status==Enum.PathStatus.Success,"Large zombie route through central courtyard")
 local enemy=live("Lineman")[1] c:PivotTo(CFrame.new(enemy.HumanoidRootPart.Position+Vector3.new(0,0,19)))
 local before=(enemy.HumanoidRootPart.Position-c.HumanoidRootPart.Position).Magnitude task.wait(1.3)
 check((enemy.HumanoidRootPart.Position-c.HumanoidRootPart.Position).Magnitude<before-3,"Spawned zombie really chases player")
 c:PivotTo(CFrame.new(zone.Arrival)) p.leaderstats.Coins.Value=0 p.Progress.XP.Value=0
 local coins,xp=0,0 local killed={}
 for _,id in zone.Types do
  local target=live(id)[1] table.insert(killed,target)
  target.Humanoid:SetAttribute("LastAttacker",p.UserId) target.Humanoid:SetAttribute("LastHitAt",os.clock())
  target.Humanoid:TakeDamage(target.Humanoid.MaxHealth+1) task.wait(.15)
  coins+=W.Zombies[id].Coins xp+=W.Zombies[id].XP
  check(target:GetAttribute("Rewarded")==true,"Real director death callback: "..id)
 end
 local level,remainder=28,xp while remainder>=W.RequiredXP(level) do remainder-=W.RequiredXP(level) level+=1 end
 check(p.leaderstats.Coins.Value==coins and p.leaderstats.Level.Value==level and p.Progress.XP.Value==remainder,"Exact base rewards and XP rollover")
 metrics.Coins=coins metrics.XP=xp metrics.Level=level metrics.RemainderXP=remainder
 for _,v in killed do if v.Parent then v.Humanoid.Health=0 end end task.wait(.15)
 check(p.leaderstats.Coins.Value==coins,"Dead zombies cannot pay twice")
 for _,id in zone.Types do
  for _=1,60 do E.OnZombieKill(p,id) end
  check((m.Fragments[id] or 0)>0,"Observed fragments with new species ID: "..id)
  m.Pets[id]=nil m.Fragments[id]=2 request("Fuse",id) check(not m.Pets[id],"Two fragments refused: "..id)
  m.Fragments[id]=3 request("Fuse",id) check(m.Pets[id]==1 and m.Fragments[id]==0,"Three fragments fuse: "..id)
  request("EquipPet",id)
  check(m.EquippedPet==id and math.abs(p:GetAttribute("CoinsMultiplier")-(1+C.Pets[id].Coins))<.001 and math.abs(p:GetAttribute("XPMultiplier")-(1+C.Pets[id].XP))<.001 and math.abs(p:GetAttribute("BaseWalkSpeed")-SC.WalkSpeed*(1+C.Pets[id].Speed))<.001,"Coin/XP/speed pet bonuses: "..id)
 end
 m.Expeditions.Power.Claimed=0
 for step=1,3 do
  local before=p.leaderstats.Coins.Value local r=X.Reward("Power",step)
  request("ClaimExpedition","Power:"..step) check(m.Expeditions.Power.Claimed==step and p.leaderstats.Coins.Value==before+r.Coins,"Permanent Power dossier "..step)
  before=p.leaderstats.Coins.Value request("ClaimExpedition","Power:"..step) check(p.leaderstats.Coins.Value==before,"Duplicate dossier refused "..step)
 end
 local deadline=os.clock()+12
 repeat local count=0 for _,id in zone.Types do count+=#live(id) end if count==6 then break end task.wait(.2) until os.clock()>deadline
 for _,id in zone.Types do check(#live(id)==2,"Respawn restores two living "..id) end
 local copy=game.HttpService:JSONDecode(game.HttpService:JSONEncode(m))
 check(copy.Expeditions.Power.Claimed==3 and copy.Pets.CoilGolem==1,"JSON keeps Power dossiers and pets")
 check(C.MonetizationEnabled==false,"Robux disabled")
end)
restore() result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Metrics=metrics,Error=not ok and tostring(err) or nil,Restored=true})
local prep=Instance.new("BindableFunction") prep.Name="PreparePowerQA" prep.Parent=game.ServerStorage
prep.OnInvoke=function(mode)
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=28
 local pos=mode=="Return" and workspace.ProgressionZones.Power.Return_Power.Field.Position or workspace.ProgressionZones.RefugePortals.Travel_Power.Field.Position
 c:PivotTo(CFrame.lookAt(pos+Vector3.new(0,0,6),pos)) E.Refresh(p) E.Send(p) return true
end
local reset=Instance.new("BindableFunction") reset.Name="RestorePowerQA" reset.Parent=game.ServerStorage reset.OnInvoke=restore
