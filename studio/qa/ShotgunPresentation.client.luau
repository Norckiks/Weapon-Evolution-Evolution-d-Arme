-- Temporary Play sampler. First shot must come from native mouse/button input.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio" and p:GetAttribute("EquippedWeapon")=="Shotgun")
local result=Instance.new("StringValue") result.Name="ShotgunPresentationQAResult" result.Value="Waiting for native shot" result.Parent=p.PlayerGui
local remotes=game.ReplicatedStorage.Remotes local Http=game.HttpService
local reduced,sfx=p:GetAttribute("ReducedMotion"),p:GetAttribute("SFXEnabled")
p:SetAttribute("ReducedMotion",false) p:SetAttribute("SFXEnabled",true)
local report={Shots=0,Tracers=0,Flashes=0,ShotSounds=0,PumpSounds=0,MaximumPump=0,Reloads={}}
local connections={}
local function connect(signal,fn) table.insert(connections,signal:Connect(fn)) end
connect(workspace.ChildAdded,function(v) if v.Name=="GunTracer" then report.Tracers+=1 elseif v.Name=="GunFlash" then report.Flashes+=1 end end)
connect(p.Character.DescendantAdded,function(v) if v:IsA("Sound") then if v.Name=="GunShot" then report.ShotSounds+=1 elseif v.Name=="ShotgunPump" then report.PumpSounds+=1 end end end)
local shotAt
connect(remotes.ShotFX.OnClientEvent,function(shooter,origin,ends,id)
 if shooter==p and id=="Shotgun" then report.Shots+=1 report.EndpointCount=#ends shotAt=os.clock() end
end)
local ok,err=pcall(function()
 local vm=workspace.CurrentCamera:WaitForChild("FistsViewmodel") local gun=vm:WaitForChild("FirstPersonWeapon")
 local baseline=gun.Receiver.CFrame:ToObjectSpace(gun.Foreend.CFrame).Position
 local deadline=os.clock()+90
 while not shotAt and os.clock()<deadline do task.wait(.02) end assert(shotAt,"Native shot timeout")
 while os.clock()-shotAt<.95 do
  report.MaximumPump=math.max(report.MaximumPump,(gun.Receiver.CFrame:ToObjectSpace(gun.Foreend.CFrame).Position-baseline).Magnitude) task.wait()
 end
 report.PumpReturned=(gun.Receiver.CFrame:ToObjectSpace(gun.Foreend.CFrame).Position-baseline).Magnitude
 assert(report.Shots==1 and report.EndpointCount==7 and report.Tracers==7 and report.Flashes==1,"Expected one event/flash and seven tracers")
 assert(report.ShotSounds==1 and report.PumpSounds==1,"Expected one shot sound and one pump sound")
 assert(report.MaximumPump>.21 and report.PumpReturned<.005,"Rendered pump must cycle and return")
 for _,reduce in {false,true} do
  p:SetAttribute("ReducedMotion",reduce) task.wait(.5)
  if reduce then remotes.Shoot:FireServer(workspace.CurrentCamera.CFrame.LookVector) task.wait(.95) end
  local arm=vm.RightArm:FindFirstChildWhichIsA("BasePart",true)
  local base=workspace.CurrentCamera.CFrame:ToObjectSpace(arm.CFrame)
  local row={ReducedMotion=reduce,MaximumAngle=0,Clicks=0}
  local clicks=game.SoundService.ChildAdded:Connect(function(v) if v.Name=="ReloadClick" then row.Clicks+=1 end end)
  remotes.ReloadGun:FireServer() local limit=os.clock()+1
  while not p:GetAttribute("GunReloading") and os.clock()<limit do task.wait(.02) end
  assert(p:GetAttribute("GunReloading"),"Reload missing") limit=os.clock()+3.5
  while p:GetAttribute("GunReloading") and os.clock()<limit do
   local pose=base:ToObjectSpace(workspace.CurrentCamera.CFrame:ToObjectSpace(arm.CFrame))
   local _,angle=pose:ToAxisAngle() row.MaximumAngle=math.max(row.MaximumAngle,math.abs(angle)) task.wait(.02)
  end
  clicks:Disconnect() row.Ammo=p:GetAttribute("GunAmmo") table.insert(report.Reloads,row)
  assert(row.Ammo==5 and row.Clicks==6,"Five insert stages and final mechanism; full magazine")
 end
 assert(report.Reloads[2].MaximumAngle<report.Reloads[1].MaximumAngle*.4,"Reduced reload pose not attenuated")
 p:SetAttribute("SFXEnabled",false) local before=report.ShotSounds+report.PumpSounds
 remotes.Shoot:FireServer(workspace.CurrentCamera.CFrame.LookVector) task.wait(1)
 assert(report.ShotSounds+report.PumpSounds==before,"SFX setting ignored") report.MutedShotPassed=true
end)
for _,c in connections do c:Disconnect() end
p:SetAttribute("ReducedMotion",reduced) p:SetAttribute("SFXEnabled",sfx)
result.Value=Http:JSONEncode({Passed=ok,Report=report,Error=not ok and tostring(err) or nil}) script:Destroy()
