local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("FistsConfig"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PunchRemote = Remotes:WaitForChild("Punch")
local PunchHitRemote = Remotes:WaitForChild("PunchHit")

-- État par joueur (cooldown + combo), côté serveur = source de vérité
local states = {}

Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
end)

local function pick(list)
	return list[math.random(#list)]
end

local function playHitSound(part, heavy)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. pick(heavy and Config.HeavyHitSounds or Config.HitSounds)
	sound.Volume = heavy and 1 or 0.8
	sound.PlaybackSpeed = 0.92 + math.random() * 0.2
	sound.RollOffMaxDistance = 90
	sound.Parent = part
	sound:Play()
	Debris:AddItem(sound, 4)
end

local function flash(model)
	local h = Instance.new("Highlight")
	h.FillColor = Color3.fromRGB(255, 60, 60)
	h.FillTransparency = 0.45
	h.OutlineTransparency = 1
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Parent = model
	Debris:AddItem(h, 0.12)
end

PunchRemote.OnServerEvent:Connect(function(player, direction)
	-- 1) Validation de l'entrée
	if typeof(direction) ~= "Vector3" or direction ~= direction then return end
	local mag = direction.Magnitude
	if mag < 0.5 or mag > 1.5 then return end
	direction = direction.Unit

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not head then return end

	-- 2) Cooldown serveur (léger rabais pour la latence)
	local now = os.clock()
	local st = states[player]
	if not st then
		st = { last = 0, combo = 0, lastCombo = 0 }
		states[player] = st
	end
	if now - st.last < Config.Cooldown * 0.8 then return end
	st.last = now

	-- 3) Combo
	if now - st.lastCombo > Config.ComboWindow then
		st.combo = 0
	end
	st.combo = st.combo % Config.ComboLength + 1
	st.lastCombo = now
	local heavy = st.combo == Config.ComboLength

	-- 4) Détection : spherecast depuis la tête (indulgent pour la visée)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }

	local result = workspace:Spherecast(head.Position, Config.HitRadius, direction * Config.Range, params)
	if not result then return end

	local targetModel = result.Instance:FindFirstAncestorOfClass("Model")
	if not targetModel or not CollectionService:HasTag(targetModel, "Zombie") then return end

	local zoneId = targetModel:GetAttribute("ZoneId")
	if zoneId then
		local world = require(ReplicatedStorage.WorldConfig)
		local zone = world.ZoneAt(head.Position)
		if not zone or zone.Id ~= zoneId or not require(script.Parent.ZoneService).CanAccess(player, zone) then return end
	end
	local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then return end

	-- 5) Dégâts
	local damage = Config.Damage * (heavy and Config.HeavyMultiplier or 1)
	targetHumanoid:SetAttribute("LastAttacker", player.UserId) -- pour récompenser les Coins plus tard
	targetHumanoid:SetAttribute("LastHitAt", os.clock())
	targetHumanoid:TakeDamage(damage)
	local killed = targetHumanoid.Health <= 0

	-- 6) Effets : knockback, flash, son d'impact (3D, audible par tous)
	local root = targetModel:FindFirstChild("HumanoidRootPart")
	if root and not root.Anchored then
		local kb = heavy and Config.HeavyKnockback or Config.Knockback
		root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + direction * kb + Vector3.new(0, heavy and 18 or 6, 0)
	end
	flash(targetModel)
	playHitSound(root or result.Instance, heavy)

	-- 7) Feedback pour le joueur qui a frappé
	PunchHitRemote:FireClient(player, heavy, killed)

	-- Rewards are granted once by ZombieDirector on Humanoid.Died.
end)
