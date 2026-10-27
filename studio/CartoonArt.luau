local Art={Welcome="rbxassetid://111558309167783",Atlas="rbxassetid://138324433949812"}
-- Roblox transcodes this atlas to 1024 x 512, verified with EditableImage.Size.
local cells={Coins={0,0},XP={1,0},Health={2,0},Speed={3,0},Pets={0,1},Weapons={1,1},Gift={2,1},Missions={3,1}}
function Art.Icon(parent,id,size,position)
 local cell=cells[id] assert(cell,"Unknown artwork icon")
 local image=Instance.new("ImageLabel") image.Name=id.."Artwork" image.BackgroundTransparency=1 image.Image=Art.Atlas
 image.ImageRectOffset=Vector2.new(cell[1]*256,cell[2]*256) image.ImageRectSize=Vector2.new(256,256)
 image.Size=UDim2.fromOffset(size,size) image.Position=position or UDim2.new() image.ScaleType=Enum.ScaleType.Fit image.Parent=parent
 return image
end
return Art
