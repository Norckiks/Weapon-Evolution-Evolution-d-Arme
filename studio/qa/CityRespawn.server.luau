-- Temporary SessionStudio integration; test NPC changes disappear when Play stops.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p and p:GetAttribute("PersistenceMode")=="SessionStudio")
local W=require(game.ReplicatedStorage.WorldConfig) local Q=require(game.ReplicatedStorage.QuickContracts)
local P=require(game.ServerScriptService.ProgressionService) local meta=P.GetMeta(p)
local before=game.HttpService:JSONEncode(meta.QuickContract or {})
local result=Instance.new("StringValue") result.Name="CityRespawnQAResult" result.Value="Running" result.Parent=game.ServerStorage
local checks,metrics={},{} local function check(v,name) assert(v,name) table.insert(checks,name) end
local function alive(zone,id)
 local list={} for _,m in workspace.LiveZombies:GetChildren() do local h=m:FindFirstChildOfClass("Humanoid") if m:GetAttribute("ZoneId")==zone and m:GetAttribute("ZombieType")==id and h and h.Health>0 then table.insert(list,m) end end return list
end
local function waitFor(fn,timeout) local deadline=os.clock()+timeout repeat local v=fn() if v then return v end task.wait(.05) until os.clock()>=deadline error("Timed out waiting for NPCs") end
local removed
local ok,err=pcall(function()
 local city=W.Zones[1] local factory=W.Zones[2]
 check(city.Id=="City" and city.RespawnDelay==7 and (factory.RespawnDelay or W.RespawnDelay)==10,"Only City uses seven-second respawn")
 check(Q.Definitions[3].Target==7 and Q.Definitions[3].Coins==100 and Q.Definitions[3].XP==60,"Existing contract target and rewards unchanged")
 waitFor(function() return #alive("City","Civilian")==2 and #alive("City","Runner")==2 and #alive("Factory","Worker")==2 end,8)
 local civil=alive("City","Civilian")[1] local runner=alive("City","Runner")[1] local worker=alive("Factory","Worker")[1]
 local start=os.clock() civil.Humanoid:TakeDamage(civil.Humanoid.MaxHealth+1) worker.Humanoid:TakeDamage(worker.Humanoid.MaxHealth+1)
 removed=runner runner.Parent=nil
 local times={}
 waitFor(function()
  local now=os.clock()-start
  if not times.CityDeath and #alive("City","Civilian")==2 then times.CityDeath=now end
  if not times.CityRemoval and #alive("City","Runner")==2 then times.CityRemoval=now end
  if not times.FactoryDeath and #alive("Factory","Worker")==2 then times.FactoryDeath=now end
  return times.CityDeath and times.CityRemoval and times.FactoryDeath
 end,13)
 metrics=times
 check(times.CityDeath>=6.9 and times.CityDeath<8.8,"City death respawns near seven seconds")
 check(times.CityRemoval>=6.9 and times.CityRemoval<8.8,"Removed City NPC respawns near seven seconds")
 check(times.FactoryDeath>=9.9 and times.FactoryDeath<11.8,"Factory retains ten-second delay")
 check(game.HttpService:JSONEncode(meta.QuickContract or {})==before,"Uncredited NPC removals do not alter contract")
end)
if removed then removed:Destroy() end
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Metrics=metrics})
