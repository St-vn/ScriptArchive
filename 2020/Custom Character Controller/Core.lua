local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local UIS = game:GetService("UserInputService")
local RenderStep = game:GetService("RunService").RenderStepped
local angles, lookAt, new = CFrame.Angles, CFrame.lookAt, CFrame.new
local Vector3new = Vector3.new
local MyController = require(game.ReplicatedStorage.Modules.Controller)
local Attach

local HRP = Character:WaitForChild("HumanoidRootPart")
local TouchGui = game.ReplicatedStorage.GUI.TouchGui
local Camera = workspace.Camera
local AnimHandler = require(game.ReplicatedStorage.Modules.AnimationHandler)

local behavior = Enum.MouseBehavior.LockCenter
local Xrot, Yrot = 0, 0
local Vector0 = Vector3new()
local pie = math.pi
local Sensitivity
local Mobile = UIS.TouchEnabled
local dragging = false
local Jumping = false

--UIS.MouseIconEnabled = false

local function CharacterSetup(newCharacter)
	newCharacter:WaitForChild("AnimationController"):WaitForChild("Animator")
	AnimHandler.Setup(newCharacter)
	Character = newCharacter
	HRP = Character:WaitForChild("HumanoidRootPart")
	
	Attach = (workspace.Terrain:FindFirstChild(Player.Name) and not workspace.Terrain:FindFirstChild(Player.Name):Destroy() and Instance.new("Attachment"))
	or Instance.new("Attachment")
	Attach.Name = Player.Name
	Attach.Parent = workspace.Terrain
	HRP.AlignOrientation.Attachment1 = Attach
	
	if not UIS.KeyboardEnabled and not UIS.MouseEnabled and not UIS.GamepadEnabled and UIS.TouchEnabled then
		MyController.SetupTouch(TouchGui:Clone())
	end
end

CharacterSetup(Character)
Player.CharacterAdded:Connect(CharacterSetup)

UIS.InputBegan:Connect(function(Input, GPE)
	if GPE or Input.KeyCode ~= Enum.KeyCode.Space or Jumping then return end
	
	Jumping = true
	
	while UIS:IsKeyDown(Enum.KeyCode.Space) do
		if not MyController.CalculateHipHeight() then RenderStep:Wait() continue end
		
		AnimHandler.Animations[Character].jump:Play()
		HRP.Velocity += Vector3new(0, MyController.JumpPower, 0)
		
		MyController.WaitForLand()
		MyController.LandConn = MyController.LandConn and MyController.LandConn:Disconnect() or nil
		
		AnimHandler.Animations[Character].jump:Stop()
	end
	
	Jumping = false
end)

UIS.InputChanged:Connect(function(Input, GPE)
	dragging = (
		Mobile and Input.UserInputType == Enum.UserInputType.Touch or
		UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	)
	
	if GPE or not dragging then return end
	
	local delta = -Input.Delta
	Yrot = math.clamp(Yrot + delta.Y * Sensitivity, -1.5, .25)
	Xrot += delta.X * Sensitivity
end)

game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
	local MoveDirection = MyController.GetMoveDirection()
	local MyAnimations = AnimHandler.Animations[Character]
	local Height = MyController.CalculateHipHeight()
	local PlayerPosition = Height and Vector3new(HRP.Position.X, Height, HRP.Position.Z) or HRP.Position
	--uis.MouseBehavior = behavior
	
	Sensitivity = DeltaTime / math.pi
	
	Attach.Orientation = MoveDirection ~= Vector0 and Vector3new(
		0,
		math.deg(math.atan2(-MoveDirection.X, -MoveDirection.Z)),
		0
	) or HRP.Orientation
	
	if MyController.CalculateHipHeight() and not Jumping then
		HRP.Velocity = Vector0
	end
	
	if Height then
		HRP.CFrame = lookAt(PlayerPosition, PlayerPosition + HRP.CFrame.LookVector)
	end
	
	Camera.CFrame = angles(0, Xrot, 0) * angles(Yrot, 0, 0) * new(0, 0, 10) + PlayerPosition
	
	if MoveDirection == Vector0 then MyAnimations.run:Stop() return end
	HRP.CFrame += MoveDirection * MyController.WalkSpeed * DeltaTime
	
	if not MyAnimations.run.IsPlaying then
		MyAnimations.run:Play(nil, nil, MyController.WalkSpeed / 16)
	end
end)
