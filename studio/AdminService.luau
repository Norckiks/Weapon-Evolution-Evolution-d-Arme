local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local P=require(script.Parent:WaitForChild("ProgressionService"))
local C=require(RS:WaitForChild("GameplayConfig"))
local A={}
local OWNER_USER_ID=10565455042 -- Bruno_ban369, verified from the connected Studio account.
local requests={}
local economy
function A.IsOwner(player)
 return player.UserId==OWNER_USER_ID
end
function A.Handle(player,verb,value,amount)
 if not A.IsOwner(player) then return false,"Acces refuse." end
 local now=os.clock()
 if now-(requests[player] or -100)<.3 then return false,"Attends un instant." end
 requests[player]=now
 if not player:GetAttribute("ProgressReady") then return false,"Profil en chargement." end
 if not RunService:IsStudio() and player:GetAttribute("PersistenceMode")~="Saved" then return false,"Sauvegarde indisponible : attribution bloquee." end
 if verb=="Status" then return true,RunService:IsStudio() and "Studio : gains temporaires, effaces a l'arret." or "Gains permanents : sauvegarde normale du compte." end
 if player:GetAttribute("HasStarted")~=true then return false,"Clique d'abord sur JOUER." end
 if typeof(verb)~="string" or #verb>24 then return false,"Commande inconnue." end
 if typeof(amount)~="number" or amount~=amount or amount%1~=0 or amount<1 or amount>1000000 then return false,"Quantite entiere de 1 a 1 000 000 requise." end
 economy.Refresh(player)
 local m=P.GetMeta(player)
 local ls=player:FindFirstChild("leaderstats")
 local progress=player:FindFirstChild("Progress")
 if not m or not ls or not progress then return false,"Profil indisponible." end
 local note
 if verb=="Coins" then
  if ls.Coins.Value+amount>2000000000 then return false,"Plafond de pieces atteint." end
  P.AddRewards(player,amount,0,"Admin") note="+"..amount.." pieces"
 elseif verb=="Levels" then
  if ls.Level.Value+amount>100000 then return false,"Niveau maximum : 100 000." end
  ls.Level.Value+=amount note="+"..amount.." niveaux (XP conservee)"
 elseif verb=="XP" then
  if ls.Level.Value>=100000 then return false,"Niveau maximum atteint." end
  P.AddRewards(player,0,amount,"Admin") note="+"..amount.." XP"
 elseif verb=="Weapon" then
  if typeof(value)~="string" or not C.Weapons[value] then return false,"Arme inconnue." end
  m.Weapons[value]=true note=C.Weapons[value].Name.." ajoutee (equipe-la dans ARMURERIE)"
 elseif verb=="Pet" or verb=="Fragments" then
  if typeof(value)~="string" or not C.Pets[value] or (verb=="Fragments" and value=="Buddy") then return false,"Pet inconnu ou sans fragments." end
  local inventory=verb=="Pet" and m.Pets or m.Fragments
  local cap=verb=="Pet" and 100000 or 1000000
  if (inventory[value] or 0)+amount>cap then return false,"Capacite atteinte." end
  inventory[value]=(inventory[value] or 0)+amount
  note="+"..amount.." "..(verb=="Pet" and "pet(s) : " or "fragment(s) : ")..C.Pets[value].Name
 else return false,"Commande inconnue." end
 economy.Refresh(player) economy.Send(player)
 -- Normal autosave keeps inventory and receipts in the existing profile.
 return true,note
end
function A.Init(service)
 economy=service
 local remote=Instance.new("RemoteFunction") remote.Name="AdminAction" remote.Parent=RS.Remotes
 remote.OnServerInvoke=A.Handle
 local function added(player) player:SetAttribute("AdminAccess",A.IsOwner(player)) end
 Players.PlayerAdded:Connect(added)
 Players.PlayerRemoving:Connect(function(player) requests[player]=nil end)
 for _,player in Players:GetPlayers() do added(player) end
end
return A
