local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("FistsConfig"))
local Gameplay = require(ReplicatedStorage:WaitForChild("GameplayConfig"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PunchRemote = Remotes:WaitForChild("Punch")
local PunchHitRemote = Remotes:WaitForChild("PunchHit")

-- État par joueur (cooldown + combo), côté serveur = source de vérité
local NPCPresentation = require(script.Parent:WaitForChild("NPCPresentation"))
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
	sound.Volume = heavy and 0.55 or 0.4
 sound.SoundGroup = game.SoundService:FindFirstChild("WorldCombat")
 sound.RollOffMinDistance = 5
 sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.PlaybackSpeed = 0.92 + math.random() * 0.2
	sound.RollOffMaxDistance = 45
	sound.Parent = part
	sound:Play()
	Debris:AddItem(sound, 4)
end

PunchRemote.OnServerEvent:Connect(function(player, direction)
	if player:GetAttribute("HasStarted")~=true or player:GetAttribute("InGameMenu") then return end
	local weapon=Gameplay.Weapons[player:GetAttribute("EquippedWeapon") or "Fists"] or Gameplay.Weapons.Fists
	if weapon.Firearm then return end
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
	if now - st.last < weapon.Cooldown * 0.8 then return end
	st.last = now

	-- 3) Combo
	if now - st.lastCombo > Config.ComboWindow then
		st.combo = 0
	end
	st.combo = st.combo % Config.ComboLength + 1
	st.lastCombo = now
	local heavy = st.combo == Config.ComboLength
	-- Cosmetic observers only receive attacks that passed server validation.
	character:SetAttribute("SwingWeapon",player:GetAttribute("EquippedWeapon") or "Fists")
	character:SetAttribute("SwingCombo",st.combo)
	character:SetAttribute("SwingAt",workspace:GetServerTimeNow())

	-- 4) Détection : spherecast depuis la tête (indulgent pour la visée)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }

	local result = workspace:Spherecast(head.Position, Config.HitRadius, direction * weapon.Range, params)
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
	local damage = weapon.Damage * (heavy and Config.HeavyMultiplier or 1)
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
	NPCPresentation.Hit(targetModel, direction, heavy)
	playHitSound(root or result.Instance, heavy)

	-- 7) Feedback pour le joueur qui a frappé
	PunchHitRemote:FireClient(player, heavy, killed, damage, result.Position)

	-- Rewards are granted once by ZombieDirector on Humanoid.Died.
end)
