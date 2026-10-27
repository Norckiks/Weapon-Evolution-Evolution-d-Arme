-- Observes native W/Shift input; rendering and real physics, not synthetic velocity.
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local result=Instance.new("StringValue") result.Name=script:GetAttribute("ResultName") or "IdeasRunQAResult" result.Value="Waiting for sprint" result.Parent=p.PlayerGui
local report={Frames=0,PeakSpeed=0,TrackSpeed=0,PoseAngle=0} local began local origin local initial
local conn
conn=game.RunService.RenderStepped:Connect(function()
 local c=p.Character local root=c and c:FindFirstChild("HumanoidRootPart") local h=c and c:FindFirstChildOfClass("Humanoid") if not root or not h then return end
 local running=c:GetAttribute("Sprinting")==true and h.MoveDirection.Magnitude>.1
 if not began and running then began=os.clock() origin=root.Position initial=c:GetAttribute("Stamina") end
 if not began then return end
 local speed=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude
 report.PeakSpeed=math.max(report.PeakSpeed,speed) report.Frames+=1
 for _,track in h.Animator:GetPlayingAnimationTracks() do if track.Animation and track.Animation.Name=="SprintAnimation" then report.TrackSpeed=math.max(report.TrackSpeed,track.Speed) end end
 for _,v in c:GetDescendants() do if (v:IsA("Motor6D") or v:IsA("AnimationConstraint")) and v.Name=="Waist" then local _,a=v.Transform:ToAxisAngle() report.PoseAngle=math.max(report.PoseAngle,math.abs(a)) end end
 if os.clock()-began>=1.7 then
  report.Displacement=(root.Position-origin).Magnitude report.StartStamina=initial report.EndStamina=c:GetAttribute("Stamina") report.WalkSpeed=h.WalkSpeed
  report.ThirdPerson=p:GetAttribute("ThirdPerson") report.Reduced=p:GetAttribute("ReducedMotion") report.Viewport=tostring(workspace.CurrentCamera.ViewportSize)
  report.Passed=report.Frames>10 and report.PeakSpeed>30 and report.Displacement>40 and report.EndStamina<initial and report.TrackSpeed>1.8
  result.Value=game.HttpService:JSONEncode(report) conn:Disconnect() script:Destroy()
 end
end)
