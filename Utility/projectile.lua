local projectiles = {}
local toMove, moveTo = {}, {}

local count = 0
local connection
local renderStep = game:GetService("RunService").RenderStepped

local rayParams = RaycastParams.new()
rayParams.FilterType, rayParams.FilterDescendantsInstances = Enum.RaycastFilterType.Blacklist, {workspace.Bullets, workspace.Terrain}

local function Callback(step)
	for stop, info in pairs(projectiles) do

		local part = info.Part
		local direction = info.Direction * step
		local results = workspace:Raycast(part.Position + info.Offset, direction)

		table.insert(toMove, part)
		table.insert(moveTo, results and CFrame.new(results.Position) - (part.Size.Z * .5 * direction.Unit) or (part.CFrame + direction))

		if results or stop < os.clock() then
			info.Callback(results)
			projectiles[stop] = nil
			
			count -= 1
			
			if count == 0 then
				connection:Disconnect()
			end
		end
	end

	workspace:BulkMoveTo(toMove, moveTo, Enum.BulkMoveMode.FireCFrameChanged)

	table.clear(toMove)
	table.clear(moveTo)
end

return function(stop, info)
	info.Offset = info.Part.Size.Z * .5 * info.Direction.Unit
	projectiles[os.clock() + stop] = info
	
	count += 1
	
	if count == 1 then
		connection = renderStep:Connect(Callback)
	end
end
