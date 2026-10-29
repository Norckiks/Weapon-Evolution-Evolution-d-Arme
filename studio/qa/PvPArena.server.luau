-- Play-only assertions for PvP bounds and server-side refusal paths.
local Players=game:GetService("Players")
local PvP=require(game.ServerScriptService:WaitForChild("PvPService"))
local W=require(game.ReplicatedStorage:WaitForChild("WorldConfig"))
local arena=workspace:WaitForChild("SurvivorArena")
local bounds=arena:WaitForChild("FightBounds")
local center=bounds.Position
assert(PvP.Contains(center),"Arena center must enable PvP")
assert(PvP.Contains(center+Vector3.new(bounds.Size.X/2,0,0)),"Arena edge must stay inside the PvP bounds")
assert(not PvP.Contains(center+Vector3.new(bounds.Size.X/2+1,0,0)),"PvP must stop outside the arena")
assert(PvP.CanEngage(true,true,false,false),"Arena PvP stays enabled without opt-in")
assert(not PvP.CanEngage(false,false,false,false),"PvP outside the arena starts disabled")
assert(not PvP.CanEngage(false,false,true,false),"Outside PvP requires both players to opt in")
assert(PvP.CanEngage(false,false,true,true),"Mutual opt-in enables outside PvP")
assert(not PvP.CanEngage(true,false,true,true),"PvP cannot cross the arena boundary")
for _,dx in {-bounds.Size.X/2,bounds.Size.X/2} do for _,dz in {-bounds.Size.Z/2,bounds.Size.Z/2} do
	assert(W.ZoneAt(center+Vector3.new(dx,-8,dz))==nil,"PvP arena must remain outside zombie zones")
end end
local player=Players:GetPlayers()[1]
if player then assert(not PvP.CanDamage(player,player),"Players cannot damage themselves") end
workspace:SetAttribute("PvPArenaQAPassed",true)
workspace:SetAttribute("PvPArenaQAResult","bounds, arena override, outside opt-in, boundary, and self-damage checks passed")
script:Destroy()
