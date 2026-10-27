-- Pure stamina rules; the server supplies movement and elapsed time.
local State={}
function State.new(config)
 return {stamina=config.MaxStamina,maxStamina=config.MaxStamina,wants=false,exhausted=false,sprinting=false,rest=0}
end
function State.step(s,config,dt,moving,alive)
 if not alive then
  s.wants=false s.sprinting=false return
 end
 if s.exhausted and not s.wants and s.stamina>=config.RecoveryThreshold then s.exhausted=false end
 s.sprinting=s.wants and moving and not s.exhausted and s.stamina>0
 if s.sprinting then
  s.stamina=math.max(0,s.stamina-config.DrainPerSecond*dt)
  s.rest=0
  if s.stamina<=0 then s.exhausted=true s.sprinting=false end
 else
  local previousRest=s.rest
  s.rest+=dt
  local regenTime=math.max(0,s.rest-math.max(previousRest,config.RegenDelay))
  s.stamina=math.min(s.maxStamina or config.MaxStamina,s.stamina+config.RegenPerSecond*regenTime)
 end
end
return State
