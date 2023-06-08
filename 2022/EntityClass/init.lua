local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")

local jobHandler = require(game:GetService("ReplicatedStorage").Common.JobUtil)
local hitbox = require(game:GetService("ReplicatedStorage").Common.HitboxClass.HitCast)
local effectHandler = require(script.Effects)
local skillHandler = nil

if runService:IsServer() then
	skillHandler = require(game:GetService("ServerStorage").Common.Skills)
else
	skillHandler = require(game:GetService("ReplicatedStorage").Common.Skills)
end

local characters = {}

local entity = {}
entity.__index = entity

local serverAttributes = {
	InvincibleFrame = false,
	RecoveryTime = 0,
}

local function SetupServer(character)
	for name, value in serverAttributes do
		character:SetAttribute(name, value)
	end
end

local function SetupClient(character)
	--[[for name, value in serverAttributes do -- need to think of something
		character:GetAttribute(name, value)
	end]]
end

local function AddStats(character, playerStats)
	for name, value in playerStats do
		character:SetAttribute(name, value)
	end
end

function entity.new(character: Model)
	if characters[character] then return characters[character] end
	
	if runService:IsServer() then
		SetupServer(character)
	else
		SetupClient(character)
	end
	
	AddStats(character, {
		Attack = 10,
		Defense = 2
	})
	
	characters[character] = setmetatable({
		Player = player or game:GetService("Players"):GetPlayerFromCharacter(character),
		Model = character,
		Root = character.PrimaryPart,
		Humanoid = character:FindFirstChildWhichIsA("Humanoid"),
		Name = character.Name,
		Hitbox = nil,
		
		Frozen = false,
		CurrentActions = {},
	}, entity)
	
	characters[character].EffectHandler = effectHandler.new(characters[character])
	characters[character].Skills = skillHandler.new(characters[character])
	
	return characters[character]
end

function entity.FindCharacter(identification: Model)
	return characters[identification]
end

function entity.GetCharacterFromPlayer(identification: Player)
	return characters[identification.Character]
end

function entity:GetPlayer()
	return self.Player
end

function entity:SetRecovery(duration: number, priority: number)
	--assert(runService:IsServer(), "Cannot set recovery from the client!")
	
	if not self:HasRecovered() and priority <= 0 then return end
	
	priority = priority or 1
	
	self.Model:SetAttribute("RecoveryTime", workspace:GetServerTimeNow() + duration)
	
	if priority > #self.CurrentActions then
		self:Freeze()
		
		table.insert(self.CurrentActions, priority, task.delay(duration, self.Recover, self))
	end
end

function entity:GetRecovery()
	return self.Model:GetAttribute("RecoveryTime")
end

function entity:HasRecovered()
	return self:GetRecovery() <= workspace:GetServerTimeNow()
end

function entity:Recover(priority)
	if priority and self.CurrentActions[priority] then
		task.cancel(self.CurrentActions[priority])
		
		table.remove(self.CurrentActions, priority)
	else
		table.clear(self.CurrentActions)
	end
	
	if self:IsFrozen() then
		self:Unfreeze()
	end
end

function entity:Stun(duration: number)
	--assert(runService:IsServer(), "Cannot call Stun from the client!")
	
	self:SetRecovery(duration, 4)
end

function entity:Unstun()
	self:Unfreeze()
end

function entity:Freeze()
	self.Humanoid.WalkSpeed = 0
	self.Humanoid.JumpPower = 0
	
	self.Frozen = true
end

function entity:Unfreeze()
	if not self.Humanoid then return end
	
	self.Humanoid.WalkSpeed = 16
	self.Humanoid.JumpPower = 50
	
	self.Frozen = false
end

function entity:IsFrozen()
	return self.Frozen
end

function entity:ToggleBlock(block)
	self.Model:SetAttribute("Blocking", block)
end

function entity:IsBlocking()
	return self.Model:GetAttribute("Blocking")
end

function entity:ToggleIFrames(toggle: boolean)
	assert(runService:IsServer(), "Cannot toggle IFrames from the client!")
	
	self.Model:SetAttribute("InvincibleFrame", toggle)
end

function entity:PerformJob(jobs: {}, target: string, ...)
	jobHandler(jobs, target, ...)
end

function entity:CreateHitbox(weapon)
	self.Hitbox = hitbox.new(weapon, true)
	
	return self.Hitbox
end

function entity:DestroyHitbox(weapon)
	if self.Hitbox then
		self.Hitbox = self.Hitbox:Destroy()
	end
end

function entity:Destroy()
	self:DestroyHitbox()
	self.Skills:Destroy()
	self.EffectHandler:Destroy()
	characters[self.Model] = nil
	
	table.foreach(self, function(key) -- too lazy to use for loop
		self[key] = nil
	end)
end

return entity
