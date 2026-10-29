-- Temporary Play SessionStudio visual fixture; never install in Edit.
local Run=game:GetService("RunService")
assert(Run:IsStudio())
local p=game.Players.LocalPlayer
assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local camera=workspace.CurrentCamera
local hub=p.PlayerGui:WaitForChild("SurvivorHub")
local torch=workspace:WaitForChild("LocalPresentation"):WaitForChild("Flashlight")
assert(torch:FindFirstChild("SurvivorFlashlight") and torch:FindFirstChild("FlashlightSpill"))
assert(not p.PlayerGui:FindFirstChild("NightLightingQA"))
local state=Instance.new("Folder") state.Name="NightLightingQA"
local oldCF,oldType=camera.CFrame,camera.CameraType
local oldHub,oldHigh,oldMotion=hub.Enabled,p:GetAttribute("HighGraphics"),p:GetAttribute("ReducedMotion")
state:SetAttribute("Camera",CFrame.lookAt(Vector3.new(0,7,90),Vector3.new(0,4,40)))
state.Parent=p.PlayerGui
hub.Enabled=false p:SetAttribute("HighGraphics",true) p:SetAttribute("ReducedMotion",true)
Run:BindToRenderStep("NightLightingQACamera",Enum.RenderPriority.Last.Value,function()
 camera.CameraType=Enum.CameraType.Scriptable camera.CFrame=state:GetAttribute("Camera")
end)
local check=Instance.new("BindableFunction") check.Name="Check" check.Parent=state
check.OnInvoke=function()
 local core,spill=torch.SurvivorFlashlight,torch.FlashlightSpill
 assert(core.Enabled==spill.Enabled,"Core and halo must toggle together")
 assert(core.Enabled==(p:GetAttribute("FlashlightEnabled")==true),"Flashlight input state differs")
 assert(core.Shadows==(p:GetAttribute("HighGraphics")~=false),"Flashlight quality option ignored")
 assert(not spill.Shadows,"Halo must not duplicate shadow rendering")
 local worldShadows=0
 for _,v in workspace:GetDescendants() do if v:IsA("Light") and v.Shadows and not v:IsDescendantOf(workspace.LocalPresentation) then worldShadows+=1 end end
 assert(worldShadows<=4,"World shadow budget exceeded")
 return {Enabled=core.Enabled,CoreAngle=core.Angle,CoreRange=core.Range,CoreBrightness=core.Brightness,Shadows=core.Shadows,HaloRange=spill.Range,WorldShadows=worldShadows,Camera=tostring(camera.CFrame)}
end
local restore=Instance.new("BindableFunction") restore.Name="Restore" restore.Parent=state
restore.OnInvoke=function()
 Run:UnbindFromRenderStep("NightLightingQACamera")
 hub.Enabled=oldHub p:SetAttribute("HighGraphics",oldHigh) p:SetAttribute("ReducedMotion",oldMotion)
 camera.CameraType=oldType camera.CFrame=oldCF
 state:Destroy()
 return true
end
