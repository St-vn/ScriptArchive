local Modules = script.Parent
local MobData = require(Modules.EntityData)
local ClockService = require(game.ReplicatedStorage.Modules.Util.ClockService) -- an older version of https://github.com/CozzyBro2/CallScheduler
local CombatHandler = require(Modules.CombatHandler)

local Players = game.Players

local Trackers = {}

local function GetStats(Target)
	local Stats = {}
	
	if game.Players:GetPlayerFromCharacter(Target) then
		local Player = game.Players:GetPlayerFromCharacter(Target)
		Stats.Level = Player.savedStats.Lvl.Value

		for _, v in ipairs(Player.Stats:GetChildren()) do
			Stats[v.Name] = v.Value
		end
		
		return Stats, CombatHandler.new(Player)
	else
		return CombatHandler.new(Target)
	end
end

local function newTracker(Target)
	if Trackers[Target] then
		return Trackers[Target]
	else
		Trackers[Target] = {}
		return Trackers[Target]
	end
end

local function DealDamage(self, Target, amount, AttackerStats, Stats)
	local Humanoid = Target:FindFirstChildWhichIsA("Humanoid")
	if Humanoid.Health <= 0 then return end
	
	local State = Stats.State.Value
	amount = math.round(amount > Humanoid.Health and Humanoid.Health or amount)
	
	if State == "Parrying" then
		AttackerStats:SetState("Staggered", 1, 2)
	elseif State ~= "Blocking" and amount > 0 then
		Stats:SetState("Staggered", .25, 2)
	end
	
	Humanoid:TakeDamage(amount)
	
	local targetTracker = newTracker(Target)
	targetTracker[self] = targetTracker[self] or {
		Hitting = true,
		Character = self,
		Damage = 0
	}; targetTracker[self].Hitting = true
	
	targetTracker[self].Damage += amount
	
	ClockService(1, function()
		if Humanoid.Health <= 0 then return end
		targetTracker[self].Hitting = nil
	end)
		
	return amount
end

return {DealDamage = DealDamage, newTracker = newTracker, GetStats = GetStats}
