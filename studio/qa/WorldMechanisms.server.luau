-- Temporary Play fixture. Set WorldMechanismsQABridge.Run only after the client is ready.
assert(game:GetService("RunService"):IsStudio())
local RS=game.ReplicatedStorage local p=game.Players:GetPlayers()[1]
assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local Motion=require(RS.WeaponMotion) local Visuals=require(RS.WeaponVisuals)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={CF=p.Character:GetPivot(),Level=p.leaderstats.Level.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local bridge=Instance.new("RemoteFunction") bridge.Name="WorldMechanismsQABridge" bridge.Parent=RS
local result=Instance.new("StringValue") result.Name="WorldMechanismsQAResult" result.Value="Waiting for client" result.Parent=game.ServerStorage
local checks={} local samples={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function equip(id)
 m.Weapons[id]=true m.EquippedWeapon=id E.Refresh(p) E.Send(p) task.wait(.25)
 return p.Character:FindFirstChild("EquippedWeaponVisual")
end
local function sample(key,verb,duration)
 local s=bridge:InvokeClient(p,verb,duration) samples[key]=s return s
end
while not bridge:GetAttribute("Run") do bridge:GetAttributeChangedSignal("Run"):Wait() end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p.leaderstats.Level.Value=20
 p.Character:PivotTo(CFrame.new(0,65,900))
 local floor=Instance.new("Part") floor.Name="WorldMechanismsQAFloor" floor.Size=Vector3.new(100,1,100) floor.Position=Vector3.new(0,59.5,900) floor.Anchored=true floor.Parent=workspace
 for _,id in {"Pistol","SMG","Revolver","Shotgun","Pipe"} do
  local model=select(1,Visuals.Build(id)) local wanted=0
  for _,v in model:GetChildren() do if Motion.IsMechanism(id,v.Name) then wanted+=1 end end model:Destroy()
  local visual=equip(id) local count=0
  for _,v in visual:GetDescendants() do
   if v:IsA("Motor6D") and v.Name=="WeaponMechanism" then
    count+=1 check(v.Part0~=nil and v.Part1~=nil and not v.Part1.Anchored and v.Part1.Massless,"Mechanism is attached and massless: "..id.."/"..v.Part1.Name)
   end
  end
  check(count==wanted,"Only moving pieces have motors: "..id)
 end
 equip("Revolver")
 local s=sample("revolverRest","Sample",.2) check(s.Count==14 and s.MaxPosition<.001 and s.MaxAngle<.001,"Revolver rests with closed cylinder")
 s=sample("revolverShot","Shoot",.25)
 check(p:GetAttribute("GunAmmo")==5 and s.MaxAngle>.9,"Real revolver shot indexes world cylinder")
 s=sample("revolverReload","Reload",1.5)
 check(p:GetAttribute("GunReloading")==true and s.MaxPosition>.15 and s.MaxAngle>.2,"Real reload opens and turns world cylinder")
 task.wait(1.5) s=sample("revolverClosed","Sample",.2)
 check(p:GetAttribute("GunAmmo")==6 and s.LastPosition<.001 and s.LastAngle<.001,"Reload refills and closes world cylinder")
 equip("Shotgun")
 s=sample("shotgunPump","Shoot",.85)
 check(s.Count==6 and s.MaxPosition>.2 and s.LastPosition<.001,"Real shotgun shot cycles all six pump pieces and settles")
 task.wait(.2) s=sample("shotgunReduced","ReducedShoot",.85)
 check(s.MaxPosition>.04 and s.MaxPosition<.06 and s.LastPosition<.001,"ReducedMotion limits pump travel to one quarter")
 s=sample("abilityReduced","Ability",.2)
 check(s.Normal>.35 and s.Normal<.48 and math.abs(s.Reduced/s.Normal-.25)<.04,"Ability torso lean respects ReducedMotion")
 local old=p.Character.EquippedWeaponVisual equip("Pistol")
 check(old.Parent==nil and #p.Character.EquippedWeaponVisual:GetDescendants()>0,"Switching removes previous weapon mechanisms")
 floor:Destroy()
end)
table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
p.leaderstats.Level.Value=saved.Level E.Refresh(p) E.Send(p)
p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) p.Character:PivotTo(saved.CF)
local floor=workspace:FindFirstChild("WorldMechanismsQAFloor") if floor then floor:Destroy() end
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Samples=samples})
bridge:Destroy() script:Destroy()
