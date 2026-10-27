-- Play-only snapshot after PrepareLoginCalendarUI(phase); no visual proof.
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local phase=p:GetAttribute("LoginCalendarQAPhase")
local row=p.PlayerGui.SurvivorHub.Window.Catalog.LoginReward
local expected={Ready="RECUPERER",Claimed="DEMAIN",Full="DEPENSE D'ABORD"}
assert(row.Action.Text==expected[phase],"Claim label")
assert(row.Action.Active==(phase=="Ready"),"Claim enabled state")
assert(row:FindFirstChild(phase=="Claimed" and "GiftArtwork" or "CoinsArtwork"),"Reward image")
assert(row:FindFirstChild("Name").Text:find(phase=="Claimed" and "2/7" or "1/7"),"Calendar step")
assert(row.Action.Position.Y.Offset+row.Action.Size.Y.Offset<=row.Size.Y.Offset,"Action within row")
return {Phase=phase,Checks=5,Text=row.Action.Text,Viewport=tostring(workspace.CurrentCamera.ViewportSize)}
