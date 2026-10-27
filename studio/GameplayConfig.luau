local C={}
C.HeadshotMultiplier=1.5
C.KillChain={Window=8}
C.Dash={Cooldown=3.5,Cost=25,Speed=65,Duration=0.18}
C.Pulse={Level=5,Cost=30,Cooldown=14,Range=14,Damage=20,Stun=.7,Knockback=38,MaxTargets=12}
C.Abilities={Arc={Name="Decharge",Key="K",Pad="ButtonL2",Level=24,Cost=38,Cooldown=20,Range=22,JumpRange=12,Damage=42,Falloff=.75,Stun=.8,Knockback=8,MaxTargets=4,Shape="Cone",Dot=.35,Color=Color3.fromRGB(113,236,255)},Slam={Name="Frappe tellurique",Key="E",Pad="DPadLeft",Level=8,Cost=34,Cooldown=12,Range=10,Damage=34,Stun=1.1,Knockback=54,MaxTargets=8,Shape="Circle",Color=Color3.fromRGB(255,174,73)},Frost={Name="Lance cryo",Key="T",Pad="DPadRight",Level=12,Cost=32,Cooldown=18,Range=70,Width=4.5,Damage=30,Stun=1.7,Knockback=12,MaxTargets=1,Shape="Beam",Color=Color3.fromRGB(93,220,255)},Aegis={Name="Égide astrale",Key="H",Pad="ButtonR3",Level=16,Cost=30,Cooldown=24,Duration=3.2,Color=Color3.fromRGB(184,133,255)},SecondSouffle={Name="Second souffle",Key="J",Pad="DPadDown",Level=20,Cost=30,Cooldown=28,Heal=.35,Color=Color3.fromRGB(111,235,166)}}
C.Upgrades={Health={Name="Vitalite",Max=10,BaseCost=100,Factor=1.7,Step=20},Speed={Name="Agilite",Max=8,BaseCost=150,Factor=1.85,Step=0.8},Stamina={Name="Souffle",Max=5,BaseCost=250,Factor=1.9,Step=20}}
function C.UpgradeCost(id,level) local d=C.Upgrades[id] return math.floor(d.BaseCost*d.Factor^level) end
C.WeaponOrder={"Fists","Pipe","Bat","Pistol","Axe","SMG","Revolver","Katana","Shotgun","Carbine","Marksman","LMG","LimitedBlade"}
C.Weapons={
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
 LimitedBlade={Name="Lame Nova · edition limitee",Premium=true,Level=1,Damage=55,Range=8,Cooldown=0.5,Color=Color3.fromRGB(173,118,255)}
}
function C.NextWeapon(owned)
 local last=0
 for i,id in C.WeaponOrder do if owned[id] and not C.Weapons[id].Premium then last=i end end
 for i=last+1,#C.WeaponOrder do local id=C.WeaponOrder[i] if id~="Fists" and not C.Weapons[id].Premium then return id end end
end
C.PetOrder={"Civilian","Runner","Brute","Worker","Soldier","Scrapper","Hazmat","Stalker","Abomination","Drowned","Raider","AnchorTitan","Lineman","SparkRunner","CoilGolem","Conductor","TunnelRunner","RailTitan","Buddy"}
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
 Buddy={Name="Buddy du refuge",Coins=0.10,XP=0.10,Speed=0.03,Color=Color3.fromRGB(255,213,107),Shape="Dog"}
}
C.PetRanks={Max=3,Bonus=.15,Copies={3,5,7}}
function C.PetBonuses(id,rank)
 local pet=C.Pets[id] if not pet then return 0,0,0 end
 rank=typeof(rank)=="number" and rank==rank and math.clamp(math.floor(rank),0,C.PetRanks.Max) or 0
 local factor=1+rank*C.PetRanks.Bonus
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
C.LevelRewardOrder={2,3,5,7,10,12,16,20,22,28,35}
C.LevelRewards={[2]=150,[3]=250,[5]=500,[7]=750,[10]=1200,[12]=1600,[16]=2400,[20]=3500,[22]=4000,[28]=6000,[35]=9000}
-- Intentionally disabled. Configure IDs and the real sale deadline before enabling.
C.MonetizationEnabled=false
C.Products={{Key="CoinsSmall",Name="1000 pieces",Kind="Coins",Amount=1000,ProductId=0},{Key="CoinsLarge",Name="6000 pieces",Kind="Coins",Amount=6000,ProductId=0},{Key="XPSmall",Name="1000 XP",Kind="XP",Amount=1000,ProductId=0},{Key="XPLarge",Name="6000 XP",Kind="XP",Amount=6000,ProductId=0}}
C.LimitedOffer={GamePassId=0,Weapon="LimitedBlade",SaleEndsAt=0}
C.Shops={Upgrades=Vector3.new(-26,0,191),Weapons=Vector3.new(26,0,191),Robux=Vector3.new(39,0,172),Pets=Vector3.new(-43,0,186)}
return C
