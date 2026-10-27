-- Temporary rendered geometry checks driven by native attack input. Never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local RS=game.ReplicatedStorage local Run=game.RunService local motion=require(RS.WeaponMotion)
local control=Instance.new("BindableFunction") control.Name="WeaponOrientationProbeQA" control.Parent=p.PlayerGui
local savedReduced=p:GetAttribute("ReducedMotion") local report={Runs={}} local current local frozen
local function snapshot()
 local frames={} local vm=workspace.CurrentCamera:FindFirstChild("FistsViewmodel")
 if vm then for _,v in vm:GetDescendants() do if v:IsA("BasePart") then frames[v]=v.CFrame end end end
 frozen=frames
end
control.OnInvoke=function(command,id,reduced)
 if command=="Start" then
  assert(not current,"Run already active") frozen=nil p:SetAttribute("ReducedMotion",reduced)
  local camera=workspace.CurrentCamera assert(camera.ViewportSize.X>100 and camera.ViewportSize.Y>100,"No real viewport")
  assert(p:GetAttribute("EquippedWeapon")==id,"Wrong equipped weapon")
  local model,pieces=require(RS.WeaponVisuals).Build(id) local first=pieces[1] and pieces[1].rel model:Destroy()
  current={Weapon=id,ReducedMotion=reduced,Viewport=tostring(camera.ViewportSize),Impacts={},Frames=0,MaximumGripError=0,FirstRel=first,Stamp=p.Character:GetAttribute("SwingAt")}
  return true
 elseif command=="Finish" then
  assert(current) local row=current current=nil row.FirstRel=nil row.Stamp=nil
  row.Passed=row.Frames>5 and row.MaximumGripError<.001 and #row.Impacts>=3
  for _,hit in row.Impacts do if not hit.Firearm and hit.Forward<=0 then row.Passed=false end end
  table.insert(report.Runs,row) return game.HttpService:JSONEncode(row)
 elseif command=="Freeze" then snapshot() return true
 elseif command=="Unfreeze" then frozen=nil return true
 elseif command=="Report" then return game.HttpService:JSONEncode(report)
 elseif command=="Restore" then frozen=nil p:SetAttribute("ReducedMotion",savedReduced) Run:UnbindFromRenderStep("WeaponOrientationQA") control:Destroy() script:Destroy() return true
 end
 error("Unknown command")
end
Run:BindToRenderStep("WeaponOrientationQA",Enum.RenderPriority.Camera.Value+3,function()
 if frozen then for v,cf in frozen do if v.Parent then v.CFrame=cf end end return end
 if not current then return end
 local row=current local cam=workspace.CurrentCamera local vm=cam:FindFirstChild("FistsViewmodel")
 local gun=vm and vm:FindFirstChild("FirstPersonWeapon") local sleeve=vm and vm.RightArm:FindFirstChild("TexturedSleeve")
 if not sleeve or not gun or not gun.PrimaryPart then return end
 local root=sleeve.CFrame*CFrame.new(0,.04,-.9)
 local firearm=require(RS.GameplayConfig).Weapons[row.Weapon].Firearm==true
 local grip=firearm and CFrame.new(0,-.08,-.13)*CFrame.Angles(math.rad(5),0,0) or CFrame.new(0,.12,-.15)*CFrame.Angles(math.rad(-15),0,math.rad(-8))
 local expected=root*grip*row.FirstRel
 local actual=gun.PrimaryPart.CFrame
 row.MaximumGripError=math.max(row.MaximumGripError,(actual.Position-expected.Position).Magnitude)
 if firearm then
  local _,angle=expected:ToObjectSpace(actual):ToAxisAngle()
  row.MaximumGunAngleError=math.max(row.MaximumGunAngleError or 0,math.abs(angle))
 end
 row.Frames+=1
 local stamp=p.Character:GetAttribute("SwingAt")
 if stamp~=row.Stamp and p.Character:GetAttribute("SwingWeapon")==row.Weapon then
  row.Stamp=stamp
  local axis=cam.CFrame:VectorToObjectSpace(actual.UpVector)
  table.insert(row.Impacts,{Combo=p.Character:GetAttribute("SwingCombo"),Forward=-axis.Z,Firearm=firearm})
 end
end)
