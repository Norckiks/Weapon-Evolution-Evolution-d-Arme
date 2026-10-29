local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local MessagingService=game:GetService("MessagingService")
local RunService=game:GetService("RunService")
local P=require(script.Parent:WaitForChild("ProgressionService"))
local C=require(RS:WaitForChild("GameplayConfig"))
local A={}
local OWNER_USER_ID=10565455042 -- Bruno_ban369, verified from the connected Studio account.
local requests={}
local delegateStore=DataStoreService:GetDataStore("AdminDelegates_v1")
local DELEGATE_TOPIC="WeaponEvolution_AdminDelegates_v1"
local delegates={}
local delegatesReady=false
local delegatesLoadedAt=0
local economy
function A.IsOwner(player)
 return player.UserId==OWNER_USER_ID
end
local function isAdmin(player)
 local delegate=delegates[tostring(player.UserId)]
 return A.IsOwner(player) or (delegatesReady and (delegate==true or typeof(delegate)=="string"))
end
local function setAccess(player)
 player:SetAttribute("AdminCanDelegate",A.IsOwner(player))
 local allowed=isAdmin(player)
 if allowed~=nil then player:SetAttribute("AdminAccess",allowed) end
end
local function loadDelegates()
 local ok,stored=pcall(function() return delegateStore:GetAsync("UserIds") end)
 if not ok then return false end
 delegates=typeof(stored)=="table" and stored or {}
 delegatesReady=true
 delegatesLoadedAt=os.clock()
 for _,player in Players:GetPlayers() do setAccess(player) end
 return true
end
local function notifyServers()
 return pcall(function() MessagingService:PublishAsync(DELEGATE_TOPIC,"refresh") end)
end
function A.Handle(player,verb,value,amount)
 if not A.IsOwner(player) and (not delegatesReady or os.clock()-delegatesLoadedAt>=5) and not loadDelegates() then
  return false,"Liste admins indisponible."
 end
 if not isAdmin(player) then return false,"Acces refuse." end
 local now=os.clock()
 if now-(requests[player] or -100)<.3 then return false,"Attends un instant." end
 requests[player]=now
 if verb=="ListAdmins" then
  if not A.IsOwner(player) then return false,"Acces refuse." end
  if not delegatesReady and not loadDelegates() then return false,"Liste indisponible : DataStore non charge." end
  local ids={} for userId,username in delegates do table.insert(ids,{UserId=userId,Username=typeof(username)=="string" and username or userId}) end
  table.sort(ids,function(a,b) return a.Username:lower()<b.Username:lower() end)
  return true,"Admins delegues",ids
 end
 if verb=="GrantAdmin" or verb=="RevokeAdmin" then
  if not A.IsOwner(player) then return false,"Seul le proprietaire peut gerer les admins." end
  if not delegatesReady then return false,"Liste indisponible : DataStore non charge." end
  if verb=="GrantAdmin" then
   if typeof(value)~="string" or #value<3 or #value>20 or not value:match("^[%w_]+$") then return false,"Entre un nom d'utilisateur Roblox valide." end
   local ok,userIdOrError=pcall(function() return Players:GetUserIdFromNameAsync(value) end)
   if not ok then return false,"Nom introuvable : verifie le nom d'utilisateur Roblox." end
   local userId=userIdOrError
   if userId==OWNER_USER_ID then return false,"Tu es deja proprietaire." end
   if delegates[tostring(userId)] then return false,"Cette personne est deja admin." end
   local count=0 for _ in delegates do count+=1 end
   if count>=50 then return false,"Limite de 50 admins delegues atteinte." end
   local full=false
   local saved,newList=pcall(function()
    return delegateStore:UpdateAsync("UserIds",function(current)
     full=false
     current=typeof(current)=="table" and current or {}
     local count=0 for _ in current do count+=1 end
     if not current[tostring(userId)] and count>=50 then full=true return nil end
     current[tostring(userId)]=value
     return current
    end)
   end)
   if full then return false,"Limite de 50 admins delegues atteinte." end
   if not saved or typeof(newList)~="table" then return false,"Sauvegarde incertaine : reconnecte-toi puis verifie la liste." end
   delegates=newList
   delegatesLoadedAt=os.clock()
   for _,target in Players:GetPlayers() do if target.UserId==userId then setAccess(target) end end
   local notified=notifyServers()
   return true,"Admin ajoute : "..value.." ("..userId..")."..(notified and "" or " Sync autres serveurs non confirmee.")
  end
  if typeof(value)~="string" or not value:match("^%d+$") then return false,"Identifiant invalide." end
  local userId=tonumber(value)
  if not userId or userId==OWNER_USER_ID or not delegates[value] then return false,"Admin delegue introuvable." end
  local saved,newList=pcall(function()
   return delegateStore:UpdateAsync("UserIds",function(current)
    current=typeof(current)=="table" and current or {}
    current[value]=nil
    return current
   end)
  end)
  if not saved or typeof(newList)~="table" then return false,"Sauvegarde incertaine : reconnecte-toi puis verifie la liste." end
  delegates=newList
  delegatesLoadedAt=os.clock()
  for _,target in Players:GetPlayers() do if target.UserId==userId then setAccess(target) end end
  local notified=notifyServers()
  return true,"Acces admin retire pour "..value.."."..(notified and "" or " Sync autres serveurs non confirmee.")
 end
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
 local function added(player) setAccess(player) end
 Players.PlayerAdded:Connect(added)
 Players.PlayerRemoving:Connect(function(player) requests[player]=nil end)
 for _,player in Players:GetPlayers() do added(player) end
 task.spawn(function()
  loadDelegates()
 end)
 task.spawn(function()
  pcall(function()
   MessagingService:SubscribeAsync(DELEGATE_TOPIC,function()
    task.spawn(loadDelegates)
   end)
  end)
 end)
end
return A
