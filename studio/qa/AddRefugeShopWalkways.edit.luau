-- One-time Studio Edit addition. This only adds decorative walkways; delete ShopAccessWalkways to roll it back.
local RunService=game:GetService("RunService")
local courtyard=workspace:FindFirstChild("RefugeCourtyard")
local shops=workspace:FindFirstChild("RefugeShops")
assert(game.PlaceId==89391796839094 and not RunService:IsRunning(),"Use the target place in Edit mode")
assert(courtyard and shops and courtyard:FindFirstChild("CentralPath"),"Refuge geometry missing")
assert(not courtyard:FindFirstChild("ShopAccessWalkways"),"Walkways already exist; inspect before rerunning")
local specs={{name="Upgrades",x=-110,z=225},{name="Weapons",x=110,z=225},{name="Pets",x=-110,z=247},{name="Robux",x=110,z=247}}
for _,spec in ipairs(specs) do

	local shop=shops:FindFirstChild(spec.name)
	local prompt=shop and shop:FindFirstChild("OpenShop",true)
	assert(prompt and prompt.Parent:IsA("BasePart"),"Shop prompt missing: "..spec.name)
	assert((prompt.Parent.Position-Vector3.new(spec.x,3,spec.z+4.8)).Magnitude<0.1,"Shop position changed: "..spec.name)
end
local root=Instance.new("Folder")
root.Name="ShopAccessWalkways"
local function part(name,size,position,color,material)
	local p=Instance.new("Part")
	p.Name,p.Size,p.Position=name,size,position
	p.Anchored=true
	p.CanCollide,p.CanTouch,p.CanQuery=false,false,false
	p.Material,p.Color=material,color
	p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
	p.Parent=root
	return p
end
local total=0
for _,side in ipairs({-1,1}) do
	local name=side<0 and "Left" or "Right"
	local x=side*125
	local laneStart,laneEnd=234.5,274
	local laneLength,laneCenter=laneEnd-laneStart,(laneStart+laneEnd)/2
	part("SideAisle_"..name,Vector3.new(8,.08,laneLength),Vector3.new(x,.24,laneCenter),Color3.fromRGB(58,75,88),Enum.Material.Slate)
	total+=1
	for _,edgeSide in ipairs({-1,1}) do
		local edge=part("SideAisleEdge_"..name.."_"..(edgeSide<0 and "L" or "R"),Vector3.new(.14,.04,laneLength-8),Vector3.new(x+edgeSide*3.78,.31,laneCenter),Color3.fromRGB(55,178,170),Enum.Material.Neon)
		edge.Transparency=.22
		total+=1
	end
	local startX,endX=side*10.5,x
	local linkLength,linkCenter=math.abs(endX-startX),(startX+endX)/2
	part("CentralConnector_"..name,Vector3.new(linkLength,.08,8),Vector3.new(linkCenter,.24,laneEnd),Color3.fromRGB(58,75,88),Enum.Material.Slate)
	total+=1
	for _,edgeSide in ipairs({-1,1}) do
		local edge=part("CentralConnectorEdge_"..name.."_"..(edgeSide<0 and "L" or "R"),Vector3.new(linkLength-8,.04,.14),Vector3.new(linkCenter,.31,laneEnd+edgeSide*3.78),Color3.fromRGB(55,178,170),Enum.Material.Neon)
		edge.Transparency=.22
		total+=1
	end
	local sideShops=side<0 and {{name="Upgrades",z=234.5},{name="Pets",z=256.5}} or {{name="Weapons",z=234.5},{name="Robux",z=256.5}}
	for _,shop in ipairs(sideShops) do
		part("ShopSpur_"..shop.name.."_"..name,Vector3.new(15,.08,8),Vector3.new(side*117.5,.24,shop.z),Color3.fromRGB(58,75,88),Enum.Material.Slate)
		total+=1
	end
end
root.Parent=courtyard
assert(#root:GetChildren()==16,"Expected two side aisles, two crosswalks and four shop spurs")
for _,item in ipairs(root:GetChildren()) do assert(item:IsA("BasePart") and item.Anchored and not item.CanCollide and not item.CanTouch and not item.CanQuery,"Walkway must remain decorative and non-interactive") end
return {folder=root:GetFullName(),parts=total,shops=#specs,collision=false,rollback="Delete ShopAccessWalkways"}
