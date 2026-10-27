local starter=game:GetService("StarterGui")
assert(not starter:FindFirstChild("SurvivalHUD"),"HUD already exists")
local gui=Instance.new("ScreenGui") gui.Name="SurvivalHUD" gui.ResetOnSpawn=false gui.DisplayOrder=10 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset=false
local function make(class,name,parent,properties)
 local o=Instance.new(class) o.Name=name for k,v in properties do o[k]=v end o.Parent=parent return o
end
local function corner(o,r) make("UICorner","Corner",o,{CornerRadius=UDim.new(0,r)}) end
local function label(name,parent,text,pos,size,font,textSize,color,align)
 return make("TextLabel",name,parent,{BackgroundTransparency=1,Position=pos,Size=size,Text=text,Font=font,TextSize=textSize,TextColor3=color,TextXAlignment=align or Enum.TextXAlignment.Left})
end
local panel=make("Frame","StatusPanel",gui,{BackgroundTransparency=1,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,24,1,-26),Size=UDim2.fromOffset(316,154)})
make("UIScale","UIScale",panel,{Scale=1})
local function card(name,y,h,strokeColor)
 local c=make("Frame",name,panel,{BackgroundColor3=Color3.fromRGB(19,24,25),BackgroundTransparency=0.1,BorderSizePixel=0,Position=UDim2.fromOffset(0,y),Size=UDim2.fromOffset(316,h)})
 corner(c,10)
 make("UIStroke","Border",c,{Color=strokeColor,Thickness=1,Transparency=0.48})
 local grad=make("UIGradient","Shade",c,{Rotation=15})
 grad.Color=ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(170,180,178))
 return c
end
local h=card("HealthCard",0,78,Color3.fromRGB(142,94,84))
local cross=make("Frame","MedicalCross",h,{Position=UDim2.fromOffset(17,19),Size=UDim2.fromOffset(21,7),BackgroundColor3=Color3.fromRGB(233,93,79),BorderSizePixel=0})
corner(cross,1)
local crossV=make("Frame","Vertical",cross,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(7,21),BackgroundColor3=Color3.fromRGB(233,93,79),BorderSizePixel=0})
corner(crossV,1)
label("Title",h,"VIE",UDim2.fromOffset(50,13),UDim2.fromOffset(105,22),Enum.Font.GothamBold,13,Color3.fromRGB(210,215,209))
label("HealthValue",h,"100 / 100",UDim2.fromOffset(164,12),UDim2.fromOffset(134,24),Enum.Font.GothamBold,19,Color3.fromRGB(247,243,230),Enum.TextXAlignment.Right)
local track=make("Frame","Track",h,{Position=UDim2.fromOffset(17,48),Size=UDim2.fromOffset(281,11),BackgroundColor3=Color3.fromRGB(54,42,41),BorderSizePixel=0,ClipsDescendants=true})
corner(track,5)
local fill=make("Frame","Fill",track,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(233,93,79),BorderSizePixel=0})
corner(fill,5)
local fg=make("UIGradient","Gradient",fill,{Rotation=0}) fg.Color=ColorSequence.new(Color3.fromRGB(255,205,165),Color3.fromRGB(202,112,96))
local c=card("CoinsCard",88,66,Color3.fromRGB(154,129,68))
label("Title",c,"PIECES",UDim2.fromOffset(76,10),UDim2.fromOffset(110,17),Enum.Font.GothamBold,11,Color3.fromRGB(179,178,154))
local money=label("CoinsValue",c,"0",UDim2.fromOffset(76,27),UDim2.fromOffset(222,30),Enum.Font.GothamBold,25,Color3.fromRGB(246,218,134))
money.TextScaled=true
make("UITextSizeConstraint","TextSizeLimit",money,{MaxTextSize=25,MinTextSize=12})
gui.Parent=starter
return "HUD hierarchy created"
