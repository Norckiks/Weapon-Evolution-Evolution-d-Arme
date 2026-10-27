-- Réglages des poings (partagé client + serveur)
return {
	Damage = 10,              -- dégâts d'un coup normal
	HeavyMultiplier = 2.5,    -- multiplicateur du 3e coup du combo
	Cooldown = 0.4,           -- délai entre deux coups (secondes)
	Range = 6.5,              -- portée du coup (studs)
	HitRadius = 1.6,          -- "épaisseur" de la zone de frappe (indulgence de visée)
	ComboLength = 3,          -- nombre de coups par combo (le dernier est le gros coup)
	ComboWindow = 1.1,        -- temps max entre 2 coups pour garder le combo
	Knockback = 22,
	HeavyKnockback = 55,

	-- IDs audio (Creator Store)
	SwingSounds = { 93311226362113, 111254855668531 },
	HitSounds = { 96359585058783, 74041775202019, 126976659766267 },
	HeavyHitSounds = { 79476956608476, 132555084427990 },
}
