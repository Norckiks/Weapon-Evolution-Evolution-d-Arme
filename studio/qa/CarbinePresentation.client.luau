-- Temporary Play observer. Requires a started/equipped carbine and two native clicks.
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local RS=game.ReplicatedStorage local Run=game:GetService("RunService")
local saved={Third=p:GetAttribute("ThirdPerson"),Reduced=p:GetAttribute("ReducedMotion"),SFX=p:GetAttribute("SFXEnabled")}
local r=Instance.new("StringValue") r.Name="CarbinePresentationQAResult" r.Value="Preparing" r.Parent=p.PlayerGui
local checks={} local sounds={GunShot=0,CarbineBolt=0,ReloadClick=0} local shots=0 local connections={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function listen(v) if v:IsA("Sound") and sounds[v.Name] then sounds[v.Name]+=1 end end
table.insert(connections,workspace.DescendantAdded:Connect(listen)) table.insert(connections,game.SoundService.DescendantAdded:Connect(listen))
table.insert(connections,RS.Remotes.ShotFX.OnClientEvent:Connect(function(who,_,_,id) if who==p and id=="Carbine" then shots+=1 end end))
local function awaitShot(name)
 local before=shots r.Value=name local untilTime=os.clock()+45
 while shots==before and os.clock()<untilTime do task.wait(.01) end
 assert(shots>before,"Native shot timeout")
end
local function observe(seconds,fn)
 local peak=0 local untilTime=os.clock()+seconds
 repeat Run.RenderStepped:Wait() peak=math.max(peak,fn()) until os.clock()>=untilTime
 return peak
end
local metrics={}
local ok,err=pcall(function()
 check(p:GetAttribute("EquippedWeapon")=="Carbine","Carbine equipped for presentation")
 p:SetAttribute("ThirdPerson",true) p:SetAttribute("ReducedMotion",false) p:SetAttribute("SFXEnabled",true) task.wait(.4)
 awaitShot("AwaitNativeShot")
 local visual=p.Character.EquippedWeaponVisual
 metrics.WorldBolt=observe(.3,function() return visual.BoltHandle.WeaponMechanism.Transform.Position.Magnitude end)
 check(metrics.WorldBolt>.09,"Native third-person shot cycles bolt")
 check(sounds.GunShot==1 and sounds.CarbineBolt==1,"One report and one delayed bolt sound")
 RS.Remotes.ReloadGun:FireServer()
 metrics.WorldMagazine=observe(2.8,function() return visual.Magazine.WeaponMechanism.Transform.Position.Magnitude end)
 check(metrics.WorldMagazine>.59 and visual.Magazine.WeaponMechanism.Transform.Position.Magnitude<.001,"World magazine leaves and returns during real reload")
 check(sounds.ReloadClick==3,"Three reload sound stages")
 check(p:GetAttribute("GunAmmo")==18,"Presentation reload uses authoritative magazine")
 p:SetAttribute("ThirdPerson",false) p:SetAttribute("ReducedMotion",true) p:SetAttribute("SFXEnabled",false) task.wait(.4)
 local vm=workspace.CurrentCamera:FindFirstChild("FistsViewmodel") local gun=vm and vm:FindFirstChild("FirstPersonWeapon")
 check(gun and gun:FindFirstChild("SightLens"),"First-person carbine visible")
 local baseline=gun.Receiver.CFrame:ToObjectSpace(gun.BoltHandle.CFrame).Position
 local audioBefore=sounds.GunShot+sounds.CarbineBolt
 local earlyPeak=0
 local function fpTravel() return (gun.Receiver.CFrame:ToObjectSpace(gun.BoltHandle.CFrame).Position-baseline).Magnitude end
 local early=Run.RenderStepped:Connect(function() earlyPeak=math.max(earlyPeak,fpTravel()) end) table.insert(connections,early)
 awaitShot("AwaitQuietNativeShot")
 metrics.ReducedFPBolt=math.max(earlyPeak,observe(.3,fpTravel)) early:Disconnect()
 check(metrics.ReducedFPBolt>.02 and metrics.ReducedFPBolt<.06,"Reduced first-person bolt travel")
 check(sounds.GunShot+sounds.CarbineBolt==audioBefore,"Muted native shot creates no gun sounds")
 check(shots==2,"Exactly two native shots accepted")
end)
for _,c in connections do c:Disconnect() end
p:SetAttribute("ThirdPerson",saved.Third) p:SetAttribute("ReducedMotion",saved.Reduced) p:SetAttribute("SFXEnabled",saved.SFX)
r.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Metrics=metrics,Sounds=sounds,Shots=shots}) script:Destroy()
