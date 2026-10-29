-- Temporary server Play Script only; never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1]
assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local A=require(game.ServerScriptService.AdminService)
local P=require(game.ServerScriptService.ProgressionService)
local E=require(game.ServerScriptService.EconomyService)
local H=game:GetService("HttpService")
local result=Instance.new("StringValue") result.Name="AdminQAResult" result.Parent=game.ServerStorage
local tests={}
local function check(ok,name) assert(ok,name) table.insert(tests,name) end
E.Refresh(p)
local m=P.GetMeta(p)
local snapshot=H:JSONEncode(m)
local coins,level,xp,started=p.leaderstats.Coins.Value,p.leaderstats.Level.Value,p.Progress.XP.Value,p:GetAttribute("HasStarted")
local function call(verb,id,amount) task.wait(.32) return A.Handle(p,verb,id,amount) end
local ok,err=xpcall(function()
 check(A.IsOwner(p),"Owner authorized")
 local foreign={UserId=42,AdminAccess=true}
 check(not A.Handle(foreign,"Coins",nil,1000),"Foreign ID rejected despite forged attribute")
 check(not A.Handle(foreign,"GrantAdmin","AnotherUser",1),"Delegated access cannot grant admin")
 check(not A.Handle(foreign,"ListAdmins",nil,1),"Delegated access cannot list or manage admin grants")
 p:SetAttribute("HasStarted",false)
 check(not call("Coins",nil,1),"Before Start rejected")
 p:SetAttribute("HasStarted",true)
 for _,bad in {0,-1,.5,0/0,math.huge,"100",{},1000001} do check(not call("Coins",nil,bad),"Invalid amount "..typeof(bad)..":"..tostring(bad)) end
 check(not call("Weapon","Bogus",1),"Unknown weapon rejected")
 check(not call("Pet","Bogus",1),"Unknown pet rejected")
 check(not call("Fragments","Buddy",1),"Buddy fragments rejected")
 check(not call("DeleteAll",nil,1),"Unknown verb rejected")
 check(call("Coins",nil,123) and p.leaderstats.Coins.Value==coins+123,"Exact coin grant")
 check(not A.Handle(p,"Coins",nil,123) and p.leaderstats.Coins.Value==coins+123,"Rate limit prevents duplicate")
 check(call("Levels",nil,3) and p.leaderstats.Level.Value==level+3 and p.Progress.XP.Value==xp,"Level grant retains XP")
 check(call("XP",nil,10) and p.Progress.XP.Value==xp+10,"Exact XP grant")
 local weapon=m.EquippedWeapon local pet=m.EquippedPet
 check(call("Weapon","Shotgun",1) and m.Weapons.Shotgun,"Weapon granted")
 check(call("Weapon","LimitedBlade",1) and m.Weapons.LimitedBlade,"Nova test grant without payment")
 local before=m.Pets.Buddy or 0
 check(call("Pet","Buddy",2) and m.Pets.Buddy==before+2,"Pet copies granted")
 before=m.Fragments.Civilian or 0
 check(call("Fragments","Civilian",3) and m.Fragments.Civilian==before+3,"Fragments granted")
 check(m.EquippedWeapon==weapon and m.EquippedPet==pet,"Equipment preserved")
 check(H:JSONEncode(m.Receipts)==H:JSONEncode(H:JSONDecode(snapshot).Receipts),"Receipts preserved")
 p.leaderstats.Coins.Value=2000000000 check(not call("Coins",nil,1),"Coin cap enforced")
 p.leaderstats.Level.Value=100000 check(not call("Levels",nil,1),"Level cap enforced")
 m.Pets.Buddy=100000 check(not call("Pet","Buddy",1),"Pet cap enforced")
 m.Fragments.Civilian=1000000 check(not call("Fragments","Civilian",1),"Fragment cap enforced")
end,debug.traceback)
for k in m do m[k]=nil end for k,v in H:JSONDecode(snapshot) do m[k]=v end
p.leaderstats.Coins.Value=coins p.leaderstats.Level.Value=level p.Progress.XP.Value=xp p:SetAttribute("HasStarted",started)
E.Refresh(p) E.Send(p)
result.Value=H:JSONEncode({Passed=ok,Tests=tests,Error=not ok and err or nil,Restored=true})

