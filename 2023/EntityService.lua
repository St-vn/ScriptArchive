--[[
	Server-side version of the EntityService
]]

export type Entity = {
	Player: Player?, -- Player, nil if the character is a NPC
	Model: Model, -- Character Model
	Humanoid: Humanoid?, -- Model's humanoid
	RootPart: BasePart?, -- Humanoid's root part
	_character: string, -- Entity's selected character
	_currentCharacter: string, -- Entity's current chosen character. If _character is different, it will change to it upon respawn

	_recoveryTime: number, -- Recovery time, when the current servertime > _recoveryTime, you can perform actions such as M1s, dashing, etc
	_lastHitTime: number, -- Last timestamp the player got hit at
	_ultimateBar: number,
	_states: {[string]: boolean}, -- States, used to determine the entity's current action
	_cooldowns: {[string]: number}, -- Cooldowns, used to determine when the next time the entity can perform the same action
	_replica: {[any]: any},
	
	_walkspeed: number, -- The humanoid's default WalkSpeed property
	_jumppower: number, -- The humanoid's default JumpPower property

	new: (object: Player | Model) -> (Entity), -- Entity Constructor, should only be used to create a new entity
	SetModel: (newModel: Model) -> (),

	GetStateEnabled: (states: {string} | string, enabled: boolean) -> boolean,
	SetStateEnabled: (states: {string} | string, enabled: boolean) -> (),
	GetRecoveryTime: (isATimestamp: number) -> (number),
	SetRecoveryTime: (recoveryTime: number, isATimestamp: boolean) -> (),

	Stun: (stunDuration: number, overrideStun: boolean?) -> (),
	Unstun: (cancelThread: boolean?) -> (),

	CanUseAbility: (abilityName: string) -> boolean,
	SetAbilityCooldown: (abilityName: string, cooldown: number, isATimestamp: boolean?) -> (),

	GetSelectedCharacter: () -> (string),
	SelectCharacter: (characterName: string) -> (),
	
	UltimateBarUpdated: signal.Signal,

	Reset: () -> (),
	Destroy: () -> ()
}

local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local gameModules = replicatedStorage:WaitForChild("Shared")
local services = serverScriptService.Server:WaitForChild("Services")

local replicaService = require(services.ReplicaService)
local signal = require(gameModules.Utility.RbxUtil.Signal)
local janitor = require(gameModules.Utility.Janitor)
local hitbox = require(gameModules.Handlers.Hitbox)

local remoteEvent = replicatedStorage:WaitForChild("RemoteEvent")
local spawns = workspace.Spawns:GetChildren()

local entities = {}

local entityClass = {}
entityClass.__index = entityClass

local debug_mode = false

local classToken = 0

local function ExtendPath(path: {string}, newDirectory: string): {string}
	local newPath = table.clone(path)
	table.insert(newPath, newDirectory)

	return newPath
end

local function Replicate(self: Entity, replica: {[any]: any}, referenceTable: {[any]: any}, path: {string})
	for key, value in referenceTable do
		local extended = ExtendPath(path, key)

		if typeof(value) == "table" then
			self[key] = {}

			Replicate(self[key], replica, value, extended)
		elseif typeof(value) == "number" or typeof(value) == "string" or typeof(value) == "boolean" then
			self[key] = value
		end
	end
end

function entityClass.new(object: Player | Model): Entity
	local player = if object:IsA("Player") then object else players:GetPlayerFromCharacter(object)
	local model = if object:IsA("Player") then player.Character else object
	
	local data = {
		_character = "Arthur",
		_walkspeed = 16,
		_jumppower = 50,
		_recoveryTime = workspace:GetServerTimeNow(),
		_lastHitTime = 0,
		_ultimateBar = 100,

		_cooldowns = {},
		_states = {
			_is_stunned = false,
			_is_attacking = false,
			_is_sprinting = false,
			_is_dashing = false,
			_is_blocking = false,
			_is_ragdolled = false,
		}
	}
	
	local replica = player and replicaService.NewReplica({
		ClassToken = replicaService.NewClassToken(tostring(classToken)),
		Replication = player or "All",
		Data = data
	})
	
	local self = setmetatable({
		Player = player,
		Model = model,
		UltimateBarUpdated = signal.new(),
		_replica = replica,
		_entityActions = janitor.new(),
	}, entityClass)
	
	data._currentCharacter = data._character
	Replicate(self, replica, data, {})
	
	if player then
		player:SetAttribute("ClassTokenId", classToken)
		classToken += 1
	end
	
	return self
end

function entityClass:_setValue( directory: {string}, newValue: any)
	if not replicaService or not self._replica then return end
	self._replica:SetValue(directory, newValue)
end

function entityClass:_setValues(directory: {string}, newValues: {[string]: any})
	if not replicaService or not self._replica then return end
	self._replica:SetValues(directory, newValues)
end

function entityClass:SetModel(newModel: Model)
	self.Model = newModel
	self.Humanoid = newModel:WaitForChild("Humanoid")
	self.RootPart = newModel:WaitForChild("HumanoidRootPart")
	
	task.defer(function()
		while newModel.Parent == workspace do
			newModel.Parent = workspace.Characters
			task.wait()
		end
	end)
end

function entityClass:GetStateEnabled(states: {string} | string, enabled: boolean): boolean
	enabled = if enabled ~= nil then enabled else true

	local list = if typeof(states) == "string" then {states} else states

	for _, stateName in list do
		local status = assert(self._states[`_is_{string.lower(stateName)}`] ~= nil, `Invalid {stateName} state!`)

		if self._states[`_is_{string.lower(stateName)}`] == enabled then
			return enabled
		end
	end

	return not enabled
end

function entityClass:SetStateEnabled(states: {string} | string, enabled: boolean)
	local list = if typeof(states) == "string" then {states} else states

	for _, stateName in list do
		assert(self._states[`_is_{string.lower(stateName)}`] ~= nil, "Invalid state!")

		self._states[`_is_{string.lower(stateName)}`] = enabled
		self:_setValue({"_states", `_is_{string.lower(stateName)}`}, enabled)
	end
end

function entityClass:IsRecovered(): boolean
	return self:GetRecoveryTime() <= 0
end

function entityClass:GetRecoveryTime(isATimestamp: boolean?): number
	return if isATimestamp then self._recoveryTime else self._recoveryTime - workspace:GetServerTimeNow()
end

function entityClass:SetRecoveryTime(recoveryTime: number, isATimestamp: boolean?)
	local recoveryTime = if isATimestamp then recoveryTime else workspace:GetServerTimeNow() + recoveryTime
	
	self._recoveryTime = recoveryTime
	self:_setValue({"_recoveryTime"}, recoveryTime)
end

function entityClass:Interrupt()
	self:SetStateEnabled({"Dashing", "Attacking", "Blocking", "Sprinting"}, false)
	
	self._entityActions:Cleanup()
	
	if self.Player then
		remoteEvent:FireClient(self.Player, "InterruptAction")
		remoteEvent:FireAllClients("ClearActiveEffects", self.Player)
	end
end

function entityClass:Stun(stunDuration: number, overrideStun: boolean?, interruptAction: boolean?)
	if self:GetStateEnabled("Stunned") and not overrideStun then return end
	
	if interruptAction then
		self:Interrupt()
	end
	
	self:SetStateEnabled("Stunned", true)
	self:SetRecoveryTime(stunDuration)
	
	if overrideStun and self._unstun_thread then
		task.cancel(self._unstun_thread)
		self._unstun_thread = nil
	end
	
	self.Humanoid.WalkSpeed = 0
	self.Humanoid.JumpPower = 0
	
	self._unstun_thread = task.delay(stunDuration, self.Unstun, self)
	
	if debug_mode then
		local highlight = Instance.new("Highlight")
		highlight.Name = "Stun Highlight"
		highlight.FillColor = Color3.new(0, 0, 1)
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.OutlineTransparency = 1
		highlight.Parent = self.Model
	end
end

function entityClass:Unstun(cancelThread: boolean?)
	if not self:GetStateEnabled("Stunned") then return end

	self:SetStateEnabled("Stunned", false)
	self:SetRecoveryTime(0)
	
	self.Humanoid.WalkSpeed = self._walkspeed * if self:GetStateEnabled("Sprinting") then 1.5 else 1
	self.Humanoid.JumpPower = self._jumppower
	
	if debug_mode and self.Model:FindFirstChild("Stun Highlight") then
		while self.Model:FindFirstChild("Stun Highlight") do
			self.Model:FindFirstChild("Stun Highlight"):Destroy()
		end
	end

	if self._unstun_thread and cancelThread then
		task.cancel(self._unstun_thread)

		self._unstun_thread = nil
	end
end

function entityClass:TakeDamage(damage: number, combat: boolean?)
	self.Humanoid.Health = math.clamp(self.Humanoid.Health - damage, if not self.Player then 0.01 else 0, self.Humanoid.MaxHealth)
	
	if combat then
		self._lastHitTime = workspace:GetServerTimeNow()
		self:_setValue({"_lastHitTime"}, workspace:GetServerTimeNow())
	end
	
	if self.Humanoid.Health <= 0.01 and not self.Player then
		self:SetStateEnabled("Ragdolled", true)
		
		task.delay(5, function()
			self.Model:PivotTo(spawns[math.random(#spawns)].CFrame + Vector3.new(0, 2.5, 0))
			self:Reset()
		end)
	end
end

function entityClass:IsInCombat()
	return (self._lastHitTime + 15) > workspace:GetServerTimeNow()
end

function entityClass:AdjustWalkSpeed()
	self.Humanoid.WalkSpeed = self._walkspeed * (if self:GetStateEnabled("Sprinting") then 1.5 else 1)
end

function entityClass:CanUseAbility(abilityName: string): boolean
	return self:IsRecovered() and (not self._cooldowns[abilityName] or self._cooldowns[abilityName] <= workspace:GetServerTimeNow())
end

function entityClass:SetAbilityCooldown(abilityName: string, cooldown: number, isATimestamp: boolean?)
	local cooldownTimestamp = if isATimestamp then cooldown else workspace:GetServerTimeNow() + cooldown
	
	self._cooldowns[abilityName] = cooldownTimestamp
	self:_setValue({"_cooldowns", abilityName}, cooldownTimestamp)
end

function entityClass:GetSelectedCharacter(): string
	return self._character
end

function entityClass:GetCurrentCharacter(): string
	return self._currentCharacter
end

function entityClass:SelectCharacter(characterName: string)
	self._character = characterName
	self:_setValue({"_character"}, characterName)
end

function entityClass:GetUltimateBar(): number
	return self._ultimateBar
end

function entityClass:UpdateUltimateBar(n: number, setTo: boolean?)
	self._ultimateBar = math.clamp(if setTo then n else self._ultimateBar + n, 0, 100)
	self.UltimateBarUpdated:Fire(self._ultimateBar)
	self:_setValue({"_ultimateBar"}, self._ultimateBar)
end

function entityClass:SpawnMeleeHitbox(...)
	if self:GetStateEnabled("Stunned") then return end
	
	local hitboxObject = hitbox.SpawnHitbox(...)
	self._entityActions:Add(hitboxObject, "Destroy")

	return hitboxObject
end

function entityClass:Destroy()
	self._replica:Destroy()
	self._entityActions:Destroy()
	
	table.clear(self)
end

function entityClass:Reset()
	if self.Player then
		self:SetModel(self.Player.Character)
	else
		self.Humanoid.Health = self.Humanoid.MaxHealth
	end
	
	self._currentCharacter = self._character
	
	local data = {
		_recoveryTime = workspace:GetServerTimeNow(),
		_walkspeed = 16,
		_jumppower = 50,
		_lastHitTime = 0,

		_cooldowns = {},

		_states = {
			_is_stunned = false,
			_is_sprinting = false,
			_is_attacking = false,
			_is_dashing = false,
			_is_blocking = false,
			_is_ragdolled = false,
		}
	}
	
	self:_setValues({}, data)
	Replicate(self, self._replica, data, {})
end

return {
	CreateEntity = function(object: Player | Model, ...: any): Entity
		local player = if object:IsA("Player") then object else players:GetPlayerFromCharacter(object)
		local model = if object:IsA("Player") then player.Character else object
		local entity = entities[player or model]

		assert(not entity, "Entity already exists, use FindEntity instead!")

		local entity = entityClass.new(object, ...)
		entities[player or model] = entity

		return entities[player or model]
	end,

	FindEntity = function(object: Player | Model): Entity
		local player = if object:IsA("Player") then object else players:GetPlayerFromCharacter(object)
		local model = if object:IsA("Player") then player.Character else object
		local entity = entities[player or model]

		assert(entity, "Invalid or nil Entity!")

		return entity
	end,

	DestroyEntity = function(object: Player | Model)
		local player = if object:IsA("Player") then object else players:GetPlayerFromCharacter(object)
		local model = if object:IsA("Player") then player.Character else object
		local entity = entities[player or model]

		assert(entity, "Invalid or nil Entity!")
		entities[player or model] = entity:Destroy()
	end,
}
