local mobs = {}
local targets = {}

local config = require(game:GetService("ReplicatedStorage").Common.config)
local module = {}

function module.GetMobs()
	return mobs
end

function module.GetTargets()
	return targets
end

function module.AddTarget(target)
	targets[target] = true
end

function module.RemoveTarget(target)
	targets[target] = nil
end

task.spawn(function()
	while true do
		for _, self in mobs do
			task.spawn(function()
				local target, distance = self:FindTarget()

				self.Target = target

				if self.Target then
					local idealAttack = self:FindIdealAttack(distance)
					
					if self:IsInPosition(distance, idealAttack.AttackRange) then
						self:TurnTo()
						self:Attack()
					else
						self:GetInPosition((target.PrimaryPart.Position - self:GetPosition()), idealAttack.AttackRange)
					end
				else
					self:MoveTo(self.Root.Position)
				end
			end)
		end
		
		task.wait(0.5)
	end
end)

return module
