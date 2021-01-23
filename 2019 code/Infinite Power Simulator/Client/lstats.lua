local PlayerAdded = false
local UIS = game:GetService("UserInputService")

while wait() do
	for i,v in pairs(script.Parent.Background.Players:GetChildren()) do
		if v.Name ~= "PlayerName" then
			v:Destroy()
		end
	end
	for i,v in pairs(game.Players:GetChildren()) do
		if script.Parent.Background.Players:FindFirstChild(v.Name) == false then return end
		local thing = script.Parent.Background.Players:FindFirstChild(v.Name)
		local name = script.Parent.Background.Players.PlayerName:Clone()
		name.Text = v.Name
		name.Parent = script.Parent.Background.Players
		name.Name = v.Name
		local Debris = v.leaderstats.Debris
		local DebrisTXT = name.Wipeouts
		if v.leaderstats.Debris.Value >= 1000 and v.leaderstats.Debris.Value < 1000000 then
			local number = math.floor(Debris.Value/100)
			DebrisTXT.Text = number/10 .."K"
		elseif v.leaderstats.Debris.Value >= 1000000 and v.leaderstats.Debris.Value < 1000000000 then
			local number = math.floor(v.leaderstats.Debris.Value/100000)
			DebrisTXT.Text = number/10 .."M"
		elseif v.leaderstats.Debris.Value >= 1000000000 and v.leaderstats.Debris.Value < 1000000000000 then
			local number = math.floor(v.leaderstats.Debris.Value/100000000)
			DebrisTXT.Text = number/10 .."B"
		elseif v.leaderstats.Debris.Value >= 1000000000000 and v.leaderstats.Debris.Value < 1000000000000000 then
			local number = math.floor(v.leaderstats.Debris.Value/100000000000)
			DebrisTXT.Text = number/10 .."T"
		elseif v.leaderstats.Debris.Value >= 1000000000000000 and v.leaderstats.Debris.Value < 1000000000000000000 then
			local number = math.floor(v.leaderstats.Debris.Value/100000000000000)
			DebrisTXT.Text = number/10 .."P"
		elseif v.leaderstats.Debris.Value >= 1000000000000000000 and v.leaderstats.Debris.Value < 1000000000000000000000 then
			local number = math.floor(v.leaderstats.Debris.Value/100000000000000000)
			DebrisTXT.Text = number/10 .."E"
		elseif v.leaderstats.Debris.Value >= 1000000000000000000000 and v.leaderstats.Debris.Value < 1000000000000000000000000 then
			local number = math.floor(v.leaderstats.Debris.Value/100000000000000000000)
			DebrisTXT.Text = number/10 .."Z"
		elseif v.leaderstats.Debris.Value >= 1000000000000000000000 and v.leaderstats.Debris.Value < 1000000000000000000000000 then
			local number = math.floor(v.leaderstats.Debris.Value/100000000000000000000)
			DebrisTXT.Text = number/10 .."Y"
		else
			DebrisTXT.Text = math.floor(v.leaderstats.Debris.Value)
		end
		if v.leaderstats.Coins.Value >= 1000 and v.leaderstats.Coins.Value < 1000000 then
			local number = math.floor(v.leaderstats.Coins.Value/100)
			name.Level.Text = number/10 .."K"
		elseif v.leaderstats.Coins.Value >= 1000000 and v.leaderstats.Coins.Value < 1000000000 then
			local number = math.floor(v.leaderstats.Coins.Value/100000)
			name.Level.Text = number/10 .."M"
		elseif v.leaderstats.Coins.Value >= 1000000000 and v.leaderstats.Coins.Value < 1000000000000 then
			local number = math.floor(v.leaderstats.Coins.Value/100000000)
			name.Level.Text = number/10 .."B"
		elseif v.leaderstats.Coins.Value >= 1000000000000 and v.leaderstats.Coins.Value < 1000000000000000 then
			local number = math.floor(v.leaderstats.Coins.Value/100000000000)
			name.Level.Text = number/10 .."T"
		elseif v.leaderstats.Coins.Value >= 1000000000000000 and v.leaderstats.Coins.Value < 1000000000000000000 then
			local number = math.floor(v.leaderstats.Coins.Value/100000000000000)
			name.Level.Text = number/10 .."P"
		elseif v.leaderstats.Coins.Value >= 1000000000000000000 and v.leaderstats.Coins.Value < 1000000000000000000000 then
			local number = math.floor(v.leaderstats.Coins.Value/100000000000000000)
			name.Level.Text = number/10 .."E"
		elseif v.leaderstats.Coins.Value >= 1000000000000000000000 and v.leaderstats.Debris.Value < 1000000000000000000000000 then
			local number = math.floor(v.leaderstats.Coins.Value/100000000000000000000)
			name.Level.Text = number/10 .."Z"
		elseif v.leaderstats.Coins.Value >= 1000000000000000000000 and v.leaderstats.Coins.Value < 1000000000000000000000000 then
			local number = math.floor(v.leaderstats.Coins.Value/100000000000000000000)
			name.Level.Text = number/10 .."Y"
		else
			name.Level.Text = math.floor(v.leaderstats.Coins.Value)
		end
		name.Visible = true
		name.Position = UDim2.new(0,5,0,10 + (i * 35-(35)))
		name.Parent.CanvasSize = UDim2.new(0,5,0,(i * 35))
		if thing then
			thing:Destroy()
		end
		UIS.InputBegan:Connect(function(I)
			if I.KeyCode == Enum.KeyCode.LeftBracket then
				if script.Parent.Background.Visible == false then
					script.Parent.Background.Visible = true
				else
					script.Parent.Background.Visible = false
				end
			end
		end)
	end
end
