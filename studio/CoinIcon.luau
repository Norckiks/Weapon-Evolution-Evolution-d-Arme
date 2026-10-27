-- Native Roblox UI coin logo: reusable at any display size, no external asset.
local CoinIcon = {}
function CoinIcon.create(parent, size)
 local function frame(name, position, dimensions, color, radius, z)
  local f=Instance.new("Frame") f.Name=name f.Position=position f.Size=dimensions
  f.BackgroundColor3=color f.BorderSizePixel=0 f.ZIndex=z or 1 f.Parent=parent
  if radius then local c=Instance.new("UICorner") c.CornerRadius=UDim.new(radius,0) c.Parent=f end
  return f
 end
 local root=Instance.new("Frame") root.Name="CoinLogo" root.BackgroundTransparency=1
 root.Size=UDim2.fromOffset(size,size) root.Parent=parent
 parent=root
 local rim=frame("GoldRim",UDim2.fromScale(0.06,0.1),UDim2.fromScale(0.88,0.88),Color3.fromRGB(159,94,22),0.5,2)
 local face=frame("CoinFace",UDim2.fromScale(0.06,0.035),UDim2.fromScale(0.88,0.88),Color3.fromRGB(255,210,79),0.5,3)
 local gradient=Instance.new("UIGradient") gradient.Rotation=65
 gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,237,151)),ColorSequenceKeypoint.new(0.45,Color3.fromRGB(244,189,49)),ColorSequenceKeypoint.new(1,Color3.fromRGB(194,119,23))}) gradient.Parent=face
 local ring=frame("MintRing",UDim2.fromScale(0.19,0.165),UDim2.fromScale(0.62,0.62),Color3.fromRGB(241,185,52),0.5,4)
 ring.BackgroundTransparency=1 local stroke=Instance.new("UIStroke") stroke.Thickness=math.max(1,size*0.035) stroke.Color=Color3.fromRGB(157,98,23) stroke.Transparency=0.15 stroke.Parent=ring
 -- Embossed Z for the zombie-world currency.
 frame("ZTop",UDim2.fromScale(0.34,0.29),UDim2.fromScale(0.32,0.075),Color3.fromRGB(133,77,19),0.15,5)
 local diagonal=frame("ZDiagonal",UDim2.fromScale(0.46,0.32),UDim2.fromScale(0.08,0.37),Color3.fromRGB(133,77,19),0.15,5) diagonal.Rotation=38
 frame("ZBottom",UDim2.fromScale(0.34,0.62),UDim2.fromScale(0.32,0.075),Color3.fromRGB(133,77,19),0.15,5)
 local glint=frame("Glint",UDim2.fromScale(0.24,0.17),UDim2.fromScale(0.2,0.035),Color3.fromRGB(255,247,202),0.5,6) glint.Rotation=-30
 return root
end
return CoinIcon
