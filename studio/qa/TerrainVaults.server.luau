-- Temporary Studio Play server test. Uses real MovementAction requests emitted by a client bridge.
assert(game:GetService("RunService"):IsStudio(),"Studio only")
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local bridge=game.ReplicatedStorage:WaitForChild("TerrainMovementQABridge",10) assert(bridge)
local c=p.Character local root=c:WaitForChild("HumanoidRootPart") local h=c:WaitForChild("Humanoid")
local old={CF=c:GetPivot(),Level=p.leaderstats.Level.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local routes={{Name="CitySandbags",Zone="City",Approach=Vector3.new(-12.25,5.2,28),BackZ=23}}
for _,name in {"FactoryCrate","FactoryPipeRack","LabConsole","LabBarrier"} do
 local model=workspace.TraversalCover:FindFirstChild(name) assert(model,name)
 table.insert(routes,{Name=name,Zone=model:GetAttribute("ZoneId"),Approach=model:GetAttribute("Approach"),BackZ=model.VaultCore.Position.Z-model.VaultCore.Size.Z/2})
end
local requiredLevel=12
local harbor=workspace.ProgressionZones:FindFirstChild("Harbor")
if harbor then
 requiredLevel=20
 for i,core in harbor.RouteDetails:GetChildren() do
  if core:IsA("BasePart") and core.Name=="CargoCover" then
   table.insert(routes,{Name="HarborCargo_"..i,Zone="Harbor",Approach=Vector3.new(core.Position.X,5.2,core.Position.Z+core.Size.Z/2+3),BackZ=core.Position.Z-core.Size.Z/2})
  end
 end
end
local samples={}
local result=Instance.new("StringValue") result.Name="TerrainVaultsQAResult" result.Value="Running" result.Parent=game.ServerStorage
local ok,err=pcall(function()
 p.leaderstats.Level.Value=requiredLevel p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 bridge:InvokeClient(p,"StopSprint")
 for _,route in routes do
  c:PivotTo(CFrame.new(route.Approach)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
  task.wait(.9)
  local initial=root.Position local stamina=c:GetAttribute("Stamina") local minimum=stamina
  bridge:InvokeClient(p,"Vault")
  local started=false local highest=initial.Y
  for _=1,28 do
   task.wait(.05) started=started or c:GetAttribute("Vaulting")==true highest=math.max(highest,root.Position.Y)
   minimum=math.min(minimum,c:GetAttribute("Stamina"))
  end
  table.insert(samples,{Name=route.Name,Zone=route.Zone,Started=started,Crossed=root.Position.Z<route.BackZ-.15,Landed=h.FloorMaterial~=Enum.Material.Air,CostPaid=minimum<=stamina-11.5,Rise=highest-initial.Y,Start={initial.X,initial.Y,initial.Z},Finish={root.Position.X,root.Position.Y,root.Position.Z}})
 end
end)
p.leaderstats.Level.Value=old.Level p:SetAttribute("HasStarted",old.Started) p:SetAttribute("InGameMenu",old.Menu)
c:PivotTo(old.CF) root.AssemblyLinearVelocity=Vector3.zero
local allPassed=ok
for _,r in samples do allPassed=allPassed and r.Started and r.Crossed and r.Landed and r.CostPaid end
result.Value=game.HttpService:JSONEncode({Passed=allPassed,Error=not ok and tostring(err) or nil,Routes=samples})
bridge:Destroy() script:Destroy()
