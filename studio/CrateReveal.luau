-- Client presentation only. Rewards are committed by EconomyService before this animation.
local Players=game:GetService("Players") local Tween=game:GetService("TweenService") local Run=game:GetService("RunService")
local RS=game.ReplicatedStorage local K=require(RS.CrateCatalog) local Visuals=require(RS.WeaponVisuals)
local R={} local p=Players.LocalPlayer local gui local panel local scale local viewport local title local info local accept local cancel local connection local model local pending=false local serial=0 local cancelAction
local INK=Color3.fromRGB(38,48,68) local CREAM=Color3.fromRGB(255,244,216)
local function decorate(v)
 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,18) c.Parent=v
 local s=Instance.new("UIStroke") s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Thickness=3 s.Color=INK s.Parent=v
end
local function label(parent,name,pos,size,font)
 local t=Instance.new("TextLabel") t.Name=name t.Position=pos t.Size=size t.BackgroundTransparency=1 t.Font=Enum.Font.Cartoon t.TextSize=font t.TextColor3=INK t.TextWrapped=true t.Parent=parent return t
end
local function clearModel()
 if connection then connection:Disconnect() connection=nil end
 if model then model:Destroy() model=nil end
end
local function close()
 serial+=1 clearModel() if gui then gui:Destroy() gui=nil end pending=false cancelAction=nil p:SetAttribute("CrateRevealOpen",false)
end
local function resize()
 if not gui then return end
 local v=workspace.CurrentCamera.ViewportSize
 local wide=v.X>v.Y and v.Y<650 local height=wide and 450 or 650
 scale.Scale=math.min(1,(v.X-20)/560,(v.Y-20)/height)
 panel.Size=UDim2.fromOffset(560,height)
 viewport.Size=UDim2.fromOffset(wide and 220 or 520,wide and 230 or 260)
 info.Position=UDim2.fromOffset(wide and 256 or 22,wide and 78 or 350)
 local bh=math.max(50,math.ceil(44/math.max(.1,scale.Scale)))
 accept.Position=UDim2.fromOffset(20,height-bh*2-18) cancel.Position=UDim2.fromOffset(20,height-bh-8)
 accept.Size=UDim2.fromOffset(520,bh) cancel.Size=UDim2.fromOffset(520,bh)
 info.Size=UDim2.fromOffset(wide and 284 or 516,wide and 230 or height-bh*2-380)
end
local function build()
 close() serial+=1
 gui=Instance.new("ScreenGui") gui.Name="CrateReveal" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=60 gui.Parent=p.PlayerGui
 local shade=Instance.new("TextButton") shade.Name="InputShield" shade.Text="" shade.AutoButtonColor=false shade.BackgroundColor3=INK shade.BackgroundTransparency=.25 shade.Size=UDim2.fromScale(1,1) shade.Parent=gui
 panel=Instance.new("Frame") panel.Name="Card" panel.AnchorPoint=Vector2.new(.5,.5) panel.Position=UDim2.fromScale(.5,.5) panel.Size=UDim2.fromOffset(560,650) panel.BackgroundColor3=CREAM panel.Parent=shade decorate(panel)
 scale=Instance.new("UIScale") scale.Parent=panel
 title=label(panel,"Title",UDim2.fromOffset(20,14),UDim2.fromOffset(520,56),28)
 viewport=Instance.new("ViewportFrame") viewport.Name="RewardPreview" viewport.Position=UDim2.fromOffset(20,78) viewport.Size=UDim2.fromOffset(520,260) viewport.BackgroundColor3=Color3.fromRGB(58,71,96) viewport.Ambient=Color3.fromRGB(210,215,235) viewport.LightColor=Color3.fromRGB(255,240,205) viewport.Parent=panel decorate(viewport)
 local camera=Instance.new("Camera") camera.FieldOfView=38 camera.Parent=viewport viewport.CurrentCamera=camera
 info=label(panel,"Details",UDim2.fromOffset(22,350),UDim2.fromOffset(516,176),18) info.TextYAlignment=Enum.TextYAlignment.Top
 local function button(name,y,color)
  local b=Instance.new("TextButton") b.Name=name b.Position=UDim2.fromOffset(20,y) b.Size=UDim2.fromOffset(520,50) b.BackgroundColor3=color b.Font=Enum.Font.Cartoon b.TextSize=22 b.TextColor3=INK b.Parent=panel decorate(b) return b
 end
 accept=button("Confirm",536,Color3.fromRGB(125,211,139)) cancel=button("Close",592,Color3.fromRGB(255,200,75)) cancel.Text="FERMER"
 cancel.Activated:Connect(function() if cancelAction then cancelAction() else close() end end)
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize) resize() p:SetAttribute("CrateRevealOpen",true)
end
local function part(name,size,cf,color)
 local v=Instance.new("Part") v.Name=name v.Size=size v.CFrame=cf v.Color=color v.Material=Enum.Material.SmoothPlastic v.Anchored=true v.CanCollide=false v.CanQuery=false v.CanTouch=false v.Parent=model return v
end
local function crateModel(crate)
 clearModel() model=Instance.new("Model") model.Name="AnimatedCrate" model.Parent=viewport
 part("Body",Vector3.new(2.5,1.65,1.8),CFrame.new(0,-.2,0),crate.Color)
 local lid=part("Lid",Vector3.new(2.65,.32,1.95),CFrame.new(0,.79,0),crate.Color)
 for _,x in {-.9,.9} do part("Band",Vector3.new(.22,1.7,1.86),CFrame.new(x,-.2,0),INK) end
 part("Lock",Vector3.new(.5,.6,.15),CFrame.new(0,.05,-.97),Color3.fromRGB(255,200,75))
 viewport.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(4,2.7,-6),Vector3.zero)
 return lid
end
function R.Confirm(id,send)
 if gui then return end
 local crate=K.Definitions[id] if not crate then return end
 build() title.Text=crate.Name.." · "..crate.Cost.." pieces"
 crateModel(crate)
 local lines={}
 for _,item in crate.Items do
  local suffix=crate.Kind=="Weapon" and (" · doublon +"..K.Refund(item.Id).." pieces") or ""
  table.insert(lines,item.Chance.."%  "..K.Item(crate,item).Name..suffix)
 end
 info.Text=table.concat(lines,"\n")..(crate.Kind=="Pet" and "\nDoublon : +1 copie, bonus non cumulables." or "")
 accept.Text="CONFIRMER · "..crate.Cost.." PIECES"
 accept.Activated:Connect(function()
  if pending then return end pending=true accept.Active=false accept.Selectable=false accept.Text="VERIFICATION..." send()
  local token=serial task.delay(8,function() if gui and serial==token and pending then accept.Text="REPONSE EN ATTENTE · FERMER POSSIBLE" end end)
 end)
end
function R.Error(message)
 if not gui then return end
 pending=false accept.Visible=false info.Text=message title.Text="CAISSE NON OUVERTE"
end
function R.Play(packet)
 local crate=K.Definitions[packet.CrateId] if not crate then return end
 if not gui then build() end
 pending=false serial+=1 local token=serial
 title.Text="OUVERTURE..." info.Text="Recompense deja ajoutee a ton inventaire." accept.Visible=false cancel.Text="PASSER"
 local lid=crateModel(crate) local start=os.clock() local reduced=p:GetAttribute("ReducedMotion")==true
 local function reveal()
  if not gui or serial~=token then return end serial+=1 clearModel()
  local def=(crate.Kind=="Weapon" and require(RS.GameplayConfig).Weapons or require(RS.GameplayConfig).Pets)[packet.Id]
  if not def then close() return end
  model=crate.Kind=="Weapon" and Visuals.Build(packet.Id) or R.PetModel(packet.Id)
  model.Parent=viewport
  for _,v in model:GetDescendants() do if v:IsA("BillboardGui") then v:Destroy() end end
  local cf,size=model:GetBoundingBox() model:PivotTo(model:GetPivot()-cf.Position)
  local distance=math.max(size.X,size.Y,size.Z)*1.8
  viewport.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(distance*.45,distance*.24,crate.Kind=="Pet" and -distance or distance),Vector3.zero)
  local rarity=K.Rarities[packet.Rarity] panel.BackgroundColor3=rarity.Color
  title.Text=rarity.Name.." ! · "..def.Name
  info.Text=packet.Refund>0 and ("DEJA POSSEDEE\nRecyclee : +"..packet.Refund.." pieces\nCout de la caisse : "..crate.Cost.." pieces") or (crate.Kind=="Weapon" and "Nouvelle arme ! Equipe-la dans ARMES." or "+1 pet ! Equipe-le dans PETS. Un seul bonus actif.")
  cancel.Text="CONTINUER" cancelAction=close
  if not reduced then
   for i=1,12 do
    local spark=label(viewport,"Spark",UDim2.fromScale(.5,.5),UDim2.fromOffset(20,20),24)
    spark.Text="+" spark.TextColor3=rarity.Color spark.AnchorPoint=Vector2.new(.5,.5)
    local angle=i*math.pi/6
    Tween:Create(spark,TweenInfo.new(.65,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(.5,math.cos(angle)*110,.5,math.sin(angle)*90),TextTransparency=1,Rotation=i*30}):Play()
    game.Debris:AddItem(spark,.7)
   end
  end
  if p:GetAttribute("SFXEnabled")~=false then
   local s=Instance.new("Sound") s.Name="CrateReward" s.SoundId=require(RS.PresentationConfig).Audio.Reward s.SoundGroup=game.SoundService:FindFirstChild("WorldUI") s.Volume=.25 s.Parent=panel s:Play()
  end
  local base=model:GetPivot() local began=os.clock()
  if not reduced then connection=Run.RenderStepped:Connect(function() if model then model:PivotTo(CFrame.Angles(0,math.sin((os.clock()-began)*1.4)*.28,0)*base) end end) end
 end
 -- Skip reveals the committed reward; it never requests another purchase.
 cancelAction=reveal
 if reduced then reveal() return end
 connection=Run.RenderStepped:Connect(function()
  if not model then return end
  local age=os.clock()-start
  local shake=age<.7 and math.sin(age*45)*.09*(age/.7) or 0
  local open=math.clamp((age-.7)/.45,0,1)
  model:PivotTo(CFrame.Angles(0,math.sin(age*3)*.15,shake))
  lid.CFrame=model:GetPivot()*CFrame.new(0,.63,.9)*CFrame.Angles(open*math.rad(115),0,0)*CFrame.new(0,.16,-.9)
 end)
 local flash=Instance.new("UIStroke") flash.Color=K.Rarities[packet.Rarity].Color flash.Thickness=0 flash.Parent=viewport game.Debris:AddItem(flash,1.2)
 task.delay(.7,function() if flash.Parent then Tween:Create(flash,TweenInfo.new(.35),{Thickness=8,Transparency=1}):Play() end end)
 task.delay(1.3,reveal)
end
return R
