local playerService = game:GetService("Players")

playerService.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		-- humanoid.BreakJointsOnDeath = false
		
		local animator = Instance.new("Animator")
		animator.Parent = humanoid
	end)
end)