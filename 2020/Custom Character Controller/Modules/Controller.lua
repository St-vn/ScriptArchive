local Player = game.Players.LocalPlayer
local cas = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local Heartbeat = game:GetService("RunService").Stepped

local Camera = workspace.CurrentCamera
local Gui
local Base
local Draggable

local Origin
local MousePosition
local Dragging

local AbsOrigin
local Vector36 = Vector2.new(0, -36)
local Vector0 = Vector3.new()

local Params = RaycastParams.new()
Params.FilterDescendantsInstances = {Player.Character}
Params.FilterType = Enum.RaycastFilterType.Blacklist

local module = {
	LocalMoveDir = Vector3.new(),
	WalkSpeed = 16,
	JumpPower = 50,
	HipHeight = Vector3.new(0, 2.51),
	YPosition = 0
}

local Dict = {
	[Enum.KeyCode.W] = Vector3.new(1, 0, 0),
	[Enum.KeyCode.A] = Vector3.new(0, 0, -1),
	[Enum.KeyCode.S] = Vector3.new(-1, 0, 0),
	[Enum.KeyCode.D] = Vector3.new(0, 0, 1)
}

local function GetMoveDirection()
	local Move = module.LocalMoveDir
	local direction = (
		Vector0
			+ (math.floor(Move.X * 10) / 10 ~= 0 and Camera.CFrame.LookVector * Move.X or Vector0)
			+ (math.floor(Move.Z * 10) / 10 ~= 0 and Camera.CFrame.RightVector * Move.Z or Vector0)
	)
	
	local magnitude = direction.Magnitude
	local x,y,z = direction.X == 0 and 0 or direction.X / magnitude,direction.Y == 0 and 0 or direction.Y / magnitude,direction.Z == 0 and 0 or direction.Z / magnitude
	
	return Vector3.new(x, y, z)
end

local function clear()
	module.LocalMoveDir = Vector0
end

cas:BindAction("Move", function(_, state, input)
	if input.UserInputType == Enum.UserInputType.None or state == Enum.UserInputState.Cancel then return end
	local n = (input.UserInputState == Enum.UserInputState.Begin and 1 or -1)
	
	module.LocalMoveDir += Dict[input.KeyCode] * n
end, false, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)

local function Drag(newMousePosition)
	local BaseRadius = Base.AbsoluteSize.X / 2
	local delta = newMousePosition - MousePosition
	local new = Draggable.AbsolutePosition + delta
	local yes = (AbsOrigin - new).Magnitude > BaseRadius and AbsOrigin + ((new - AbsOrigin).Unit * BaseRadius) or new
	
	Draggable.Position = UDim2.fromOffset(yes.X, yes.Y)
	
	yes = (new - AbsOrigin).Unit
	module.LocalMoveDir = Vector3.new(yes.X, 0, yes.Y)
	
	MousePosition = newMousePosition
end

local function SetupTouch(TouchGui)
	TouchGui.Parent = Player.PlayerGui
	
	Gui = TouchGui
	Base = Gui.Joystick.Base
	Draggable = Base.Drag
	Origin = Draggable.Position
	AbsOrigin = Draggable.AbsolutePosition
	
	Draggable.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			MousePosition = UIS:GetMouseLocation() + Vector36
			Draggable.Position = UDim2.fromOffset(AbsOrigin.X, AbsOrigin.Y)
			Draggable.Size = UDim2.fromOffset(Draggable.AbsoluteSize.X, Draggable.AbsoluteSize.Y)
			Draggable.Parent = Gui
			
			Dragging = UIS.InputChanged:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch then
					Drag(UIS:GetMouseLocation() + Vector36)
				end
			end)
		end
	end)
	
	Draggable.InputEnded:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
			Dragging:Disconnect()
			Draggable.Parent = Base
			Draggable.Position = Origin
			module.LocalMoveDir = module.Vector0
		end
	end)
end

local function CalculateHipHeight()
	for _, Attachment in ipairs(Player.Character.HumanoidRootPart:GetChildren()) do
		if not Attachment:IsA("Attachment") or Attachment.Name ~= "Hip" then continue end
		
		local Results = workspace:Raycast(Attachment.WorldPosition, -module.HipHeight, Params)
		
		if Results then
			return Results.Position.Y + module.HipHeight.Y - Attachment.Position.Y 
		end
	end
end

local function WaitForLand()
	Heartbeat:Wait()
	module.YPosition = Player.Character.HumanoidRootPart.Position.Y
	
	if Player.Character.HumanoidRootPart.Position.Y >= module.YPosition then return end
	
	local Thread = coroutine.running()
	local Goal = time() + .1
	
	module.LandConn = Heartbeat:Connect(function()
		local Current = Player.Character.HumanoidRootPart.Position.Y
		print(Current - module.YPosition, not not CalculateHipHeight())
		if CalculateHipHeight() and Current - module.YPosition <= -0.25 and Current <= module.YPosition and Goal <= time() then
			coroutine.resume(Thread)
		end
		
		module.YPosition = Current
	end)

	coroutine.yield()
end

UIS.TextBoxFocusReleased:Connect(clear);
UIS.WindowFocusReleased:Connect(clear);

module.WaitForLand = WaitForLand
module.GetMoveDirection = GetMoveDirection
module.SetupTouch = SetupTouch
module.CalculateHipHeight = CalculateHipHeight

return module
