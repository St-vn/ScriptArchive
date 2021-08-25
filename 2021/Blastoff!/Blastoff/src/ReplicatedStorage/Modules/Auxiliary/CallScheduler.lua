local toCall = {}

game:GetService("RunService").Stepped:Connect(function()
	for callDate, callback in pairs(toCall) do
		if callDate < os.clock() then
			toCall[callDate] = nil

			callback()
		end
	end
end)

return toCall