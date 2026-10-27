if workspace:FindFirstChild("RefugeShops") then return "Refuge shops already installed" end
local C=require(game.ReplicatedStorage.GameplayConfig)
local Visuals=require(game.ReplicatedStorage.WeaponVisuals)
local root=Instance.new("Folder") root.Name="RefugeShops" root.Parent=workspace
local function part(parent,name,size,cf,color,material)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Color=color p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local specs={
 {"Upgrades","ATELIER","VIE + VITESSE",Color3.fromRGB(115,207,136)},
 {"Weapons","ARMURERIE","ARMES EN PIECES",Color3.fromRGB(255,188,74)},
 {"Pets","FUSION PETS","3 FRAGMENTS = 1 PET",Color3.fromRGB(91,198,224)},
 {"Robux","ROBUX","BIENTOT · ACHATS DESACTIVES",Color3.fromRGB(188,145,239)}
}
for _,s in specs do
 local id,title,sub,color=s[1],s[2],s[3],s[4] local origin=CFrame.new(C.Shops[id])
 local m=Instance.new("Model") m.Name=id m.Parent=root
 part(m,"Foundation",Vector3.new(13,0.35,10),origin*CFrame.new(0,0.18,0),Color3.fromRGB(74,87,98),Enum.Material.Concrete)
 for _,x in {-5.8,5.8} do for _,z in {-3.8,3.8} do part(m,"Post",Vector3.new(0.35,7.5,0.35),origin*CFrame.new(x,3.9,z),Color3.fromRGB(47,59,73),Enum.Material.Metal) end end
 part(m,"Roof",Vector3.new(13.8,0.6,10.5),origin*CFrame.new(0,7.6,0),color,Enum.Material.Metal)
 part(m,"BackWall",Vector3.new(12,4.2,0.3),origin*CFrame.new(0,2.5,-4),Color3.fromRGB(53,66,79),Enum.Material.WoodPlanks)
 part(m,"Counter",Vector3.new(11.6,2.7,1.8),origin*CFrame.new(0,1.7,1),Color3.fromRGB(67,80,88),Enum.Material.WoodPlanks)
 part(m,"CounterTop",Vector3.new(12.1,0.22,2.1),origin*CFrame.new(0,3.14,1),color)
 local sign=part(m,"ShopSign",Vector3.new(12,1.65,0.25),origin*CFrame.new(0,6.18,3.85),color)
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
  local surface=Instance.new("SurfaceGui") surface.Face=face surface.CanvasSize=Vector2.new(720,110) surface.LightInfluence=0 surface.Parent=sign
  local t=Instance.new("TextLabel") t.Size=UDim2.new(1,0,0.62,0) t.BackgroundTransparency=1 t.Text=title t.TextColor3=Color3.fromRGB(38,48,68) t.Font=Enum.Font.Cartoon t.TextScaled=true t.Parent=surface
  local d=t:Clone() d.Position=UDim2.fromScale(0,0.65) d.Size=UDim2.fromScale(1,0.3) d.Text=sub d.Parent=surface
 end
 local interact=part(m,"Interact",Vector3.new(2,2,1),origin*CFrame.new(0,3,4.8),color) interact.Transparency=1 interact.CanCollide=false interact.CanQuery=false
 local prompt=Instance.new("ProximityPrompt") prompt.Name="OpenShop" prompt.ActionText="Ouvrir" prompt.ObjectText=title prompt.HoldDuration=0.25 prompt.MaxActivationDistance=10 prompt.RequiresLineOfSight=false prompt:SetAttribute("ShopPage",id) prompt.Parent=interact
 if id=="Weapons" then
  for i,weapon in {"Pipe","Bat","Axe"} do local display=Visuals.Build(weapon) display.Name=weapon.."Display" display:PivotTo(origin*CFrame.new((i-2)*3,3.8,-0.6)*CFrame.Angles(0,0,0.18)) display.Parent=m end
 elseif id=="Upgrades" then
  for _,cf in {CFrame.new(-2,3.8,0.7),CFrame.new(2,3.8,0.7)} do
   part(m,"SupplyBox",Vector3.new(1.6,1.1,1.2),origin*cf,Color3.fromRGB(245,236,202))
   part(m,"MedicalCross",Vector3.new(0.7,0.18,0.05),origin*cf*CFrame.new(0,0,0.63),Color3.fromRGB(234,102,87))
   part(m,"MedicalCrossV",Vector3.new(0.18,0.7,0.05),origin*cf*CFrame.new(0,0,0.64),Color3.fromRGB(234,102,87))
  end
 elseif id=="Pets" then
  local body=part(m,"PetDisplay",Vector3.new(1.7,1.5,1.5),origin*CFrame.new(0,4,0.7),Color3.fromRGB(255,211,109)) body.Shape=Enum.PartType.Ball
  for _,x in {-0.35,0.35} do local eye=part(m,"Eye",Vector3.new(0.2,0.25,0.15),origin*CFrame.new(x,4.15,1.42),Color3.fromRGB(38,48,68)) eye.Shape=Enum.PartType.Ball end
  for i=1,3 do local f=part(m,"Fragment",Vector3.new(0.55,0.75,0.55),origin*CFrame.new((i-2)*2.8,3.6,1)*CFrame.Angles(0,0,0.7),color,Enum.Material.Neon) f.CanCollide=false end
 else
  local display=Visuals.Build("LimitedBlade") display.Name="NovaDisplay" display:PivotTo(origin*CFrame.new(0,4,0)*CFrame.Angles(0,0,0.2)) display.Parent=m
 end
 local light=Instance.new("PointLight") light.Brightness=0.7 light.Range=12 light.Color=color light.Shadows=false light.Parent=sign
 task.wait()
end
return "Installed four refuge shops"
