local AttackSetup = require(game.ReplicatedStorage.Modules.Combat.AttackHandler)
local SetupAnims = require(game.ReplicatedStorage.Modules.Combat.AnimationHandler)
local inputHandler = require(script.Input)
local camera = require(script.Camera)

local function Added(newCharacter)
	AttackSetup(newCharacter, SetupAnims(newCharacter))
	camera.Setup(newCharacter)
end
	
local function Delete()
	inputHandler.RemoveInput("Combat")
	camera.Remove()
end

return {Added = Added, Removing = Delete}
