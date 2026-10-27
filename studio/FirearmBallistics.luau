-- Server-owned deterministic spread; the client supplies only an aim direction.
local B={}
function B.Directions(direction,weapon)
 local forward=direction.Unit
 local count=math.clamp(math.floor(weapon.Pellets or 1),1,12)
 local list={forward} if count==1 then return list end
 local basis=CFrame.lookAt(Vector3.zero,forward)
 local radius=math.tan(math.rad(math.clamp(weapon.Spread or 0,0,12)))
 for i=1,count-1 do
  local a=(i-1)*math.pi*2/(count-1)
  table.insert(list,(forward+basis.RightVector*(math.cos(a)*radius)+basis.UpVector*(math.sin(a)*radius)).Unit)
 end
 return list
end
-- Only canonical head parts of this server-owned target qualify; accessories do not.
function B.HitDamage(weapon,part,target,multiplier)
 local headshot=false
 if part and target and part:IsA("BasePart") and part:IsDescendantOf(target) then
  headshot=part==target:FindFirstChild("Head") or (part.Name=="VisualHead" and part==target:FindFirstChild("VisualHead",true))
 end
 local factor=headshot and math.clamp(tonumber(multiplier) or 1,1,3) or 1
 return math.floor(weapon.Damage*factor+.5),headshot
end
return B
