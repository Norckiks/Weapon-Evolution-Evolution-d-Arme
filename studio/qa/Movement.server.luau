assert(game:GetService("RunService"):IsStudio())
local M=require(game.ServerScriptService.AdvancedMovement)
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local c=p.Character local root=c.HumanoidRootPart local h=c.Humanoid
local saved=c:GetPivot() local started=p:GetAttribute("HasStarted") local menu=p:GetAttribute("InGameMenu")
local arena=Instance.new("Folder") arena.Name="MovementQA" arena.Parent=workspace
local function block(name,size,pos)
 local b=Instance.new("Part") b.Name=name b.Size=size b.Position=pos b.Anchored=true b.Parent=arena return b
end
block("Floor",Vector3.new(80,2,80),Vector3.new(0,999,0))
local s={character=c,humanoid=h,stamina=100,wants=true,baseHipHeight=h.HipHeight}
local checks={}
local function check(value,name) assert(value,name) table.insert(checks,name) end
local function reset()
 M.Cancel(s) s.crouching=false s.lastMovementRequest=0 s.slideReadyAt=0 s.vaultReadyAt=0 s.stamina=100
 c:PivotTo(CFrame.new(0,1005,0)) root.AssemblyLinearVelocity=Vector3.zero task.wait(.7)
end
local ok,err=pcall(function()
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) root:SetNetworkOwner(nil)
 reset() root.AssemblyLinearVelocity=Vector3.new(0,0,-25)
 check(M.Handle(p,s,"Crouch") and s.slideUntil~=nil and s.stamina==85,"Slide accepted and costs 15 stamina")
 check(not M.Handle(p,s,"Vault"),"Vault blocked while sliding")
 local initial=root.Position
 for _=1,18 do task.wait(.05) M.Update(p,s,.05,true) end
 check((root.Position-initial).Magnitude>3,"Slide physically moves character")
 check(s.moveVelocity==nil and not M.Busy(s),"Slide constraint cleaned after duration")
 reset()
 local obstacle=block("LowObstacle",Vector3.new(8,2,1),Vector3.new(0,1001,-3))
 check(M.Handle(p,s,"Vault") and s.stamina==88,"Low obstacle vault accepted and costs 12 stamina")
 check(root.AssemblyLinearVelocity.Y>30,"Vault applies upward impulse")
 for _=1,28 do task.wait(.05) M.Update(p,s,.05,true) end
 check(root.Position.Z < -3.7,"Vault crosses the obstacle")
 check(h.FloorMaterial~=Enum.Material.Air,"Vault lands on the far side")
 M.Cancel(s) obstacle:Destroy()
 reset() check(not M.Handle(p,s,"Vault") and s.stamina==100,"No obstacle means no vault or cost")
 local wall=block("Wall",Vector3.new(8,8,1),Vector3.new(0,1004,-3))
 check(not M.Handle(p,s,"Vault"),"Tall wall rejected") wall:Destroy()
 reset() s.stamina=0 local low=block("LowAgain",Vector3.new(8,2,1),Vector3.new(0,1001,-3))
 check(not M.Handle(p,s,"Vault"),"Insufficient vault stamina rejected") low:Destroy()
 reset() p:SetAttribute("InGameMenu",true) check(not M.Handle(p,s,"Crouch"),"Menu rejects movement actions")
end)
M.Cancel(s) h.HipHeight=s.baseHipHeight c:PivotTo(saved) root.AssemblyLinearVelocity=Vector3.zero root:SetNetworkOwnershipAuto()
p:SetAttribute("HasStarted",started) p:SetAttribute("InGameMenu",menu) arena:Destroy()
local result=Instance.new("StringValue") result.Name="MovementQAResult" result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks}) result.Parent=game.ServerStorage script:Destroy()
