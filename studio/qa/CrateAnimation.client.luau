-- Temporary observer of a real server result and rendered crate; never install in Edit.
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local r=Instance.new("StringValue") r.Name="CrateAnimationQAResult" r.Value="Waiting for native confirmation" r.Parent=p.PlayerGui
local report={Frames=0,MinimumLidY=math.huge,MaximumLidY=-math.huge,MaximumAngle=0} local began local previous
local event=game.ReplicatedStorage.Remotes.GameState.OnClientEvent:Connect(function(packet)
 if packet.Kind=="CrateResult" and not began then began=os.clock() report.Packet=packet end
end)
local conn
conn=game.RunService.RenderStepped:Connect(function()
 if not began then return end
 local gui=p.PlayerGui:FindFirstChild("CrateReveal") local card=gui and gui.InputShield.Card
 local vm=card and card.RewardPreview:FindFirstChild("AnimatedCrate")
 if vm then
  report.Frames+=1
  local cf=vm.Body.CFrame:ToObjectSpace(vm.Lid.CFrame)
  report.MinimumLidY=math.min(report.MinimumLidY,cf.Y) report.MaximumLidY=math.max(report.MaximumLidY,cf.Y)
  local _,angle=cf:ToAxisAngle() report.MaximumAngle=math.max(report.MaximumAngle,math.abs(angle))
 end
 if os.clock()-began>1.7 then
  report.Revealed=card and card.Title.Text~="OUVERTURE..." report.Viewport=tostring(workspace.CurrentCamera.ViewportSize)
  report.Sound=card and card:FindFirstChild("CrateReward")~=nil
  if report.Frames==0 then report.MinimumLidY=nil report.MaximumLidY=nil end
  event:Disconnect() conn:Disconnect() r.Value=game.HttpService:JSONEncode(report) script:Destroy()
 end
end)
