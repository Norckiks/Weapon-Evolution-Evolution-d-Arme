local ServerStorage = game:GetService("ServerStorage")
local template = ServerStorage:WaitForChild("TrainingDummyTemplate")
local home = template:GetPivot()

local function watch(dummy)
	local hum = dummy:WaitForChild("Humanoid")
	hum.Died:Connect(function()
		task.wait(2)
		dummy:Destroy()
		task.wait(1.5)
		local new = template:Clone()
		new.Name = "TrainingDummy"
		new:PivotTo(home)
		new.Parent = workspace
		watch(new)
	end)
end

local first = workspace:WaitForChild("TrainingDummy")
watch(first)
