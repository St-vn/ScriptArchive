local logic = require(script.Logic)
local config = require(game:GetService("ReplicatedStorage").Common.config)
local list = logic.GetMobs()

local entityHandler = require(game:GetService("ReplicatedStorage").Common.EntityClass)
local hitbox = require(game:GetService("ReplicatedStorage").Common.HitboxClass.HitCast)
local damage = require(game:GetService("ServerStorage").Common.Damage)

local mobClass = {}
mobClass.__index = mobClass

setmetatable(mobClass, entityHandler)

function mobClass.new(new)
	local root = new.PrimaryPart
	local mob = setmetatable(entityHandler.new(new), mobClass)
	
	mob.Hitbox = hitbox.new(root, false)
	mob.MaxDistance = 20
	mob.Target = nil
	mob.Clone = new:Clone()
	
	root:SetNetworkOwner(nil)
	
	mob.Hitbox.Signal:Connect(function(part, humanoid)
		damage.Deal(mob, part:FindFirstAncestorWhichIsA("Model"), 60, 0.25)
	end)
	
	mob.Humanoid.Died:Connect(function()
		mob:Died()
	end)
	
	list[new] = mob
end

function mobClass:FindTarget()
	local closest = nil
	local closestDistance = self.MaxDistance

	for target in logic.GetTargets() do
		local distance = (self.Root.Position - target.PrimaryPart.Position).Magnitude

		if distance <= closestDistance then
			closestDistance = distance
			closest = target
		end
	end
	
	return closest, closestDistance
end

function mobClass:FindIdealAttack(distance)
	local attacks = config.Mobs[self.Model.Name].Attacks
	local ideal = nil
	local closestDistance = 100000
	
	for name, info in attacks do
		local newDistance = math.min(
			math.abs(distance - info.AttackRange.Min),
			math.abs(distance - info.AttackRange.Max)
		)
		
		if newDistance < closestDistance then
			ideal = info
			closestDistance = newDistance
		end
	end
	
	return ideal, closestDistance
end

function mobClass:GetInPosition(direction, attackRange)
	local unit = direction.Unit
	local magnitude = direction.Magnitude
	local idealDistance = if math.abs(magnitude - attackRange.Max) < math.abs(magnitude - attackRange.Min) then attackRange.Min else attackRange.Max
	
	self:MoveTo(self.Target.PrimaryPart.Position - unit * idealDistance, self.Target.PrimaryPart)
end

function mobClass:IsInPosition(distance, attackRange)
	distance = math.round(distance)
	
	return distance >= attackRange.Min and distance <= attackRange.Max
end

function mobClass:GetPosition()
	return self.Root.Position
end

function mobClass:MoveTo(...)
	self.Humanoid:MoveTo(...)
end

function mobClass:Attack()
	if self:HasRecovered() then
		self.Hitbox:Activate{workspace.Mobs}
		self:SetRecovery(0.65, 2)
		
		task.delay(0.35, self.Hitbox.Deactivate, self.Hitbox)
	end
end

function mobClass:Respawn()
	self.Clone.Parent = workspace.Mobs
	
	mobClass.new(self.Clone)
end

function mobClass:Died()
	task.wait(5)
	-- initiate respawn
	list[self.Model] = nil
	
	self.Model:Destroy()
	self:Respawn()
	self:Destroy()
end

return mobClass
