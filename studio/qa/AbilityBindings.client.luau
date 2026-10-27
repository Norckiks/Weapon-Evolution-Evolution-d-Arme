-- Temporary Play assertion; run after all client controllers have bound their actions.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local bindings=game.ContextActionService:GetAllBoundActionInfo()
local expected={SurvivalArc={"K","ButtonL2"},SurvivalFrost={"T","DPadRight"},SurvivalSlam={"E","DPadLeft"},SurvivalAegis={"H","ButtonR3"},SurvivalSecondSouffle={"J","DPadDown"},SurvivalReload={"R","ButtonX"},SurvivalVault={"V","ButtonY"},SurvivalDash={"LeftControl","ButtonB"}}
local checks={} local used={}
for name,keys in expected do
 local actual={} assert(bindings[name],"Missing action: "..name)
 for _,key in bindings[name].inputTypes do actual[key.Name]=true end
 for _,key in keys do assert(actual[key],name.." missing "..key) end
 table.insert(checks,"Expected inputs: "..name)
end
for name,info in bindings do
 if name:match("^Survival") or name:match("^Survivor") or name:match("^Fists") then
  for _,key in info.inputTypes do
   local id=tostring(key)
   assert(not used[id] or used[id]==name,"Input collision: "..id.." / "..tostring(used[id]).." / "..name)
   used[id]=name
  end
 end
end
table.insert(checks,"No shared input among survival, survivor and fists actions")
local result=Instance.new("StringValue") result.Name="AbilityBindingsQAResult" result.Value=game.HttpService:JSONEncode({Passed=true,Checks=checks,Bindings=used}) result.Parent=p.PlayerGui
script:Destroy()
