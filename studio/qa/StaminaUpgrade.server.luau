-- Temporary SessionStudio test; restores metadata, statistics and character position.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService)
local E=require(game.ServerScriptService.EconomyService)
local State=require(game.ServerScriptService.SprintState)
local C=require(game.ReplicatedStorage.GameplayConfig)
local SC=require(game.ReplicatedStorage.SprintConfig)
local bridge=game.ReplicatedStorage:WaitForChild("StaminaUpgradeQABridge",10) assert(bridge)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local saved={Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,XP=p.Progress.XP.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu"),CF=p.Character:GetPivot(),HP=p.Character.Humanoid.Health}
local result=Instance.new("StringValue") result.Name="StaminaUpgradeQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={}
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function request(verb,id) task.wait(.16) bridge:InvokeClient(p,verb,id) task.wait(.18) end
local function maximum() return p.Character:GetAttribute("MaxStamina") end
local function restore()
 table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level p.Progress.XP.Value=saved.XP
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
 p.Character:PivotTo(saved.CF) E.Refresh(p) p.Character.Humanoid.Health=math.min(saved.HP,p.Character.Humanoid.MaxHealth) E.Send(p)
 return true
end
local ok,err=pcall(function()
 check(C.ProgressionLevelLimit==1000000000 and C.UpgradeCost("Stamina",C.ProgressionLevelLimit)==C.MaxUpgradeCost,"Upgrade rank and price stay finite")
 local atSoftCap=C.ProgressionSteps(25,C.Upgrades.Stamina.SoftTail) local afterSoftCap=C.ProgressionSteps(26,C.Upgrades.Stamina.SoftTail)
 check(afterSoftCap>atSoftCap and afterSoftCap-atSoftCap<1,"Upgrade benefits continue with diminishing returns")
 check(m.StaminaLevel==0,"Legacy profile starts at zero upgrades")
 m.StaminaLevel=0 m.HealthLevel=0 m.SpeedLevel=0 m.Receipts.StaminaQASentinel=true
 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",true)
 p.Character:PivotTo(CFrame.new(0,5,220)) E.Refresh(p) task.wait(.25)
 check(maximum()==100,"Base capacity remains 100")
 p.leaderstats.Coins.Value=0 request("Upgrade","Stamina")
 check(m.StaminaLevel==0 and maximum()==100,"Insufficient coins refused")
 p.leaderstats.Coins.Value=10000 request("Upgrade","Stamina")
 check(m.StaminaLevel==1 and p.leaderstats.Coins.Value==9750 and maximum()==120,"First purchase costs 250 and adds 20")
 local distance=(p.Character.HumanoidRootPart.Position-C.Shops.Upgrades).Magnitude
 check(distance>20,"Purchase works away from stand")
 p:SetAttribute("InGameMenu",false) request("Dash","") p:SetAttribute("InGameMenu",true) task.wait(.15)
 check(math.abs(p.Character:GetAttribute("Stamina")-95)<.3,"Dash still costs exactly 25 from 120")
 request("Upgrade","Stamina")
 check(m.StaminaLevel==2 and maximum()==140 and p.leaderstats.Coins.Value==9275,"Second price 475, capacity 140")
 check(math.abs(p.Character:GetAttribute("Stamina")-115)<.3,"Upgrade adds 20 without refilling spent reserve")
 E.Refresh(p) E.Refresh(p) task.wait(.25)
 check(math.abs(p.Character:GetAttribute("Stamina")-115)<.3,"Repeated economy refresh does not refill stamina")
 for level=2,4 do
  local before=p.leaderstats.Coins.Value local cost=C.UpgradeCost("Stamina",level)
  request("Upgrade","Stamina")
  check(m.StaminaLevel==level+1 and maximum()==100+(level+1)*20 and p.leaderstats.Coins.Value==before-cost,"Exact tier price and capacity "..(level+1))
 end
 local nextCost=C.UpgradeCost("Stamina",5) p.leaderstats.Coins.Value=nextCost request("Upgrade","Stamina")
 check(m.StaminaLevel==6 and maximum()==220 and p.leaderstats.Coins.Value==0,"Stamina remains purchasable beyond its former rank 5 cap")
 m.StaminaLevel=C.ProgressionLevelLimit E.Refresh(p) task.wait(.25)
 local coins=350 p.leaderstats.Coins.Value=coins request("Upgrade","Stamina")
 check(m.StaminaLevel==C.ProgressionLevelLimit and p.leaderstats.Coins.Value==coins,"Technical rank guard refuses further debit")
 m.StaminaLevel=6 E.Refresh(p) task.wait(.25)
 request("Upgrade",{Id="Stamina",Price=0}) request("Upgrade","StaminaLevel")
 check(p.leaderstats.Coins.Value==coins,"Malformed and forged upgrade IDs refused")
 request("Upgrade","Health") check(m.HealthLevel==1 and p.leaderstats.Coins.Value==coins-100,"Existing Health upgrade still works")
 request("Upgrade","Speed") check(m.SpeedLevel==1 and p.leaderstats.Coins.Value==coins-250,"Existing Speed upgrade still works")
 local copy=game.HttpService:JSONDecode(game.HttpService:JSONEncode(m))
 check(copy.StaminaLevel==6 and copy.Receipts.StaminaQASentinel==true,"JSON keeps upgrade and existing receipts")
 m.Daily.Day=math.floor(os.time()/86400)-1 E.Send(p)
 check(m.StaminaLevel==6 and maximum()==220,"Daily rollover leaves capacity intact")
 local s=State.new(SC) s.maxStamina=200 s.stamina=200 s.wants=true
 State.step(s,SC,4,true,true) check(s.stamina==120,"Drain remains 20 per second at upgraded capacity")
 State.step(s,SC,6,true,true) check(s.stamina==0 and s.exhausted,"Upgraded reserve still exhausts")
 s.wants=false State.step(s,SC,20,false,true)
 check(s.stamina==200,"Regeneration reaches upgraded maximum")
 State.step(s,SC,20,false,true) check(s.stamina==200,"Regeneration clamps at 200")
 local base=State.new(SC) base.stamina=0 State.step(base,SC,20,false,true)
 check(base.stamina==100,"Default reserve still clamps at 100")
 p:LoadCharacterAsync() p.Character:WaitForChild("Humanoid",10) task.wait(.7)
 check(maximum()==220 and p.Character:GetAttribute("Stamina")==220,"Respawn restores purchased full capacity")
 m.StaminaLevel=0 E.Refresh(p) task.wait(.3)
 check(maximum()==100 and p.Character:GetAttribute("Stamina")<=100,"Capacity reduction clamps current reserve")
 check(C.MonetizationEnabled==false,"Robux stays disabled")
end)
restore()
result.Value=game.HttpService:JSONEncode({Passed=ok,Checks=checks,Error=not ok and tostring(err) or nil,Restored=true})
local prepare=Instance.new("BindableFunction") prepare.Name="PrepareStaminaUpgradeUI" prepare.Parent=game.ServerStorage
prepare.OnInvoke=function() m.StaminaLevel=0 p.leaderstats.Coins.Value=1000 p:SetAttribute("HasStarted",true) E.Refresh(p) E.Send(p,nil,"Upgrades") return true end
local read=Instance.new("BindableFunction") read.Name="ReadStaminaUpgradeQA" read.Parent=game.ServerStorage
read.OnInvoke=function() return game.HttpService:JSONEncode({Level=m.StaminaLevel,Coins=p.leaderstats.Coins.Value,Max=maximum(),Stamina=p.Character:GetAttribute("Stamina")}) end
local reset=Instance.new("BindableFunction") reset.Name="RestoreStaminaUpgradeQA" reset.Parent=game.ServerStorage reset.OnInvoke=restore
