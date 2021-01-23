local Player = game:GetService("Players").LocalPlayer
local Character

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService")
local Modules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes
local Main = ReplicatedStorage.Gui.Main

local Loaded = require(Modules.Gui.Util).Loaded
local RealInteract = require(Modules.Player.Character.Input).Interact
local NPC

local function Interact(_, state)
	if state == Enum.UserInputState.Begin and NPC and #Player.PlayerGui.Other:GetChildren() == 0 then
		RealInteract(NPC)
	end
end

local function ClosestNPC()
	local Dist = 15
	local MyPosition = Character.HumanoidRootPart.Position
	NPC = nil

	for _, CurrNPC in ipairs(workspace.NPCs:GetChildren()) do
		if (CurrNPC.HumanoidRootPart.Position - MyPosition).Magnitude < Dist then
			NPC = CurrNPC
			Dist = (CurrNPC.HumanoidRootPart.Position - MyPosition).Magnitude
		end
	end

	if NPC and not CAS:GetBoundActionInfo("Interact")[1] then
		CAS:BindAction("Interact", Interact, false, Enum.KeyCode.Q)
	elseif not NPC and CAS:GetBoundActionInfo("Interact")[1] then
		CAS:UnbindAction("Interact")
	end
end

return function()
	local Main = Main:Clone()

	if Player.PlayerGui:FindFirstChild("Main") then
		Player.PlayerGui.ChildAdded:Wait()
	end

	Main.Parent = Player.PlayerGui
	Loaded(Main.Finished)

	Character = Player.Character
	Character:WaitForChild("Humanoid").Changed:Connect(ClosestNPC)
end
