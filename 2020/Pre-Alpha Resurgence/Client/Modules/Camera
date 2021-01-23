local camera = workspace.CurrentCamera
local inputService = game:GetService("UserInputService")
local inputHandler = require(script.Parent.Input)

local shiftLock = false
local pan = 0
local tilt = 0

local default = Enum.MouseBehavior.Default

local subject
local sens

camera.CameraType = Enum.CameraType.Scriptable

local function Setup(character)
	subject = character.PrimaryPart
	camera.CameraSubject = subject
	camera.CFrame = subject.CFrame
end

local function Remove()
	subject = nil
	camera.CameraSubject = nil
end

local function Callback(step)
	if not subject then return end
	
	sens = step / math.pi
	camera.CFrame = camera.CFrame:Lerp(CFrame.fromOrientation(tilt, pan, 0) + subject.Position - camera.CFrame.LookVector * 10, .25)
end

inputHandler.AddInput("Drag", {[Enum.UserInputType.MouseButton2] = Enum.UserInputState.None}, function(input, state)
	inputService.MouseBehavior = state == Enum.UserInputState.Begin and Enum.MouseBehavior.LockCurrentPosition or default
end)

inputHandler.AddInput("ToggleLock", {[Enum.KeyCode.Backquote] = Enum.UserInputState.Begin}, function(input)
	shiftLock = not shiftLock
	inputService.MouseBehavior = shiftLock and Enum.MouseBehavior.LockCenter or default
end, true)

inputService.InputChanged:Connect(function(input, gpe)
	if not gpe and input.UserInputType == Enum.UserInputType.MouseMovement and (inputService.MouseBehavior ~= default or shiftLock) then
		local delta = -input.Delta * .004
		pan += delta.X
		tilt = math.clamp(tilt + delta.Y, -1.2, .3)
		
		inputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

table.insert(require(game.ReplicatedStorage.Modules.Util.FrameBased).RenderStepped, 1, Callback)

return {Setup = Setup, Remove = Remove}
