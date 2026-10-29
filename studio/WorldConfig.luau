local C={}
C.Zones={
 {Id="City",Name="VILLE EN RUINE",Level=1,RespawnDelay=7,Center=Vector3.new(0,0,-120),Half=Vector3.new(200,100,150),Arrival=Vector3.new(0,4,10),Color=Color3.fromRGB(209,170,83),
  Spawns={Vector3.new(-10,4,-80),Vector3.new(10,4,-115),Vector3.new(-8,4,-155),Vector3.new(9,4,-195),Vector3.new(-5,4,-225),Vector3.new(12,4,-245)},
  Types={"Civilian","Runner","Brute"}},
 {Id="Factory",Name="USINE CONDAMNEE",Level=5,Center=Vector3.new(620,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(620,4,10),Color=Color3.fromRGB(235,132,61),
  Spawns={Vector3.new(588,4,-70),Vector3.new(650,4,-90),Vector3.new(590,4,-135),Vector3.new(648,4,-155),Vector3.new(596,4,-205),Vector3.new(650,4,-230)},
  Types={"Worker","Soldier","Scrapper"}},
 {Id="Lab",Name="LABORATOIRE TOXIQUE",Level=12,Center=Vector3.new(1240,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(1240,4,10),Color=Color3.fromRGB(125,224,86),
  Spawns={Vector3.new(1208,4,-70),Vector3.new(1270,4,-90),Vector3.new(1210,4,-135),Vector3.new(1275,4,-155),Vector3.new(1200,4,-205),Vector3.new(1278,4,-230)},
  Types={"Hazmat","Stalker","Abomination"}},
 {Id="Harbor",Name="PORT DES CENDRES",Level=20,Center=Vector3.new(1860,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(1860,4,10),Color=Color3.fromRGB(89,177,208),
  Spawns={Vector3.new(1830,4,-70),Vector3.new(1890,4,-95),Vector3.new(1828,4,-135),Vector3.new(1892,4,-160),Vector3.new(1832,4,-205),Vector3.new(1890,4,-235)},
  Types={"Drowned","Raider","AnchorTitan"}},
 {Id="Power",Name="CENTRALE FOUDROYEE",Level=28,Center=Vector3.new(2480,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(2480,4,10),Color=Color3.fromRGB(189,154,255),
  Spawns={Vector3.new(2450,4,-70),Vector3.new(2510,4,-95),Vector3.new(2448,4,-135),Vector3.new(2512,4,-160),Vector3.new(2452,4,-205),Vector3.new(2510,4,-235)},
  Types={"Lineman","SparkRunner","CoilGolem"}},
 {Id="Metro",Name="METRO OUBLIE",Level=35,Center=Vector3.new(3100,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(3100,4,10),Color=Color3.fromRGB(107,213,172),
  Spawns={Vector3.new(3076,4,-65),Vector3.new(3124,4,-85),Vector3.new(3076,4,-125),Vector3.new(3124,4,-155),Vector3.new(3076,4,-205),Vector3.new(3124,4,-235)},Types={"Conductor","TunnelRunner","RailTitan"}},
 {Id="Quarantine",Name="FOSSE DE QUARANTAINE",Level=45,Center=Vector3.new(3720,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(3720,4,10),Color=Color3.fromRGB(220,166,86),Spawns={Vector3.new(3692,4,-65),Vector3.new(3748,4,-85),Vector3.new(3692,4,-125),Vector3.new(3748,4,-155),Vector3.new(3692,4,-205),Vector3.new(3748,4,-235)},Types={"Warden","MireRunner","QuakeBrute"}},
 {Id="Dam",Name="BARRAGE DES NOYES",Level=60,Center=Vector3.new(4340,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(4340,4,10),Color=Color3.fromRGB(95,174,190),Spawns={Vector3.new(4312,4,-65),Vector3.new(4368,4,-85),Vector3.new(4312,4,-125),Vector3.new(4368,4,-155),Vector3.new(4312,4,-205),Vector3.new(4368,4,-235)},Types={"Flooded","Skirmisher","Leviathan"}},
 {Id="Citadel",Name="CITADELLE DES CENDRES",Level=80,Center=Vector3.new(4960,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(4960,4,10),Color=Color3.fromRGB(180,143,214),Spawns={Vector3.new(4932,4,-65),Vector3.new(4988,4,-85),Vector3.new(4932,4,-125),Vector3.new(4988,4,-155),Vector3.new(4932,4,-205),Vector3.new(4988,4,-235)},Types={"Sentry","Glitch","Colossus"}},
 {Id="Crater",Name="CRATERE DU REACTEUR",Level=100,Center=Vector3.new(5580,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(5580,4,10),Color=Color3.fromRGB(255,112,78),Spawns={Vector3.new(5552,4,-65),Vector3.new(5608,4,-85),Vector3.new(5552,4,-125),Vector3.new(5608,4,-155),Vector3.new(5552,4,-205),Vector3.new(5608,4,-235)},Types={"CinderHusk","AshWraith","CoreBehemoth"}},
 {Id="GlassSea",Name="MER DE VERRE",Level=120,Center=Vector3.new(6200,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(6200,4,10),Color=Color3.fromRGB(121,196,226),Spawns={Vector3.new(6172,4,-65),Vector3.new(6228,4,-85),Vector3.new(6172,4,-125),Vector3.new(6228,4,-155),Vector3.new(6172,4,-205),Vector3.new(6228,4,-235)},Types={"PrismGuard","GlassRunner","ShardTitan"}},
 {Id="Skyline",Name="CITE DES ANTENNES",Level=140,Center=Vector3.new(6820,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(6820,4,10),Color=Color3.fromRGB(244,190,92),Spawns={Vector3.new(6792,4,-65),Vector3.new(6848,4,-85),Vector3.new(6792,4,-125),Vector3.new(6848,4,-155),Vector3.new(6792,4,-205),Vector3.new(6848,4,-235)},Types={"RelayWarden","StaticRunner","TowerGoliath"}},
 {Id="OrbitalWreck",Name="STATION ORBITALE",Level=160,Center=Vector3.new(7440,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(7440,4,10),Color=Color3.fromRGB(218,156,110),Spawns={Vector3.new(7412,4,-65),Vector3.new(7468,4,-85),Vector3.new(7412,4,-125),Vector3.new(7468,4,-155),Vector3.new(7412,4,-205),Vector3.new(7468,4,-235)},Types={"VoidMechanic","OrbitRunner","CapsuleTitan"}},
 {Id="Depths",Name="BUNKER DES PROFONDEURS",Level=180,Center=Vector3.new(8060,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(8060,4,10),Color=Color3.fromRGB(94,151,139),Spawns={Vector3.new(8032,4,-65),Vector3.new(8088,4,-85),Vector3.new(8032,4,-125),Vector3.new(8088,4,-155),Vector3.new(8032,4,-205),Vector3.new(8088,4,-235)},Types={"VaultWarden","SirenRunner","ContainmentGoliath"}},
 {Id="IronSanctum",Name="FONDERIE DU DERNIER JOUR",Level=200,Center=Vector3.new(8680,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(8680,4,10),Color=Color3.fromRGB(206,109,74),Spawns={Vector3.new(8652,4,-65),Vector3.new(8708,4,-85),Vector3.new(8652,4,-125),Vector3.new(8708,4,-155),Vector3.new(8652,4,-205),Vector3.new(8708,4,-235)},Types={"CrucibleGuard","CinderRunner","ForgeTitan"}},
 {Id="LastConvoy",Name="TERMINUS DU DERNIER CONVOI",Level=220,Center=Vector3.new(9300,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(9300,4,10),Color=Color3.fromRGB(122,167,180),Spawns={Vector3.new(9272,4,-65),Vector3.new(9328,4,-85),Vector3.new(9272,4,-125),Vector3.new(9328,4,-155),Vector3.new(9272,4,-205),Vector3.new(9328,4,-235)},Types={"ConvoyMarshal","AshHound","SiegeBehemoth"}}
 ,{Id="Gridfall",Name="GRILLE DECHUE",Level=240,Center=Vector3.new(9920,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(9920,4,10),Color=Color3.fromRGB(193,177,103),Spawns={Vector3.new(9892,4,-65),Vector3.new(9948,4,-85),Vector3.new(9892,4,-125),Vector3.new(9948,4,-155),Vector3.new(9892,4,-205),Vector3.new(9948,4,-235)},Types={"GridWarden","FlashHound","BreakerTitan"}}
 ,{Id="BlackoutCore",Name="NOYAU D'ARRET",Level=260,Center=Vector3.new(10540,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(10540,4,10),Color=Color3.fromRGB(128,139,149),Spawns={Vector3.new(10512,4,-65),Vector3.new(10568,4,-85),Vector3.new(10512,4,-125),Vector3.new(10568,4,-155),Vector3.new(10512,4,-205),Vector3.new(10568,4,-235)},Types={"BlackoutWarden","ArcRipper","CoreTitan"}}
 ,{Id="EclipseVault",Name="VOUTE DE L'ECLIPSE",Level=280,Center=Vector3.new(11160,0,-120),Half=Vector3.new(145,100,150),Arrival=Vector3.new(11160,4,10),Color=Color3.fromRGB(122,111,151),Spawns={Vector3.new(11132,4,-65),Vector3.new(11188,4,-85),Vector3.new(11132,4,-125),Vector3.new(11188,4,-155),Vector3.new(11132,4,-205),Vector3.new(11188,4,-235)},Types={"EclipseWarden","NightStalker","VaultGoliath"}}
}
C.Zombies={
 Conductor={AttackWindup=.5,AttackRecovery=.4,Name="Controleur dechu",Health=1700,Speed=10,Damage=42,Coins=2000,XP=2600,Scale=1.14,Template="Civilian",Skin=Color3.fromRGB(130,157,143),Cloth=Color3.fromRGB(46,109,96)},
 TunnelRunner={AttackWindup=.28,AttackRecovery=.3,Name="Coureur des tunnels",Health=2100,Speed=18,Damage=45,Coins=2500,XP=3200,Scale=1.08,Template="Runner",Skin=Color3.fromRGB(169,170,140),Cloth=Color3.fromRGB(145,113,63)},
 RailTitan={AttackWindup=1.1,AttackRecovery=.6,Name="Titan des rails",Health=3200,Speed=7,Damage=60,Coins=3600,XP=4600,Scale=2,Template="Brute",Skin=Color3.fromRGB(134,150,144),Cloth=Color3.fromRGB(71,91,88)},
 Civilian={AttackWindup=0.45,AttackRecovery=0.35,Name="Rodeur",Health=35,Speed=7,Damage=4,Coins=8,XP=20,Scale=1,Style="Civilian",Skin=Color3.fromRGB(112,132,84),Cloth=Color3.fromRGB(81,88,107)},
 Runner={AttackWindup=0.32,AttackRecovery=0.3,Name="Affame",Health=50,Speed=13,Damage=6,Coins=12,XP=30,Scale=0.94,Style="Runner",Skin=Color3.fromRGB(141,144,97),Cloth=Color3.fromRGB(118,63,54)},
 Brute={AttackWindup=0.7,AttackRecovery=0.45,Name="Colosse",Health=90,Speed=5,Damage=10,Coins=25,XP=60,Scale=1.35,Style="Brute",Skin=Color3.fromRGB(111,128,77),Cloth=Color3.fromRGB(62,69,59)},
 Worker={AttackWindup=0.48,AttackRecovery=0.35,Name="Ouvrier contamine",Health=120,Speed=8,Damage=10,Coins=35,XP=75,Scale=1.05,Style="Worker",Skin=Color3.fromRGB(125,133,89),Cloth=Color3.fromRGB(166,99,41)},
 Soldier={AttackWindup=0.42,AttackRecovery=0.35,Name="Soldat infecte",Health=160,Speed=10,Damage=12,Coins=50,XP=100,Scale=1.08,Style="Soldier",Skin=Color3.fromRGB(110,130,96),Cloth=Color3.fromRGB(67,83,63)},
 Scrapper={AttackWindup=0.8,AttackRecovery=0.45,Name="Broyeur de fer",Health=240,Speed=6,Damage=16,Coins=80,XP=150,Scale=1.45,Style="Scrapper",Skin=Color3.fromRGB(102,115,87),Cloth=Color3.fromRGB(93,85,69)},
 Hazmat={AttackWindup=0.5,AttackRecovery=0.35,Name="Chercheur toxique",Health=280,Speed=9,Damage=14,Coins=100,XP=180,Scale=1.05,Style="Hazmat",Skin=Color3.fromRGB(121,157,82),Cloth=Color3.fromRGB(184,173,52)},
 Stalker={AttackWindup=0.28,AttackRecovery=0.3,Name="Traqueur mutant",Health=360,Speed=15,Damage=18,Coins=150,XP=250,Scale=1.13,Style="Stalker",Skin=Color3.fromRGB(90,107,128),Cloth=Color3.fromRGB(53,58,71)},
 Abomination={AttackWindup=0.9,AttackRecovery=0.5,Name="Abomination",Health=520,Speed=6,Damage=25,Coins=240,XP=400,Scale=1.7,Style="Abomination",Skin=Color3.fromRGB(117,144,79),Cloth=Color3.fromRGB(60,72,57)},
 Drowned={AttackWindup=0.5,AttackRecovery=0.4,Name="Matelot noye",Health=650,Speed=8,Damage=24,Coins=320,XP=500,Scale=1.08,Template="Civilian",Skin=Color3.fromRGB(102,151,147),Cloth=Color3.fromRGB(57,88,110)},
 Raider={AttackWindup=0.34,AttackRecovery=0.3,Name="Ecumeur des cendres",Health=800,Speed=14,Damage=28,Coins=420,XP=650,Scale=1.04,Template="Runner",Skin=Color3.fromRGB(144,155,126),Cloth=Color3.fromRGB(148,89,55)},
 AnchorTitan={AttackWindup=1.0,AttackRecovery=0.5,Name="Titan de l'ancre",Health=1200,Speed=5,Damage=38,Coins=650,XP=1000,Scale=1.85,Template="Brute",Skin=Color3.fromRGB(111,139,144),Cloth=Color3.fromRGB(60,77,85)},
 Lineman={AttackWindup=.52,AttackRecovery=.4,Name="Electricien brule",Health=1100,Speed=9,Damage=32,Coins=850,XP=1200,Scale=1.12,Template="Civilian",Skin=Color3.fromRGB(138,139,164),Cloth=Color3.fromRGB(202,153,65)},
 SparkRunner={AttackWindup=.3,AttackRecovery=.32,Name="Etincelle errante",Health=1400,Speed=16,Damage=36,Coins=1100,XP=1500,Scale=1.06,Template="Runner",Skin=Color3.fromRGB(137,169,184),Cloth=Color3.fromRGB(87,84,132)},
 CoilGolem={AttackWindup=1.05,AttackRecovery=.55,Name="Golem bobine",Health=2100,Speed=6,Damage=48,Coins=1600,XP=2100,Scale=1.9,Template="Brute",Skin=Color3.fromRGB(129,135,155),Cloth=Color3.fromRGB(87,78,102)},
 Warden={AttackWindup=.55,AttackRecovery=.42,Name="Gardien de fosse",Health=2500,Speed=9,Damage=46,Coins=2100,XP=2800,Scale=1.16,Template="Soldier",Skin=Color3.fromRGB(126,136,105),Cloth=Color3.fromRGB(163,114,65)},
 MireRunner={AttackWindup=.3,AttackRecovery=.3,Name="Fuyard des cuves",Health=2200,Speed=18,Damage=42,Coins=1900,XP=2700,Scale=1.08,Template="Runner",Skin=Color3.fromRGB(101,148,104),Cloth=Color3.fromRGB(69,105,73)},
 QuakeBrute={AttackWindup=1.05,AttackRecovery=.6,Name="Briseur de confinement",Health=4200,Speed=6,Damage=62,Coins=3300,XP=4100,Scale=1.9,Template="Brute",Skin=Color3.fromRGB(138,124,99),Cloth=Color3.fromRGB(106,77,57)},
 Flooded={AttackWindup=.6,AttackRecovery=.42,Name="Noye du barrage",Health=4700,Speed=9,Damage=61,Coins=4100,XP=5100,Scale=1.12,Template="Drowned",Skin=Color3.fromRGB(94,154,161),Cloth=Color3.fromRGB(61,104,123)},
 Skirmisher={AttackWindup=.28,AttackRecovery=.3,Name="Eclaireur submerge",Health=3900,Speed=18,Damage=55,Coins=3700,XP=4800,Scale=1.12,Template="Raider",Skin=Color3.fromRGB(141,150,122),Cloth=Color3.fromRGB(167,109,67)},
 Leviathan={AttackWindup=1.1,AttackRecovery=.62,Name="Leviathan de retenue",Health=6500,Speed=7,Damage=82,Coins=6000,XP=7200,Scale=2,Template="AnchorTitan",Skin=Color3.fromRGB(103,140,153),Cloth=Color3.fromRGB(52,84,102)},
 Sentry={AttackWindup=.55,AttackRecovery=.43,Name="Sentinelle des remparts",Health=7600,Speed=10,Damage=76,Coins=7300,XP=8600,Scale=1.16,Template="Lineman",Skin=Color3.fromRGB(129,142,129),Cloth=Color3.fromRGB(77,106,90)},
 Glitch={AttackWindup=.27,AttackRecovery=.32,Name="Eclat instable",Health=6600,Speed=19,Damage=70,Coins=6800,XP=8200,Scale=1.12,Template="SparkRunner",Skin=Color3.fromRGB(152,139,181),Cloth=Color3.fromRGB(112,82,145)},
 Colossus={AttackWindup=1.18,AttackRecovery=.68,Name="Colosse de la citadelle",Health=11000,Speed=7,Damage=105,Coins=10500,XP=12500,Scale=2.1,Template="RailTitan",Skin=Color3.fromRGB(131,132,139),Cloth=Color3.fromRGB(84,78,100)},
 CinderHusk={AttackWindup=.58,AttackRecovery=.42,Name="Carcasse des braises",Health=12500,Speed=9,Damage=105,Coins=11500,XP=15000,Scale=1.2,Template="Soldier",Skin=Color3.fromRGB(108,91,83),Cloth=Color3.fromRGB(142,75,52)},
 AshWraith={AttackWindup=.27,AttackRecovery=.3,Name="Spectre de cendre",Health=10000,Speed=20,Damage=92,Coins=10500,XP=15500,Scale=1.1,Template="Runner",Skin=Color3.fromRGB(129,116,126),Cloth=Color3.fromRGB(86,72,100)},
 CoreBehemoth={AttackWindup=1.25,AttackRecovery=.7,Name="Behemoth du coeur",Health=17000,Speed=7,Damage=140,Coins=18000,XP=22000,Scale=2.2,Template="RailTitan",Skin=Color3.fromRGB(103,91,84),Cloth=Color3.fromRGB(133,64,47)},
 PrismGuard={AttackWindup=.58,AttackRecovery=.42,Name="Gardien prismatique",Health=19000,Speed=10,Damage=118,Coins=19500,XP=27000,Scale=1.2,Template="Soldier",Skin=Color3.fromRGB(112,133,144),Cloth=Color3.fromRGB(70,119,147)},
 GlassRunner={AttackWindup=.26,AttackRecovery=.29,Name="Eclat fulgurant",Health=15000,Speed=22,Damage=105,Coins=18000,XP=27000,Scale=1.1,Template="Runner",Skin=Color3.fromRGB(151,187,193),Cloth=Color3.fromRGB(93,124,148)},
 ShardTitan={AttackWindup=1.28,AttackRecovery=.72,Name="Titan de silice",Health=24000,Speed=6,Damage=178,Coins=28000,XP=36000,Scale=2.2,Template="RailTitan",Skin=Color3.fromRGB(131,150,156),Cloth=Color3.fromRGB(68,98,119)},
 RelayWarden={AttackWindup=.6,AttackRecovery=.44,Name="Gardien du relais",Health=28000,Speed=9,Damage=155,Coins=26000,XP=36000,Scale=1.24,Template="Sentry",Skin=Color3.fromRGB(144,130,99),Cloth=Color3.fromRGB(77,93,112)},
 StaticRunner={AttackWindup=.25,AttackRecovery=.28,Name="Sprinteur statique",Health=23000,Speed=22,Damage=136,Coins=23500,XP=35000,Scale=1.13,Template="Glitch",Skin=Color3.fromRGB(161,143,119),Cloth=Color3.fromRGB(148,111,66)},
 TowerGoliath={AttackWindup=1.32,AttackRecovery=.74,Name="Goliath des tours",Health=36000,Speed=6,Damage=220,Coins=40000,XP=52000,Scale=2.25,Template="Colossus",Skin=Color3.fromRGB(122,122,113),Cloth=Color3.fromRGB(73,82,96)},
 VoidMechanic={AttackWindup=.62,AttackRecovery=.44,Name="Mecano du vide",Health=41000,Speed=10,Damage=190,Coins=31000,XP=44000,Scale=1.25,Template="RelayWarden",Skin=Color3.fromRGB(122,133,142),Cloth=Color3.fromRGB(85,91,101)},
 OrbitRunner={AttackWindup=.24,AttackRecovery=.28,Name="Coureur stellaire",Health=34000,Speed=24,Damage=170,Coins=28000,XP=42000,Scale=1.14,Template="StaticRunner",Skin=Color3.fromRGB(142,129,151),Cloth=Color3.fromRGB(88,94,119)},
 CapsuleTitan={AttackWindup=1.4,AttackRecovery=.78,Name="Titan de capsule",Health=52000,Speed=6,Damage=255,Coins=48000,XP=62000,Scale=2.35,Template="TowerGoliath",Skin=Color3.fromRGB(128,121,113),Cloth=Color3.fromRGB(81,75,70)},
 VaultWarden={AttackWindup=.64,AttackRecovery=.46,Name="Gardien du sas",Health=62000,Speed=10,Damage=270,Coins=54000,XP=70000,Scale=1.28,Template="VoidMechanic",Skin=Color3.fromRGB(110,137,125),Cloth=Color3.fromRGB(55,82,78)},
 SirenRunner={AttackWindup=.23,AttackRecovery=.27,Name="Sirene des profondeurs",Health=49000,Speed=25,Damage=230,Coins=50000,XP=72000,Scale=1.16,Template="OrbitRunner",Skin=Color3.fromRGB(132,163,150),Cloth=Color3.fromRGB(66,107,99)},
 ContainmentGoliath={AttackWindup=1.45,AttackRecovery=.82,Name="Goliath de confinement",Health=78000,Speed=6,Damage=320,Coins=68000,XP=88000,Scale=2.42,Template="CapsuleTitan",Skin=Color3.fromRGB(103,125,117),Cloth=Color3.fromRGB(52,72,69)},
 CrucibleGuard={AttackWindup=.66,AttackRecovery=.48,Name="Garde du creuset",Health=76000,Speed=10,Damage=310,Coins=66000,XP=90000,Scale=1.3,Template="VaultWarden",Skin=Color3.fromRGB(134,100,82),Cloth=Color3.fromRGB(75,67,63)},
 CinderRunner={AttackWindup=.22,AttackRecovery=.26,Name="Sprinteur incandescent",Health=61000,Speed=26,Damage=275,Coins=62000,XP=92000,Scale=1.17,Template="SirenRunner",Skin=Color3.fromRGB(174,106,78),Cloth=Color3.fromRGB(99,56,51)},
 ForgeTitan={AttackWindup=1.5,AttackRecovery=.86,Name="Titan de la forge",Health=96000,Speed=6,Damage=370,Coins=82000,XP=112000,Scale=2.48,Template="ContainmentGoliath",Skin=Color3.fromRGB(125,86,72),Cloth=Color3.fromRGB(65,52,49)},
 ConvoyMarshal={AttackWindup=.7,AttackRecovery=.5,Name="Marechal du convoi",Health=98000,Speed=10,Damage=410,Coins=96000,XP=116000,Scale=1.32,Template="CrucibleGuard",Skin=Color3.fromRGB(108,143,156),Cloth=Color3.fromRGB(54,77,91)},
 AshHound={AttackWindup=.2,AttackRecovery=.25,Name="Limier des cendres",Health=78000,Speed=27,Damage=350,Coins=84000,XP=112000,Scale=1.18,Template="CinderRunner",Skin=Color3.fromRGB(147,165,153),Cloth=Color3.fromRGB(73,86,93)},
 SiegeBehemoth={AttackWindup=1.55,AttackRecovery=.9,Name="Behemoth de siege",Health=130000,Speed=6,Damage=480,Coins=128000,XP=152000,Scale=2.52,Template="ForgeTitan",Skin=Color3.fromRGB(111,136,144),Cloth=Color3.fromRGB(51,70,84)}
 ,GridWarden={AttackWindup=.72,AttackRecovery=.5,Name="Gardien du reseau",Health=150000,Speed=10,Damage=520,Coins=140000,XP=170000,Scale=1.35,Template="ConvoyMarshal",Skin=Color3.fromRGB(167,152,102),Cloth=Color3.fromRGB(69,72,59)},
 FlashHound={AttackWindup=.19,AttackRecovery=.24,Name="Limier electrique",Health=112000,Speed=28,Damage=450,Coins=122000,XP=164000,Scale=1.2,Template="AshHound",Skin=Color3.fromRGB(189,177,111),Cloth=Color3.fromRGB(75,76,58)},
 BreakerTitan={AttackWindup=1.6,AttackRecovery=.92,Name="Titan disjoncteur",Health=180000,Speed=6,Damage=590,Coins=168000,XP=198000,Scale=2.58,Template="SiegeBehemoth",Skin=Color3.fromRGB(154,144,102),Cloth=Color3.fromRGB(58,63,49)}
 ,BlackoutWarden={AttackWindup=.76,AttackRecovery=.52,Name="Gardien du noyau",Health=215000,Speed=11,Damage=690,Coins=195000,XP=235000,Scale=1.4,Template="GridWarden",Skin=Color3.fromRGB(113,131,147),Cloth=Color3.fromRGB(48,60,74)},
 ArcRipper={AttackWindup=.18,AttackRecovery=.23,Name="Eventreur d'arc",Health=168000,Speed=31,Damage=575,Coins=174000,XP=225000,Scale=1.24,Template="FlashHound",Skin=Color3.fromRGB(150,166,177),Cloth=Color3.fromRGB(63,79,91)},
 CoreTitan={AttackWindup=1.68,AttackRecovery=.96,Name="Titan du noyau",Health=260000,Speed=6,Damage=780,Coins=235000,XP=275000,Scale=2.68,Template="BreakerTitan",Skin=Color3.fromRGB(105,123,140),Cloth=Color3.fromRGB(44,57,74)}
 ,EclipseWarden={AttackWindup=.82,AttackRecovery=.55,Name="Gardien de la voute",Health=290000,Speed=11,Damage=850,Coins=250000,XP=310000,Scale=1.45,Template="BlackoutWarden",Skin=Color3.fromRGB(112,103,137),Cloth=Color3.fromRGB(53,47,74)},
 NightStalker={AttackWindup=.17,AttackRecovery=.22,Name="Traqueur nocturne",Health=215000,Speed=33,Damage=720,Coins=225000,XP=300000,Scale=1.28,Template="ArcRipper",Skin=Color3.fromRGB(135,122,161),Cloth=Color3.fromRGB(58,49,83)},
 VaultGoliath={AttackWindup=1.75,AttackRecovery=1,Name="Goliath du caveau",Health=360000,Speed=6,Damage=940,Coins=300000,XP=360000,Scale=2.78,Template="CoreTitan",Skin=Color3.fromRGB(102,93,126),Cloth=Color3.fromRGB(43,41,64)}
}
C.Elites={Every=8,MinLevel=5,Health=1.8,Damage=1.2,Rewards=2.5,Scale=1.1}
function C.ZombieVariant(id,elite)
 local base=C.Zombies[id] if not base or not elite then return base end
 local def=table.clone(base)
 def.Name="ELITE · "..base.Name
 def.Health=math.floor(base.Health*C.Elites.Health+.5) def.Damage=math.floor(base.Damage*C.Elites.Damage+.5)
 def.Coins=math.floor(base.Coins*C.Elites.Rewards+.5) def.XP=math.floor(base.XP*C.Elites.Rewards+.5)
 def.Scale=base.Scale*C.Elites.Scale
 return def
end
C.RespawnDelay=10
C.AggroRange=48
C.LeashRange=65
C.AttackRange=4.4
C.AttackCooldown=1.5
C.AttackWindup=.45
C.AttackRecovery=.35
C.AttackArc=100
C.KillCreditSeconds=20
function C.RequiredXP(level) return 80+40*(level-1) end
function C.ZoneAt(position)
 for _,zone in C.Zones do
  local d=position-zone.Center
  if math.abs(d.X)<=zone.Half.X and math.abs(d.Z)<=zone.Half.Z and position.Y>-20 and position.Y<180 then return zone end
 end
 return nil
end
return C
