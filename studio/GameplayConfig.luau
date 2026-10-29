local C={}
C.HeadshotMultiplier=1.5
C.KillChain={Window=8}
C.Dash={Cooldown=3.5,Cost=25,Speed=65,Duration=0.18}
C.Pulse={Level=5,Cost=30,Cooldown=14,Range=14,Damage=20,Stun=.7,Knockback=38,MaxTargets=12}
C.Abilities={Arc={Name="Decharge",Key="K",Pad="ButtonL2",Level=24,Cost=38,Cooldown=20,Range=22,JumpRange=12,Damage=42,Falloff=.75,Stun=.8,Knockback=8,MaxTargets=4,Shape="Cone",Dot=.35,Color=Color3.fromRGB(113,236,255)},Slam={Name="Frappe tellurique",Key="E",Pad="DPadLeft",Level=8,Cost=34,Cooldown=12,Range=10,Damage=34,Stun=1.1,Knockback=54,MaxTargets=8,Shape="Circle",Color=Color3.fromRGB(255,174,73)},Frost={Name="Lance cryo",Key="T",Pad="DPadRight",Level=12,Cost=32,Cooldown=18,Range=70,Width=4.5,Damage=30,Stun=1.7,Knockback=12,MaxTargets=1,Shape="Beam",Color=Color3.fromRGB(93,220,255)},Aegis={Name="Égide astrale",Key="H",Pad="ButtonR3",Level=16,Cost=30,Cooldown=24,Duration=3.2,Color=Color3.fromRGB(184,133,255)},SecondSouffle={Name="Second souffle",Key="J",Pad="DPadDown",Level=20,Cost=30,Cooldown=28,Heal=.35,Color=Color3.fromRGB(111,235,166)}}
C.ProgressionLevelLimit=1000000000
C.MaxUpgradeCost=2000000000
function C.ProgressionSteps(level,softTail,softStart)
 if typeof(level)~="number" or not math.isfinite(level) then return 0 end
 level=math.clamp(math.floor(level),0,C.ProgressionLevelLimit) softStart=softStart or 25
 if level<=softStart then return level end
 return softStart+softTail*math.log(1+(level-softStart)/softTail)
end
C.Upgrades={Health={Name="Vitalite",BaseCost=100,Factor=1.7,Step=20,SoftTail=10},Speed={Name="Agilite",BaseCost=150,Factor=1.85,Step=0.8,SoftTail=.5},Stamina={Name="Souffle",BaseCost=250,Factor=1.9,Step=20,SoftTail=10},Ability={Name="Puissance",BaseCost=1200,Factor=2.1,Step=.08,SoftTail=1}}
function C.UpgradeSteps(id,level) local d=C.Upgrades[id] return d and C.ProgressionSteps(level,d.SoftTail) or 0 end
function C.UpgradeCost(id,level)
 local d=C.Upgrades[id]
 if not d or typeof(level)~="number" or not math.isfinite(level) then return C.MaxUpgradeCost end
 level=math.clamp(math.floor(level),0,C.ProgressionLevelLimit)
 if level>=math.ceil(math.log(C.MaxUpgradeCost/d.BaseCost)/math.log(d.Factor)) then return C.MaxUpgradeCost end
 return math.floor(d.BaseCost*d.Factor^level)
end
C.WeaponOrder={"Fists","Pipe","Bat","Pistol","Axe","SMG","Machete","Revolver","Katana","Shotgun","Sledgehammer","Carbine","Marksman","LMG","Hook","Kris","Spear","Cleaver","WarHammer","Pike","PhaseBlade","MirrorAxe","RelayLance","OrbitalSpear","RiftCleaver","ForgeMaul","ConvoyEdge","ArcPike","BlackoutEdge","EclipseGlaive","LimitedBlade"}
C.Weapons={
 Sledgehammer={Name="Masse de demolition",ShortName="MASSE",Cost=16500,Level=19,Damage=170,Range=8.5,Cooldown=.95,Color=Color3.fromRGB(239,177,79)},
 Machete={Name="Machette de secours",ShortName="MACHETTE",Cost=5200,Level=9,Damage=62,Range=8,Cooldown=.55,Color=Color3.fromRGB(220,112,82)},
 LMG={Name="Mitrailleuse de barrage",ShortName="BARRAGE",Cost=54000,Level=35,Damage=28,Range=160,Cooldown=.12,Color=Color3.fromRGB(190,153,77),Firearm=true,Magazine=48,ReloadTime=3.8},
 Marksman={Name="Fusil du guetteur",ShortName="GUETTEUR",Cost=32000,Level=28,Damage=140,Range=260,Cooldown=1.05,Color=Color3.fromRGB(192,154,107),Firearm=true,Magazine=6,ReloadTime=3.1},
 Carbine={Name="Carabine des cendres",ShortName="CARABINE",Cost=18000,Level=22,Damage=38,Range=175,Cooldown=.24,Color=Color3.fromRGB(112,189,153),Firearm=true,Magazine=18,ReloadTime=2.4},
 Shotgun={Name="Fusil a pompe des quais",ShortName="FUSIL POMPE",Cost=11500,Level=16,Damage=20,Range=75,Cooldown=.95,Color=Color3.fromRGB(236,145,78),Firearm=true,Magazine=5,ReloadTime=2.9,Pellets=7,Spread=4.5},
 Revolver={Name="Revolver du pisteur",ShortName="REVOLVER",Cost=6800,Level=12,Damage=72,Range=180,Cooldown=.72,Color=Color3.fromRGB(233,151,86),Firearm=true,Magazine=6,ReloadTime=2.6},
 SMG={Name="Mitraillette du recuperateur",ShortName="MITRAILLETTE",Cost=4200,Level=7,Damage=14,Range=105,Cooldown=.11,Color=Color3.fromRGB(84,210,200),Firearm=true,Magazine=24,ReloadTime=2.1},
 Pistol={Name="Pistolet du refuge",Cost=1400,Level=3,Damage=24,Range=150,Cooldown=.28,Color=Color3.fromRGB(255,190,66),Firearm=true,Magazine=12,ReloadTime=1.6},
 Fists={Name="Poings",Cost=0,Level=1,Damage=10,Range=6.5,Cooldown=0.4,Color=Color3.fromRGB(155,117,71)},
 Pipe={Name="Tuyau de recuperation",Cost=150,Level=1,Damage=16,Range=7,Cooldown=0.46,Color=Color3.fromRGB(125,157,167)},
 Bat={Name="Batte a pointes",Cost=650,Level=2,Damage=28,Range=7.5,Cooldown=0.54,Color=Color3.fromRGB(163,109,65)},
 Axe={Name="Hache de secours",Cost=2200,Level=5,Damage=48,Range=7.5,Cooldown=0.65,Color=Color3.fromRGB(227,92,68)},
 Katana={Name="Lame du survivant",Cost=8500,Level=12,Damage=80,Range=8,Cooldown=0.48,Color=Color3.fromRGB(89,211,204)},
 Hook={Name="Crochet de quarantaine",ShortName="CROCHET",Cost=68000,Level=40,Damage=118,Range=8.2,Cooldown=.48,Color=Color3.fromRGB(224,151,79)},
 Kris={Name="Kris du veilleur",ShortName="KRIS",Cost=92000,Level=48,Damage=105,Range=8.1,Cooldown=.36,Color=Color3.fromRGB(123,196,194)},
 Spear={Name="Lance de rupture",ShortName="LANCE",Cost=145000,Level=56,Damage=142,Range=10.5,Cooldown=.62,Color=Color3.fromRGB(174,197,145)},
 Cleaver={Name="Couperet des digues",ShortName="COUPERET",Cost=230000,Level=64,Damage=245,Range=8.5,Cooldown=.78,Color=Color3.fromRGB(194,103,77)},
 WarHammer={Name="Marteau de siege",ShortName="SIEGE",Cost=360000,Level=72,Damage=360,Range=9,Cooldown=1.05,Color=Color3.fromRGB(174,130,92)},
 Pike={Name="Pique des remparts",ShortName="PIQUE",Cost=560000,Level=80,Damage=285,Range=12,Cooldown=.72,Color=Color3.fromRGB(112,177,153)},
 PhaseBlade={Name="Lame du coeur",ShortName="COEUR",Cost=760000,Level=90,Damage=420,Range=9.5,Cooldown=.98,Color=Color3.fromRGB(255,112,78)},
 MirrorAxe={Name="Hache de verre",ShortName="VERRE",Cost=1100000,Level=110,Damage=490,Range=9.5,Cooldown=.88,Color=Color3.fromRGB(121,196,226)},
 RelayLance={Name="Lance du relais",ShortName="RELAIS",Cost=1650000,Level=130,Damage=625,Range=11,Cooldown=.86,Color=Color3.fromRGB(244,190,92)},
 OrbitalSpear={Name="Lance orbitale",ShortName="ORBITALE",Cost=2400000,Level=150,Damage=740,Range=13,Cooldown=1.02,Color=Color3.fromRGB(218,156,110)},
 RiftCleaver={Name="Fendoir des abysses",ShortName="ABYSSES",Cost=3300000,Level=170,Damage=850,Range=13.5,Cooldown=.98,Color=Color3.fromRGB(94,151,139)},
 ForgeMaul={Name="Maillet du dernier jour",ShortName="CREUSET",Cost=4400000,Level=190,Damage=980,Range=14,Cooldown=1.08,Color=Color3.fromRGB(206,109,74)},
 ConvoyEdge={Name="Lame du dernier convoi",ShortName="CONVOI",Cost=6000000,Level=210,Damage=1120,Range=15,Cooldown=1.04,Color=Color3.fromRGB(122,167,180)},
 ArcPike={Name="Pique de la grille",ShortName="ORAGE",Cost=8200000,Level=230,Damage=1300,Range=16,Cooldown=.98,Color=Color3.fromRGB(255,207,25)},
 BlackoutEdge={Name="Trancheuse du blackout",ShortName="BLACKOUT",Cost=11000000,Level=250,Damage=1550,Range=17,Cooldown=1.12,Color=Color3.fromRGB(24,146,255)},
 EclipseGlaive={Name="Glaive de l'eclipse",ShortName="ECLIPSE",Cost=15000000,Level=270,Damage=1850,Range=17.5,Cooldown=1.06,Color=Color3.fromRGB(164,68,255)},
 LimitedBlade={Name="Lame Nova · edition limitee",Premium=true,Level=1,Damage=55,Range=8,Cooldown=0.5,Color=Color3.fromRGB(173,118,255)}
}
function C.NextWeapon(owned)
 local last=0
 for i,id in C.WeaponOrder do if owned[id] and not C.Weapons[id].Premium then last=i end end
 for i=last+1,#C.WeaponOrder do local id=C.WeaponOrder[i] if id~="Fists" and not C.Weapons[id].Premium then return id end end
end
C.PetOrder={"Civilian","Runner","Brute","Worker","Soldier","Scrapper","Hazmat","Stalker","Abomination","Drowned","Raider","AnchorTitan","Lineman","SparkRunner","CoilGolem","Conductor","TunnelRunner","RailTitan","Warden","MireRunner","QuakeBrute","Flooded","Skirmisher","Leviathan","Sentry","Glitch","Colossus","CinderHusk","AshWraith","CoreBehemoth","PrismGuard","GlassRunner","ShardTitan","RelayWarden","StaticRunner","TowerGoliath","VoidMechanic","OrbitRunner","CapsuleTitan","VaultWarden","SirenRunner","ContainmentGoliath","CrucibleGuard","CinderRunner","ForgeTitan","ConvoyMarshal","AshHound","SiegeBehemoth","GridWarden","FlashHound","BreakerTitan","BlackoutWarden","ArcRipper","CoreTitan","EclipseWarden","NightStalker","VaultGoliath","Buddy"}
C.Pets={
 Conductor={Name="Ticketou",Coins=.80,XP=.40,Speed=.04,Color=Color3.fromRGB(105,213,172),Shape="Robot"},
 TunnelRunner={Name="Lampin",Coins=.35,XP=.65,Speed=.25,Color=Color3.fromRGB(241,204,110),Shape="Rabbit"},
 RailTitan={Name="Railours",Coins=.90,XP=.75,Speed=.10,Color=Color3.fromRGB(134,173,163),Shape="Bear"},
 Lineman={Name="Voltix",Coins=.60,XP=.25,Speed=0,Color=Color3.fromRGB(237,190,78),Shape="Robot"},
 SparkRunner={Name="Flashou",Coins=.25,XP=.50,Speed=.22,Color=Color3.fromRGB(139,204,241),Shape="Rabbit"},
 CoilGolem={Name="Bobinours",Coins=.65,XP=.60,Speed=.07,Color=Color3.fromRGB(180,143,239),Shape="Bear"},
 Drowned={Name="Crabi",Coins=.45,XP=.20,Speed=0,Color=Color3.fromRGB(107,200,207),Shape="Crab"},
 Raider={Name="Requinou",Coins=.15,XP=.30,Speed=.18,Color=Color3.fromRGB(147,177,208),Shape="Shark"},
 AnchorTitan={Name="Krakenou",Coins=.50,XP=.45,Speed=.06,Color=Color3.fromRGB(187,144,224),Shape="Kraken"},
 Civilian={Name="Mini Rodeur",Coins=0.10,XP=0.05,Speed=0,Color=Color3.fromRGB(126,212,146),Shape="Cat"},
 Runner={Name="Zippy",Coins=0,XP=0.08,Speed=0.08,Color=Color3.fromRGB(105,212,237),Shape="Rabbit"},
 Brute={Name="Mini Colosse",Coins=0.20,XP=0,Speed=0,Color=Color3.fromRGB(238,170,88),Shape="Bear"},
 Worker={Name="Boulon",Coins=0.18,XP=0.12,Speed=0,Color=Color3.fromRGB(255,187,73),Shape="Robot"},
 Soldier={Name="Sentinelle",Coins=0.12,XP=0.20,Speed=0,Color=Color3.fromRGB(128,177,117),Shape="Bear"},
 Scrapper={Name="Ferraille",Coins=0.30,XP=0.08,Speed=0,Color=Color3.fromRGB(176,188,206),Shape="Robot"},
 Hazmat={Name="Gloop",Coins=0.12,XP=0.30,Speed=0,Color=Color3.fromRGB(181,236,82),Shape="Alien"},
 Stalker={Name="Spectre",Coins=0.08,XP=0.15,Speed=0.15,Color=Color3.fromRGB(182,148,238),Shape="Bat"},
 Abomination={Name="Titanou",Coins=0.35,XP=0.35,Speed=0.05,Color=Color3.fromRGB(243,116,138),Shape="Alien"},
 Warden={Name="Mini Gardien",Coins=.8,XP=.55,Speed=.04,Color=Color3.fromRGB(231,173,90),Shape="Robot"},
 MireRunner={Name="Boue-boule",Coins=.45,XP=.7,Speed=.2,Color=Color3.fromRGB(102,186,151),Shape="Rabbit"},
 QuakeBrute={Name="Mini Seisme",Coins=.85,XP=.75,Speed=.03,Color=Color3.fromRGB(178,124,93),Shape="Bear"},
 Flooded={Name="Goutte",Coins=.55,XP=.65,Speed=.04,Color=Color3.fromRGB(106,190,202),Shape="Crab"},
 Skirmisher={Name="P'tit Fulgurant",Coins=.35,XP=.75,Speed=.22,Color=Color3.fromRGB(226,161,102),Shape="Rabbit"},
 Leviathan={Name="Mini Leviathan",Coins=.9,XP=.8,Speed=.06,Color=Color3.fromRGB(119,164,178),Shape="Bear"},
 Sentry={Name="Veillou",Coins=.7,XP=.7,Speed=.08,Color=Color3.fromRGB(116,186,149),Shape="Robot"},
 Glitch={Name="Pixelou",Coins=.5,XP=.8,Speed=.16,Color=Color3.fromRGB(169,131,225),Shape="Alien"},
 Colossus={Name="Mini Citadelle",Coins=1,XP=.9,Speed=.05,Color=Color3.fromRGB(201,173,118),Shape="Bear"},
 CinderHusk={Name="Braiselet",Coins=.75,XP=.65,Speed=.04,Color=Color3.fromRGB(242,125,83),Shape="Bear"},
 AshWraith={Name="Fumelin",Coins=.45,XP=.85,Speed=.22,Color=Color3.fromRGB(172,143,191),Shape="Bat"},
 CoreBehemoth={Name="Coeur-de-pierre",Coins=.95,XP=.9,Speed=.05,Color=Color3.fromRGB(241,111,77),Shape="Robot"},
 PrismGuard={Name="Prismignon",Coins=.80,XP=.75,Speed=.07,Color=Color3.fromRGB(123,193,211),Shape="Robot"},
 GlassRunner={Name="Eclatin",Coins=.55,XP=.90,Speed=.24,Color=Color3.fromRGB(143,213,225),Shape="Bat"},
 ShardTitan={Name="Silicorne",Coins=1,XP=.95,Speed=.05,Color=Color3.fromRGB(118,163,190),Shape="Bear"},
 RelayWarden={Name="Relayin",Coins=.8,XP=.8,Speed=.05,Color=Color3.fromRGB(227,185,105),Shape="Robot"},
 StaticRunner={Name="Voltibat",Coins=.5,XP=1,Speed=.25,Color=Color3.fromRGB(237,191,112),Shape="Bat"},
 TowerGoliath={Name="Toursaurus",Coins=1,XP=.95,Speed=.05,Color=Color3.fromRGB(179,160,122),Shape="Bear"},
 VoidMechanic={Name="Vaculet",Coins=.85,XP=.85,Speed=.07,Color=Color3.fromRGB(146,176,193),Shape="Robot"},
 OrbitRunner={Name="Cometou",Coins=.55,XP=1,Speed=.25,Color=Color3.fromRGB(183,160,210),Shape="Bat"},
 CapsuleTitan={Name="Capsulours",Coins=1,XP=.95,Speed=.05,Color=Color3.fromRGB(181,153,127),Shape="Bear"},
 VaultWarden={Name="Sasou",Coins=.9,XP=.9,Speed=.07,Color=Color3.fromRGB(94,151,139),Shape="Robot"},
 SirenRunner={Name="Sireneau",Coins=.6,XP=1,Speed=.27,Color=Color3.fromRGB(132,190,171),Shape="Bat"},
 ContainmentGoliath={Name="Bunkerours",Coins=1.05,XP=1,Speed=.06,Color=Color3.fromRGB(77,127,115),Shape="Bear"},
 CrucibleGuard={Name="Creusetou",Coins=1,XP=.95,Speed=.08,Color=Color3.fromRGB(206,109,74),Shape="Robot"},
 CinderRunner={Name="Braizip",Coins=.65,XP=1.05,Speed=.29,Color=Color3.fromRGB(239,126,82),Shape="Bat"},
 ForgeTitan={Name="Forgerours",Coins=1.1,XP=1.05,Speed=.07,Color=Color3.fromRGB(157,93,71),Shape="Bear"},
 ConvoyMarshal={Name="Marechalou",Coins=1.05,XP=1,Speed=.08,Color=Color3.fromRGB(122,167,180),Shape="Robot"},
 AshHound={Name="Cendreloup",Coins=.7,XP=1.1,Speed=.3,Color=Color3.fromRGB(147,165,153),Shape="Bat"},
 SiegeBehemoth={Name="Convoiro",Coins=1.15,XP=1.1,Speed=.07,Color=Color3.fromRGB(101,144,158),Shape="Bear"},
 GridWarden={Name="Gardienet",Coins=1.2,XP=1.15,Speed=.08,Color=Color3.fromRGB(193,177,103),Shape="Robot"},
 FlashHound={Name="Fulguroc",Coins=.75,XP=1.2,Speed=.32,Color=Color3.fromRGB(218,202,118),Shape="Bat"},
 BreakerTitan={Name="Disjonctosaure",Coins=1.25,XP=1.25,Speed=.07,Color=Color3.fromRGB(162,153,103),Shape="Bear"},
 BlackoutWarden={Name="Noyau Gardien",Coins=1.3,XP=1.3,Speed=.09,Color=Color3.fromRGB(128,139,149),Shape="Robot"},
 ArcRipper={Name="Arcif",Coins=.8,XP=1.35,Speed=.34,Color=Color3.fromRGB(155,182,197),Shape="Bat"},
 CoreTitan={Name="Titanoir",Coins=1.4,XP=1.4,Speed=.07,Color=Color3.fromRGB(109,130,151),Shape="Bear"},
 EclipseWarden={Name="Voutelet",Coins=1.45,XP=1.45,Speed=.1,Color=Color3.fromRGB(122,111,151),Shape="Robot"},
 NightStalker={Name="Noctif",Coins=.9,XP=1.5,Speed=.36,Color=Color3.fromRGB(147,128,184),Shape="Bat"},
 VaultGoliath={Name="Caveauteur",Coins=1.55,XP=1.55,Speed=.07,Color=Color3.fromRGB(107,94,143),Shape="Bear"},
 Buddy={Name="Buddy du refuge",Coins=0.10,XP=0.10,Speed=0.03,Color=Color3.fromRGB(255,213,107),Shape="Dog"}
}
C.PetRanks={Bonus=.15,Copies={3,5,7}}
function C.PetRankCost(rank)
 if typeof(rank)~="number" or not math.isfinite(rank) then return nil end
 rank=math.clamp(math.floor(rank),0,C.ProgressionLevelLimit)
 if rank>=C.ProgressionLevelLimit then return nil end
 return C.PetRanks.Copies[rank+1] or math.min(100000,3+2*rank)
end
function C.PetBonuses(id,rank)
 local pet=C.Pets[id] if not pet then return 0,0,0 end
 rank=typeof(rank)=="number" and math.isfinite(rank) and math.clamp(math.floor(rank),0,C.ProgressionLevelLimit) or 0
 local factor=1+C.ProgressionSteps(rank,.2,5)*C.PetRanks.Bonus
 return pet.Coins*factor,pet.XP*factor,pet.Speed*factor
end
C.TimeRewards={
 {Seconds=300,Name="Echauffement",Description="XP x2 pendant 10 minutes",Kind="XPBoost",Amount=600},
 {Seconds=600,Name="Ravitaillement",Description="150 pieces",Kind="Coins",Amount=150},
 {Seconds=900,Name="Petit echantillon",Description="1 fragment de Rodeur",Kind="Fragment",Id="Civilian",Amount=1},
 {Seconds=1200,Name="Chasseur de tresors",Description="Pieces x2 pendant 10 minutes",Kind="CoinBoost",Amount=600},
 {Seconds=1800,Name="Un nouvel ami",Description="Pet Buddy gratuit : +10% pieces et XP",Kind="Pet",Id="Buddy",Amount=1},
 {Seconds=2700,Name="Fusion express",Description="3 fragments d'Affame",Kind="Fragment",Id="Runner",Amount=3},
 {Seconds=3600,Name="Veteran",Description="1000 pieces",Kind="Coins",Amount=1000},
 {Seconds=5400,Name="Expert",Description="2000 XP",Kind="XP",Amount=2000},
 {Seconds=7200,Name="Expedition toxique",Description="3 fragments de Chercheur toxique",Kind="Fragment",Id="Hazmat",Amount=3}
}
C.LoginRewards={
 {Name="Ravitaillement",Description="200 pieces",Kind="Coins",Amount=200},
 {Name="Entrainement",Description="XP x2 pendant 10 minutes",Kind="XPBoost",Amount=600},
 {Name="Reserve",Description="500 pieces",Kind="Coins",Amount=500},
 {Name="Chasseur de tresors",Description="Pieces x2 pendant 10 minutes",Kind="CoinBoost",Amount=600},
 {Name="Butin du refuge",Description="1000 pieces",Kind="Coins",Amount=1000},
 {Name="Experience",Description="1000 XP",Kind="XP",Amount=1000},
 {Name="Un compagnon",Description="1 pet Buddy permanent",Kind="Pet",Id="Buddy",Amount=1}
}
C.Missions={{Kills=10,Coins=120,XP=60},{Kills=30,Coins=400,XP=180},{Kills=75,Coins=1200,XP=600},{Kills=150,Coins=3000,XP=1500}}
C.FirstHunt={Coins=100,XP=50}
C.LevelRewardOrder={2,3,5,7,10,12,16,20,22,28,35,40,45,48,50,55,60,64,65,70,72,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240,250,260,270,280}
C.LevelRewards={[2]=150,[3]=250,[5]=500,[7]=750,[10]=1200,[12]=1600,[16]=2400,[20]=3500,[22]=4000,[28]=6000,[35]=9000,[40]=11000,[45]=12500,[48]=14000,[50]=15500,[55]=18000,[60]=22000,[64]=25000,[65]=27000,[70]=32000,[72]=35000,[80]=45000,[90]=55000,[100]=70000,[110]=85000,[120]=100000,[130]=120000,[140]=140000,[150]=160000,[160]=180000,[170]=200000,[180]=225000,[190]=250000,[200]=280000,[210]=310000,[220]=340000,[230]=370000,[240]=400000,[250]=440000,[260]=480000,[270]=520000,[280]=560000}
-- Intentionally disabled. Configure IDs and the real sale deadline before enabling.
C.MonetizationEnabled=false
C.Products={{Key="CoinsSmall",Name="1000 pieces",Kind="Coins",Amount=1000,ProductId=0},{Key="CoinsLarge",Name="6000 pieces",Kind="Coins",Amount=6000,ProductId=0},{Key="XPSmall",Name="1000 XP",Kind="XP",Amount=1000,ProductId=0},{Key="XPLarge",Name="6000 XP",Kind="XP",Amount=6000,ProductId=0}}
C.LimitedOffer={GamePassId=0,Weapon="LimitedBlade",SaleEndsAt=0}
C.Shops={Upgrades=Vector3.new(-110,0,225),Weapons=Vector3.new(110,0,225),Robux=Vector3.new(110,0,247),Pets=Vector3.new(-110,0,247)}
return C
