local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Config = require(ReplicatedStorage:WaitForChild("FistsConfig"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PunchRemote = Remotes:WaitForChild("Punch")
local PunchHitRemote = Remotes:WaitForChild("PunchHit")

local BASE_FOV = 75
local SLEEVE_COLOR = Color3.fromRGB(45, 45, 55)

-- Phases de l'animation d'un coup (secondes)
local WINDUP, STRIKE, RECOVER = 0.09, 0.08, 0.30

------------------------------------------------------------------
-- SONS
------------------------------------------------------------------
local function playSound(ids, volume, speed)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. ids[math.random(#ids)]
	s.Volume = volume
	s.PlaybackSpeed = (speed or 1) * (0.93 + math.random() * 0.14)
	s.Parent = SoundService
	s:Play()
	s.Ended:Once(function() s:Destroy() end)
	Debris:AddItem(s, 4)
end

task.spawn(function() -- préchargement pour éviter le silence au 1er coup
	local toLoad = {}
	for _, list in ipairs({ Config.SwingSounds, Config.HitSounds, Config.HeavyHitSounds }) do
		for _, id in ipairs(list) do
			local s = Instance.new("Sound")
			s.SoundId = "rbxassetid://" .. id
			table.insert(toLoad, s)
		end
	end
	pcall(function() ContentProvider:PreloadAsync(toLoad) end)
	for _, s in ipairs(toLoad) do s:Destroy() end
end)

------------------------------------------------------------------
-- VIEWMODEL (bras + poings devant la caméra)
------------------------------------------------------------------
local function getHumanoid()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function getSkinColor()
	local hum = getHumanoid()
	if hum then
		local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
		if ok and desc then return desc.RightArmColor end
	end
	return Color3.fromRGB(234, 184, 146)
end

local function makePart(name, size, color, shape, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Massless = true
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local viewmodel = Instance.new("Folder")
viewmodel.Name = "FistsViewmodel"

local function buildSide(sign, skin)
	local model = Instance.new("Model")
	model.Name = sign < 0 and "LeftArm" or "RightArm"
	model.Parent = viewmodel
	return {
		sign = sign,
		start = -math.huge,
		scale = 1,
		-- position de repos (bas gauche / bas droite de l'écran), légèrement tournée vers le centre
		base = CFrame.new(sign * 0.9, -0.85, -2.0) * CFrame.Angles(math.rad(6), math.rad(sign * 8), 0),
		parts = {
			{ part = makePart("Fist", Vector3.one * 0.72, skin, Enum.PartType.Ball, model), rel = CFrame.new() },
			{ part = makePart("Forearm", Vector3.new(0.5, 0.5, 1.3), skin, nil, model), rel = CFrame.new(0, 0, 0.85) },
			{ part = makePart("Sleeve", Vector3.new(0.68, 0.68, 1.4), SLEEVE_COLOR, nil, model), rel = CFrame.new(0, 0, 2.2) },
		},
	}
end

local skin = getSkinColor()
local sides = {
	Left = buildSide(-1, skin),
	Right = buildSide(1, skin),
}

------------------------------------------------------------------
-- VISEUR
------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "Crosshair"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local dot = Instance.new("Frame")
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.fromScale(0.5, 0.5)
dot.Size = UDim2.fromOffset(6, 6)
dot.BackgroundColor3 = Color3.new(1, 1, 1)
dot.BorderSizePixel = 0
dot.Parent = gui
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", dot)
stroke.Thickness = 1.5
stroke.Color = Color3.new(0, 0, 0)
stroke.Transparency = 0.3

local function flashCrosshair(heavy)
	local big = heavy and 16 or 11
	dot.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
	dot.Size = UDim2.fromOffset(big, big)
	TweenService:Create(dot, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.fromOffset(6, 6),
	}):Play()
end

------------------------------------------------------------------
-- ANIMATION D'UN COUP
-- renvoie p : -0.35 (recul) -> 1 (coup tendu) -> 0 (repos)
------------------------------------------------------------------
local function punchAlpha(t)
	if t < WINDUP then
		local a = t / WINDUP
		return -0.35 * (1 - (1 - a) ^ 2)
	elseif t < WINDUP + STRIKE then
		local a = (t - WINDUP) / STRIKE
		return -0.35 + 1.35 * (1 - (1 - a) ^ 3)
	elseif t < WINDUP + STRIKE + RECOVER then
		local a = (t - WINDUP - STRIKE) / RECOVER
		return 1 - a * a * (3 - 2 * a)
	end
	return 0
end

-- Camera shake + FOV kick
local shakeStart, shakeDur, shakeAmp = -math.huge, 0.2, 0
local function shake(amp)
	shakeStart = os.clock()
	shakeAmp = amp
end

local fovImpulse = 0
local function fovKick(amount)
 fovImpulse = amount
end

camera.FieldOfView = BASE_FOV

------------------------------------------------------------------
-- BOUCLE DE RENDU
------------------------------------------------------------------
local sway = Vector3.zero
local lastCF = camera.CFrame
local bobT, moveAlpha = 0, 0
local sprintAlpha = 0

RunService:BindToRenderStep("FistsViewmodel", Enum.RenderPriority.Camera.Value + 1, function(dt)
	camera = workspace.CurrentCamera
	local hum = getHumanoid()
	local alive = hum ~= nil and hum.Health > 0

	local wantedParent = alive and camera or nil
	if viewmodel.Parent ~= wantedParent then
		viewmodel.Parent = wantedParent
	end
	if not alive then
  sprintAlpha = 0
  fovImpulse = 0
  camera.FieldOfView = BASE_FOV
  return
 end
 local running = player.Character:GetAttribute("Sprinting") == true
 sprintAlpha += ((running and 1 or 0) - sprintAlpha) * math.clamp(dt * 9, 0, 1)
 fovImpulse *= math.exp(-dt * 12)
 local targetFov = BASE_FOV + 7 * sprintAlpha - fovImpulse
 camera.FieldOfView += (targetFov - camera.FieldOfView) * (1 - math.exp(-dt * 12))

	-- Sway : les bras "traînent" quand on tourne la caméra
	local baseCF = camera.CFrame
	local rx, ry = lastCF:ToObjectSpace(baseCF):ToEulerAnglesYXZ()
	lastCF = baseCF
	local goal = Vector3.new(math.clamp(ry * 5, -0.3, 0.3), math.clamp(-rx * 5, -0.3, 0.3), 0)
	sway = sway:Lerp(goal, math.clamp(dt * 10, 0, 1))

	-- Camera shake (appliqué après le calcul du sway)
	local st = os.clock() - shakeStart
	if st < shakeDur then
		local k = (1 - st / shakeDur) ^ 2 * shakeAmp
		camera.CFrame = baseCF * CFrame.Angles(
			math.rad((math.random() - 0.5) * 2 * k),
			math.rad((math.random() - 0.5) * 2 * k),
			math.rad((math.random() - 0.5) * 2 * k)
		)
	end

	-- Balancement de marche + respiration
	local moving = (hum.MoveDirection.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air) and 1 or 0
	moveAlpha += (moving - moveAlpha) * math.clamp(dt * 8, 0, 1)
	bobT += dt * (9 + 5 * sprintAlpha) * moveAlpha
	local bob = Vector3.new(math.sin(bobT) * 0.045, -math.abs(math.sin(bobT)) * 0.05, 0) * moveAlpha
	local idle = Vector3.new(0, math.sin(os.clock() * 1.6) * 0.008, 0)
	local offset = CFrame.new(sway + bob + idle)

	local camCF = camera.CFrame
	local now = os.clock()
	for _, side in pairs(sides) do
		local p = punchAlpha(now - side.start) * side.scale
		local anim = CFrame.new(-side.sign * 0.55 * p, 0.38 * p, -1.25 * p)
			* CFrame.Angles(math.rad(6 * p), math.rad(side.sign * 10 * p), math.rad(-side.sign * 8 * p))
		local notPunching = math.clamp(1 - math.abs(p) * 3, 0, 1)
  local run = sprintAlpha * notPunching
  local stride = math.sin(bobT + (side.sign < 0 and math.pi or 0))
  local runPose = CFrame.new(-side.sign * 0.1 * run, (-0.2 + stride * 0.12) * run, stride * 0.16 * run)
   * CFrame.Angles(math.rad((-18 + stride * 12) * run), 0, math.rad(side.sign * 14 * run))
  local root = camCF * offset * side.base * runPose * anim
		for _, item in ipairs(side.parts) do
			item.part.CFrame = root * item.rel
		end
	end
end)

------------------------------------------------------------------
-- ACTION : FRAPPER
------------------------------------------------------------------
local lastPunch, lastComboTime, comboIndex = 0, 0, 0
local nextHand = "Right"
local held = false

local function doPunch()
	local hum = getHumanoid()
	if not hum or hum.Health <= 0 then return end

	local now = os.clock()
	if now - lastPunch < Config.Cooldown then return end
	lastPunch = now

	if now - lastComboTime > Config.ComboWindow then comboIndex = 0 end
	comboIndex = comboIndex % Config.ComboLength + 1
	lastComboTime = now
	local heavy = comboIndex == Config.ComboLength

	-- main qui frappe (alternance droite / gauche)
	local side = sides[nextHand]
	nextHand = (nextHand == "Right") and "Left" or "Right"
	side.start = now
	side.scale = heavy and 1.3 or 1

	-- SFX du coup dans l'air
	playSound(Config.SwingSounds, heavy and 0.9 or 0.6, heavy and 0.85 or 1)

	-- Le coup est envoyé au serveur au moment où le poing arrive au bout
	task.delay(WINDUP + STRIKE, function()
		local h = getHumanoid()
		if not h or h.Health <= 0 then return end
		fovKick(heavy and 3 or 1.5)
		PunchRemote:FireServer(workspace.CurrentCamera.CFrame.LookVector)
	end)
end

ContextActionService:BindAction("FistsPunch", function(_, state)
	if state == Enum.UserInputState.Begin then
		held = true
		doPunch()
	elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
		held = false
	end
	return Enum.ContextActionResult.Sink
end, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
ContextActionService:SetTitle("FistsPunch", "👊")
ContextActionService:SetPosition("FistsPunch", UDim2.new(1, -100, 1, -160))

-- Maintenir le clic = enchaîner les coups
RunService.Heartbeat:Connect(function()
	if held then doPunch() end
end)

-- Confirmation d'impact venant du serveur : shake + viseur rouge
PunchHitRemote.OnClientEvent:Connect(function(heavy, killed)
	shake(heavy and 1.1 or 0.55)
	flashCrosshair(heavy)
end)
