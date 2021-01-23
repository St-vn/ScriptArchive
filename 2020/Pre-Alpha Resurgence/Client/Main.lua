-- important code

game.StarterGui:SetCoreGuiEnabled("Backpack", false)

local player = game.Players.LocalPlayer
local modules = game.ReplicatedStorage.Modules
local remotes = game.ReplicatedStorage.Remotes

if player.PlayerGui:FindFirstChild("LoadingScreen") then
	player.PlayerGui.LoadingScreen.Background:GetPropertyChangedSignal("Visible"):Wait()
end

require(modules.Gui.MainMenuHandler)
require(modules.Player.Lighting)

local characterHandler = require(modules.Player.Character)
--local characterAnimations = require(modules.Combat.AnimationHandler).Animations

characterHandler.Added(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(characterHandler.Added)
player.CharacterRemoving:Connect(characterHandler.Removing)
remotes.PlayerLoaded.OnClientEvent:Connect(require(modules.Player.Character.UI))
remotes.Client.DamageIndicator.OnClientEvent:Connect(require(modules.Combat.DamageIndicator))
remotes.Notification.OnClientEvent:Connect(require(modules.Gui.Util).NotificationPop)

player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):Destroy()

--[[game.ReplicatedStorage.Remotes.AnimEvent.OnClientEvent:Connect(function(Character, Animation, Action) I was gonna use this eventually to play mobs' anim on the client
	local AnimationTrack = CharacterAnimations[Character][Animation]
	AnimationTrack[Action](AnimationTrack) --AnimationTrack:Play()
end)]]
