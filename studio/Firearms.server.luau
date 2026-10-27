local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local CollectionService=game:GetService("CollectionService")
local C=require(RS:WaitForChild("GameplayConfig"))
local Ballistics=require(RS:WaitForChild("FirearmBallistics"))
local remotes=RS:WaitForChild("Remotes")
local function remote(name)
 local r=remotes:FindFirstChild(name) or Instance.new("RemoteEvent") r.Name=name r.Parent=remotes return r
end
local shoot,reload,fx=remote("Shoot"),remote("ReloadGun"),remote("ShotFX")
local sessions={}
local function current(p)
 local id=p:GetAttribute("EquippedWeapon") local w=C.Weapons[id]
 if not w or not w.Firearm then return end
 local session=sessions[p] if not session then session={} sessions[p]=session end
 local s=session[id] if not s then s={Ammo=w.Magazine,Last=-math.huge,Token=0} session[id]=s end
 return id,w,s
end
local function publish(p)
 local id,w,s=current(p)
 p:SetAttribute("GunAmmo",s and s.Ammo or 0) p:SetAttribute("GunMagazine",w and w.Magazine or 0)
 p:SetAttribute("GunReloadStarted",s and s.Reloading and s.ReloadStarted or 0)
 p:SetAttribute("GunReloadDuration",w and w.ReloadTime or 0)
 p:SetAttribute("GunReloading",s and s.Reloading==true or false)
end
local function valid(p)
 local c=p.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 return c and h and h.Health>0 and p:GetAttribute("HasStarted")==true and not p:GetAttribute("InGameMenu")
end
local function startReload(p)
 if not valid(p) then return end
 local id,w,s=current(p) if not s or s.Reloading or s.Ammo>=w.Magazine then return end
 s.Reloading=true s.ReloadStarted=workspace:GetServerTimeNow() s.Token+=1 local token=s.Token local character=p.Character publish(p)
 task.delay(w.ReloadTime,function()
  if not p.Parent or not sessions[p] or s.Token~=token then return end
  s.Reloading=false
  if p.Character==character and valid(p) and p:GetAttribute("EquippedWeapon")==id then s.Ammo=w.Magazine end
  publish(p)
 end)
end
reload.OnServerEvent:Connect(startReload)
local function zombie(part)
 local x=part
 while x and x~=workspace do
  if x:IsA("Model") and CollectionService:HasTag(x,"Zombie") then return x end
  x=x.Parent
 end
end
local function trace(character,origin,direction)
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
 local exclude={character} local result
 for _=1,32 do
  params.FilterDescendantsInstances=exclude
  result=workspace:Raycast(origin,direction,params)
  if not result then return end
  local target=zombie(result.Instance)
  if target or result.Instance.CanCollide then return result,target end
  table.insert(exclude,result.Instance)
 end
 return result,nil -- Too many decorations: stop safely without damage.
end
shoot.OnServerEvent:Connect(function(p,direction)
 if not valid(p) or typeof(direction)~="Vector3" or direction~=direction then return end
 local magnitude=direction.Magnitude if magnitude<.5 or magnitude>1.5 then return end
 local id,w,s=current(p) if not s or s.Reloading then return end
 local now=os.clock() if now-s.Last<w.Cooldown*.9 then return end
 if s.Ammo<=0 then startReload(p) return end
 local c=p.Character local head=c:FindFirstChild("Head") if not head then return end
 s.Last=now s.Ammo-=1 publish(p)
 local origin=head.Position local destinations={} local damage={}
 for _,ray in Ballistics.Directions(direction,w) do
  local result,target=trace(c,origin,ray*w.Range)
  table.insert(destinations,result and result.Position or origin+ray*w.Range)
  if target then
   local amount,critical=Ballistics.HitDamage(w,result.Instance,target,C.HeadshotMultiplier)
   local entry=damage[target]
   if entry then
    entry.Amount+=amount entry.Critical=entry.Critical or critical
    if critical then entry.Position=result.Position end
   else damage[target]={Amount=amount,Position=result.Position,Critical=critical} end
  end
 end
 c:SetAttribute("SwingWeapon",id) c:SetAttribute("SwingCombo",1) c:SetAttribute("SwingAt",workspace:GetServerTimeNow())
 fx:FireAllClients(p,origin,destinations,id)
 for target,entry in damage do
  local h=target:FindFirstChildOfClass("Humanoid")
  if h and h.Health>0 then
   local zoneId=target:GetAttribute("ZoneId")
   if zoneId then
    local world=require(RS.WorldConfig) local zone=world.ZoneAt(origin)
    if not zone or zone.Id~=zoneId or not require(script.Parent.ZoneService).CanAccess(p,zone) then continue end
   end
   h:SetAttribute("LastAttacker",p.UserId) h:SetAttribute("LastHitAt",os.clock())
   h:TakeDamage(entry.Amount) remotes.PunchHit:FireClient(p,entry.Critical,h.Health<=0,entry.Amount,entry.Position,entry.Critical and "Headshot" or nil)
  end
 end
 if s.Ammo<=0 then startReload(p) end
end)
local function setup(p)
 p:GetAttributeChangedSignal("EquippedWeapon"):Connect(function()
  for _,s in sessions[p] or {} do s.Token+=1 s.Reloading=false end publish(p)
 end)
 p.CharacterAdded:Connect(function() sessions[p]={} publish(p) end)
 publish(p)
end
Players.PlayerAdded:Connect(setup) Players.PlayerRemoving:Connect(function(p) sessions[p]=nil end)
for _,p in Players:GetPlayers() do setup(p) end
