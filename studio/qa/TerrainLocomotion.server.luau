-- Temporary server sampler. After Ready, drive the character with real Shift/W/C/Ctrl inputs.
assert(game:GetService("RunService"):IsStudio(),"Studio only")
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local zoneId=script:GetAttribute("ZoneId")
local zone for _,z in require(game.ReplicatedStorage.WorldConfig).Zones do if z.Id==zoneId then zone=z end end assert(zone,"Zone required")
local c=p.Character local root=c.HumanoidRootPart
local old={CF=c:GetPivot(),Level=p.leaderstats.Level.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="TerrainLocomotionQA_"..zoneId result.Value="Preparing" result.Parent=game.ServerStorage
local report={Zone=zoneId,Sprint=false,Slide=false,Dash=false,DashDuringSlide=false,Crouch=false,PeakSpeed=0}
p:SetAttribute("TerrainLocomotionReady",false)
local ok,err=pcall(function()
 p.leaderstats.Level.Value=math.max(12,zone.Level) p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 c:PivotTo(CFrame.new(zone.Arrival)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
 task.wait(.9)
 local deadline=os.clock()+7
 while (c:GetAttribute("Stamina") or 0)<90 and os.clock()<deadline do task.wait(.1) end
 assert((c:GetAttribute("Stamina") or 0)>=90,"Stamina did not recover")
 local start=root.Position report.StartStamina=c:GetAttribute("Stamina")
 result.Value="Running" p:SetAttribute("TerrainLocomotionReady",true)
 for _=1,120 do
  task.wait(.05)
  local v=root.AssemblyLinearVelocity local speed=Vector3.new(v.X,0,v.Z).Magnitude
  local slide=c:GetAttribute("Sliding")==true
  local dash=(c:GetAttribute("DashUntil") or 0)>workspace:GetServerTimeNow()
  report.Sprint=report.Sprint or c:GetAttribute("Sprinting")==true
  report.Slide=report.Slide or slide report.Dash=report.Dash or dash
  report.DashDuringSlide=report.DashDuringSlide or (slide and dash)
  report.Crouch=report.Crouch or c:GetAttribute("Crouching")==true
  report.PeakSpeed=math.max(report.PeakSpeed,speed)
 end
 report.Displacement=(root.Position-start).Magnitude
 report.EndStamina=c:GetAttribute("Stamina")
end)
p:SetAttribute("TerrainLocomotionReady",false)
p.leaderstats.Level.Value=old.Level p:SetAttribute("HasStarted",old.Started) p:SetAttribute("InGameMenu",old.Menu)
c:PivotTo(old.CF) root.AssemblyLinearVelocity=Vector3.zero
report.Passed=ok and report.Sprint and report.Slide and report.Dash and not report.DashDuringSlide and not report.Crouch and report.PeakSpeed>40 and report.Displacement>25
report.Error=not ok and tostring(err) or nil
result.Value=game.HttpService:JSONEncode(report) script:Destroy()
