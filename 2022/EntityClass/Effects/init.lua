local config = require(game:GetService("ReplicatedStorage").Common.config).Effects
local vfx = game:GetService("ReplicatedStorage").Assets.Effects
local isClient = game:GetService("RunService"):IsClient()

local effectHandler = {}
effectHandler.__index = effectHandler

local effectClass = {}
effectClass.__index = effectClass

local handlers = {}

local filteredProperties = {"Level", "EffectEnd"}
local effects = {}

for _, module in script:GetChildren() do
	effects[module.Name] = require(module)
end

function effectHandler.new(entity)
	local handler = setmetatable({
		Entity = entity,
		Effects = {}
	}, effectHandler)
	
	handlers[entity] = handler
	
	return handler
end

function effectHandler:Add(effectName: string, duration: number, level: number, maxStack: number)
	local serverTimeNow = workspace:GetServerTimeNow()
	local newEffect = setmetatable({
		EffectName = effectName,
		EffectEnd = serverTimeNow + duration,
		Level = level or 1,
		PreviousTime = serverTimeNow,
		Effects = self.Effects,
	}, effectClass)
	
	if isClient and vfx:FindFirstChild(effectName) then
		local emitter = vfx:FindFirstChild(effectName):Clone()
		emitter.Parent = self.Entity.Root
		
		newEffect.VFX = emitter
	end
	
	table.insert(self.Effects, newEffect)
	
	return newEffect
end

function effectHandler:Destroy()
	handlers[self.Entity] = nil
	
	table.foreachi(self.Effects, function(k)
		table.remove(self.Effects)
	end)
end

function effectClass:Update(propertyName, newValue)
	if not filteredProperties[propertyName] and self[propertyName] then
		self[propertyName] = newValue
	end
end

function effectClass:GetIndex()
	return table.find(self.Effects, self)
end

function effectClass:Remove()
	if self.VFX then
		self.VFX = self.VFX:Destroy()
	end
	
	table.remove(self.Effects, self:GetIndex())
end

game:GetService("RunService").Heartbeat:Connect(function()
	for entity, handler in handlers do
		for index, effect in handler.Effects do
			local timeLeft = effect.EffectEnd - math.min(effect.EffectEnd, workspace:GetServerTimeNow())
			local deltaTime = workspace:GetServerTimeNow() - effect.PreviousTime
			local ticks = deltaTime / config[effect.EffectName].TickTime
			
			if ticks >= 1 then
				effects[effect.EffectName].Tick(entity, ticks, effect.Level, isClient)
				
				effect.PreviousTime = workspace:GetServerTimeNow()
			end
			
			if timeLeft <= 0 then
				effect:Remove(index)
			end
		end
	end
end)

return effectHandler
