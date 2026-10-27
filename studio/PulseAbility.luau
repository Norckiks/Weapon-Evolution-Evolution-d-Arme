-- Server owns unlocks, stamina, cooldowns, protection, healing and all damage.
local Players=game:GetService("Players")
local RS=game.ReplicatedStorage
local CS=game:GetService("CollectionService")
local Gameplay=require(RS.GameplayConfig)
local W=require(RS.WorldConfig)
local Zones=require(script.Parent.ZoneService)
local Movement=require(script.Parent.AdvancedMovement)
local NPC=require(script.Parent.NPCPresentation)
local M={} local ready={} local requests={}
Players.PlayerRemoving:Connect(function(p) ready[p]=nil requests[p]=nil end)
function M.Bind(player,character)
 ready[player]=ready[player] or {}
 character:SetAttribute("PulseReadyAt",ready[player].Pulse or 0)
 for id in Gameplay.Abilities do character:SetAttribute(id.."ReadyAt",ready[player][id] or 0) end
 character:SetAttribute("GuardUntil",0)
end
local function sight(character,target,from,to,source)
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances=source and {character,target,source} or {character,target} params.RespectCanCollide=true
 return workspace:Raycast(from,to-from,params)==nil
end
function M.Handle(player,s,id,aimDirection)
 if typeof(id)~="string" then return false,"Action" end
 local d=id=="Pulse" and Gameplay.Pulse or Gameplay.Abilities[id]
 if not d then return false,"Action" end
 local now=workspace:GetServerTimeNow()
 if now-(requests[player] or -math.huge)<.1 then return false,"Rate" end requests[player]=now
 if not s or s.character~=player.Character or not s.humanoid or s.humanoid.Health<=0 or player:GetAttribute("ProgressReady")~=true or player:GetAttribute("HasStarted")~=true or player:GetAttribute("InGameMenu") then return false,"State" end
 local c,h=s.character,s.humanoid local root=c:FindFirstChild("HumanoidRootPart")
 if not root or root.Anchored or h.Sit or h.PlatformStand or h.FloorMaterial==Enum.Material.Air then return false,"Ground" end
 local aimedForward
 if id=="Frost" then
  if typeof(aimDirection)~="Vector3" or aimDirection~=aimDirection or aimDirection.Magnitude<.9 or aimDirection.Magnitude>1.1 then return false,"Aim" end
  local flat=Vector3.new(aimDirection.X,0,aimDirection.Z)
  if flat.Magnitude<.25 then return false,"Aim" end
  aimedForward=flat.Unit
 end
 local ls=player:FindFirstChild("leaderstats") local level=ls and ls:FindFirstChild("Level")
 if not level or level.Value<d.Level then return false,"Level" end
 ready[player]=ready[player] or {}
 if now<(ready[player][id] or 0) then return false,"Cooldown" end
 if s.crouching or Movement.Busy(s) or (c:GetAttribute("DashUntil") or 0)>now or player:GetAttribute("GunReloading") then return false,"Busy" end
 if s.stamina<d.Cost then return false,"Stamina" end
 local zone=W.ZoneAt(root.Position)
 if not zone or not Zones.CanAccess(player,zone) then return false,"Zone" end
 if id=="SecondSouffle" and h.Health>=h.MaxHealth then return false,"Health" end
 s.stamina-=d.Cost s.rest=0
 ready[player][id]=now+d.Cooldown
 local readyAttribute=id=="Pulse" and "PulseReadyAt" or id.."ReadyAt"
 c:SetAttribute(readyAttribute,ready[player][id]) c:SetAttribute("AbilityAt",now) c:SetAttribute("AbilityId",id)
 c:SetAttribute("Stamina",math.floor(s.stamina*10+.5)/10)
 if id=="Aegis" then
  c:SetAttribute("GuardUntil",now+d.Duration)
  RS.Remotes.AbilityFX:FireAllClients(id,player,root.Position,0)
  return true,0
 end
 if id=="SecondSouffle" then
  local healed=math.min(h.MaxHealth-h.Health,math.floor(h.MaxHealth*d.Heal+.5))
  h.Health+=healed
  RS.Remotes.AbilityFX:FireAllClients(id,player,root.Position,0)
  return true,healed
 end
 local targets={} local forward=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
 if forward.Magnitude<.01 then forward=Vector3.zAxis else forward=forward.Unit end
 if aimedForward then forward=aimedForward end
 for _,m in CS:GetTagged("Zombie") do
  local r=m:FindFirstChild("HumanoidRootPart") local enemy=m:FindFirstChildOfClass("Humanoid")
  if r and enemy and enemy.Health>0 and m:GetAttribute("ZoneId")==zone.Id then
   local delta=r.Position-root.Position local distance=delta.Magnitude
   local facing=Vector3.new(delta.X,0,delta.Z)
   local along=facing:Dot(forward) local side=(facing-forward*along).Magnitude
   local inShape=d.Shape=="Beam" and along>0 and side<=d.Width or d.Shape=="Cone" and (facing.Magnitude<.01 or facing.Unit:Dot(forward)>=d.Dot) or d.Shape~="Beam" and d.Shape~="Cone"
   if distance<=d.Range and inShape and sight(c,m,root.Position+Vector3.new(0,1,0),r.Position+Vector3.new(0,1,0)) then table.insert(targets,{Model=m,Root=r,Humanoid=enemy,Distance=distance}) end
  end
 end
 table.sort(targets,function(a,b) return a.Distance<b.Distance end)
 if id=="Arc" and targets[1] then
  local chain={targets[1]} local seen={[targets[1].Model]=true}
  for _=2,d.MaxTargets do
   local previous=chain[#chain] local best local nearest=d.JumpRange
   for _,model in CS:GetTagged("Zombie") do
    local r=model:FindFirstChild("HumanoidRootPart") local enemy=model:FindFirstChildOfClass("Humanoid")
    if not seen[model] and r and enemy and enemy.Health>0 and model:GetAttribute("ZoneId")==zone.Id then
     local distance=(r.Position-previous.Root.Position).Magnitude
     if distance<=nearest and sight(c,model,previous.Root.Position+Vector3.new(0,1,0),r.Position+Vector3.new(0,1,0),previous.Model) then
      nearest=distance best={Model=model,Root=r,Humanoid=enemy,Distance=distance}
     end
    end
   end
   if not best then break end
   table.insert(chain,best) seen[best.Model]=true
  end
  targets=chain
 end
 local arcPath=id=="Arc" and {root.Position+Vector3.new(0,1,0)} or nil
 local hits=0 local impactPosition
 for i=1,math.min(#targets,d.MaxTargets) do
  local t=targets[i] local damage=id=="Arc" and math.floor(d.Damage*d.Falloff^(i-1)+.5) or d.Damage
  if arcPath then table.insert(arcPath,t.Root.Position+Vector3.new(0,1,0)) end
  local delta=t.Root.Position-root.Position local flat=Vector3.new(delta.X,0,delta.Z)
  if flat.Magnitude<.01 then flat=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z) end
  if flat.Magnitude<.01 then flat=Vector3.zAxis end flat=flat.Unit
  impactPosition=t.Root.Position
  t.Model:SetAttribute("StunnedUntil",math.max(t.Model:GetAttribute("StunnedUntil") or 0,now+d.Stun))
  NPC.Hit(t.Model,flat,true)
  t.Humanoid:SetAttribute("LastAttacker",player.UserId) t.Humanoid:SetAttribute("LastHitAt",os.clock())
  t.Humanoid:TakeDamage(damage) hits+=1
  if t.Humanoid.Health>0 and not t.Root.Anchored then
   local scale=math.max(1,t.Model:GetScale()) local velocity=t.Root.AssemblyLinearVelocity
   local desired=flat*(d.Knockback/scale)+Vector3.new(0,math.clamp(velocity.Y+6,6,12),0)
   local mass=t.Root.AssemblyMass
   if mass>0 and mass<1e7 then t.Root:ApplyImpulse((desired-velocity)*mass) end
  end
  RS.Remotes.PunchHit:FireClient(player,false,t.Humanoid.Health<=0,damage,t.Root.Position)
 end
 local event=id=="Pulse" and RS.Remotes.PulseFX or RS.Remotes.AbilityFX
 if id=="Pulse" then event:FireAllClients(player,root.Position,hits) else
  if id=="Frost" then
   impactPosition=impactPosition or root.Position+forward*d.Range
   local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={c} params.RespectCanCollide=true
   local wall=workspace:Raycast(root.Position+Vector3.new(0,1,0),forward*d.Range,params)
   if wall and (not targets[1] or wall.Instance:IsDescendantOf(targets[1].Model)==false) then impactPosition=wall.Position end
  end
  event:FireAllClients(id,player,root.Position,hits,arcPath or impactPosition)
 end
 return true,hits
end
return M
