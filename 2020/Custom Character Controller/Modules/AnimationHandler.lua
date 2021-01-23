local Player = game.Players.LocalPlayer
local AnimationHandler = {Animations = {}}
local Animations = AnimationHandler.Animations

local function Setup(Character)
	if Animations[Character] then AnimationHandler.Remove(Character) end
	local AnimController = Player.Character:WaitForChild("AnimationController")
	Animations[Character] = {}
	
	for _, Animation in ipairs(Character.Animate:GetChildren()) do
		if not Animation:FindFirstChildWhichIsA("Animation") then continue end
		Animation = Animation:FindFirstChildWhichIsA("Animation")
		Animations[Character][Animation.Parent.Name] = AnimController:LoadAnimation(Animation)
	end
end

local function Remove(Character)
	for Key, Animation in ipairs(Animations[Character]) do
		Animation:Destroy()
		Animations[Character][Key] = nil
	end
	
	Animations[Character] = nil
end

AnimationHandler.Setup = Setup
AnimationHandler.Remove = Remove

return AnimationHandler
