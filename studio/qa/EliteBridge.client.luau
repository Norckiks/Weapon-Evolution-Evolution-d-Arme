-- Temporary Play camera/target-card fixture, not native aiming proof.
assert(game.RunService:IsStudio())
local p=game.Players.LocalPlayer local camera=workspace.CurrentCamera
local cf,kind=camera.CFrame,camera.CameraType local menu,options=p:GetAttribute("GameMenuOpen"),p:GetAttribute("OptionsOpen")
local bridge=game.ReplicatedStorage:WaitForChild("EliteQABridge",10) assert(bridge)
bridge.OnClientInvoke=function(verb,model)
 if verb=="Restore" then camera.CameraType=kind camera.CFrame=cf p:SetAttribute("GameMenuOpen",menu) p:SetAttribute("OptionsOpen",options) return true end
 if verb=="Forge" then game.ReplicatedStorage.Remotes.GameAction:FireServer("SpawnElite","Factory") return true end
 p:SetAttribute("GameMenuOpen",false) p:SetAttribute("OptionsOpen",false)
 camera.CameraType=Enum.CameraType.Scriptable camera.CFrame=CFrame.lookAt(model.Head.Position+Vector3.new(0,1,12),model.Head.Position)
 task.wait(.25)
 local card=p.PlayerGui.TargetHUD.TargetCard
 return {Visible=card.Visible,Name=card.EnemyName.Text,Gold=card.BackgroundColor3==Color3.fromRGB(255,227,149)}
end
