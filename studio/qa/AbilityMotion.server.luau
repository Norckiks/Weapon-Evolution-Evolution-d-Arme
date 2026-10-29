-- Temporary ordinary server Script in Play only.
assert(game:GetService("RunService"):IsStudio())
local result=Instance.new("StringValue")
result.Name="AbilityMotionQAResult"
result.Parent=game.ServerStorage
local ok,err=pcall(function()
 local motion=require(game.ReplicatedStorage.WeaponMotion)
 local count=0
 for id,d in motion.AbilityProfiles do
  for _,sign in {-1,1} do
   local previous
   for i=0,math.ceil(d.Duration*1000) do
    local time=i/1000
    local frame,weight,body=motion.Ability(id,time,sign)
    for _,value in {frame:GetComponents()} do assert(value==value and math.abs(value)<math.huge,id.." invalid pose") end
    assert(weight>=0 and weight<=1 and body==body,id.." invalid weight")
    if previous then
     local delta=previous:ToObjectSpace(frame)
     local _,angle=delta:ToAxisAngle()
     assert(delta.Position.Magnitude<.08 and math.abs(angle)<.08,id.." discontinuity")
    end
    previous=frame count+=1
   end
   local frame,weight,body=motion.Ability(id,d.Duration,sign)
   assert(frame==CFrame.identity and weight==0 and body==0,id.." fails to settle")
  end
 end
 local right=motion.Ability("Frost",.43,1)
 local left=motion.Ability("Frost",.43,-1)
 assert((right.Position-left.Position).Magnitude>.25,"Frost hands should differ")
 local slam=motion.Ability("Slam",.49,1)
 assert((slam.Position-motion.AbilityProfiles.Slam.HitRight.Position).Magnitude>.02,"Slam follow-through should rebound after impact")
 local frost=motion.AbilityProfiles.Frost
 local frostWind=motion.Ability("Frost",frost.Wind*.5,1)
 assert((frostWind.Position-CFrame.identity:Lerp(frost.WindRight,.25).Position).Magnitude<1e-5,"Frost windup should build with a slow-start curve")
 local frostStrike=motion.Ability("Frost",frost.Wind+frost.Hit*.5,1)
 assert((frostStrike.Position-frost.WindRight:Lerp(frost.HitRight,.9375).Position).Magnitude<1e-5,"Frost cast should snap into its full lance extension")
 assert(motion.Ability("Invalid",0,1)==CFrame.identity,"Unknown ability must be idle")
 result.Value="PASS "..count.." pose samples; six abilities, two hands"
end)
if not ok then result.Value="FAIL "..tostring(err) end
script:Destroy()
