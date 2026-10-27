-- Temporary Play bridge and effect-instance observer, no rendered image claim.
assert(game.RunService:IsStudio())
local p=game.Players.LocalPlayer local RS=game.ReplicatedStorage
local bridge=RS:WaitForChild("ArcQABridge",10) assert(bridge)
local camera=workspace.CurrentCamera local cf,kind=camera.CFrame,camera.CameraType
local reduced,sfx=p:GetAttribute("ReducedMotion"),p:GetAttribute("SFXEnabled")
local report={Events=0}
RS.Remotes.AbilityFX.OnClientEvent:Connect(function(id,_,_,hits,path)
 if id~="Arc" then return end
 local events=report.Events+1 report={Events=events,Hits=hits,Path=path,Bolts=0,Sounds=0,Safe=true}
 local current=report
 task.defer(function()
  for _,v in workspace.LocalPulseFX:GetDescendants() do
   if v.Name=="ArcChainBolt" then current.Bolts+=1 current.Safe=current.Safe and v.Anchored and not v.CanCollide and not v.CanQuery and not v.CanTouch end
   if v.Name=="ArcDischarge" then current.Sounds+=1 end
  end
 end)
end)
bridge.OnClientInvoke=function(verb)
 if verb=="Snapshot" then return report end
 if verb=="Restore" then
  p:SetAttribute("ReducedMotion",reduced) p:SetAttribute("SFXEnabled",sfx) camera.CameraType=kind camera.CFrame=cf return true
 end
 camera.CameraType=Enum.CameraType.Scriptable camera.CFrame=p.Character.Head.CFrame*CFrame.new(0,2,8)
 p:SetAttribute("ReducedMotion",verb=="Reduced") p:SetAttribute("SFXEnabled",verb~="Reduced")
 RS.Remotes.UseAbility:FireServer("Arc",Vector3.new(999,0,999)) return true
end
