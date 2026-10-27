local folder=Instance.new("Model") folder.Name="RefugeRadio" folder.Parent=workspace.PresentationV2
local function part(name,size,position,color,mat)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=position p.Color=color p.Material=mat p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false p.Parent=folder return p
end
part("Crate",Vector3.new(2.4,2.2,2),Vector3.new(-15,1.4,184),Color3.fromRGB(81,76,54),Enum.Material.WoodPlanks)
local body=part("Receiver",Vector3.new(1.8,0.9,0.75),Vector3.new(-15,2.95,184),Color3.fromRGB(51,64,57),Enum.Material.Metal) body:SetAttribute("RadioStatic",true)
local antenna=part("Antenna",Vector3.new(0.04,1.7,0.04),Vector3.new(-15.6,4,184.2),Color3.fromRGB(120,129,122),Enum.Material.Metal)
antenna.Orientation=Vector3.new(0,0,-12)
for i=1,5 do part("SpeakerGrille",Vector3.new(0.04,0.55,0.03),Vector3.new(-15.78+i*0.11,2.98,183.61),Color3.fromRGB(17,27,23),Enum.Material.Metal) end
local screen=part("Tuner",Vector3.new(0.65,0.36,0.04),Vector3.new(-14.65,3.06,183.6),Color3.fromRGB(49,92,66),Enum.Material.Neon)
local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Front gui.PixelsPerStud=120 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.Parent=screen
local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundTransparency=1 text.Text="CH.07" text.TextColor3=Color3.fromRGB(165,218,154) text.TextScaled=true text.Font=Enum.Font.RobotoMono text.Parent=gui
for _,p in workspace.ProgressionZones.Lab:GetDescendants() do
 if p:IsA("BasePart") and (p.Name=="Mutagen" or p.Name=="ToxicLiquid") then
  p.Material=Enum.Material.Glass p.Color=Color3.fromRGB(60,121,73) p.Transparency=0.25 p.Reflectance=0.08
  local l=Instance.new("PointLight") l.Color=Color3.fromRGB(112,173,84) l.Brightness=0.4 l.Range=9 l.Parent=p
 end
end
return "Refuge radio and restrained laboratory fluid lighting added"
