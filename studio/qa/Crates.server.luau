-- Temporary SessionStudio integration checks. Restore before stopping Play; never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local RS=game.ReplicatedStorage local E=require(game.ServerScriptService.EconomyService) local P=require(game.ServerScriptService.ProgressionService)
local K=require(RS.CrateCatalog) local C=require(RS.GameplayConfig) local bridge=RS.CrateQABridge local m=P.GetMeta(p)
local saved={Meta=game.HttpService:JSONEncode(m),Coins=p.leaderstats.Coins.Value,Level=p.leaderstats.Level.Value,Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local result=Instance.new("StringValue") result.Name="CratesQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks={} local outcomes={}
local restore=Instance.new("BindableFunction") restore.Name="RestoreCratesQA" restore.Parent=game.ServerStorage
restore.OnInvoke=function()
 table.clear(m) for k,v in game.HttpService:JSONDecode(saved.Meta) do m[k]=v end
 p.leaderstats.Coins.Value=saved.Coins p.leaderstats.Level.Value=saved.Level E.Refresh(p) E.Send(p)
 p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu) restore:Destroy() script:Destroy() return true
end
local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local function action(verb,id,forged)
 task.wait(.18) bridge:InvokeClient(p,"Probe") bridge:InvokeClient(p,"Action",verb,id,forged) task.wait(.25)
 return bridge:InvokeClient(p,"Probe")
end
local function last(packet,kind) for _,v in packet.Packets do if v.Kind==kind then return v end end end
local ok,err=pcall(function()
 for _,id in K.Order do
  local def=K.Definitions[id] local counts={}
  for ticket=1,100 do local item=K.Roll(def,{NextInteger=function() return ticket end}) counts[item.Id]=(counts[item.Id] or 0)+1 end
  for _,item in def.Items do check(counts[item.Id]==item.Chance,id.." exact ticket coverage "..item.Id) end
 end
 check(not C.MonetizationEnabled and C.Products[1].ProductId==0,"Robux remains disabled")
 check(bridge:InvokeClient(p,"Probe").State.CratesAllowed==true,"Real PolicyService allows this test player")
 p.leaderstats.Coins.Value=20000 p.leaderstats.Level.Value=20 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",true)
 m.Weapons={Fists=true} m.EquippedWeapon="Fists" m.Pets={} m.EquippedPet="" E.Refresh(p) E.Send(p)
 local before=p.leaderstats.Coins.Value
 action("OpenCrate",{}) check(p.leaderstats.Coins.Value==before,"Malformed crate id does not debit")
 check(last(action("OpenCrate","Unknown"),"CrateError") and p.leaderstats.Coins.Value==before,"Unknown crate rejects without debit")
 p:SetAttribute("HasStarted",false) action("OpenCrate","Salvage") check(p.leaderstats.Coins.Value==before,"Start gate blocks crate") p:SetAttribute("HasStarted",true)
 p.leaderstats.Level.Value=1 check(last(action("OpenCrate","Arsenal"),"CrateError") and p.leaderstats.Coins.Value==before,"Level gate rejects without debit") p.leaderstats.Level.Value=20
 p.leaderstats.Coins.Value=0 check(last(action("OpenCrate","Pets"),"CrateError") and next(m.Pets)==nil,"Insufficient funds cannot grant pet") p.leaderstats.Coins.Value=before
 for _,id in K.Order do
  local def=K.Definitions[id] local old=p.leaderstats.Coins.Value
  local v=last(action("OpenCrate",id,{Id="LimitedBlade",Cost=0,Chance=100}),"CrateResult") assert(v,"Missing crate result")
  table.insert(outcomes,v)
  local found=false for _,item in def.Items do if item.Id==v.Id and item.Rarity==v.Rarity then found=true end end
  check(found and v.Id~="LimitedBlade",id.." outcome and rarity selected by server; forged payload ignored")
  check(p.leaderstats.Coins.Value==old-def.Cost,id.." exactly one debit")
  check(def.Kind=="Weapon" and m.Weapons[v.Id]==true or def.Kind=="Pet" and m.Pets[v.Id]==1,id.." grant before presentation")
  check(m.EquippedWeapon=="Fists" and m.EquippedPet=="",id.." does not replace equipment")
  local paid=p.leaderstats.Coins.Value action("OpenCrate",id) check(p.leaderstats.Coins.Value==paid,id.." replay in cooldown does not debit")
  task.wait(4.1)
 end
 for _,item in K.Definitions.Salvage.Items do m.Weapons[item.Id]=true end
 local old=p.leaderstats.Coins.Value local v=last(action("OpenCrate","Salvage"),"CrateResult") assert(v)
 check(v.Refund==K.Refund(v.Id) and p.leaderstats.Coins.Value==old-450+v.Refund,"Duplicate weapon grants exact unmultiplied recycling coins")
 task.wait(4.1)
 for _,item in K.Definitions.Pets.Items do m.Pets[item.Id]=3 end
 v=last(action("OpenCrate","Pets"),"CrateResult") check(v and m.Pets[v.Id]==4 and v.Refund==0,"Pet duplicate adds one inventory copy")
 action("EquipPet",v.Id) check(m.EquippedPet==v.Id and p:GetAttribute("CoinsMultiplier")==1+C.Pets[v.Id].Coins,"Crate pet uses normal equipment bonuses")
 task.wait(4.1) m.Pets.Civilian=100000 old=p.leaderstats.Coins.Value
 check(last(action("OpenCrate","Pets"),"CrateError") and p.leaderstats.Coins.Value==old,"Pet inventory cap rejects before debit")
 m.Pets={} m.EquippedPet="" p.leaderstats.Coins.Value=20000 E.Refresh(p) E.Send(p)
 -- Leave a temporary funded profile for native UI checks; RestoreCratesQA removes it.
end)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Outcomes=outcomes})
