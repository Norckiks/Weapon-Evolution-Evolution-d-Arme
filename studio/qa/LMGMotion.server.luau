-- Temporary ordinary Script in SessionStudio. Restore all fixture changes.
assert(game.RunService:IsStudio())
local p=game.Players:GetPlayers()[1] assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local E=require(game.ServerScriptService.EconomyService) local P=require(game.ServerScriptService.ProgressionService)
local m=P.GetMeta(p) local original=game.HttpService:JSONEncode(m)
local started,menu=p:GetAttribute("HasStarted"),p:GetAttribute("InGameMenu")
local root=p.Character.HumanoidRootPart local cf,anchored=p.Character:GetPivot(),root.Anchored
local result=Instance.new("StringValue",game.ServerStorage) result.Name="LMGMotionResult" result.Value="Running"
local samples={} local checks={} local function check(ok,name) assert(ok,name) table.insert(checks,name) end
local ok,err=pcall(function()
 m.Weapons.LMG=true m.EquippedWeapon="LMG" p:SetAttribute("HasStarted",true) p:SetAttribute("InGameMenu",false)
 root.Anchored=true p.Character:PivotTo(CFrame.new(0,1000,0)) E.Refresh(p) E.Send(p) task.wait(.4)
 local bridge=game.ReplicatedStorage.LMGMotionBridge
 bridge:InvokeClient(p,"Reload")
 for _,verb in {"Shoot","ReducedShoot","MutedShoot","Reload"} do
  local ammo=p:GetAttribute("GunAmmo")
  samples[verb]=bridge:InvokeClient(p,verb)
  if verb~="Reload" then check(p:GetAttribute("GunAmmo")==ammo-1,verb.." accepted by server") end
  check(samples[verb].Frames>1,verb.." sampled real world motors")
  check(samples[verb].Last<.001,verb.." returns to rest")
 end
 check(samples.Shoot.Bolt>.13,"World bolt moves full stroke")
 check(samples.ReducedShoot.Bolt>.032 and samples.ReducedShoot.Bolt<.041,"Reduced stroke is one quarter")
 check(samples.Reload.Magazine>.81,"World magazine insertion")
 check(samples.Reload.Cover>1.09,"World feed cover hinges open")
 check(samples.Reload.Bolt>.13 and samples.Reload.Bolt<.161,"World bolt cycles during reload")
 check(p:GetAttribute("GunAmmo")==48 and not p:GetAttribute("GunReloading"),"Three accepted shots and refill")
 check(samples.Shoot.Sounds.GunShot==1,"One shot sound created")
 check(next(samples.MutedShoot.Sounds)==nil,"Muted shot creates no sounds")
end)
table.clear(m) for k,v in game.HttpService:JSONDecode(original) do m[k]=v end
p:SetAttribute("HasStarted",started) p:SetAttribute("InGameMenu",menu) p.Character:PivotTo(cf) root.Anchored=anchored E.Refresh(p) E.Send(p)
result.Value=game.HttpService:JSONEncode({Passed=ok,Error=not ok and tostring(err) or nil,Checks=checks,Samples=samples,Restored=true})
