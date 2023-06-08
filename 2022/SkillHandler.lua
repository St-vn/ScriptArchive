-- Server variant

local formulas = require(game:GetService("ReplicatedStorage").Common.Formulas)
local manaHandler = require(game:GetService("ServerScriptService").Server.Players.ManaHandler)
local config = require(game:GetService("ReplicatedStorage").Common.config)

local remotes = game:GetService("ReplicatedStorage").Remotes
local assignHotkey = remotes.AssignHotkey
local clearHotkey = remotes.ClearHotkey
local activate = remotes.ActivateSkill
local visuals = remotes.SkillVisuals
local levelUpSkill = remotes.LevelUpSkill

local skillHandler = {}
skillHandler.__index = skillHandler

local handlers = {}

local function FindEntity(entity)
    return handlers[entity]
end

function skillHandler.new(entity)
    local handler = setmetatable({
        Entity = entity,
        Cooldowns = {}
    }, skillHandler)

    handlers[entity.Model] = handler

    return handler
end

function skillHandler:GetSkillLevel(skillName)
    return self.Entity:GetPlayer().Skills[skillName]:GetAttribute("SkillLevel") -- path to skill level, currently non existent
end

function skillHandler:UpgradeSkill(skillName, increment)
    local player = self.Entity:GetPlayer()
    local skill = player.Skills[skillName]

    skill:SetAttribute("SkillLevel", skill:GetAttribute("SkillLevel") + increment)-- path to skill level, currently non existent
    player:SetAttribute("SkillPoints", player:GetAttribute("SkillPoints") - increment)-- path to skill level, currently non existent
end

function skillHandler:GetActivationTime(skillName) -- the next time the skill can be activated
    if not self.Cooldowns[skillName] then
        self:SetActivationTime(skillName, 0)
    end

    return self.Cooldowns[skillName]
end

function skillHandler:SetActivationTime(skillName, activationTime) -- the next time the skill can be activated
    self.Cooldowns[skillName] = if activationTime then activationTime else workspace:GetServerTimeNow() + config.Skills[skillName].CooldownLength
end

function skillHandler:CanActivate(skillName)
    return (self:GetSkillLevel(skillName) >= 1)
        and (self.Entity:GetPlayer():GetAttribute("Mana") - formulas.CalculateManaUse(1) >= 1000)
        and (self.Entity:HasRecovered())
        and (self:GetActivationTime(skillName) <= workspace:GetServerTimeNow())
end

function skillHandler:ActivateSkill(skillName, serverTime, ...)
    local player = self.Entity:GetPlayer()
    manaHandler.UseMana(player, config.Skills[skillName].ManaCost)

    self:SetActivationTime(skillName)
    self.Entity:SetRecovery(config.Skills[skillName].RecoveryTime, 2)

    local results = require(script[skillName]).Activate(self.Entity, serverTime, ...)
    visuals:FireAllClients(player, skillName, serverTime, results, ...)
end

function skillHandler:AssignHotkey(slot, skillName)
    self.Entity:GetPlayer().Hotkeys["Slot".. slot]:SetAttribute("SkillName", skillName)
end

function skillHandler:ClearHotkey(slot)
    self.Entity:GetPlayer().Hotkeys["Slot".. slot]:SetAttribute("SkillName", "")
end

function skillHandler:Destroy()
    handlers[self.Entity.Model] = nil
end

activate.OnServerEvent:Connect(function(player, skillName, ...)
    local handler = FindEntity(player.Character)
    local serverTime = workspace:GetServerTimeNow()

    if handler:CanActivate(skillName) then
        handler:ActivateSkill(skillName, serverTime, ...)
    end
end)

levelUpSkill.OnServerEvent:Connect(function(player, skillName, increment)
    local handler = FindEntity(player.Character)

    if player:GetAttribute("SkillPoints") >= increment then
        handler:UpgradeSkill(skillName, increment)
    end
end)

return skillHandler
