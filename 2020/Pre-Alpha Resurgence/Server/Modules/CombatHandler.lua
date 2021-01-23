-- 17th September 2020

local ClockService = require(game.ReplicatedStorage.Modules.Util.ClockService)
local MobData = require(script.Parent.EntityData)

local functions = {}
functions.__index = functions

local Important = {
	functions = functions,
	States = {
		Idling = {
			Priority = 1,
			StaminaAdd = 1,
		},
		Sprinting = {
			Priority = 1.1,
			StaminaAdd = -.5,
			WalkSpeed = 1.75,
			Hold = true
		},
		Attacking = {
			Priority = 2,
			WalkSpeed = .1
		},
		Blocking = {
			Priority = 2,
			StaminaAdd = .25,
			WalkSpeed = .35,
			Hold = true
		},
		Parrying = {
			Priority = 2,
			WalkSpeed = .1
		},
		Dashing = {
			Priority = 4.1,
		},
		Staggered = {
			Priority = 4,
			WalkSpeed = 0,
			Cancel = true
		},
		Exhausted = {
			Priority = 4,
			StaminaAdd = 2.5,
			WalkSpeed = .1
		},
	}
}

local Combats = {}

local function new(Player)
	if Combats[Player] then
		return Combats[Player]
	else
		local self = setmetatable({
			State = "Idling",
			Player = Player,
			Character = Player:IsA("Player") and (Player.Character or Player.CharacterAdded:Wait()) or Player,
		}, functions)
		
		Combats[Player] = self
		
		if Player:IsA("Player") then
			Player:WaitForChild("Stats")
			
			self.Stamina = Player.Stats.Stamina
			self.State = Instance.new("StringValue"); self.State.Name = "State"
			self.State.Value = "Idling"
			self.State.Parent = Player
		else
			self.Character = Player
			self.Stamina = {
				Value = MobData.Mobs[Player.Name].Stamina,
				MaxValue = MobData.Mobs[Player.Name].Stamina
			}
			
			self.State = {Value = "Idling"}
		end
		
		return self
	end
end

function functions:Remove()
	local Player = self.Player
	
	if not Combats[Player] then return end
	
	for k in pairs(Combats[Player]) do
		Combats[Player][k] = nil
	end
	
	Combats[Player] = nil
end

function functions:NewCharacter(Character)
	self.Character = Character or self.Player.Character or self.Player.CharacterAdded:Wait()
end

function functions:SetWalkSpeed()
	self.Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed = 16 * (Important.States[self.State.Value].WalkSpeed or 1)
end

function functions:SetState(State, Time, RemoveStamina)
	if RemoveStamina and RemoveStamina > self.Stamina.Value then return end
	local StateConfig = Important.States[State]
	local MyStateConfig = Important.States[self.State.Value]
	
	if 
		(StateConfig.Cancel and StateConfig.Priority <= math.floor(MyStateConfig.Priority)) or
		(StateConfig.Priority < 1)
	then return end
	
	if type(Time) == "boolean" or not Time then
		self.State.Value = Time and State or "Idling"
	else
		self.Stamina.Value -= (RemoveStamina or 0)
		self.State.Value = State
		
		ClockService(Time, function()
			self.State.Value = "Idling"
			self:SetWalkSpeed()
		end)
	end
	
	self:SetWalkSpeed()
	
	return State
end

Important.new = new

return Important
