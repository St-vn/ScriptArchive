local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFolder = ReplicatedStorage:WaitForChild("GameRemotes")

RemoteFolder:WaitForChild("DamageEvent").OnServerEvent:Connect(function(plr,hit,enemy)
	require(script.DamageEvent).Damage(plr,enemy)
end)

RemoteFolder:WaitForChild("PowerHit").OnServerEvent:Connect(function(plr,hit,Multiplier)
	require(script.PowerHit).Damage(plr,hit,Multiplier)
end)

RemoteFolder:WaitForChild("P2WCEvent").OnServerEvent:Connect(function(plr,currency,amount)
	require(script.P2WCEvent).Purchase(plr)
end)

RemoteFolder:WaitForChild("ChangePowersShop").OnServerEvent:Connect(function(plr,side,shop)
	require(script.ShopItemEvent).ChangePower(plr,shop,side)
end)

RemoteFolder:WaitForChild("ChangeSpecial").OnServerEvent:Connect(function(plr,side,shop)
	require(script.ShopItemEvent).ChangeSpecial(plr,shop,side)
end)

RemoteFolder:WaitForChild("BuyPowersEvent").OnServerEvent:Connect(function(plr,item,cost,Type)
	require(script.BuyEvent).PurchasePower(plr,cost,Type,item)
end)

RemoteFolder:WaitForChild("ChangeWeaponsShop").OnServerEvent:Connect(function(plr,side,shop)
	require(script.ShopItemEvent).ChangeWeapon(plr,shop,side)
end)

RemoteFolder:WaitForChild("BuyWeaponsEvent").OnServerEvent:Connect(function(plr,item,cost,Type)
	require(script.BuyEvent).PurchaseWeapon(plr,cost,Type,item)
end)

RemoteFolder:WaitForChild("BuyCaseEvent").OnServerEvent:Connect(function(plr,item,cost,Type)
	require(script.BuyEvent).PurchaseCase(plr,cost,Type,item)
end)

RemoteFolder:WaitForChild("BuySpecialEvent").OnServerEvent:Connect(function(plr,item,cost,Type)
	require(script.BuyEvent).PurchaseSpecial(plr,cost,Type,item)
end)

RemoteFolder:WaitForChild("OpenCaseEvent").OnServerEvent:Connect(function(plr,item,cost,Type,thing)
	require(script.OpenCaseEvent).Open(plr,cost,Type,thing,item)
end)

RemoteFolder:WaitForChild("DailyEvent").OnServerEvent:Connect(function(plr,hours,reward)
	plr.leaderstats.Coins.Value = plr.leaderstats.Coins.Value + reward
end)

RemoteFolder:WaitForChild("SkinEvent").OnServerEvent:Connect(function(plr,item,cat)
	require(script.SkinEvent).ChangeSkin(plr,item,cat)
end)

RemoteFolder:WaitForChild("GiveEvent").OnServerEvent:Connect(function(plr,coins,debris)
	local P = game.ReplicatedStorage.Giver:Clone()
	P.CFrame = CFrame.new(plr.Character.HumanoidRootPart.CFrame.X + math.random(-5,5),plr.Character.HumanoidRootPart.CFrame.Y + math.random(5,10),plr.Character.HumanoidRootPart.CFrame.Z + math.random(-5,5))
	P.Parent = workspace
	P.Script.Disabled = false
	P.Script.Coins.Value = coins
	P.Script.Debris.Value = debris
end)
