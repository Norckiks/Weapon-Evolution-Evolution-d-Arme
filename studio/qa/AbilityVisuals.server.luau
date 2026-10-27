-- SessionStudio only. Temporary server Script; send each real UseAbility request from the Client.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local RS=game.ReplicatedStorage local CS=game:GetService("CollectionService")
local c=p.Character local h=c:FindFirstChildOfClass("Humanoid") local saved={CF=c:GetPivot(),Level=p.leaderstats.Level.Value,Health=h.Health,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),Ready=p:GetAttribute("ProgressReady"),Stamina=c:GetAttribute("Stamina")}
local control=RS:FindFirstChild("AbilityVisualsQAControl") if control then control:Destroy() end
local result=game.ServerStorage:FindFirstChild("AbilityVisualsQAResult") if result then result:Destroy() end
control=Instance.new("StringValue") control.Name="AbilityVisualsQAControl" control.Value="Preparing" control.Parent=RS
result=Instance.new("StringValue") result.Name="AbilityVisualsQAResult" result.Value="Running" result.Parent=game.ServerStorage
local origin=Vector3.new(100,60,-120) local checks={} local arena=Instance.new("Folder") arena.Name="AbilityVisualsQAArena" arena.Parent=workspace
local tagged={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function waitUntil(fn,seconds) local deadline=os.clock()+seconds while not fn() and os.clock()<deadline do task.wait(.03) end return fn() end
local function dummy(pos)
 local m=Instance.new("Model") m.Name="SlamQA"
 local r=Instance.new("Part") r.Name="HumanoidRootPart" r.Size=Vector3.new(2,2,1) r.Position=pos r.Anchored=true r.CanCollide=false r.Parent=m
 local head=Instance.new("Part") head.Name="Head" head.Size=Vector3.one head.Position=pos+Vector3.new(0,1.5,0) head.CanCollide=false head.Parent=m
 local weld=Instance.new("WeldConstraint") weld.Part0=r weld.Part1=head weld.Parent=head
 local hum=Instance.new("Humanoid") hum.MaxHealth=100 hum.Health=100 hum.WalkSpeed=0 hum.Parent=m
 m.PrimaryPart=r m:SetAttribute("ZoneId","City") m.Parent=arena CS:AddTag(m,"Zombie") table.insert(tagged,m) return m
end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) p:SetAttribute("ProgressReady",true) p.leaderstats.Level.Value=20
 local floor=Instance.new("Part") floor.Name="TestFloor" floor.Size=Vector3.new(90,1,180) floor.Position=origin-Vector3.new(0,5,0) floor.Anchored=true floor.Parent=arena
 c:PivotTo(CFrame.lookAt(origin,origin+Vector3.new(0,0,-1))) task.wait(.55) c=p.Character h=c.Humanoid
 local lost=math.min(20,h.MaxHealth-1) h.Health=h.MaxHealth-lost control.Value="ReadyHeal"
 check(waitUntil(function() return h.Health==h.MaxHealth end,12),"Second Souffle heals real missing health through the client remote")
 check((c:GetAttribute("SecondSouffleReadyAt") or 0)>workspace:GetServerTimeNow()+27,"Second Souffle cooldown is server-owned")
 check(waitUntil(function() return (c:GetAttribute("Stamina") or 0)>=34 end,4),"Shared stamina regenerates for the next test action")
 local target=dummy(origin+Vector3.new(0,0,-8)) control.Value="ReadySlam"
 check(waitUntil(function() return target.Humanoid.Health<100 end,12),"Frappe tellurique damages a close zombie through the client remote")
 check(target.Humanoid.Health==66 and (target:GetAttribute("StunnedUntil") or 0)>workspace:GetServerTimeNow(),"Ground strike deals 34 and stuns")
 control.Value="Complete"
end)
for _,m in tagged do CS:RemoveTag(m,"Zombie") end arena:Destroy()
if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then c=p.Character h=c.Humanoid c:PivotTo(saved.CF) h.Health=math.min(h.MaxHealth,saved.Health) c:SetAttribute("Stamina",saved.Stamina) end
p.leaderstats.Level.Value=saved.Level p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) p:SetAttribute("ProgressReady",saved.Ready)
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil}) script:Destroy()
