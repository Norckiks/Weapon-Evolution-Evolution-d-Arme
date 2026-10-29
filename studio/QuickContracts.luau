local Q={}
Q.ZoneMultipliers={City=1,Factory=2,Lab=4,Harbor=7,Power=10,Metro=14,Quarantine=18,Dam=22,Citadel=26,Crater=32,GlassSea=38,Skyline=44,OrbitalWreck=50,Depths=52,IronSanctum=54,LastConvoy=56,Gridfall=58,BlackoutCore=60,EclipseVault=62}
Q.Definitions={
 {Name="Premiere sortie",Description="Elimine 3 zombies",Target=3,Coins=40,XP=20},
 {Name="Chasseur polyvalent",Description="Elimine 2 especes differentes",Target=2,Coins=60,XP=30,Variety=true},
 {Name="Nettoyage express",Description="Elimine 7 zombies",Target=7,Coins=100,XP=60},
}
function Q.Ensure(meta)
 local s=meta.QuickContract
 if typeof(s)~="table" then s={} meta.QuickContract=s end
 local index=s.Index
 if typeof(index)~="number" or index~=index or index<1 or index>#Q.Definitions or index%1~=0 then index=1 end
 s.Index=index
 local count=s.Count
 if typeof(count)~="number" or count~=count then count=0 end
 s.Count=math.clamp(math.floor(count),0,Q.Definitions[index].Target-1)
 if typeof(s.Seen)~="table" then s.Seen={} end
 local multiplier=s.Multiplier
 if typeof(multiplier)~="number" or multiplier~=multiplier or math.abs(multiplier)==math.huge then multiplier=1 end
 s.Multiplier=math.clamp(math.floor(multiplier),1,62)
 return s,Q.Definitions[index]
end
function Q.Reward(s)
 local d=Q.Definitions[s.Index] local multiplier=s.Count==0 and 1 or s.Multiplier or 1
 return {Coins=d.Coins*multiplier,XP=d.XP*multiplier,Multiplier=multiplier}
end
function Q.OnKill(meta,species,zoneId)
 local s,d=Q.Ensure(meta)
 if d.Variety then
  if s.Seen[species] then return end
  s.Seen[species]=true
 end
 local multiplier=Q.ZoneMultipliers[zoneId] or 1
 s.Multiplier=s.Count==0 and multiplier or math.min(s.Multiplier,multiplier)
 s.Count+=1
 if s.Count<d.Target then return end
 -- Advance before awarding: a completed contract cannot be claimed again.
 local reward=Q.Reward(s)
 s.Index=s.Index%#Q.Definitions+1 s.Count=0 s.Seen={} s.Multiplier=1
 return reward
end
return Q
