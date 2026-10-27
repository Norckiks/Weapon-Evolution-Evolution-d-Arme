-- Temporary SessionStudio fixture and assertions. RestoreIdeasQA before stopping Play.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local P=require(game.ServerScriptService.ProgressionService) local E=require(game.ServerScriptService.EconomyService)
local S=require(game.ReplicatedStorage.SprintConfig) local M=require(game.ReplicatedStorage.MovementConfig)
local meta=P.GetMeta(p) local saved={Meta=game.HttpService:JSONEncode(meta),Level=p.leaderstats.Level.Value,Coins=p.leaderstats.Coins.Value,XP=p.Progress.XP.Value,CF=p.Character:GetPivot(),Started=p:GetAttribute("HasStarted"),Menu=p:GetAttribute("InGameMenu")}
local arena=Instance.new("Folder") arena.Name="IdeasMovementQA" arena.Parent=workspace
local floor=Instance.new("Part") floor.Name="TestFloor" floor.Size=Vector3.new(350,1,350) floor.Position=Vector3.new(0,59.5,900) floor.Anchored=true floor.Parent=arena
local restore=Instance.new("BindableFunction") restore.Name="RestoreIdeasQA" restore.Parent=game.ServerStorage
restore.OnInvoke=function()
 table.clear(meta) for k,v in game.HttpService:JSONDecode(saved.Meta) do meta[k]=v end
 p.leaderstats.Level.Value=saved.Level p.leaderstats.Coins.Value=saved.Coins p.Progress.XP.Value=saved.XP
 E.Refresh(p) E.Send(p) p.Character:PivotTo(saved.CF) p:SetAttribute("HasStarted",saved.Started) p:SetAttribute("InGameMenu",saved.Menu)
 arena:Destroy() restore:Destroy() script:Destroy() return true
end
local checks={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
check(S.WalkSpeed==18 and S.SprintSpeed==32,"New base movement speeds")
check(M.Acceleration==14 and M.SlideSpeed==40 and M.VaultForwardSpeed==22,"Snappier acceleration, slide and vault")
local state=require(game.ServerScriptService.SprintState).new(S) state.wants=true
require(game.ServerScriptService.SprintState).step(state,S,1,true,true)
check(state.stamina==80 and state.sprinting,"Faster sprint still consumes authoritative stamina")
meta.SpeedLevel=1 meta.Pets={Buddy=1} meta.EquippedPet="Buddy" E.Refresh(p)
check(math.abs(p:GetAttribute("BaseWalkSpeed")-(18+.8)*1.03)<.001,"Speed upgrade and pet compose with new walking base")
check(math.abs(p:GetAttribute("SprintWalkSpeed")-(32+.8)*1.03)<.001,"Speed upgrade and pet compose with new sprint base")
meta.SpeedLevel=0 meta.Pets={} meta.EquippedPet="" meta.Weapons.Pistol=true meta.Weapons.Pipe=true meta.EquippedWeapon="Pistol"
p.leaderstats.Level.Value=20 p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false) E.Refresh(p) E.Send(p)
p.Character:PivotTo(CFrame.new(0,64,900)) p.Character.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero
local result=Instance.new("StringValue") result.Name="IdeasMovementQAResult" result.Value=game.HttpService:JSONEncode({Passed=true,Checks=checks}) result.Parent=game.ServerStorage
