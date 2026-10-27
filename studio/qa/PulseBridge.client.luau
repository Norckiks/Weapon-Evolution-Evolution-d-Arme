-- Temporary Studio Play bridge and rendered-effect sampler, never a startup script.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer local RS=game.ReplicatedStorage
local bridge=RS:WaitForChild("PulseQABridge",10) assert(bridge)
local oldReduced=p:GetAttribute("ReducedMotion") local oldSFX=p:GetAttribute("SFXEnabled")
local count=0 local last={}
RS.Remotes.PulseFX.OnClientEvent:Connect(function(_,_,hits)
 count+=1 last={Hits=hits,Arcs=0,Sounds=0,PoseDistance=0}
 local report=last local vm=workspace.CurrentCamera:FindFirstChild("FistsViewmodel")
 local arm=vm and vm:FindFirstChild("RightArm") local part=arm and arm:FindFirstChildWhichIsA("BasePart",true)
 local baseline=part and workspace.CurrentCamera.CFrame:ToObjectSpace(part.CFrame)
 task.spawn(function()
  for _=1,12 do
   task.wait(.025)
   local folder=workspace:FindFirstChild("LocalPulseFX") local arcs,sounds=0,0
   for _,v in folder and folder:GetDescendants() or {} do if v.Name=="PulseArc" then arcs+=1 end if v.Name=="PulseImpact" then sounds+=1 end end
   report.Arcs=math.max(report.Arcs,arcs) report.Sounds=math.max(report.Sounds,sounds)
   if baseline and part.Parent then report.PoseDistance=math.max(report.PoseDistance,(baseline.Position-workspace.CurrentCamera.CFrame:ToObjectSpace(part.CFrame).Position).Magnitude) end
  end
 end)
end)
bridge.OnClientInvoke=function(action,value)
 if action=="Cast" then RS.Remotes.UseAbility:FireServer("Pulse")
 elseif action=="Invalid" then RS.Remotes.UseAbility:FireServer({Cost=0,Damage=999})
 elseif action=="Options" then p:SetAttribute("ReducedMotion",value) p:SetAttribute("SFXEnabled",not value)
 elseif action=="Restore" then p:SetAttribute("ReducedMotion",oldReduced) p:SetAttribute("SFXEnabled",oldSFX)
 elseif action=="Snapshot" then return {Count=count,Last=last,Button=p.PlayerGui.AbilityHUD.AbilityButton.Text}
 else error("Invalid pulse QA command") end
 return true
end
