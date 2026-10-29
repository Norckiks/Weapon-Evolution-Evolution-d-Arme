-- Shared definitions and bounded profile rules. EconomyService alone authorizes claims/rewards.
local W=require(script.Parent.WorldConfig)
local X={}
X.Rewards={City={Coins=120,XP=60},Factory={Coins=550,XP=240},Lab={Coins=1400,XP=650},Harbor={Coins=3000,XP=1300},Power={Coins=6000,XP=2600},Metro={Coins=10000,XP=4500},Quarantine={Coins=15000,XP=6800},Dam={Coins=22000,XP=9800},Citadel={Coins=32000,XP=14500},Crater={Coins=42000,XP=19000},GlassSea={Coins=62000,XP=29000},Skyline={Coins=90000,XP=43000},OrbitalWreck={Coins=120000,XP=55000},Depths={Coins=160000,XP=72000},IronSanctum={Coins=180000,XP=80000},LastConvoy={Coins=220000,XP=100000},Gridfall={Coins=280000,XP=130000},BlackoutCore={Coins=350000,XP=170000},EclipseVault={Coins=430000,XP=210000}}
X.Steps={{Name="Prendre pied",Target=6},{Name="Connaitre la menace",Target=3,Variety=true},{Name="Nettoyer le secteur",Target=18}}
local zones={} local species={}
for _,zone in W.Zones do
 zones[zone.Id]=zone
 for _,id in zone.Types do species[id]=zone end
end
local function integer(value,max)
 if typeof(value)~="number" or value~=value or math.abs(value)==math.huge then return 0 end
 return math.clamp(math.floor(value),0,max)
end
function X.Ensure(meta)
 if typeof(meta.Expeditions)~="table" then meta.Expeditions={} end
 for id in X.Rewards do
  local s=meta.Expeditions[id] if typeof(s)~="table" then s={} meta.Expeditions[id]=s end
  s.Kills=integer(s.Kills,18) s.Claimed=integer(s.Claimed,3)
  local old=typeof(s.Seen)=="table" and s.Seen or {} local seen={}
  for _,typeId in zones[id].Types do if old[typeId]==true then seen[typeId]=true end end
  s.Seen=seen
 end
 return meta.Expeditions
end
function X.ZoneForSpecies(id) return species[id] end
function X.OnKill(meta,id)
 local zone=species[id] if not zone or not X.Rewards[zone.Id] then return end
 local s=X.Ensure(meta)[zone.Id] s.Kills=math.min(18,s.Kills+1) s.Seen[id]=true
end
function X.Progress(record,zone,step)
 local d=X.Steps[step] if not d then return 0,1 end
 local count=0
 if d.Variety then for _,id in zone.Types do if record and record.Seen and record.Seen[id]==true then count+=1 end end
 else count=record and record.Kills or 0 end
 return math.min(count,d.Target),d.Target
end
function X.Reward(zoneId,step)
 local d=X.Rewards[zoneId] if not d or not X.Steps[step] then return end
 local factor=1+(step-1)*.5
 return {Coins=math.floor(d.Coins*factor),XP=math.floor(d.XP*factor)}
end
function X.Parse(key)
 if typeof(key)~="string" then return end
 local id,step=key:match("^([%a]+):([123])$")
 if id and X.Rewards[id] then return zones[id],tonumber(step) end
end
function X.Claim(meta,zoneId,step)
 local zone=zones[zoneId] if not zone or not X.Rewards[zoneId] then return end
 local s=X.Ensure(meta)[zoneId]
 if step~=s.Claimed+1 or not X.Steps[step] then return end
 local count,target=X.Progress(s,zone,step) if count<target then return end
 s.Claimed=step -- Commit the receipt before the server awards; repeated requests cannot pay twice.
 return X.Reward(zoneId,step)
end
return X
