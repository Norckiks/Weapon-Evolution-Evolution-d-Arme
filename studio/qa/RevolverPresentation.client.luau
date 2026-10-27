-- Temporary Studio Play client sampler. Requires a started, equipped revolver fixture.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer
assert(p:GetAttribute("PersistenceMode")=="SessionStudio" and p:GetAttribute("EquippedWeapon")=="Revolver")
local result=Instance.new("StringValue") result.Name="RevolverPresentationQAResult" result.Value="Running" result.Parent=p.PlayerGui
local remotes=game.ReplicatedStorage.Remotes
local previous=p:GetAttribute("ReducedMotion") local previousSFX=p:GetAttribute("SFXEnabled")
local reports={}
local ok,err=pcall(function()
 p:SetAttribute("SFXEnabled",true)
 for _,reduced in {false,true} do
  p:SetAttribute("ReducedMotion",reduced) task.wait(.85)
  remotes.Shoot:FireServer(workspace.CurrentCamera.CFrame.LookVector) task.wait(.2)
  local vm=workspace.CurrentCamera.FistsViewmodel local gun=vm.FirstPersonWeapon
  local arm=vm.RightArm:FindFirstChildWhichIsA("BasePart",true) assert(arm)
  local baseline=workspace.CurrentCamera.CFrame:ToObjectSpace(arm.CFrame)
  local center=gun.Frame.CFrame:ToObjectSpace(gun.Cylinder.CFrame).Position
  local pitches={}
  local connection=game.SoundService.ChildAdded:Connect(function(v) if v:IsA("Sound") and v.Name=="ReloadClick" then table.insert(pitches,v.PlaybackSpeed) end end)
  remotes.ReloadGun:FireServer()
  local deadline=os.clock()+1
  while not p:GetAttribute("GunReloading") and os.clock()<deadline do task.wait(.02) end
  assert(p:GetAttribute("GunReloading"),"Reload did not start")
  local report={ReducedMotion=reduced,MaximumCylinderOffset=0,MidPoseAngle=0,SoundPitches=pitches}
  deadline=os.clock()+3.3
  while p:GetAttribute("GunReloading") and os.clock()<deadline do
   local position=gun.Frame.CFrame:ToObjectSpace(gun.Cylinder.CFrame).Position
   report.MaximumCylinderOffset=math.max(report.MaximumCylinderOffset,(position-center).Magnitude)
   local alpha=(workspace:GetServerTimeNow()-p:GetAttribute("GunReloadStarted"))/2.6
   if alpha>.4 and alpha<.6 then
    local pose=baseline:ToObjectSpace(workspace.CurrentCamera.CFrame:ToObjectSpace(arm.CFrame))
    local _,angle=pose:ToAxisAngle() report.MidPoseAngle=math.max(report.MidPoseAngle,math.abs(angle))
   end
   task.wait(.025)
  end
  task.wait(.1) connection:Disconnect()
  report.AmmoAfter=p:GetAttribute("GunAmmo")
  report.CylinderClosedOffset=(gun.Frame.CFrame:ToObjectSpace(gun.Cylinder.CFrame).Position-center).Magnitude
  assert(report.MaximumCylinderOffset>.3 and report.CylinderClosedOffset<.02,"Cylinder did not open/close")
  assert(report.AmmoAfter==6 and not p:GetAttribute("GunReloading"),"Reload incomplete")
  assert(#pitches==3,"Expected three mechanical sound stages")
  table.insert(reports,report)
 end
 assert(reports[2].MidPoseAngle<reports[1].MidPoseAngle*.4,"Reduced motion did not reduce rendered reload pose")
end)
p:SetAttribute("ReducedMotion",previous) p:SetAttribute("SFXEnabled",previousSFX)
result.Value=game.HttpService:JSONEncode({Passed=ok,Reports=reports,Error=not ok and tostring(err) or nil})
script:Destroy()
