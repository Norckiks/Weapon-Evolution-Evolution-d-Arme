-- Temporary Play observer: actual world motors, no RenderStepped dependency.
assert(game.RunService:IsStudio())
local p=game.Players.LocalPlayer local RS=game.ReplicatedStorage
local bridge=RS:WaitForChild("LMGMotionBridge",10) assert(bridge)
bridge.OnClientInvoke=function(verb)
 local camera=workspace.CurrentCamera local cf,kind=camera.CFrame,camera.CameraType
 local reduced,third,sfx=p:GetAttribute("ReducedMotion"),p:GetAttribute("ThirdPerson"),p:GetAttribute("SFXEnabled")
 local follow=game.RunService.Heartbeat:Connect(function()
  camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=p.Character.Head.CFrame*CFrame.new(0,2,8)
 end)
 p:SetAttribute("ThirdPerson",true) p:SetAttribute("ReducedMotion",verb=="ReducedShoot") p:SetAttribute("SFXEnabled",verb~="MutedShoot")
 local report={Frames=0,Bolt=0,Magazine=0,Cover=0,Last=0,Sounds={}}
 local listener=workspace.DescendantAdded:Connect(function(v)
  if v:IsA("Sound") and (v.Name=="GunShot" or v.Name=="LMGBolt") then report.Sounds[v.Name]=(report.Sounds[v.Name] or 0)+1 end
 end)
 local ok,err=pcall(function()
  task.wait(.1)
  if verb=="Reload" then RS.Remotes.ReloadGun:FireServer() else RS.Remotes.Shoot:FireServer(Vector3.new(0,0,-1)) end
  local finish=os.clock()+(verb=="Reload" and 4.1 or .3)
  repeat
   game.RunService.Heartbeat:Wait() report.Frames+=1 local last=0
   local model=p.Character:FindFirstChild("EquippedWeaponVisual") assert(model)
   for _,v in model:GetDescendants() do
    if v:IsA("Motor6D") and v.Name=="WeaponMechanism" and v.Part1 then
     local pos=v.Transform.Position
     if v.Part1.Name=="BoltHandle" then report.Bolt=math.max(report.Bolt,pos.Z) end
     if v.Part1.Name=="FeedCover" then local _,angle=v.Transform:ToAxisAngle() report.Cover=math.max(report.Cover,math.abs(angle)) end
     if v.Part1.Name=="Magazine" then report.Magazine=math.max(report.Magazine,-pos.Y) end
     last=math.max(last,pos.Magnitude)
    end
   end
   report.Last=last
  until os.clock()>=finish
 end)
 listener:Disconnect() follow:Disconnect()
 p:SetAttribute("ReducedMotion",reduced) p:SetAttribute("ThirdPerson",third) p:SetAttribute("SFXEnabled",sfx)
 camera.CameraType=kind camera.CFrame=cf
 assert(ok,err) return report
end
