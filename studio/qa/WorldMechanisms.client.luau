-- Temporary Play observer for the real CharacterCombat layers and weapon motors.
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local RS=game.ReplicatedStorage local Run=game:GetService("RunService")
local bridge=RS:WaitForChild("WorldMechanismsQABridge",10) assert(bridge)
bridge.OnClientInvoke=function(verb,duration)
 local reduced=p:GetAttribute("ReducedMotion") local third=p:GetAttribute("ThirdPerson")
 p:SetAttribute("ThirdPerson",true) p:SetAttribute("ReducedMotion",verb=="ReducedShoot")
 local report={Count=0,MaxPosition=0,MaxAngle=0,LastPosition=0,LastAngle=0,Frames=0}
 if verb=="Ability" then
  local c=p.Character local id,stamp=c:GetAttribute("AbilityId"),c:GetAttribute("AbilityAt")
  local waist
  for _,v in c:GetDescendants() do if (v:IsA("Motor6D") or v:IsA("AnimationConstraint")) and v.Name=="Waist" then waist=v break end end
  assert(waist,"R15 waist required for this isolated torso check")
  local animate=c:FindFirstChild("Animate") local wasDisabled=animate and animate.Disabled
  if animate then animate.Disabled=true end
  local tracks=c.Humanoid.Animator:GetPlayingAnimationTracks() for _,track in tracks do track:Stop(0) end
  local freeze=Run.PreAnimation:Connect(function() c:SetAttribute("AbilityId","Slam") c:SetAttribute("AbilityAt",workspace:GetServerTimeNow()-.4) end)
  p:SetAttribute("ReducedMotion",false) task.wait(.2) local _,normal=waist.Transform:ToAxisAngle()
  p:SetAttribute("ReducedMotion",true) task.wait(.2) local _,small=waist.Transform:ToAxisAngle()
  freeze:Disconnect() c:SetAttribute("AbilityId",id) c:SetAttribute("AbilityAt",stamp)
  if animate then animate.Disabled=wasDisabled end
  for _,track in tracks do track:Play(.1) end
  p:SetAttribute("ReducedMotion",reduced) p:SetAttribute("ThirdPerson",third)
  return {Normal=math.abs(normal),Reduced=math.abs(small)}
 end
 if verb=="Shoot" or verb=="ReducedShoot" then RS.Remotes.Shoot:FireServer(Vector3.new(0,0,-1)) end
 if verb=="Reload" then RS.Remotes.ReloadGun:FireServer() end
 local finish=os.clock()+duration
 repeat
  Run.RenderStepped:Wait() report.Frames+=1
  local model=p.Character:FindFirstChild("EquippedWeaponVisual") local count=0 local last=0 local lastAngle=0
  if model then for _,v in model:GetDescendants() do
   if v:IsA("Motor6D") and v.Name=="WeaponMechanism" then
    count+=1 local pos=v.Transform.Position.Magnitude local _,angle=v.Transform:ToAxisAngle()
    assert(pos==pos and angle==angle,"Nonfinite mechanism")
    report.MaxPosition=math.max(report.MaxPosition,pos) report.MaxAngle=math.max(report.MaxAngle,math.abs(angle)) last=math.max(last,pos) lastAngle=math.max(lastAngle,math.abs(angle))
   end
  end end
  report.Count=count report.LastPosition=last report.LastAngle=lastAngle
 until os.clock()>=finish
 report.Ammo=p:GetAttribute("GunAmmo") report.Swing=p.Character:GetAttribute("SwingWeapon") report.Age=workspace:GetServerTimeNow()-(p.Character:GetAttribute("SwingAt") or 0)
 p:SetAttribute("ReducedMotion",reduced) p:SetAttribute("ThirdPerson",third)
 return report
end
bridge:SetAttribute("ClientReady",true)
