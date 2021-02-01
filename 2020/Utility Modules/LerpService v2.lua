--  Made by St_vn#3931, 9/11/2020
-- Aka St_vnC in roblox
-- Meant to replace TweenService

local emptyTable = {}
local tasks = {}

local function LerpFunction(start, goal, alpha)
	return start + (goal - start) * alpha
end

game:GetService("RunService").RenderStepped:Connect(function(step)
	for index, task in pairs(tasks) do
		task.Alpha += step / task.Length
		
		local object = task.Object
		local start = task.Start
		local alpha = task.Alpha

		for property, value in pairs(task.Goal) do
			object[property] = task.LerpMethod[property] and start[property]:Lerp(value, alpha) or LerpFunction(start[property], value, alpha)
		end

		if alpha >= 1 then
			task.Object = nil
			table.remove(tasks, index)
      
			if task.Callback then task.Callback(unpack(task.Args)) end
		end
	end
end

return function(properties)
	local object = properties.Object
	local start = {}
	local lerpMethod = {}

	for property, value in pairs(properties.Goal) do
		start[property] = object[property]
		lerpMethod[property] = type(value) == "userdata"
	end
	
	table.insert(tasks, {
		Object = object,
		Start = start,
		Goal = properties.Goal,
		LerpMethod = lerpMethod,
		Length = properties.Length,
		Args = properties.Args or emptyTable,
		Callback = properties.Callback,
		Alpha = 0
	})
end
