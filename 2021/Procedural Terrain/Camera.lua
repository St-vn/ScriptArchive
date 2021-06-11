local Camera        = workspace.CurrentCamera
local ActionService = game:GetService("ContextActionService")
local Pan, Tilt     = 0, 0
local MoveDirection = Vector3.new(0, 0, 0)
local EmptyVector   = Vector3.new(0, 0, 0)
local Orientation   = CFrame.fromOrientation(0, 0, 0)

local KeyMap = {
    [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
    [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
    [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
    [Enum.KeyCode.D] = Vector3.new(1, 0, 0)
}

ActionService:BindAction("Drag", function(_, _, Input)
    local Delta = -Input.Delta * 0.003

    Tilt = math.clamp(Tilt + Delta.Y, -1.5, 1.5)
    Pan += Delta.X

    Orientation = CFrame.fromOrientation(Tilt, Pan, 0)
end, false, Enum.UserInputType.MouseMovement)

ActionService:BindAction("Move", function(_, State, Input)
    if KeyMap[Input.KeyCode] then
        MoveDirection += KeyMap[Input.KeyCode] * (State == Enum.UserInputState.Begin and 1 or -1)
    end
end, false, Enum.KeyCode.W, Enum.KeyCode.S, Enum.KeyCode.A, Enum.KeyCode.D)

game:GetService("RunService").RenderStepped:Connect(function(Step)
    Camera.CFrame = Camera.CFrame:Lerp(
        Orientation + Camera.CFrame.Position + (MoveDirection == EmptyVector and EmptyVector or Camera.CFrame:VectorToWorldSpace(MoveDirection).Unit * 512 * Step),
        1 - math.cos((.6 * math.pi) / 2)
    )

    Camera.Focus = Camera.CFrame
end)

return Camera