local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local HttpService=game:GetService("HttpService")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer local C=require(RS:WaitForChild("GameplayConfig"))
local WeaponVisuals=require(RS:WaitForChild("WeaponVisuals"))
local Art=require(RS:WaitForChild("CartoonArt"))
local Contracts=require(RS:WaitForChild("QuickContracts"))
local Expeditions=require(RS:WaitForChild("Expeditions"))
local World=require(RS:WaitForChild("WorldConfig"))
local Crates=require(RS:WaitForChild("CrateCatalog"))
local CrateReveal=require(RS:WaitForChild("CrateReveal"))
local action=RS.Remotes:WaitForChild("GameAction") local remote=RS.Remotes:WaitForChild("GameState") local dashRemote=RS.Remotes:WaitForChild("Dash")
local INK=Color3.fromRGB(38,48,68) local CREAM=Color3.fromRGB(255,244,216) local GOLD=Color3.fromRGB(255,200,75)
local BLUE=Color3.fromRGB(91,195,223) local GREEN=Color3.fromRGB(125,211,139) local RED=Color3.fromRGB(243,117,96)
local gui=Instance.new("ScreenGui") gui.Name="SurvivorHub" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=25 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=player:WaitForChild("PlayerGui")
local function round(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 14) c.Parent=o end
local function stroke(o,t) local s=Instance.new("UIStroke") s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Color=INK s.Thickness=t or 3 s.Parent=o end
local function frame(parent,name,pos,size,color)
 local f=Instance.new("Frame") f.Name=name f.Position=pos f.Size=size f.BackgroundColor3=color f.BorderSizePixel=0 f.Parent=parent round(f,12) stroke(f,3)
 local gradient=Instance.new("UIGradient") gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(245,226,192)) gradient.Rotation=90 gradient.Parent=f
 return f
end
local function text(parent,name,value,pos,size,fontSize,color)
 local t=Instance.new("TextLabel") t.Name=name t.Text=value t.Position=pos t.Size=size t.BackgroundTransparency=1
 t.TextColor3=color or INK t.Font=Enum.Font.FredokaOne t.TextSize=fontSize or 16 t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=parent return t
end
local function button(parent,value,pos,size,color,fn,enabled)
 local b=Instance.new("TextButton") b.Text=value b.Position=pos b.Size=size b.BorderSizePixel=0 b.BackgroundColor3=enabled==false and Color3.fromRGB(173,181,187) or color
 b.Active=enabled~=false and fn~=nil b.Selectable=b.Active
 b.TextColor3=INK b.Font=Enum.Font.FredokaOne b.TextSize=16 b.TextWrapped=true b.AutoButtonColor=false b.Parent=parent round(b,12) stroke(b,2)
 if enabled~=false and fn then
  local sc=Instance.new("UIScale") sc.Parent=b
  local anim local hover=false
  local function animate(scale)
   if anim then anim:Cancel() end
   anim=TweenService:Create(sc,TweenInfo.new(player:GetAttribute("ReducedMotion") and 0 or .14,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=scale}) anim:Play()
  end
  b.MouseEnter:Connect(function() hover=true animate(1.025) end)
  b.MouseLeave:Connect(function() hover=false animate(1) end)
  b.SelectionGained:Connect(function() animate(1.025) end)
  b.SelectionLost:Connect(function() animate(1) end)
  b.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then animate(.94) end end)
  b.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then animate(hover and 1.025 or 1) end end)
  b.Activated:Connect(fn)
 end return b
end
local welcomeArt=Instance.new("ViewportFrame") welcomeArt.Name="WelcomeIllustration" welcomeArt.Size=UDim2.fromScale(1,1) welcomeArt.BackgroundColor3=Color3.fromRGB(9,12,17) welcomeArt.BorderSizePixel=0 welcomeArt.ZIndex=0 welcomeArt.Ambient=Color3.fromRGB(67,75,83) welcomeArt.LightColor=Color3.fromRGB(184,197,207) welcomeArt.LightDirection=Vector3.new(-1,-1,-.7) welcomeArt.Parent=gui
local menuCamera=Instance.new("Camera") menuCamera.FieldOfView=40 menuCamera.Parent=welcomeArt welcomeArt.CurrentCamera=menuCamera
local menuWorld=Instance.new("WorldModel") menuWorld.Parent=welcomeArt
local function scenePart(name,size,cf,color,material)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Color=color p.Material=material or Enum.Material.Concrete p.Anchored=true p.CanCollide=false p.Parent=menuWorld return p
end
scenePart("Street",Vector3.new(60,.5,80),CFrame.new(0,-.3,-12),Color3.fromRGB(30,33,34),Enum.Material.Asphalt)
local menuTemplate=RS:WaitForChild("PresentationAssets"):FindFirstChild("MenuQuarantine")
if menuTemplate then
 local environment=menuTemplate:Clone() environment.Parent=menuWorld
else
scenePart("BuildingLeft",Vector3.new(8,18,28),CFrame.new(-13,8,-9),Color3.fromRGB(35,39,42))
scenePart("BuildingRight",Vector3.new(8,21,28),CFrame.new(14,10,-13),Color3.fromRGB(28,32,35))
scenePart("FarWall",Vector3.new(34,15,2),CFrame.new(0,7,-28),Color3.fromRGB(38,40,40))
for _,x in {-8,8} do
 for _,z in {-21,-15,-9,-3} do
  for _,y in {4,8,12} do
   scenePart("Window",Vector3.new(.08,2,1.6),CFrame.new(x,y,z),Color3.fromRGB(12,16,18))
  end
 end
end
end
for z=-23,5,7 do scenePart("RoadMark",Vector3.new(.16,.02,2.5),CFrame.new(0,-.03,z),Color3.fromRGB(76,70,57)) end
local assets=RS:WaitForChild("PresentationAssets")
local function sceneModel(name,cf)
 local source=assets:FindFirstChild(name) if not source then return end
 local model=source:Clone()
 for _,part in model:GetDescendants() do if part:IsA("BasePart") then part.Anchored=true part.CanCollide=false end end
 model.Parent=menuWorld model:PivotTo(cf) return model
end
sceneModel("WreckSedan",CFrame.new(-5,1.9,-6)*CFrame.Angles(0,math.rad(30),0))
sceneModel("Rubble",CFrame.new(7,1.2,-8))
sceneModel("Weeds",CFrame.new(3,.3,-3))
local menuZombie=sceneModel("CivilianBody",CFrame.new(2,3,-1)*CFrame.Angles(0,math.rad(180),0))
local menuLimbs={}
if menuZombie then for _,part in menuZombie:GetDescendants() do
 if part:IsA("BasePart") and (part.Name=="LeftArm_geom" or part.Name=="RightArm_geom" or part.Name=="Head_geom") then
  local offset=part.Name=="Head_geom" and -.35 or part.Size.Y*.34
  table.insert(menuLimbs,{Part=part,Base=part.CFrame,Pivot=CFrame.new(0,offset,0),Side=part.Name=="LeftArm_geom" and -1 or 1})
 end
end end
local cinemaStart local cinemaFinish
local shots={
 {From=Vector3.new(5,7,19),To=Vector3.new(2,5,13),Look=Vector3.new(0,3,-10),Title="LA VILLE EST TOMBÉE",Line="Les rues se sont tues. Puis les pas sont revenus."},
 {From=Vector3.new(-10,5,12),To=Vector3.new(-8,5,10),Look=Vector3.new(-1,4,-1),Title="ILS NE DORMENT PLUS",Line="Chaque bruit attire ce qui rôde dans l'obscurité."},
 {From=Vector3.new(4,5,12),To=Vector3.new(2,5,10),Look=Vector3.new(-1,4,-1),Title="SURVIS JUSQU'AU MATIN",Line="Trouve une arme. Reste en vie. Reconstruis l'espoir."},
}
local cinemaLayer=Instance.new("Frame") cinemaLayer.Name="Prologue" cinemaLayer.Size=UDim2.fromScale(1,1) cinemaLayer.BackgroundTransparency=1 cinemaLayer.Visible=false cinemaLayer.Parent=welcomeArt
local shade=Instance.new("Frame") shade.Size=UDim2.fromScale(1,1) shade.BackgroundColor3=Color3.fromRGB(4,7,11) shade.BorderSizePixel=0 shade.ZIndex=2 shade.Parent=cinemaLayer
for _,y in {0,.82} do
 local bar=Instance.new("Frame") bar.Position=UDim2.fromScale(0,y) bar.Size=UDim2.fromScale(1,.18) bar.BackgroundColor3=Color3.fromRGB(4,7,11) bar.BorderSizePixel=0 bar.ZIndex=3 bar.Parent=cinemaLayer
end
local cinemaTitle=text(cinemaLayer,"Title","",UDim2.fromScale(.06,.84),UDim2.fromScale(.88,.065),26,Color3.fromRGB(233,226,208))
cinemaTitle.Font=Enum.Font.SpecialElite cinemaTitle.TextScaled=true cinemaTitle.ZIndex=4
local titleLimit=Instance.new("UITextSizeConstraint") titleLimit.MaxTextSize=26 titleLimit.MinTextSize=12 titleLimit.Parent=cinemaTitle
local cinemaLine=text(cinemaLayer,"Caption","",UDim2.fromScale(.06,.915),UDim2.fromScale(.88,.06),16,Color3.fromRGB(190,179,165))
cinemaLine.TextScaled=true cinemaLine.ZIndex=4
local lineLimit=Instance.new("UITextSizeConstraint") lineLimit.MaxTextSize=16 lineLimit.MinTextSize=10 lineLimit.Parent=cinemaLine
local cinemaSkip=button(cinemaLayer,"PASSER",UDim2.new(1,-148,0,20),UDim2.fromOffset(128,48),Color3.fromRGB(106,42,36),function() if cinemaFinish then cinemaFinish() end end)
cinemaSkip.ZIndex=5 cinemaSkip.TextColor3=Color3.fromRGB(241,231,214)
local function setMenuCamera(t)
 local reduced=player:GetAttribute("ReducedMotion")==true
 local portraitMenu=welcomeArt.AbsoluteSize.X<welcomeArt.AbsoluteSize.Y
 menuCamera.FieldOfView=portraitMenu and cinemaStart and 70 or 40
 local drift=reduced and 0 or math.sin(t*.28)*.3
 menuCamera.CFrame=CFrame.lookAt(Vector3.new(1+drift,4.6,18),Vector3.new(portraitMenu and 1 or -3,3.4,-4))
 if cinemaStart then
  local elapsed=t-cinemaStart
  if elapsed>=24 or player:GetAttribute("HasStarted")==true then
   if cinemaFinish then cinemaFinish() end
  else
   local shot=shots[math.floor(elapsed/8)+1] local phase=elapsed%8
   local u=reduced and 0 or phase/8
   u=u*u*(3-2*u)
   menuCamera.CFrame=CFrame.lookAt(shot.From:Lerp(shot.To,u),shot.Look)
   shade.BackgroundTransparency=math.min(1,phase/.65,(8-phase)/.65)
   cinemaTitle.Text=shot.Title cinemaLine.Text=shot.Line
   cinemaTitle.TextTransparency=1-math.clamp((phase-.4)/.6,0,1)
   cinemaLine.TextTransparency=1-math.clamp((phase-1)/.7,0,1)
  end
 end
 for _,limb in menuLimbs do
  local sway=reduced and 0 or math.sin(t*.85+limb.Side)*.035
  limb.Part.CFrame=limb.Base*limb.Pivot*CFrame.Angles(sway,0,sway*limb.Side*.5)*limb.Pivot:Inverse()
 end
end
setMenuCamera(0)
RunService.RenderStepped:Connect(function() if welcomeArt.Visible then setMenuCamera(os.clock()) elseif cinemaStart and cinemaFinish then cinemaFinish() end end)
local backdrop=Instance.new("Frame") backdrop.Name="Backdrop" backdrop.Size=UDim2.fromScale(1,1) backdrop.BackgroundColor3=Color3.fromRGB(4,7,11) backdrop.BackgroundTransparency=0 backdrop.BorderSizePixel=0 backdrop.Parent=gui
local menuGradient=Instance.new("UIGradient") menuGradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.04),NumberSequenceKeypoint.new(.38,.18),NumberSequenceKeypoint.new(.7,.85),NumberSequenceKeypoint.new(1,.62)}) menuGradient.Parent=backdrop
local main=frame(gui,"Welcome",UDim2.fromScale(0.5,0.5),UDim2.fromOffset(500,510),Color3.fromRGB(15,18,21)) main.AnchorPoint=Vector2.new(0.5,0.5)
main.BackgroundTransparency=1
main:FindFirstChildOfClass("UIGradient"):Destroy()
main:FindFirstChildOfClass("UIStroke").Enabled=false
local ms=Instance.new("UIScale") ms.Parent=main
local cinemaReplay
cinemaReplay=button(main,"03   VOIR LE PROLOGUE",UDim2.fromOffset(28,408),UDim2.fromOffset(420,56),Color3.fromRGB(24,30,31),function()
 if not main.Visible or player:GetAttribute("HasStarted")==true then return end
 cinemaStart=os.clock() cinemaLayer.Visible=true main.Visible=false cinemaReplay.Visible=false welcomeArt.ZIndex=3
 if GuiService.SelectedObject then GuiService.SelectedObject=cinemaSkip end
end)
cinemaReplay.Name="WatchPrologue" cinemaReplay.TextColor3=Color3.fromRGB(241,231,214) cinemaReplay.ZIndex=5
cinemaFinish=function()
 cinemaStart=nil cinemaLayer.Visible=false cinemaReplay.Visible=true welcomeArt.ZIndex=0
 main.Visible=player:GetAttribute("HasStarted")~=true
 menuCamera.FieldOfView=40
 if GuiService.SelectedObject==cinemaSkip then GuiService.SelectedObject=cinemaReplay end
end
UIS.InputBegan:Connect(function(input,processed)
 if cinemaStart and not processed and (input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.ButtonB) then cinemaFinish() end
end)

local brand=text(main,"Brand","WEAPON\nEVOLUTION",UDim2.fromOffset(28,42),UDim2.fromOffset(444,138),68,Color3.fromRGB(233,226,208)) brand.Font=Enum.Font.Creepster
local sub=text(main,"Subtitle","ZONE DE QUARANTAINE  /  01",UDim2.fromOffset(30,12),UDim2.fromOffset(444,26),14,Color3.fromRGB(184,133,94)) sub.Font=Enum.Font.SpecialElite
local warning=text(main,"Warning","Le refuge tient encore.\nDehors, la nuit appartient aux infectés.",UDim2.fromOffset(30,192),UDim2.fromOffset(410,48),18,Color3.fromRGB(175,187,184)) warning.Font=Enum.Font.SpecialElite
local play=button(main,"01   JOUER",UDim2.fromOffset(28,260),UDim2.fromOffset(420,70),Color3.fromRGB(113,42,34),function() if player:GetAttribute("ProgressReady") then action:FireServer("Start") end end) play.Name="Play" play.TextSize=28 play.Font=Enum.Font.SpecialElite play.TextColor3=Color3.fromRGB(241,231,214)
local startHint=text(main,"StartHint","ENTRÉE / A  ·  REJOINDRE LE REFUGE",UDim2.fromOffset(30,482),UDim2.fromOffset(430,22),12,Color3.fromRGB(150,164,159)) startHint.Font=Enum.Font.SpecialElite
CAS:BindAction("SurvivalStart",function(_,phase)
 if not main.Visible or player:GetAttribute("HasStarted")==true or UIS:GetFocusedTextBox() or (GuiService.SelectedObject and GuiService.SelectedObject~=play) then return Enum.ContextActionResult.Pass end
 if phase==Enum.UserInputState.Begin and player:GetAttribute("ProgressReady")==true then action:FireServer("Start") end
 return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.Return,Enum.KeyCode.ButtonA,Enum.KeyCode.ButtonStart)
local function readyChanged()
 local ready=player:GetAttribute("ProgressReady")==true
 play.Text=ready and "01   JOUER" or "CHARGEMENT..." play.BackgroundColor3=ready and Color3.fromRGB(106,42,36) or Color3.fromRGB(55,58,60)
end
player:GetAttributeChangedSignal("ProgressReady"):Connect(readyChanged) readyChanged()
local window=frame(gui,"Window",UDim2.fromScale(0.5,0.5),UDim2.fromOffset(720,490),CREAM) window.AnchorPoint=Vector2.new(0.5,0.5) window.Visible=false
local ws=Instance.new("UIScale") ws.Parent=window
local pageTitle=text(window,"PageTitle","LE REFUGE",UDim2.fromOffset(20,12),UDim2.fromOffset(600,36),26)
local note=text(window,"Note","",UDim2.fromOffset(20,438),UDim2.fromOffset(680,36),13,Color3.fromRGB(151,78,53))
local bonus=text(window,"Bonus","",UDim2.fromOffset(20,409),UDim2.fromOffset(680,26),12)
local tabs=Instance.new("Frame") tabs.Name="Tabs" tabs.BackgroundTransparency=1 tabs.Position=UDim2.fromOffset(16,55) tabs.Size=UDim2.fromOffset(688,34) tabs.Parent=window
local scroll=Instance.new("ScrollingFrame") scroll.Name="Catalog" scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0 scroll.Position=UDim2.fromOffset(16,101) scroll.Size=UDim2.fromOffset(688,301) scroll.ScrollBarThickness=5 scroll.ScrollBarImageColor3=INK scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y scroll.CanvasSize=UDim2.new() scroll.Parent=window
local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,8) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=scroll
local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,4) pad.PaddingRight=UDim.new(0,10) pad.PaddingTop=UDim.new(0,4) pad.PaddingBottom=UDim.new(0,8) pad.Parent=scroll
local quick=Instance.new("Frame") quick.Name="QuickNavigation" quick.BackgroundTransparency=1 quick.AnchorPoint=Vector2.new(1,0) quick.Position=UDim2.new(1,-18,0,152) quick.Size=UDim2.fromOffset(148,116) quick.Parent=gui
local contractCard=frame(gui,"QuickContract",UDim2.new(1,-18,0,286),UDim2.fromOffset(204,112),CREAM) contractCard.AnchorPoint=Vector2.new(1,0) contractCard.Visible=false
Art.Icon(contractCard,"Missions",30,UDim2.fromOffset(8,7))
local contractTitle=text(contractCard,"Title","OBJECTIFS",UDim2.fromOffset(42,8),UDim2.fromOffset(153,22),13)
local contractText=text(contractCard,"Objective","",UDim2.fromOffset(10,34),UDim2.fromOffset(184,68),12) contractText.TextYAlignment=Enum.TextYAlignment.Top
local toast=frame(gui,"HubToast",UDim2.new(0.5,0,0,150),UDim2.fromOffset(390,50),GOLD) toast.AnchorPoint=Vector2.new(0.5,0) toast.Visible=false
local toastText=text(toast,"Message","",UDim2.fromOffset(10,4),UDim2.new(1,-20,1,-8),15) toastText.TextXAlignment=Enum.TextXAlignment.Center
local ts=Instance.new("UIScale") ts.Parent=toast
local dashCard=frame(gui,"DashStatus",UDim2.new(0.5,0,1,-26),UDim2.fromOffset(166,28),BLUE) dashCard.AnchorPoint=Vector2.new(0.5,1)
local dashLabel=text(dashCard,"Label","CTRL · DASH",UDim2.fromOffset(6,1),UDim2.new(1,-12,1,-2),12) dashLabel.TextXAlignment=Enum.TextXAlignment.Center
local state local currentPage="Upgrades" local locked=false local savedCamera local toastSerial=0 local render
local renderGeneration=0 local pendingPageReset=false
local layoutWindow
local tutorialCards={
 {"LES PREMIERS PAS","Déplace-toi avec ZQSD ou les flèches. MAJ / L3 te fait sprinter, CTRL / B déclenche le dash et F allume la lampe (haut du pavé sur manette). Sur téléphone, utilise les boutons affichés.","ZQSD · MAJ / L3 · CTRL / B · F / ↑"},
 {"FAIRE FACE AUX ZOMBIES","Tu commences avec tes poings. Clique ou touche l’écran pour frapper ; quand tu achètes une arme, équipe-la dans ARMES. Les armes à feu se rechargent avec R ou X.","CLIC / TOUCHER · R / X POUR RECHARGER"},
 {"PIÈCES, XP ET FRAGMENTS","Chaque zombie vaincu donne des pièces et de l’XP. Il peut aussi laisser un fragment propre à son espèce : rassemble 3 fragments identiques pour fabriquer son pet.","1 CHANCE SUR 3 · 3 FRAGMENTS IDENTIQUES"},
 {"AMÉLIORE TON ÉQUIPEMENT","Ouvre MENU, puis ATELIER pour améliorer ta vie, ta vitesse ou ton endurance. Dans ARMES, achète et équipe des armes avec tes pièces, même loin des boutiques.","MENU · ATELIER · ARMES"},
 {"EXPLORE À TON RYTHME","Les portails indiquent le niveau requis pour chaque zone. Suis le guide à l’écran ; dans MISSIONS, consulte tes contrats et récupère les récompenses disponibles.","NIVEAU REQUIS · PORTAIL · MISSIONS"},
}
local tutorialIndex=1 local tutorialShown=false
local tutorial=frame(gui,"Tutorial",UDim2.fromScale(.5,.5),UDim2.fromOffset(560,480),Color3.fromRGB(20,22,24)) tutorial.AnchorPoint=Vector2.new(.5,.5) tutorial.Visible=false
tutorial:FindFirstChildOfClass("UIGradient"):Destroy() tutorial:FindFirstChildOfClass("UIStroke").Color=Color3.fromRGB(105,65,54)
local tutorialScale=Instance.new("UIScale") tutorialScale.Parent=tutorial
local tutorialHeading=text(tutorial,"Heading","GUIDE DE SURVIE",UDim2.fromOffset(30,24),UDim2.fromOffset(380,36),26,Color3.fromRGB(236,226,205))
local tutorialCount=text(tutorial,"Step","ÉTAPE 1 / 5",UDim2.fromOffset(30,66),UDim2.fromOffset(500,22),13,Color3.fromRGB(183,127,103))
local tutorialTitle=text(tutorial,"Title","",UDim2.fromOffset(30,105),UDim2.fromOffset(500,42),24,Color3.fromRGB(255,205,119))
local tutorialBody=text(tutorial,"Body","",UDim2.fromOffset(30,154),UDim2.fromOffset(500,126),19,Color3.fromRGB(235,230,216)) tutorialBody.TextYAlignment=Enum.TextYAlignment.Top
local tutorialHint=frame(tutorial,"Controls",UDim2.fromOffset(30,292),UDim2.fromOffset(500,66),Color3.fromRGB(43,39,39)) tutorialHint:FindFirstChildOfClass("UIGradient"):Destroy() tutorialHint:FindFirstChildOfClass("UIStroke").Color=Color3.fromRGB(105,65,54)
local tutorialKeys=text(tutorialHint,"Keys","",UDim2.fromOffset(12,5),UDim2.new(1,-24,1,-10),16,Color3.fromRGB(246,193,141)) tutorialKeys.TextXAlignment=Enum.TextXAlignment.Center
local tutorialPrevious=button(tutorial,"PRÉCÉDENT",UDim2.fromOffset(30,390),UDim2.fromOffset(170,78),Color3.fromRGB(51,57,58),function() end)
local tutorialSkip=button(tutorial,"PASSER",UDim2.fromOffset(424,20),UDim2.fromOffset(110,58),Color3.fromRGB(92,45,39),function() end)
local tutorialNext=button(tutorial,"SUIVANT",UDim2.fromOffset(364,390),UDim2.fromOffset(170,78),Color3.fromRGB(112,54,43),function() end)
local function layoutTutorial()
 local viewport=gui.AbsoluteSize
 if viewport.X>24 and viewport.Y>24 then tutorialScale.Scale=math.clamp(math.min(1,(viewport.X-24)/560,(viewport.Y-24)/480),.1,1) end
end
local function updateTutorial()
 local card=tutorialCards[tutorialIndex]
 tutorialCount.Text="ÉTAPE "..tutorialIndex.." / "..#tutorialCards
 tutorialTitle.Text=card[1] tutorialBody.Text=card[2] tutorialKeys.Text=card[3]
 tutorialPrevious.Active=tutorialIndex>1 tutorialPrevious.Selectable=tutorialPrevious.Active
 tutorialPrevious.BackgroundColor3=tutorialPrevious.Active and Color3.fromRGB(51,57,58) or Color3.fromRGB(36,39,40)
 tutorialNext.Text=tutorialIndex==#tutorialCards and "C’EST PARTI" or "SUIVANT"
end
local function portraitCatalog()
 local camera=workspace.CurrentCamera
 return UIS.TouchEnabled and camera and camera.ViewportSize.Y>camera.ViewportSize.X
end
local pageNames={Upgrades="ATELIER",Weapons="ARMURERIE",Pets="FRAGMENTS & PETS",Time="CADEAUX & PALIERS",Missions="MISSIONS & DOSSIERS",Robux="BOUTIQUE ROBUX",Options="OPTIONS",Crates="CAISSES"}
local function lock()
 local open=main.Visible or window.Visible or tutorial.Visible or player:GetAttribute("CrateRevealOpen")==true or player:GetAttribute("AdminPanelOpen")==true
 if open and not locked then savedCamera=workspace.CurrentCamera.CFrame end
 player:SetAttribute("GameMenuOpen",open) action:FireServer("MenuState",open or player:GetAttribute("OptionsOpen")==true)
 backdrop.Visible=open
 welcomeArt.Visible=player:GetAttribute("HasStarted")~=true
 if not open and locked then workspace.CurrentCamera.CameraType=Enum.CameraType.Custom UIS.MouseBehavior=Enum.MouseBehavior.LockCenter UIS.MouseIconEnabled=false end
 locked=open
 local hud=player.PlayerGui:FindFirstChild("SurvivalHUD") if hud then hud.Enabled=player:GetAttribute("HasStarted")==true end
end
player:GetAttributeChangedSignal("CrateRevealOpen"):Connect(lock)
player:GetAttributeChangedSignal("AdminPanelOpen"):Connect(lock)
local function close()
 window.Visible=false main.Visible=player:GetAttribute("HasStarted")~=true lock()
end
local function open(page)
 local entering=not window.Visible
 pendingPageReset=currentPage~=page or entering
 currentPage=page main.Visible=false window.Visible=true lock() if render then render() end
 if entering and not player:GetAttribute("ReducedMotion") then
  window.Position=UDim2.new(.5,0,.5,28)
  TweenService:Create(window,TweenInfo.new(.24,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.fromScale(.5,.5)}):Play()
 end
end
local function closeTutorial(markComplete)
 tutorial.Visible=false
 main.Visible=player:GetAttribute("HasStarted")~=true
 lock()
 if markComplete and player:GetAttribute("HasStarted")==true then action:FireServer("TutorialComplete") end
end
local function showTutorial()
 tutorialIndex=1 tutorial.Visible=true main.Visible=false window.Visible=false
 layoutTutorial() updateTutorial() lock()
 task.delay(player:GetAttribute("ReducedMotion") and .1 or .5,function()
  if UIS.GamepadEnabled and tutorial.Visible and tutorialNext.Visible and tutorialNext.Selectable and tutorialNext:IsDescendantOf(gui) then GuiService.SelectedObject=tutorialNext end
 end)
 if not player:GetAttribute("ReducedMotion") then
  tutorial.Position=UDim2.new(.5,0,.5,18)
  TweenService:Create(tutorial,TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromScale(.5,.5)}):Play()
 end
end
local function previousTutorial() if tutorialIndex>1 then tutorialIndex-=1 updateTutorial() end end
local function nextTutorial()
 if tutorialIndex<#tutorialCards then tutorialIndex+=1 updateTutorial() else closeTutorial(true) end
end
tutorialPrevious.Activated:Connect(previousTutorial)
tutorialNext.Activated:Connect(nextTutorial)
tutorialSkip.Activated:Connect(function() closeTutorial(true) end)
UIS.InputBegan:Connect(function(input)
 if not tutorial.Visible then return end
 if input.KeyCode==Enum.KeyCode.Left then previousTutorial()
 elseif input.KeyCode==Enum.KeyCode.Right or input.KeyCode==Enum.KeyCode.Return or input.KeyCode==Enum.KeyCode.KeypadEnter then nextTutorial()
 elseif input.KeyCode==Enum.KeyCode.Escape then closeTutorial(true) end
end)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutTutorial)
task.defer(layoutTutorial)
local menuOptions=button(main,"02   OPTIONS",UDim2.fromOffset(28,344),UDim2.fromOffset(420,56),Color3.fromRGB(24,30,31),function() open("Options") end) menuOptions.Name="Options" menuOptions.Font=Enum.Font.SpecialElite menuOptions.TextColor3=Color3.fromRGB(222,219,205) menuOptions.TextSize=20
for _,b in {play,menuOptions,cinemaReplay} do
 b.TextXAlignment=Enum.TextXAlignment.Left
 local padding=Instance.new("UIPadding") padding.PaddingLeft=UDim.new(0,22) padding.Parent=b
 b:FindFirstChildOfClass("UICorner").CornerRadius=UDim.new(0,3)
 b:FindFirstChildOfClass("UIStroke").Color=Color3.fromRGB(83,76,63)
end
cinemaReplay.Font=Enum.Font.SpecialElite cinemaReplay.TextSize=18
button(window,"X",UDim2.fromOffset(660,14),UDim2.fromOffset(42,32),RED,close).Name="Close"
local tabButtons={}
for i,id in {"Upgrades","Weapons","Pets","Time","Missions","Robux","Options","Crates"} do
 local names={Upgrades="ATELIER",Weapons="ARMES",Pets="PETS",Time="CADEAUX",Missions="MISSIONS",Robux="ROBUX",Options="OPTIONS",Crates="CAISSES"}
 local b=button(tabs,names[id],UDim2.fromOffset((i-1)*86,0),UDim2.fromOffset(82,32),BLUE,function() open(id) end) b.TextSize=12 tabButtons[id]=b
 local iconId=({Upgrades="Health",Weapons="Weapons",Pets="Pets",Time="Gift",Missions="Missions",Robux="Coins"})[id]
 if iconId then
  local icon=Art.Icon(b,iconId,24,UDim2.new(0,-23,.5,-12)) icon.ZIndex=b.ZIndex+1
  b.TextXAlignment=Enum.TextXAlignment.Right b.TextSize=10
  local padding=Instance.new("UIPadding") padding.PaddingRight=UDim.new(0,4) padding.PaddingLeft=UDim.new(0,26) padding.Parent=b
 end
end
local shopShortcut=button(quick,"BOUTIQUES [B]",UDim2.fromOffset(0,0),UDim2.fromOffset(148,32),GOLD,function() open("Upgrades") end)
local petShortcut=button(quick,"PETS [N]",UDim2.fromOffset(0,40),UDim2.fromOffset(148,32),GREEN,function() open("Pets") end)
local gift=button(quick,"CADEAUX [G]",UDim2.fromOffset(0,80),UDim2.fromOffset(148,32),BLUE,function() open("Time") end)
for i,b in {shopShortcut,petShortcut,gift} do
 Art.Icon(b,({"Weapons","Pets","Gift"})[i],28,UDim2.new(0,-30,.5,-14))
 local inset=Instance.new("UIPadding") inset.PaddingLeft=UDim.new(0,34) inset.PaddingRight=UDim.new(0,4) inset.Parent=b
 b.TextSize=12
end
if UIS.TouchEnabled then
 for _,b in quick:GetChildren() do if b:IsA("TextButton") then b.Visible=b==shopShortcut end end
 shopShortcut.Size=UDim2.fromOffset(120,44) shopShortcut.Position=UDim2.new() shopShortcut.Text="MENU"
 quick.Size=UDim2.fromOffset(120,44)
 window.Close.Size=UDim2.fromOffset(62,62) window.Close.Position=UDim2.fromOffset(644,6)
 tabs.Position=UDim2.fromOffset(16,80) tabs.Size=UDim2.fromOffset(688,60)
 for _,b in tabButtons do b.Size=UDim2.fromOffset(82,60) end
 scroll.Position=UDim2.fromOffset(16,152) scroll.Size=UDim2.fromOffset(688,250)
end
local function send(verb,id) action:FireServer(verb,tostring(id or "")) end
-- Portrait uses a tall window and stacked actions; Missions retains its compact tracker cards.
local function portraitActionHeight() return math.max(92,math.ceil(44/math.max(.1,ws.Scale))) end
local function row(title,desc,color,height)
 local portrait=portraitCatalog() local stacked=portrait and currentPage~="Missions"
 local extra=portrait and portraitActionHeight()-92 or 0
 local rowHeight=portrait and ((currentPage=="Weapons" and 260 or stacked and 250 or 190)+extra) or height or 86
 local f=frame(scroll,"Item",UDim2.new(),UDim2.new(1,-8,0,rowHeight),color or Color3.fromRGB(255,237,190))
 f.LayoutOrder=#scroll:GetChildren() f.ClipsDescendants=false
 local width=stacked and ((currentPage=="Upgrades" or currentPage=="Time" or currentPage=="Pets" or currentPage=="Crates" or currentPage=="Robux" or currentPage=="Options") and 510 or 636) or 390
 local titleLabel=text(f,"Name",title,UDim2.fromOffset(14,5),UDim2.fromOffset(width,portrait and 48 or 29),portrait and 28 or 18)
 local description=text(f,"Description",desc,UDim2.fromOffset(14,portrait and 54 or 34),UDim2.fromOffset(width,stacked and 76 or portrait and 72 or (height or 86)-40),portrait and 22 or 12)
 titleLabel.TextYAlignment=Enum.TextYAlignment.Top description.TextYAlignment=Enum.TextYAlignment.Top
 if currentPage=="Missions" or currentPage=="Robux" or currentPage=="Options" then
  Art.Icon(f,currentPage=="Missions" and "Missions" or currentPage=="Robux" and "Coins" or "Speed",stacked and 96 or 56,UDim2.fromOffset(stacked and 540 or 420,17))
 end
 return f
end
local function rowButton(f,value,fn,color,enabled,x,width)
 local portrait=portraitCatalog() local stacked=portrait and currentPage~="Missions"
 local bx,by,bw=x or 495,portrait and 35 or UIS.TouchEnabled and 12 or 22,width or 156
 if stacked then
  by=currentPage=="Weapons" and 160 or 152
  if currentPage=="Pets" then bx=x==286 and 14 or x==416 and 230 or 446 bw=204
  else bx=14 bw=636 end
 end
 local b=button(f,value,UDim2.fromOffset(bx,by),UDim2.fromOffset(bw,portrait and portraitActionHeight() or UIS.TouchEnabled and 62 or 42),color or GREEN,fn,enabled)
 b.Name="Action"
 if portrait then b.TextSize=26 end return b
end
local function rowIcon(parent,id)
 local existing=parent:FindFirstChild(id.."Artwork") if existing then return existing end
 local stacked=portraitCatalog() and currentPage~="Missions"
 local small=currentPage=="Pets" and not stacked
 return Art.Icon(parent,id,small and 26 or stacked and 96 or 56,small and UDim2.fromOffset(14,4) or UDim2.fromOffset(stacked and 540 or 420,17))
end
local function progressBar(parent,ratio,color)
 local portrait=portraitCatalog() local stacked=portrait and currentPage~="Missions"
 local track=Instance.new("Frame") track.Name="ProgressTrack" track.Position=UDim2.fromOffset(14,stacked and 138 or portrait and 158 or 78) track.Size=UDim2.fromOffset(stacked and 636 or 375,8) track.BackgroundColor3=INK track.BackgroundTransparency=.82 track.BorderSizePixel=0 track.Parent=parent round(track,4)
 local fill=Instance.new("Frame") fill.Name="Fill" fill.Size=UDim2.fromScale(math.clamp(ratio,0,1),1) fill.BackgroundColor3=color fill.BorderSizePixel=0 fill.Parent=track round(fill,4)
 if not stacked then parent.Description.Size=UDim2.fromOffset(390,portrait and 72 or 36) end
end
local previews={}
local function weaponPreview(parent,id)
 local portrait=portraitCatalog()
 local viewport=Instance.new("ViewportFrame") viewport.Name="WeaponPreview" viewport.Position=UDim2.fromOffset(portrait and 16 or 8,portrait and 16 or 7) viewport.Size=UDim2.fromOffset(portrait and 96 or 82,portrait and 96 or 82)
 viewport.BackgroundColor3=Color3.fromRGB(42,53,78) viewport.BorderSizePixel=0 viewport.Ambient=Color3.fromRGB(235,240,255) viewport.LightColor=Color3.fromRGB(255,252,240) viewport.Parent=parent round(viewport,14)
 local cam=Instance.new("Camera") cam.FieldOfView=34 cam.Parent=viewport viewport.CurrentCamera=cam
 local model,pieces=WeaponVisuals.Build(id) model.Parent=viewport
 if id=="Fists" then
  for _,x in {-.35,.35} do local glove=Instance.new("Part") glove.Size=Vector3.new(.52,.6,.65) glove.Color=C.Weapons.Fists.Color glove.CFrame=CFrame.new(x,1,0) glove.Parent=model end
 end
 local bounds,size=model:GetBoundingBox()
 local center=bounds.Position
 local halfVertical=math.rad(cam.FieldOfView/2)
 local halfHorizontal=math.atan(math.tan(halfVertical)*viewport.Size.X.Offset/viewport.Size.Y.Offset)
 local radius=math.max(size.Magnitude/2,.6)
 local distance=radius/math.sin(math.min(halfVertical,halfHorizontal))*1.15
 local direction=Vector3.new(3,2.2,5.3).Unit
 cam.CFrame=CFrame.lookAt(center+direction*distance,center)
 table.insert(previews,{viewport=viewport,model=model,base=model:GetPivot(),center=center})
 parent.Name="Weapon_"..id
 parent:FindFirstChild("Name").Position=UDim2.fromOffset(portrait and 128 or 102,portrait and 10 or 7) parent:FindFirstChild("Name").Size=UDim2.fromOffset(portrait and 522 or 365,portrait and 48 or 29)
 parent.Description.Position=UDim2.fromOffset(portrait and 128 or 102,portrait and 64 or 39) parent.Description.Size=UDim2.fromOffset(portrait and 522 or 365,portrait and 80 or 48)
end
RunService.RenderStepped:Connect(function()
 if not window.Visible or currentPage~="Weapons" or player:GetAttribute("ReducedMotion") then return end
 for _,item in previews do if item.viewport.Parent then
  local turn=CFrame.new(item.center)*CFrame.Angles(0,math.sin(os.clock()*.7)*.32,0)*CFrame.new(-item.center)
  item.model:PivotTo(turn*item.base)
 end end
end)
local function timeString(seconds)
 seconds=math.max(0,math.ceil(seconds)) return string.format("%02d:%02d",math.floor(seconds/60),seconds%60)
end
local function petBonus(id,rank)
 local coins,xp,speed=C.PetBonuses(id,rank)
 local t={} if coins>0 then table.insert(t,"+"..math.round(coins*100).."% pieces") end
 if xp>0 then table.insert(t,"+"..math.round(xp*100).."% XP") end
 if speed>0 then table.insert(t,"+"..math.round(speed*100).."% vitesse") end return table.concat(t," / ")
end
local boostStrip=text(gui,"ActiveBoosts","",UDim2.new(),UDim2.fromOffset(230,24),12)
boostStrip.BackgroundTransparency=0 boostStrip.BackgroundColor3=BLUE boostStrip.TextXAlignment=Enum.TextXAlignment.Center boostStrip.TextScaled=true boostStrip.Visible=false
round(boostStrip,8) stroke(boostStrip,2)
local boostTextLimit=Instance.new("UITextSizeConstraint") boostTextLimit.MinTextSize=9 boostTextLimit.MaxTextSize=12 boostTextLimit.Parent=boostStrip
bonus.TextScaled=true
local bonusTextLimit=Instance.new("UITextSizeConstraint") bonusTextLimit.MinTextSize=9 bonusTextLimit.MaxTextSize=12 bonusTextLimit.Parent=bonus
local function activeBoosts()
 if not state then return "" end
 local now=math.floor(workspace:GetServerTimeNow())
 local list={}
 local xp=math.max(0,(state.XPBoostUntil or 0)-now)
 local coins=math.max(0,(state.CoinBoostUntil or 0)-now)
 if xp>0 then table.insert(list,"XP x2 "..timeString(xp)) end
 if coins>0 then table.insert(list,"PIECES x2 "..timeString(coins)) end
 return table.concat(list," · ")
end
local function refreshBoosts()
 if not state then boostStrip.Visible=false return end
 local value=activeBoosts()
 local panel=player.PlayerGui:FindFirstChild("StatusPanel",true)
 boostStrip.Visible=value~="" and panel~=nil and player:GetAttribute("HasStarted")==true and not locked and not player:GetAttribute("OptionsOpen")
 boostStrip.Text=value
 if panel then
  local origin=gui.AbsolutePosition
  local y=UIS.TouchEnabled and panel.AbsolutePosition.Y+panel.AbsoluteSize.Y+6 or panel.AbsolutePosition.Y-30
  boostStrip.Position=UDim2.fromOffset(panel.AbsolutePosition.X-origin.X,y-origin.Y)
  boostStrip.Size=UDim2.fromOffset(panel.AbsoluteSize.X,24)
 end
 bonus.Text=string.format("%d pieces | Gains zombies : pieces x%.2f / XP x%.2f",state.Coins,state.CoinsMultiplier,state.XPMultiplier)..(value~="" and (" | "..value) or "")
end
local boostClock=0
RunService.Heartbeat:Connect(function(dt)
 boostClock+=dt
 if boostClock>=.25 then boostClock=0 refreshBoosts() end
end)
local timeRows={}
local function refreshTimeRows()
 if currentPage~="Time" or not state then return end
 local seconds=state.Daily.Seconds
 note.Text="Paliers uniques · Temps du jour : "..timeString(seconds).."\nCadeaux de temps remis a zero a 00:00 UTC."
 for i,refs in timeRows do
  local reward=C.TimeRewards[i]
  refs.fill.Size=UDim2.fromScale(math.clamp(seconds/reward.Seconds,0,1),1)
  if not state.Daily.Claimed[tostring(i)] and seconds<reward.Seconds then refs.button.Text=timeString(reward.Seconds-seconds) end
 end
end
render=function()
 if layoutWindow then layoutWindow() end
 renderGeneration+=1 local generation=renderGeneration
 local canvas=pendingPageReset and Vector2.zero or scroll.CanvasPosition pendingPageReset=false
 table.clear(timeRows)
 table.clear(previews)
 for _,v in scroll:GetChildren() do if v:IsA("GuiObject") then v:Destroy() end end
 pageTitle.Text=pageNames[currentPage] or "LE REFUGE"
 for id,b in tabButtons do b.BackgroundColor3=id==currentPage and GOLD or BLUE end
 if not state then row("Chargement...","Les donnees du survivant arrivent.") return end
 local s=state
 bonus.Text=string.format("%d pieces   |   Gains zombies : pieces x%.2f / XP x%.2f   |   Un pet actif",s.Coins,s.CoinsMultiplier,s.XPMultiplier)
 if currentPage=="Upgrades" then
  note.Text="Ameliorations permanentes sans plafond de jeu visible."
  for _,id in {"Health","Speed","Stamina","Ability"} do
   local d=C.Upgrades[id] local lv=s[id.."Level"] or 0 local value=C.UpgradeSteps(id,lv)*d.Step
   local desc=id=="Health" and string.format("Vie max : %.1f PV · rendement décroissant après le rang 25",100+value) or id=="Stamina" and string.format("Endurance max : %.1f · rendement décroissant après le rang 25",100+value) or id=="Ability" and ("Puissance des capacites : x"..string.format("%.2f",1+value).." · rendement décroissant après le rang 25") or ("Vitesse bonus : +"..string.format("%.1f",value).." · marche/sprint · rendement décroissant après 25")
   local f=row(d.Name.." · RANG "..string.format("%.0f",lv),desc,nil,100)
   f.Name="Upgrade_"..id rowIcon(f,id=="Stamina" and "XP" or id)

   local cost=C.UpgradeCost(id,lv) rowButton(f,lv>=C.ProgressionLevelLimit and "LIMITE TECH." or cost.." pieces",function() send("Upgrade",id) end,GREEN,lv<C.ProgressionLevelLimit and s.Coins>=cost)
  end
 elseif currentPage=="Weapons" then
  note.Text="Achete et equipe ici, ou que tu sois ! Armes a feu : tete x"..C.HeadshotMultiplier.."."
  local nextId=C.NextWeapon(s.Weapons)
  if nextId then
   local w=C.Weapons[nextId] local missing=math.max(0,w.Cost-s.Coins) local ready=s.Level>=w.Level and missing==0
   local f=row("PROCHAIN PALIER · "..w.Name,"Niveau "..s.Level.." / "..w.Level.." · "..s.Coins.." / "..w.Cost.." pieces\n"..(s.Level<w.Level and ("Encore "..(w.Level-s.Level).." niveau(x)") or "Niveau atteint")..(missing>0 and (" · Manque "..missing.." pieces") or " · Budget atteint"),GOLD,100)
   f.Name="NextWeaponGoal" rowIcon(f,"Weapons") f:SetAttribute("WeaponId",nextId)
   progressBar(f,s.Coins/math.max(1,w.Cost),GREEN)
   rowButton(f,ready and "OBTENIR · "..w.Cost or s.Level<w.Level and "NIVEAU "..w.Level or "ECONOMISE "..missing,function() send("BuyWeapon",nextId) end,GREEN,ready)
  else
   local f=row("DERNIER PALIER ATTEINT","Ton arsenal a atteint le dernier palier actuel.\nLes autres armes restent disponibles dans le catalogue.",GREEN,86)
   f.Name="NextWeaponGoal" f.Size=UDim2.new(1,-8,0,portraitCatalog() and 164 or 86)
  end
  for _,id in C.WeaponOrder do
   local w=C.Weapons[id] local owned=s.Weapons[id] local equipped=s.EquippedWeapon==id
   local f=row(w.Name,(w.Pellets and (w.Pellets.." x "..w.Damage) or tostring(w.Damage)).." degats · "..w.Range.." portee · "..w.Cooldown.." s / coup\n"..(w.Firearm and (w.Magazine.." balles · "..w.ReloadTime.." s recharge · ") or "").."Niveau "..w.Level..(owned and " · Possedee" or ""),equipped and Color3.fromRGB(208,245,225) or nil,100)
   weaponPreview(f,id)
   if w.Premium and not owned then rowButton(f,"VOIR ROBUX",function() open("Robux") end,BLUE)
   elseif owned then rowButton(f,equipped and "EQUIPEE" or "EQUIPER",function() send("EquipWeapon",id) end,BLUE,not equipped)
   else rowButton(f,s.Level<w.Level and "NIVEAU "..w.Level or w.Cost.." pieces",function() send("BuyWeapon",id) end,GREEN,s.Level>=w.Level and s.Coins>=w.Cost) end
  end
 elseif currentPage=="Crates" then
  note.Text=s.CratesAllowed and "Details et probabilites avant confirmation. Aucun achat automatique." or "Caisses indisponibles pour ce compte ou verification en cours. Achats directs dans ARMES."
  for _,id in Crates.Order do
   local d=Crates.Definitions[id]
   local f=row(d.Name,"Niveau "..d.Level.." · "..d.Cost.." pieces\n"..#d.Items.." objets possibles · Probabilites dans DETAILS",d.Color,100)
   f.Name="Crate_"..id rowIcon(f,"Gift")
   rowButton(f,"DETAILS",function() CrateReveal.Confirm(id,function() send("OpenCrate",id) end) end,GOLD,s.CratesAllowed and s.Level>=d.Level and s.Coins>=d.Cost)
  end
 elseif currentPage=="Pets" then
  note.Text="3 fragments = 1 pet · evolue avec des copies identiques · rangs sans plafond visible."
  for _,id in C.PetOrder do
   local pet=C.Pets[id] local count=s.Pets[id] or 0 local fragments=s.Fragments[id] or 0
   local rank=(s.PetRanks or {})[id] or 0 local needed=C.PetRankCost(rank)
   local desc=petBonus(id,rank).."\n"..(id=="Buddy" and "Cadeau des 30 minutes" or "Fragments : "..fragments.."/3").." · Copies : "..count
   desc..="\nRang "..string.format("%.0f",rank)..(needed and (" · Evolution : "..needed.." copies") or " · Limite technique")
   local f=row(pet.Name,desc,Color3.fromRGB(230,246,221),104) f.Name="Pet_"..id rowIcon(f,"Pets")
   if not portraitCatalog() then f:FindFirstChild("Name").Position=UDim2.fromOffset(46,5) f:FindFirstChild("Name").Size=UDim2.fromOffset(232,29) f.Description.Size=UDim2.fromOffset(260,64) end
   local evolve=rowButton(f,needed and "EVOLUER" or "LIMITE TECH.",function() send("UpgradePet",id) end,GREEN,needed~=nil and count>=needed,286,120) evolve.Name="Evolve"
   if id~="Buddy" then rowButton(f,"FUSIONNER",function() send("Fuse",id) end,GOLD,fragments>=3 and count<100000,416,116) end
   local equipped=s.EquippedPet==id
   rowButton(f,equipped and "RANGER" or "EQUIPER",function() send("EquipPet",equipped and "" or id) end,BLUE,count>0,542,112)
  end
 elseif currentPage=="Time" then
  note.Text="Paliers uniques · Temps du jour : "..timeString(s.Daily.Seconds).."\nCadeaux de temps remis a zero a 00:00 UTC."
  local login=s.Login or {Step=0} local reward=C.LoginRewards[login.Step+1]
  local room=reward.Kind~="Coins" or s.Coins<=2000000000-reward.Amount
  local space=reward.Kind~="Pet" or (s.Pets[reward.Id] or 0)<100000
  local ready=s.LoginReady and room and space
  local calendar=row("CONNEXION · CADEAU "..(login.Step+1).."/7",reward.Description.."\n1 cadeau par jour UTC · Aucun jour perdu",GOLD,100)
  calendar.Name="LoginReward" rowIcon(calendar,reward.Kind=="Pet" and "Pets" or reward.Kind=="Coins" and "Coins" or reward.Kind=="XP" and "XP" or "Gift")
  progressBar(calendar,login.Step/#C.LoginRewards,GREEN)
  rowButton(calendar,not s.LoginReady and "DEMAIN" or not room and "DEPENSE D'ABORD" or not space and "INVENTAIRE PLEIN" or "RECUPERER",function() send("ClaimLogin","Daily") end,GREEN,ready)
  for _,level in C.LevelRewardOrder do
   if (s.LevelRewards or {})[tostring(level)]==true then continue end
   local amount=C.LevelRewards[level] local unlocked=s.Level>=level local ready=unlocked and s.Coins<=2000000000-amount
   local f=row("NIVEAU "..level.." · PRIME DE SURVIE",amount.." pieces · A recuperer une seule fois\nTon niveau : "..s.Level.." / "..level,GOLD,100)
   f.Name="NextLevelReward" f:SetAttribute("RequiredLevel",level) rowIcon(f,"Coins")
   progressBar(f,s.Level/level,GREEN)
   rowButton(f,ready and "RECUPERER · "..amount or not unlocked and "NIVEAU "..level or "DEPENSE D'ABORD",function() send("ClaimLevel",level) end,GREEN,ready)
   break
  end
  for i,r in C.TimeRewards do
   local claimed=s.Daily.Claimed[tostring(i)] local ready=s.Daily.Seconds>=r.Seconds
   local f=row(math.floor(r.Seconds/60).." MIN · "..r.Name,r.Description,claimed and Color3.fromRGB(208,235,219) or nil,100)
   f.Name="Time_"..i rowIcon(f,r.Kind=="Coins" and "Coins" or r.Kind=="XP" and "XP" or r.Kind=="Pet" and "Pets" or "Gift")
   progressBar(f,s.Daily.Seconds/r.Seconds,GOLD)
   local claimButton=rowButton(f,claimed and "RECUPERE" or ready and "RECUPERER" or timeString(r.Seconds-s.Daily.Seconds),function() send("ClaimTime",i) end,GOLD,ready and not claimed)
   timeRows[i]={button=claimButton,fill=f.ProgressTrack.Fill}
  end
 elseif currentPage=="Missions" then
  note.Text="Express : zone la plus basse du contrat.\nPrime du jour et dossiers : recompenses fixes · Nouveau jour : 00:00 UTC."
  local claimed=s.Daily.FirstHuntClaimed==true local unlocked=s.Daily.Kills>=1
  local room=s.Coins<=2000000000-C.FirstHunt.Coins
  local hunt=row("PREMIERE CHASSE DU JOUR","Elimine 1 zombie\n"..C.FirstHunt.Coins.." pieces + "..C.FirstHunt.XP.." XP",claimed and GREEN or GOLD,100)
  hunt.Name="FirstDailyHunt" progressBar(hunt,unlocked and 1 or 0,GREEN)
  rowButton(hunt,claimed and "RECUPERE" or not unlocked and "1 ZOMBIE REQUIS" or not room and "DEPENSE D'ABORD" or "RECUPERER",function() send("ClaimDailyHunt","FirstHunt") end,GREEN,unlocked and room and not claimed)
  if s.Contract then
   local d=Contracts.Definitions[s.Contract.Index]
   local reward=Contracts.Reward(s.Contract) local tier=s.Contract.Count==0 and " · BASE" or " · x"..reward.Multiplier
   local f=row("EXPRESS · "..d.Name,d.Description.." · "..s.Contract.Count.." / "..d.Target.."\n"..reward.Coins.." pieces + "..reward.XP.." XP"..tier,Color3.fromRGB(209,241,230),100)
   f.Name="ExpressContractRow"
   progressBar(f,s.Contract.Count/d.Target,GREEN)
   rowButton(f,"AUTOMATIQUE",nil,GREEN,false)
  end
  local short={City="VILLE",Factory="USINE",Lab="LABO",Harbor="PORT",Power="CENTRALE",Metro="METRO"}
  for _,zone in World.Zones do
   if not Expeditions.Rewards[zone.Id] then continue end
   local record=s.Expeditions and s.Expeditions[zone.Id] or {Kills=0,Claimed=0,Seen={}}
   local step=record.Claimed+1 local unlocked=s.Level>=zone.Level
   if step>3 then
    local f=row(short[zone.Id].." · DOSSIER TERMINE","Les 3 recompenses permanentes ont ete recuperees.",Color3.fromRGB(208,235,219),100)
    progressBar(f,1,GREEN) rowButton(f,"TERMINE",nil,GREEN,false)
   else
    local d=Expeditions.Steps[step] local count,target=Expeditions.Progress(record,zone,step) local reward=Expeditions.Reward(zone.Id,step)
    local description=(d.Variety and "Especes eliminees" or "Eliminations dans la zone").." : "..count.." / "..target.."\n"..reward.Coins.." pieces + "..reward.XP.." XP · permanent"
    local ready=count>=target local key=zone.Id..":"..step
    local f=row(short[zone.Id].." · DOSSIER "..step.."/3",description,ready and unlocked and Color3.fromRGB(208,245,225) or nil,100)
    progressBar(f,count/target,zone.Color)
    rowButton(f,not unlocked and "NIV. "..zone.Level or ready and "RECUPERER" or "EN COURS",function() send("ClaimExpedition",key) end,GREEN,unlocked and ready)
   end
  end
  for i,m in C.Missions do
   local claimed=s.Daily.Missions[tostring(i)] local ready=s.Daily.Kills>=m.Kills
   local f=row("CHASSE · "..math.min(s.Daily.Kills,m.Kills).." / "..m.Kills,m.Coins.." pieces + "..m.XP.." XP",claimed and Color3.fromRGB(208,235,219) or nil,100)
   rowIcon(f,"Missions")
   progressBar(f,s.Daily.Kills/m.Kills,GREEN)
   rowButton(f,claimed and "RECUPERE" or ready and "RECUPERER" or "EN COURS",function() send("ClaimMission",i) end,GREEN,ready and not claimed)
  end
 elseif currentPage=="Robux" then
  note.Text=C.MonetizationEnabled and "Achats confirmes dans la fenetre officielle Roblox." or "ACHATS ROBUX DESACTIVES · Configuration des produits a venir."
  for _,p in C.Products do
   local enabled=C.MonetizationEnabled and p.ProductId>0 local f=row(p.Name,"Pack instantane · Prix dans la confirmation Roblox") f.Name="Product_"..p.Key
   rowButton(f,enabled and "ACHETER" or "BIENTOT",function() send("Robux",p.Key) end,GOLD,enabled)
  end
  local enabled=C.MonetizationEnabled and C.LimitedOffer.GamePassId>0 and C.LimitedOffer.SaleEndsAt>os.time()
  local sale=C.LimitedOffer.SaleEndsAt>0 and ("Fin : "..os.date("!%d/%m/%Y %H:%M UTC",C.LimitedOffer.SaleEndsAt)) or "Offre limitee : dates a configurer"
  local f=row(C.Weapons.LimitedBlade.Name,"Arme permanente · 55 degats · Habillage Nova\n"..sale,Color3.fromRGB(229,211,255),96)
  rowButton(f,s.Weapons.LimitedBlade and "POSSEDEE" or enabled and "ACHETER" or "BIENTOT",function() send("Robux","LimitedBlade") end,GOLD,enabled and not s.Weapons.LimitedBlade)
 elseif currentPage=="Options" then
  note.Text="Reglages de cette session. CTRL : dash · MAJ : sprint · F : torche."
  local guide=row("GUIDE DE SURVIE","Revoir les commandes, les armes, les fragments et les zones.") guide.Name="Option_Tutorial"
  rowButton(guide,"OUVRIR LE TUTORIEL",showTutorial,BLUE,true)
  local optedIn=player:GetAttribute("PvPEnabled")==true
  local pvp=row("PVP HORS ARÈNE","Les deux joueurs doivent activer ce réglage pour se battre ailleurs.") pvp.Name="Option_PvPEnabled"
  rowButton(pvp,optedIn and "ACTIF" or "INACTIF",function() action:FireServer("PvPPreference",not optedIn) end,optedIn and BLUE or RED,player:GetAttribute("HasStarted")==true)
  for _,o in {{"ThirdPerson","Vue du personnage","3E PERSONNE","1RE PERSONNE",true},{"HighGraphics","Qualite graphique","ELEVEE","STANDARD",false},{"RainEnabled","Pluie","ACTIVE","COUPEE",false},{"ReducedMotion","Camera douce","ACTIVE","COUPEE",true},{"SFXEnabled","Effets sonores","ACTIFS","COUPES",false}} do
   local value=player:GetAttribute(o[1]) local on=o[5] and value==true or not o[5] and value~=false
   local f=row(o[2],o[1]=="ThirdPerson" and "O : changer de vue. Clic droit / glisser : tourner la camera." or o[1]=="ReducedMotion" and "Reduit les mouvements de camera et les variations de champ de vision." or "Personnalise l'ambiance du jeu.") f.Name="Option_"..o[1]
   rowButton(f,on and o[3] or o[4],function() player:SetAttribute(o[1],not on) render() end,on and BLUE or RED)
  end
 end
 task.defer(function() if scroll.Parent and generation==renderGeneration then
  local extent=scroll.AbsoluteCanvasSize.Y-scroll.AbsoluteWindowSize.Y
  scroll.CanvasPosition=Vector2.new(0,math.clamp(canvas.Y,0,math.max(0,extent)))
 end end)
end
player:GetAttributeChangedSignal("PvPEnabled"):Connect(function() if window.Visible and currentPage=="Options" then render() end end)
local function notify(message)
 if window.Visible then note.Text=message return end
 toastSerial+=1 local serial=toastSerial toastText.Text=message toast.Visible=true
 task.delay(3,function() if toastSerial==serial then toast.Visible=false end end)
end
local renderedSignature
local function catalogSignature(data)
 local selected={CratesAllowed=data.CratesAllowed,Page=currentPage,Coins=data.Coins,Level=data.Level,Health=data.HealthLevel,Speed=data.SpeedLevel,Stamina=data.StaminaLevel,Ability=data.AbilityLevel,Weapon=data.EquippedWeapon,Weapons=data.Weapons,PetRanks=data.PetRanks,Pets=data.Pets,Fragments=data.Fragments,Pet=data.EquippedPet,XP=data.XPMultiplier,Money=data.CoinsMultiplier}
 if currentPage=="Time" then
  selected.Login=data.Login selected.LoginReady=data.LoginReady
  selected.LevelRewards=data.LevelRewards
  selected.Claims=data.Daily.Claimed selected.Ready={}
  for i,reward in C.TimeRewards do selected.Ready[i]=data.Daily.Seconds>=reward.Seconds end
 end
 if currentPage=="Missions" then selected.Kills=data.Daily.Kills selected.Claims=data.Daily.Missions selected.FirstHunt=data.Daily.FirstHuntClaimed selected.Contract=data.Contract selected.Expeditions=data.Expeditions end
 return HttpService:JSONEncode(selected)
end
local function refreshContractText()
 if not state or not state.Contract then return end
 local d=Contracts.Definitions[state.Contract.Index]
 local reward=Contracts.Reward(state.Contract) local tier=state.Contract.Count==0 and " (base)" or " x"..reward.Multiplier
 local value=d.Description.."\n"..state.Contract.Count.." / "..d.Target.." · +"..reward.Coins.." P / +"..reward.XP.." XP"..tier
 for _,zone in World.Zones do
  if zone.Name==player:GetAttribute("CurrentZone") and state.Expeditions then
   local record=state.Expeditions[zone.Id] local step=record and record.Claimed+1 or 1
   if record and step<=3 then
    local count,target=Expeditions.Progress(record,zone,step)
    value..="\nDOSSIER "..step.."/3 · "..count.."/"..target..(count>=target and "\nA RECUPERER · MISSIONS" or "")
   end
   break
  end
 end
 contractText.Text=value
end
player:GetAttributeChangedSignal("CurrentZone"):Connect(refreshContractText)
remote.OnClientEvent:Connect(function(packet)
 if typeof(packet)~="table" then return end
 if packet.Kind=="CrateResult" then CrateReveal.Play(packet) return end
 if packet.Kind=="CrateError" then CrateReveal.Error(packet.Note) return end
 if packet.Kind~="State" then return end
 state=packet.Data
 if state.HasStarted==true and state.TutorialCompleted~=true and not tutorialShown then tutorialShown=true showTutorial() end
 refreshContractText()
 local signature=catalogSignature(state)
 if packet.Open then open(packet.Open) elseif window.Visible and signature~=renderedSignature then render() end
 renderedSignature=catalogSignature(state)
 if window.Visible then refreshTimeRows() end
 if packet.Note then notify(packet.Note) end
end)
local function startedChanged()
 if player:GetAttribute("HasStarted")==true then main.Visible=false window.Visible=false end lock()
end
player:GetAttributeChangedSignal("HasStarted"):Connect(startedChanged)
player:GetAttributeChangedSignal("OptionsOpen"):Connect(function() action:FireServer("MenuState",locked or player:GetAttribute("OptionsOpen")==true) end)
UIS.InputBegan:Connect(function(input,processed)
 if processed or UIS:GetFocusedTextBox() or player:GetAttribute("HasStarted")~=true then return end
 if player:GetAttribute("AdminPanelOpen") then return end
 local page=input.KeyCode==Enum.KeyCode.B and "Upgrades" or input.KeyCode==Enum.KeyCode.N and "Pets" or input.KeyCode==Enum.KeyCode.G and "Time"
 if page then if window.Visible and currentPage==page then close() else open(page) end end
end)
local function bindTouchActions()
CAS:BindAction("SurvivalDash",function(_,phase)
 if phase==Enum.UserInputState.Begin and not player:GetAttribute("GameMenuOpen") and not player:GetAttribute("OptionsOpen") and player:GetAttribute("HasStarted")==true and not UIS:GetFocusedTextBox() then
  local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  local direction=h and h.MoveDirection or Vector3.zero if direction.Magnitude<0.1 then direction=workspace.CurrentCamera.CFrame.LookVector end
  direction=Vector3.new(direction.X,0,direction.Z) if direction.Magnitude>0.1 then dashRemote:FireServer(direction.Unit) end
 end return Enum.ContextActionResult.Sink
end,true,Enum.KeyCode.LeftControl,Enum.KeyCode.ButtonB)
CAS:SetTitle("SurvivalDash","DASH") CAS:SetPosition("SurvivalDash",UDim2.new(1,-235,1,-95))
end
bindTouchActions()
UIS:GetPropertyChangedSignal("TouchEnabled"):Connect(bindTouchActions)
local function dashVisuals(char)
 char:GetAttributeChangedSignal("DashUntil"):Connect(function()
  if (char:GetAttribute("DashUntil") or 0)<=workspace:GetServerTimeNow() then return end
  local root=char:FindFirstChild("HumanoidRootPart") if not root then return end
  local a=Instance.new("Attachment") a.Position=Vector3.new(-0.6,0,0) a.Parent=root
  local b=Instance.new("Attachment") b.Position=Vector3.new(0.6,0,0) b.Parent=root
  local trail=Instance.new("Trail") trail.Attachment0=a trail.Attachment1=b trail.FaceCamera=true trail.Lifetime=0.14 trail.Color=ColorSequence.new(BLUE,GOLD) trail.Transparency=NumberSequence.new(0.25,1) trail.Parent=root
  task.delay(C.Dash.Duration,function() if trail.Parent then trail.Enabled=false end end)
  Debris:AddItem(trail,0.5) Debris:AddItem(a,0.5) Debris:AddItem(b,0.5)
  local sound=Instance.new("Sound") sound.SoundId="rbxassetid://"..require(RS.FistsConfig).SwingSounds[1] sound.Volume=0.35 sound.PlaybackSpeed=1.4 sound.SoundGroup=game.SoundService:FindFirstChild("WorldCombat") sound.Parent=root sound:Play() Debris:AddItem(sound,2)
 end)
end
player.CharacterAdded:Connect(dashVisuals) if player.Character then dashVisuals(player.Character) end
local viewportConnection
layoutWindow=function()
 local v=workspace.CurrentCamera.ViewportSize if v.X<100 or v.Y<100 then return end
 local portrait=portraitCatalog()
 local factor=math.min(UIS.TouchEnabled and 1 or .84,(v.X-24)/720,(v.Y-24)/490)
 ws.Scale=factor
 local height=portrait and (v.Y-24)/factor or 490
 window.Size=UDim2.fromOffset(720,height)
 local actionHeight=portraitActionHeight()
 local closeSize=portrait and math.max(84,math.ceil(44/factor)) or UIS.TouchEnabled and 62 or 42
 local header=portrait and math.max(104,closeSize+22) or UIS.TouchEnabled and 80 or 55
 local tabHeight=portrait and actionHeight*2+10 or UIS.TouchEnabled and 60 or 34
 pageTitle.TextSize=portrait and 34 or 26 pageTitle.Size=UDim2.fromOffset(portrait and math.min(590,720-closeSize-46) or 600,portrait and 44 or 36)
 tabs.Position=UDim2.fromOffset(16,header)
 tabs.Size=UDim2.fromOffset(688,tabHeight)
 local labels={Upgrades="ATELIER",Weapons="ARMES",Pets="PETS",Time="CADEAUX",Missions=portrait and "QUETES" or "MISSIONS",Robux="ROBUX",Options="OPTIONS",Crates="CAISSES"}
 for i,id in {"Upgrades","Weapons","Pets","Time","Missions","Robux","Options","Crates"} do
  local b=tabButtons[id] local second=i>4
  b.Name="Tab_"..id
  b.Position=portrait and UDim2.fromOffset(((i-1)%4)*174,second and actionHeight+10 or 0) or UDim2.fromOffset((i-1)*86,0)
  b.Size=UDim2.fromOffset(portrait and 164 or 82,portrait and actionHeight or UIS.TouchEnabled and 60 or 32) b.TextSize=portrait and 26 or id=="Options" and 12 or 10
  b.Text=labels[id] b.TextWrapped=not portrait b.TextXAlignment=portrait and Enum.TextXAlignment.Center or id=="Options" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Right
  for _,v in b:GetChildren() do if v:IsA("ImageLabel") then v.Visible=not portrait end end
  local padding=b:FindFirstChildOfClass("UIPadding") if padding then padding.PaddingLeft=UDim.new(0,portrait and 4 or 26) end
 end
 window.Close.Size=UDim2.fromOffset(closeSize,portrait and closeSize or UIS.TouchEnabled and 62 or 32)
 window.Close.Position=UDim2.fromOffset(portrait and 720-closeSize-6 or UIS.TouchEnabled and 644 or 660,UIS.TouchEnabled and 6 or 14) window.Close.TextSize=portrait and 32 or 16
 local catalogTop=portrait and header+tabHeight+14 or UIS.TouchEnabled and 152 or 101
 scroll.Position=UDim2.fromOffset(16,catalogTop)
 scroll.Size=UDim2.fromOffset(688,portrait and height-catalogTop-190 or UIS.TouchEnabled and 250 or 301)
 bonus.TextScaled=not portrait bonus.TextSize=portrait and 22 or 12
 bonus.Position=UDim2.fromOffset(20,portrait and height-174 or 409) bonus.Size=UDim2.fromOffset(680,portrait and 64 or 26)
 bonusTextLimit.MinTextSize=9 bonusTextLimit.MaxTextSize=portrait and 22 or 12
 note.Position=UDim2.fromOffset(20,portrait and height-102 or 438) note.Size=UDim2.fromOffset(680,portrait and 88 or 36) note.TextSize=portrait and 20 or 13
end
local function resize()
 local camera=workspace.CurrentCamera if not camera then return end local v=camera.ViewportSize
 if v.X<100 or v.Y<100 then return end -- Studio can briefly expose a 1 x 1 viewport before the client tab renders.
 local compactMenu=v.X>v.Y and v.Y<500
 local menuHeight=compactMenu and 336 or 530
 local availableHeight=v.Y-GuiService:GetGuiInset().Y
 main.Size=UDim2.fromOffset(500,menuHeight)
 brand.Position=UDim2.fromOffset(28,compactMenu and 34 or 42) brand.Size=UDim2.fromOffset(444,compactMenu and 50 or 138) brand.TextSize=compactMenu and 34 or 68 brand.Text=compactMenu and "WEAPON EVOLUTION" or "WEAPON\nEVOLUTION"
 warning.Position=UDim2.fromOffset(30,compactMenu and 90 or 192) warning.TextSize=compactMenu and 16 or 18
 play.Position=UDim2.fromOffset(28,compactMenu and 146 or 260) play.Size=UDim2.fromOffset(420,compactMenu and 54 or 70)
 menuOptions.Position=UDim2.fromOffset(28,compactMenu and 204 or 344) menuOptions.Size=UDim2.fromOffset(420,62)
 cinemaReplay.Position=UDim2.fromOffset(28,compactMenu and 272 or 414) cinemaReplay.Size=UDim2.fromOffset(420,62)
 startHint.Visible=not compactMenu startHint.Position=UDim2.fromOffset(30,500)
 ms.Scale=math.min(1,(v.X-40)/500,(availableHeight-24)/menuHeight) ws.Scale=math.min(1,(v.X-24)/720,(v.Y-24)/490) ts.Scale=math.min(1,(v.X-30)/390)
 main.AnchorPoint=Vector2.zero
 local menuX=v.X>v.Y and math.max(24,v.X*.25-250*ms.Scale) or (v.X-500*ms.Scale)*.5
 local menuY=math.max(12,(availableHeight-menuHeight*ms.Scale)*(v.X>v.Y and .5 or .58))
 main.Position=UDim2.fromOffset(menuX-gui.AbsolutePosition.X,menuY-gui.AbsolutePosition.Y)
 menuGradient.Rotation=v.X>v.Y and 0 or 90
 local landscape=UIS.TouchEnabled and v.X>v.Y and v.Y<500
 quick.AnchorPoint=landscape and Vector2.new(.5,0) or Vector2.new(1,0)
 quick.Position=landscape and UDim2.new(.5,0,0,134) or UDim2.new(1,-18,0,152)
 quick.Size=UDim2.fromOffset(landscape and 292 or 148,landscape and 44 or 116)
 for i,b in {shopShortcut,petShortcut,gift} do
  b.Visible=not UIS.TouchEnabled or b==shopShortcut
  b.Position=UDim2.fromOffset(landscape and (i-1)*100 or 0,landscape and 0 or (i-1)*40)
  b.Size=UDim2.fromOffset(landscape and 92 or 148,landscape and 44 or 32)
 end
 local qscale=quick:FindFirstChildOfClass("UIScale") or Instance.new("UIScale") qscale.Parent=quick qscale.Scale=1
 layoutWindow()
 if window.Visible and render then render() end
end
local function cameraChanged() if viewportConnection then viewportConnection:Disconnect() end if workspace.CurrentCamera then viewportConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end resize() end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraChanged) cameraChanged()
UIS:GetPropertyChangedSignal("TouchEnabled"):Connect(resize)
local touchButtonsCache={}
RunService:BindToRenderStep("GameHubCursor",Enum.RenderPriority.Camera.Value+20,function()
 if locked then
  local camera=workspace.CurrentCamera camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=player:GetAttribute("HasStarted")~=true and CFrame.lookAt(Vector3.new(0,15,246),Vector3.new(0,5,150)) or savedCamera or camera.CFrame
  UIS.MouseBehavior=Enum.MouseBehavior.Default UIS.MouseIconEnabled=true
  local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h:Move(Vector3.zero,false) end
 end
end)
-- Status labels/layout do not need to block the camera render step.
local statusClock=0
RunService.Heartbeat:Connect(function(dt)
 statusClock+=dt if statusClock<.1 then return end statusClock%=.1
 local playing=player:GetAttribute("HasStarted")==true
 local progressToast=player.PlayerGui:FindFirstChild("ProgressToast",true)
 local toastY=150
 local viewport=workspace.CurrentCamera.ViewportSize
 local landscape=UIS.TouchEnabled and viewport.X>viewport.Y
 local portrait=UIS.TouchEnabled and viewport.X<=viewport.Y
 local toastWidth=landscape and math.min(300,math.max(220,viewport.X-430)) or 390
 local center=viewport.X/2
 local status=player.PlayerGui:FindFirstChild("StatusPanel",true)
 if landscape and status then center=math.max(center,status.AbsolutePosition.X+status.AbsoluteSize.X+8+toastWidth*ts.Scale/2) end
 local inset=GuiService:GetGuiInset()
 if portrait then
  local boosts=player.PlayerGui:FindFirstChild("ActiveBoosts",true)
  local ammo=player.PlayerGui:FindFirstChild("Ammo",true)
  for _,item in {status,boosts,ammo} do
   if item and item.Visible then toastY=math.max(toastY,item.AbsolutePosition.Y+item.AbsoluteSize.Y+inset.Y+8) end
  end
 end
 if progressToast and progressToast.Visible then
  local screen=progressToast:FindFirstAncestorWhichIsA("ScreenGui")
  local offset=screen and not screen.IgnoreGuiInset and inset.Y or 0
  toastY=math.max(toastY,progressToast.AbsolutePosition.Y+progressToast.AbsoluteSize.Y+offset+8)
 end
 toast.Size=UDim2.fromOffset(toastWidth,50) toast.Position=UDim2.fromOffset(center,toastY)
 local touchGui=player.PlayerGui:FindFirstChild("TouchGui") if touchGui then touchGui.Enabled=playing and not locked and not player:GetAttribute("OptionsOpen") end
 quick.Visible=playing and not locked and not player:GetAttribute("OptionsOpen") dashCard.Visible=quick.Visible and not UIS.TouchEnabled
 contractCard.Visible=quick.Visible and not UIS.TouchEnabled and workspace.CurrentCamera.ViewportSize.X>=1000 and workspace.CurrentCamera.ViewportSize.Y>=600
 play.Text=player:GetAttribute("ProgressReady") and "01   JOUER" or "CHARGEMENT..."
 local c=player.Character local remaining=c and math.max(0,(c:GetAttribute("DashReadyAt") or 0)-workspace:GetServerTimeNow()) or 0
 local stamina=c and (c:GetAttribute("Stamina") or 0) or 0
 dashLabel.Text=remaining>0 and string.format("DASH · %.1f s",remaining) or stamina<C.Dash.Cost and "DASH · 25 ENDURANCE" or UIS.TouchEnabled and "DASH PRET" or "CTRL · DASH PRET"
 dashCard.BackgroundColor3=remaining>0 and Color3.fromRGB(167,181,190) or BLUE
 if UIS.TouchEnabled then
  local jump=player.PlayerGui:FindFirstChild("JumpButton",true)
  local base=jump and (jump.AbsolutePosition+Vector2.new(jump.AbsoluteSize.X/2,-50)) or Vector2.new(workspace.CurrentCamera.ViewportSize.X-70,180)
  local layout={{"FistsPunch","COUP",base,RED},{"SurvivalSprint","SPRINT",base+Vector2.new(-68,-68),BLUE},{"SurvivorFlashlight","LAMPE",base+Vector2.new(-68,0),GOLD},{"SurvivalDash","DASH",base+Vector2.new(-136,68),GREEN},{"SurvivalCrouch","GLISSE",base+Vector2.new(-136,0),BLUE},{"SurvivalVault","FRANCHIR",base+Vector2.new(-136,-68),GOLD},{"SurvivalReload","RECHARGE",base+Vector2.new(-204,0),GOLD}}
  local viewport=workspace.CurrentCamera.ViewportSize
  if jump and viewport.X>viewport.Y and viewport.X>=700 then
   -- Keep the aiming lane clear; primary actions remain next to Jump.
   local center=jump.AbsolutePosition+jump.AbsoluteSize/2
   local bottom=center.Y
   layout={
    {"FistsPunch","COUP",center+Vector2.new(0,-72),RED},
    {"SurvivalReload","RECHARGE",center+Vector2.new(-72,-72),GOLD},
    {"SurvivalVault","FRANCHIR",center+Vector2.new(-72,0),GOLD},
    {"SurvivalCrouch","GLISSE",center+Vector2.new(-140,0),BLUE},
    {"SurvivalDash","DASH",center+Vector2.new(-208,0),GREEN},
    {"SurvivalSprint","SPRINT",Vector2.new(190,bottom),BLUE},
    {"SurvivorFlashlight","LAMPE",Vector2.new(258,bottom),GOLD},
   }
  end
  for _,info in layout do
   local touch=touchButtonsCache[info[1]]
   if not touch or not touch.Parent then
    if player.PlayerGui:FindFirstChild("ContextActionGui") and CAS:GetAllBoundActionInfo()[info[1]] then touch=CAS:GetButton(info[1]) touchButtonsCache[info[1]]=touch else touch=nil end
   end
   if touch and touch.Parent then
    touch.Visible=quick.Visible and (info[1]~="SurvivalReload" or (C.Weapons[player:GetAttribute("EquippedWeapon") or "Fists"].Firearm==true)) touch.Size=UDim2.fromOffset(54,54) touch.AnchorPoint=Vector2.new(0.5,0.5)
    local pos=info[3]-touch.Parent.AbsolutePosition touch.Position=UDim2.fromOffset(pos.X,pos.Y)
    touch.ImageTransparency=1 touch.BackgroundTransparency=0 touch.BackgroundColor3=info[4]
    if not touch:FindFirstChildOfClass("UICorner") then local co=Instance.new("UICorner") co.CornerRadius=UDim.new(1,0) co.Parent=touch end
    local border=touch:FindFirstChildOfClass("UIStroke") if not border then stroke(touch,3) border=touch:FindFirstChildOfClass("UIStroke") end border.Color=INK border.Thickness=3 border.Transparency=0
    local title=touch:FindFirstChild("ActionTitle") if title then title.Text=info[1]=="SurvivalDash" and remaining>0 and string.format("%.1f",remaining) or (info[1]=="FistsPunch" and C.Weapons[player:GetAttribute("EquippedWeapon") or "Fists"].Firearm) and "TIR" or info[2] title.Font=Enum.Font.FredokaOne title.TextSize=12 title.TextColor3=INK title.TextWrapped=false title.TextStrokeTransparency=1 end
   end
  end
 end
 if state then
  local loginReward=C.LoginRewards[(state.Login and state.Login.Step or 0)+1]
  local loginReady=state.LoginReady and (loginReward.Kind~="Coins" or state.Coins<=2000000000-loginReward.Amount) and (loginReward.Kind~="Pet" or (state.Pets[loginReward.Id] or 0)<100000)
  local ready=loginReady and 1 or 0 for i,r in C.TimeRewards do if state.Daily.Seconds>=r.Seconds and not state.Daily.Claimed[tostring(i)] then ready+=1 end end
  for _,level in C.LevelRewardOrder do if state.Level>=level and state.Coins<=2000000000-C.LevelRewards[level] and (state.LevelRewards or {})[tostring(level)]~=true then ready+=1 end end
  gift.Text=ready>0 and "CADEAUX ("..ready..") [G]" or "CADEAUX [G]"
  local upgradeReady=false
  for _,id in {"Health","Speed","Stamina","Ability"} do
   local level=state[id.."Level"] or 0
   if level<C.ProgressionLevelLimit and state.Coins>=C.UpgradeCost(id,level) then upgradeReady=true break end
  end
  shopShortcut.Text=UIS.TouchEnabled and ((upgradeReady and "ATELIER !" or "MENU")..(ready>0 and " +"..ready or "")) or (upgradeReady and "ATELIER ! [B]" or "BOUTIQUES [B]")
 end
end)
-- One cosmetic companion per player; bonus values stay authoritative on the server.
local petFolder=Instance.new("Folder") petFolder.Name="LocalPetCompanions" petFolder.Parent=workspace local companions={}
local function petModel(id)
 local d=C.Pets[id] local m=Instance.new("Model") m.Name=d.Name
 local function piece(name,size,pos,color,shape,class)
  local p=Instance.new(class or "Part") p.Name=name p.Size=size p.CFrame=CFrame.new(pos) p.Color=color p.Material=Enum.Material.SmoothPlastic
  if p:IsA("Part") then p.Shape=shape or Enum.PartType.Block end
  p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false p.Parent=m return p
 end
 local body=piece("Body",Vector3.new(1.35,1.2,1.25),Vector3.zero,d.Color,d.Shape=="Robot" and Enum.PartType.Block or Enum.PartType.Ball) m.PrimaryPart=body
 for _,sign in {-1,1} do
  piece("Eye",Vector3.new(0.19,0.23,0.12),Vector3.new(sign*0.27,0.12,-0.58),INK,Enum.PartType.Ball)
  piece("EyeShine",Vector3.new(0.05,0.07,0.035),Vector3.new(sign*0.27-0.03,0.17,-0.646),CREAM,Enum.PartType.Ball)
  piece("Foot",Vector3.new(0.32,0.23,0.4),Vector3.new(sign*0.38,-0.52,0.1),d.Color,Enum.PartType.Ball)
  if d.Shape=="Crab" then
   piece("ClawStem",Vector3.new(.48,.13,.13),Vector3.new(sign*.84,.18,-.25),d.Color)
   piece("Claw",Vector3.new(.38,.4,.32),Vector3.new(sign*1.08,.3,-.3),d.Color,Enum.PartType.Ball)
   piece("ClawSplit",Vector3.new(.1,.24,.34),Vector3.new(sign*1.08,.46,-.3),INK)
   for i=1,3 do piece("CrabLeg",Vector3.new(.44,.1,.12),Vector3.new(sign*.78,-.35,-.35+i*.3),d.Color) end
  elseif d.Shape=="Shark" then
   local fin=piece("SideFin",Vector3.new(.5,.12,.6),Vector3.new(sign*.8,-.05,.12),d.Color,nil,"WedgePart") fin.CFrame*=CFrame.Angles(0,0,sign*.18)
  elseif d.Shape=="Kraken" then
   for i=1,3 do
    local tentacle=piece("Tentacle",Vector3.new(.22,.22,.85),Vector3.new(sign*(.32+i*.13),-.52,-.35+i*.4),d.Color,Enum.PartType.Ball)
    tentacle.CFrame*=CFrame.Angles(0,sign*.5,0)
    piece("Sucker",Vector3.new(.13,.07,.13),Vector3.new(sign*(.32+i*.13),-.64,-.55+i*.4),CREAM,Enum.PartType.Ball)
   end
  elseif d.Shape=="Bat" then
   local wing=piece("Wing",Vector3.new(0.85,0.15,0.85),Vector3.new(sign*0.95,0,0),d.Color,nil,"WedgePart") wing.CFrame*=CFrame.Angles(0,0,sign*0.2)
  elseif d.Shape=="Alien" then
   piece("Antenna",Vector3.new(0.1,0.48,0.1),Vector3.new(sign*0.32,0.69,0),d.Color)
   piece("Tip",Vector3.new(0.2,0.2,0.2),Vector3.new(sign*0.32,0.97,0),GOLD,Enum.PartType.Ball)
  else
   local tall=d.Shape=="Rabbit" and 0.75 or d.Shape=="Dog" and 0.55 or 0.35
   piece("Ear",Vector3.new(0.33,tall,0.32),Vector3.new(sign*0.45,0.54+tall*0.25,0),d.Color,d.Shape=="Bear" and Enum.PartType.Ball or Enum.PartType.Block)
  end
 end
 if d.Shape=="Shark" then
  piece("DorsalFin",Vector3.new(.18,.65,.65),Vector3.new(0,.64,.05),d.Color,nil,"WedgePart")
  piece("Tail",Vector3.new(.8,.14,.6),Vector3.new(0,.03,.84),d.Color,nil,"WedgePart")
 end
 piece("Smile",Vector3.new(0.2,0.045,0.05),Vector3.new(0,-0.22,-0.625),INK)
 local b=Instance.new("BillboardGui") b.Name="PetName" b.Size=UDim2.fromOffset(132,24) b.StudsOffsetWorldSpace=Vector3.new(0,1.2,0) b.MaxDistance=28 b.Parent=body
 local t=text(b,"Name",d.Name,UDim2.new(),UDim2.fromScale(1,1),12,CREAM) t.TextXAlignment=Enum.TextXAlignment.Center t.TextStrokeColor3=INK t.TextStrokeTransparency=0.1
 return m
end
CrateReveal.PetModel=petModel
local function watchPet(p)
 local function update()
  if companions[p] then companions[p].model:Destroy() companions[p]=nil end
  local id=p:GetAttribute("EquippedPet") if C.Pets[id] then companions[p]={model=petModel(id),initialized=false} end
 end
 p:GetAttributeChangedSignal("EquippedPet"):Connect(update) p.CharacterAdded:Connect(function() if companions[p] then companions[p].initialized=false end end) update()
end
Players.PlayerAdded:Connect(watchPet) for _,p in Players:GetPlayers() do watchPet(p) end
Players.PlayerRemoving:Connect(function(p) if companions[p] then companions[p].model:Destroy() companions[p]=nil end end)
RunService.RenderStepped:Connect(function(dt)
 local camera=workspace.CurrentCamera if not camera then return end
 for p,data in companions do
  local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart") local m=data.model
  if root and (root.Position-camera.CFrame.Position).Magnitude<120 then
   m.Parent=petFolder local pos=(root.CFrame*CFrame.new(2.6,-1.25,2.7)).Position+Vector3.new(0,math.sin(os.clock()*4)*0.15,0)
   local look=pos+Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
   local target=CFrame.lookAt(pos,look) m:PivotTo(data.initialized and m:GetPivot():Lerp(target,1-math.exp(-dt*9)) or target) data.initialized=true
  else m.Parent=nil data.initialized=false end
 end
end)
player.PlayerGui.ChildAdded:Connect(function(child) if child.Name=="SurvivalHUD" and child:IsA("ScreenGui") then child.Enabled=player:GetAttribute("HasStarted")==true end end)
task.spawn(function() local hud=player.PlayerGui:WaitForChild("SurvivalHUD",30) if hud then hud.Enabled=player:GetAttribute("HasStarted")==true end end)
lock() action:FireServer("Sync")

-- Admin UI uses the same controls and menu lock as the existing hub.
task.spawn(function()
 while player:GetAttribute("AdminAccess")==nil do player:GetAttributeChangedSignal("AdminAccess"):Wait() end
 if player:GetAttribute("AdminAccess")~=true then return end
 local adminRemote=RS.Remotes:WaitForChild("AdminAction")
 local adminGui=Instance.new("ScreenGui") adminGui.Name="AdminPanel" adminGui.ResetOnSpawn=false adminGui.DisplayOrder=40 adminGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling adminGui.Parent=player.PlayerGui
 local panel=frame(adminGui,"Panel",UDim2.fromScale(.5,.5),UDim2.new(1,-24,1,-24),CREAM) panel.AnchorPoint=Vector2.new(.5,.5) panel.Visible=false
 local bounds=Instance.new("UISizeConstraint") bounds.MaxSize=Vector2.new(560,580) bounds.Parent=panel
 text(panel,"Title","ADMIN · TESTS",UDim2.fromOffset(16,10),UDim2.new(1,-85,0,40),24)
 local status=text(panel,"Status","",UDim2.new(0,16,1,-65),UDim2.new(1,-32,0,58),14)
 local mode=RunService:IsStudio() and "Studio : gains temporaires." or "Gains sauvegardes sur ton compte."
 status.Text=mode
 local busy=false
 local function toggle()
  if not panel.Visible and (player:GetAttribute("HasStarted")~=true or player:GetAttribute("GameMenuOpen") or player:GetAttribute("OptionsOpen")) then return end
  panel.Visible=not panel.Visible player:SetAttribute("AdminPanelOpen",panel.Visible)
 end
 local entry=button(adminGui,"ADMIN [F4]",UDim2.new(.5,-62,1,-140),UDim2.fromOffset(124,44),GOLD,toggle) entry.Name="Open"
 local closeAdmin=button(panel,"X",UDim2.new(1,-60,0,8),UDim2.fromOffset(44,44),RED,toggle) closeAdmin.Name="Close" closeAdmin.Modal=true
 text(panel,"QuantityLabel","QUANTITE",UDim2.fromOffset(16,62),UDim2.new(.5,-24,0,44),16)
 local quantity=Instance.new("TextBox") quantity.Name="Quantity" quantity.Text="1" quantity.ClearTextOnFocus=false quantity.PlaceholderText="1 a 1000000" quantity.Font=Enum.Font.FredokaOne quantity.TextSize=20 quantity.TextColor3=INK quantity.BackgroundColor3=Color3.new(1,1,1) quantity.Position=UDim2.new(.5,0,0,62) quantity.Size=UDim2.new(.5,-16,0,44) quantity.Parent=panel round(quantity,10) stroke(quantity,2)
 local categories={{"Coins","PIECES"},{"Levels","NIVEAUX"},{"XP","XP"},{"Weapon","ARMES"},{"Pet","PETS"},{"Fragments","FRAGMENTS"}}
 if player:GetAttribute("AdminCanDelegate")==true then table.insert(categories,{"Admins","ADMINS"}) end
 local category=1
 local list=Instance.new("ScrollingFrame") list.Name="Items" list.BackgroundTransparency=1 list.BorderSizePixel=0 list.Position=UDim2.fromOffset(16,168) list.Size=UDim2.new(1,-32,1,-240) list.CanvasSize=UDim2.new() list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.ScrollBarThickness=5 list.Parent=panel
 local flow=Instance.new("UIListLayout") flow.Padding=UDim.new(0,8) flow.SortOrder=Enum.SortOrder.LayoutOrder flow.Parent=list
 local targetName=Instance.new("TextBox") targetName.Name="TargetUsername" targetName.Text="" targetName.PlaceholderText="Nom d'utilisateur Roblox" targetName.ClearTextOnFocus=false targetName.Font=Enum.Font.FredokaOne targetName.TextSize=18 targetName.TextColor3=INK targetName.BackgroundColor3=Color3.new(1,1,1) targetName.Size=UDim2.new(1,-10,0,44) targetName.Parent=list round(targetName,10) stroke(targetName,2)
 local selectCategory
 local function give(verb,id)
  if busy then return end
  local amount=verb=="Weapon" and 1 or tonumber(quantity.Text)
  if not amount or amount~=amount or amount%1~=0 or amount<1 or amount>1000000 then status.Text="Entre une quantite entiere de 1 a 1 000 000." return end
  busy=true status.Text="Attribution en cours..."
  local ok,accepted,message=pcall(function() return adminRemote:InvokeServer(verb,id,amount) end)
  status.Text=ok and (message.."\n"..mode) or "Connexion interrompue : verifie ton inventaire avant de reessayer."
  status.TextColor3=ok and accepted and INK or Color3.fromRGB(151,55,45)
  task.wait(.35) busy=false
 end
 local function manage(verb,id)
  if busy then return false end
  busy=true status.Text="Mise a jour des acces..."
  local ok,accepted,message=pcall(function() return adminRemote:InvokeServer(verb,id,1) end)
  status.Text=ok and (message.."\n"..mode) or "Connexion interrompue : acces non confirme."
  status.TextColor3=ok and accepted and INK or Color3.fromRGB(151,55,45)
  busy=false
  return ok and accepted
 end
 local function renderAdmin()
  for _,child in list:GetChildren() do if child:IsA("GuiObject") and child~=targetName then child:Destroy() end end
  list.CanvasPosition=Vector2.zero
  local verb=categories[category][1]
  selectCategory.Text="<  "..categories[category][2].."  >"
  quantity.Visible=verb~="Weapon"
  targetName.Visible=verb=="Admins"
  panel.QuantityLabel.Text=verb=="Admins" and "NOM ROBLOX" or (verb=="Weapon" and "Une copie · equipement conserve" or "QUANTITE")
  panel.QuantityLabel.Size=verb=="Weapon" and UDim2.new(1,-32,0,44) or UDim2.new(.5,-24,0,44)
  local function row(id,label,index)
   local b=button(list,"+  "..label,UDim2.new(),UDim2.new(1,-10,0,48),GREEN,function() give(verb,id) end)
   b.Name=id or verb b.LayoutOrder=index
  end
  if verb=="Admins" then
   quantity.Visible=false
   local add=button(list,"+  DONNER LES ACCES ADMIN",UDim2.new(),UDim2.new(1,-10,0,48),GREEN,function()
    if manage("GrantAdmin",targetName.Text) then targetName.Text="" task.delay(.35,renderAdmin) end
   end)
   add.Name="GrantAdmin" add.LayoutOrder=1
   local ok,accepted,message,ids=pcall(function() return adminRemote:InvokeServer("ListAdmins",nil,1) end)
   if ok and accepted and typeof(ids)=="table" then
    if #ids==0 then text(list,"NoDelegates","Aucun admin delegue",UDim2.new(),UDim2.new(1,-10,0,42),16).LayoutOrder=2 end
    for i,delegate in ids do
     local revoke=button(list,"RETIRER  ·  "..delegate.Username,UDim2.new(),UDim2.new(1,-10,0,48),RED,function()
      if manage("RevokeAdmin",delegate.UserId) then task.delay(.35,renderAdmin) end
     end)
     revoke.Name="Revoke_"..delegate.UserId revoke.LayoutOrder=i+2
    end
   else status.Text=(ok and tostring(message) or "Connexion interrompue").."\n"..mode end
  elseif verb=="Weapon" then
   for i,id in C.WeaponOrder do row(id,C.Weapons[id].Name,i) end
  elseif verb=="Pet" or verb=="Fragments" then
   for i,id in C.PetOrder do if verb=="Pet" or id~="Buddy" then row(id,C.Pets[id].Name,i) end end
  else row(nil,"AJOUTER "..categories[category][2],1) end
 end
 selectCategory=button(panel,"",UDim2.fromOffset(16,114),UDim2.new(1,-32,0,44),BLUE,function() category=category%#categories+1 renderAdmin() end) selectCategory.Name="Category"
 renderAdmin()
 local function entryVisible()
  entry.Visible=player:GetAttribute("HasStarted")==true and not player:GetAttribute("GameMenuOpen") and not player:GetAttribute("OptionsOpen")
 end
 for _,attribute in {"HasStarted","GameMenuOpen","OptionsOpen"} do player:GetAttributeChangedSignal(attribute):Connect(entryVisible) end
 entryVisible()
 UIS.InputBegan:Connect(function(input,processed) if not processed and not UIS:GetFocusedTextBox() and input.KeyCode==Enum.KeyCode.F4 then toggle() end end)
 player.CharacterAdded:Connect(function() panel.Visible=false player:SetAttribute("AdminPanelOpen",false) end)
 player:GetAttributeChangedSignal("AdminAccess"):Connect(function()
  local allowed=player:GetAttribute("AdminAccess")==true
  adminGui.Enabled=allowed
  if not allowed then panel.Visible=false player:SetAttribute("AdminPanelOpen",false) end
 end)
end)
