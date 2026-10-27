-- Temporary Studio Play geometry inspector, never install in Edit.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer assert(p:GetAttribute("PersistenceMode")=="SessionStudio")
local pg=p.PlayerGui local hub=pg:WaitForChild("SurvivorHub") local window=hub.Window local catalog=window.Catalog
local inspect=Instance.new("BindableFunction") inspect.Name="InspectCatalogQA" inspect.Parent=pg
local function rect(v)
 local pos=v.AbsolutePosition-hub.AbsolutePosition local size=v.AbsoluteSize
 return {X=pos.X,Y=pos.Y,W=size.X,H=size.Y}
end
local function contains(a,b) return b.X>=a.X-1 and b.Y>=a.Y-1 and b.X+b.W<=a.X+a.W+1 and b.Y+b.H<=a.Y+a.H+1 end
local function intersects(a,b) return math.min(a.X+a.W,b.X+b.W)-math.max(a.X,b.X)>1 and math.min(a.Y+a.H,b.Y+b.H)-math.max(a.Y,b.Y)>1 end
inspect.OnInvoke=function(bottom)
 if bottom then catalog.CanvasPosition=Vector2.new(0,math.max(0,catalog.AbsoluteCanvasSize.Y-catalog.AbsoluteWindowSize.Y)) end
 -- Caller waits for layout outside this callback; no render-event yield in an MCP invocation.
 local view=workspace.CurrentCamera.ViewportSize local portrait=game.UserInputService.TouchEnabled and view.Y>view.X
 if view.X<100 or view.Y<100 then return game.HttpService:JSONEncode({Passed=false,Status="UnavailableViewport",Viewport={X=view.X,Y=view.Y},Issues={"Client viewport has not rendered; do not count as product geometry failures"}}) end
 local out={Page=window.PageTitle.Text,Portrait=portrait,Viewport={X=view.X,Y=view.Y},Window=rect(window),CanvasY=catalog.CanvasPosition.Y,Rows={},Issues={}}
 local function check(ok,msg) if not ok then table.insert(out.Issues,msg) end end
 check(window.Visible,"Window not visible") check(contains({X=0,Y=0,W=view.X,H=view.Y},out.Window),"Window outside viewport")
 check(window.PageTitle.TextFits,"Page title clipped") check(window.Note.TextFits,"Footer note clipped") check(window.Bonus.TextFits,"Footer coins clipped")
 local tabs={}
 for _,v in window.Tabs:GetChildren() do if v:IsA("TextButton") then
  local r=rect(v) table.insert(tabs,r) check(contains(out.Window,r),"Tab outside window: "..v.Name) check(v.TextFits,"Tab text clipped: "..v.Name)
  if portrait then check(r.W>=43.9 and r.H>=43.9,"Tab below 44 pixels: "..v.Name) end
 end end
 for i,a in tabs do for j,b in tabs do if j>i then check(not intersects(a,b),"Tabs overlap") end end end
 if portrait then check(window.Close.AbsoluteSize.Y>=43.9,"Close below 44 pixels") end
 for _,row in catalog:GetChildren() do if row:IsA("Frame") then
  local r={Name=row.Name,Bounds=rect(row),Buttons={}} local actions={}
  local title=row:FindFirstChild("Name") local desc=row:FindFirstChild("Description")
  check(title and title.TextFits,"Row title clipped: "..row.Name) check(desc and desc.TextFits,"Row description clipped: "..row.Name)
  for _,v in row:GetChildren() do if v:IsA("GuiObject") then
   local vr=rect(v) check(contains(r.Bounds,vr),"Child outside row: "..row.Name.."/"..v.Name)
   if v:IsA("TextButton") then
    table.insert(actions,v) table.insert(r.Buttons,{Text=v.Text,Rect=vr,Active=v.Active,Selectable=v.Selectable})
    check(v.TextFits,"Action text clipped: "..row.Name)
    if portrait then check(vr.H>=43.9,"Action below 44 pixels: "..row.Name) end
    if title then check(not intersects(vr,rect(title)),"Action overlaps title: "..row.Name) end
    if desc then check(not intersects(vr,rect(desc)),"Action overlaps description: "..row.Name) end
    local preview=row:FindFirstChild("WeaponPreview") if preview then check(not intersects(vr,rect(preview)),"Action overlaps preview") end
   end
  end end
  for i,a in actions do for j,b in actions do if j>i then check(not intersects(rect(a),rect(b)),"Pet actions overlap") end end end
  table.insert(out.Rows,r)
 end end
 table.sort(out.Rows,function(a,b) return a.Bounds.Y<b.Bounds.Y end)
 if bottom and #out.Rows>0 then local last=out.Rows[#out.Rows] local c=rect(catalog) check(last.Bounds.Y+last.Bounds.H<=c.Y+c.H+2,"Last row unreachable at bottom") end
 out.Passed=#out.Issues==0
 return game.HttpService:JSONEncode(out)
end
