local module = {}

function module.Tick(entity, ticks, level, isClient)
	if not isClient then
		entity.Humanoid.Health -= ticks * (level * 2)
	end
end

return module
