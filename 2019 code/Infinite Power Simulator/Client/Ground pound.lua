local enabled = script:WaitForChild("Enabled").Value
Player = script.Parent.Parent
local uis = game:GetService("UserInputService")
local destruction_multiplier = 0.75

uis.InputBegan:Connect(function(i)
	if script.Key.Value == nil then return end
		if i.KeyCode == Enum.KeyCode[script.Key.Value] then
			if not enabled then return end
			if Player.PlayerGui.KeyBindsDisplay.PowersActive.Activate.Text == "Yes" then
			if tonumber(Player.PlayerGui.KeyBindsDisplay.Background[script.Name].CooldownFrame.Time.Text) > 0 then return end
			enabled = false
			Player.PlayerGui.KeyBindsDisplay.Background[script.Name].CooldownFrame.Visible = true
			Player.Character.HumanoidRootPart.Anchored = true
			for i = 1,100,1 do
				wait()
				Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0,.45,0)
			end
			wait(.25)
			Player.Character.HumanoidRootPart.Anchored = false
			local anim = Player.Character.Humanoid:LoadAnimation(script.Animation)
			anim:Play()
			wait(0.6)
			local explosion = Instance.new("Explosion", Player.Character)
			explosion.Position = Vector3.new(explosion.Parent.HumanoidRootPart.Position.X, explosion.Parent.HumanoidRootPart.Position.Y - 50, explosion.Parent.HumanoidRootPart.Position.Z)
			explosion.BlastRadius = 80
			explosion.BlastPressure = 750000
			explosion.Hit:Connect(function(hit)
				if hit.Locked == false then
					hit.Anchored = false
					if hit:FindFirstChild("Damage") then
					else
						game.ReplicatedStorage.GameRemotes.PowerHit:FireServer(hit,destruction_multiplier)
					end
				end
			end)
			wait(5)
			enabled = true
			end
		end
end)
