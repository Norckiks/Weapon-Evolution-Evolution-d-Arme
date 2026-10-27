local C=require(script.Parent.GameplayConfig)
local K={Order={"Salvage","Arsenal","Pets"}}
K.Rarities={Common={Name="COMMUN",Color=Color3.fromRGB(130,214,156)},Rare={Name="RARE",Color=Color3.fromRGB(91,195,245)},Epic={Name="EPIQUE",Color=Color3.fromRGB(190,139,244)},Legendary={Name="LEGENDAIRE",Color=Color3.fromRGB(255,200,75)}}
K.Definitions={
 Salvage={Name="Caisse de recuperation",Kind="Weapon",Cost=450,Level=5,Color=Color3.fromRGB(91,195,223),Items={{Id="Pipe",Chance=50,Rarity="Common"},{Id="Bat",Chance=30,Rarity="Common"},{Id="Pistol",Chance=15,Rarity="Rare"},{Id="Axe",Chance=5,Rarity="Epic"}}},
 Arsenal={Name="Arsenal des survivants",Kind="Weapon",Cost=3500,Level=16,Color=Color3.fromRGB(190,139,244),Items={{Id="SMG",Chance=45,Rarity="Rare"},{Id="Revolver",Chance=30,Rarity="Rare"},{Id="Katana",Chance=20,Rarity="Epic"},{Id="Shotgun",Chance=5,Rarity="Legendary"}}},
 Pets={Name="Cocon des compagnons",Kind="Pet",Cost=800,Level=1,Color=Color3.fromRGB(125,211,139),Items={{Id="Civilian",Chance=45,Rarity="Common"},{Id="Runner",Chance=30,Rarity="Common"},{Id="Brute",Chance=15,Rarity="Rare"},{Id="Worker",Chance=8,Rarity="Epic"},{Id="Buddy",Chance=2,Rarity="Legendary"}}}
}
function K.Item(crate,item) return (crate.Kind=="Weapon" and C.Weapons or C.Pets)[item.Id] end
function K.Refund(id) return math.floor(C.Weapons[id].Cost*.25) end
function K.Roll(crate,rng)
 local ticket=rng:NextInteger(1,100)
 for _,item in crate.Items do ticket-=item.Chance if ticket<=0 then return item end end
 error("Invalid crate probabilities")
end
for _,crate in K.Definitions do
 local total=0
 for _,item in crate.Items do
  local def=K.Item(crate,item)
  assert(def and K.Rarities[item.Rarity] and item.Chance>0 and item.Chance%1==0,"Invalid crate item")
  assert(crate.Kind~="Weapon" or not def.Premium and def.Level<=crate.Level,"Inaccessible crate weapon")
  total+=item.Chance
 end
 assert(total==100,"Crate probabilities must total 100%")
end
return K
