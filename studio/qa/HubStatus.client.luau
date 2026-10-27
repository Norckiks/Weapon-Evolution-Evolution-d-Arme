-- Temporary Play snapshot after preparing the two-gift/XP-boost fixture.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer local g=p.PlayerGui:WaitForChild("SurvivorHub")
local result=Instance.new("StringValue") result.Name="HubStatusQAResult" result.Value="Running" result.Parent=p.PlayerGui
local checks={} local metrics={} local connection local rendered,beats=0,0
local r=game.RunService.RenderStepped:Connect(function() rendered+=1 end)
local h=game.RunService.Heartbeat:Connect(function() beats+=1 end)
local old=p.Character:GetAttribute("DashReadyAt")
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local ok,err=pcall(function()
 task.wait(.65)
 local gift for _,b in g.QuickNavigation:GetChildren() do if b:IsA("TextButton") and b.Text:find("^CADEAUX") then gift=b end end
 check(g.Window.Visible and not g.QuickNavigation.Visible,"Menu hides shortcuts without a render frame")
 check(gift and gift.Text=="CADEAUX (2) [G]","Gift counter combines ready time and level rewards")
 check(g.ActiveBoosts.Text:find("XP x2")~=nil,"Boost timer refreshes without a render frame")
 local samples={} local label=g.DashStatus.Label local start=os.clock()
 connection=label:GetPropertyChangedSignal("Text"):Connect(function() table.insert(samples,os.clock()-start) end)
 p.Character:SetAttribute("DashReadyAt",workspace:GetServerTimeNow()+5)
 task.wait(1.25) connection:Disconnect() connection=nil
 check(#samples>=7 and #samples<=14,"Dash label updates at bounded UI cadence")
 check(samples[1]<=.3,"First status refresh within 300 ms in this run")
 local maxGap=0 for i=2,#samples do maxGap=math.max(maxGap,samples[i]-samples[i-1]) end
 check(maxGap<=.35,"No status refresh gap over 350 ms in this run")
 metrics.Updates=#samples metrics.FirstUpdate=samples[1] metrics.MaxGap=maxGap metrics.SampleSeconds=os.clock()-start
end)
if connection then connection:Disconnect() end
p.Character:SetAttribute("DashReadyAt",old) r:Disconnect() h:Disconnect()
metrics.RenderFrames=rendered metrics.Heartbeats=beats
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Metrics=metrics,Error=not ok and tostring(err) or nil})
