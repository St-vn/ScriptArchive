local datastore = game:GetService("DataStoreService"):GetDataStore("GameStore")
serv = game:GetService("DataStoreService")
local Stats = serv:GetDataStore("StatsDS")
local Tools = serv:GetDataStore("ToolDS")
local MS = game:GetService("MarketplaceService")
local Hours = 24

LoadData = function(plr)
	pcall(function()
		-- Tools
		local ActualTools = {}
		local ToolStorage = game.ReplicatedStorage.Items.WeaponFolder
		if (Tools:GetAsync(plr.UserId)) then
			for _,v in pairs(Tools:GetAsync(plr.UserId)) do
				print(v)
				if ToolStorage:FindFirstChild(v) then
					table.insert(ActualTools, v)
				end
			end
			for _,v in pairs(ActualTools) do
				ToolStorage:FindFirstChild(v):Clone().Parent = plr:WaitForChild("Backpack")
			end
		end
		local DataLoadBoolean = Instance.new("BoolValue")
		DataLoadBoolean.Name = "DataLoaded"
		DataLoadBoolean.Parent = plr
	end)
end



game.Players.PlayerAdded:connect(function(player)
	local leaderstats = Instance.new("IntValue")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local coins = Instance.new("DoubleConstrainedValue", leaderstats)
	coins.Name = "Coins"
	coins.MaxValue = math.huge
	
	local damage = Instance.new("DoubleConstrainedValue", leaderstats)
	damage.Name = "Debris"
	damage.MaxValue = math.huge
	
	local Owned = Instance.new("Folder", player)
	Owned.Name = "Owned"
	
	local Powers = Instance.new("Folder", Owned)
	Powers.Name = "Powers"
	
	local Weapons = Instance.new("Folder", Owned)
	Weapons.Name = "Weapons"
	
	local CanadaDay = Instance.new("Folder", Owned)
	CanadaDay.Name = "CanadaDay"
	
	local MapleLeafBoom = Instance.new("BoolValue", CanadaDay)
	MapleLeafBoom.Name = "MapleLeafExplosion"
	
	local MapleLeafRocket = Instance.new("BoolValue", CanadaDay)
	MapleLeafRocket.Name = "MapleLeafCannon"
	
	local IndependenceDay = Instance.new("Folder", Owned)
	IndependenceDay.Name = "IndependenceDay"
	
	local IndependenceBoom = Instance.new("BoolValue", IndependenceDay)
	IndependenceBoom.Name = "FireworkNuke"
	
	local IndependenceRocket = Instance.new("BoolValue", IndependenceDay)
	IndependenceRocket.Name = "FireworkCannon"
	
	local Meteor = Instance.new("BoolValue", Powers)
 	Meteor.Name = "Meteor"
	Meteor.Value = true
	
	local WeaponFolder = Instance.new("Folder", player)
	WeaponFolder.Name = "WeaponFolder"
  
	local Thunderbolt = Instance.new("BoolValue", Powers)
	Thunderbolt.Name = "Thunderbolt"
	
	local GrenadeShower = Instance.new("BoolValue", Powers)
	GrenadeShower.Name = "GrenadeShower"
	  
	local Nuke = Instance.new("BoolValue", Powers)
	Nuke.Name = "Nuke"
	 
	local GroundPound = Instance.new("BoolValue", Powers)
	GroundPound.Name = "GroundPound"
	 
	local MicroSupernova = Instance.new("BoolValue", Powers)
	
	local Stones = Instance.new("Folder", Owned)
	Stones.Name = "Stones"
	
	MicroSupernova.Name = "MicroSupernova"
	
	local Knife = Instance.new("BoolValue", Weapons)
	Knife.Name = "Knife"
	
    local Rifle = Instance.new("BoolValue", Weapons)
	Rifle.Name = "Rifle"
	
    local Sniper = Instance.new("BoolValue", Weapons)
	Sniper.Name = "Sniper"
	
	local SpaceStone = Instance.new("BoolValue", Stones)
	SpaceStone.Name = "SpaceStone"
	SpaceStone.Value = false
	
	local TimeStone = Instance.new("BoolValue", Stones)
	TimeStone.Name = "TimeStone"
	TimeStone.Value = false
	
	local PowerStone = Instance.new("BoolValue", Stones)
	PowerStone.Name = "PowerStone"
	PowerStone.Value = false
	
	local RealityStone = Instance.new("BoolValue", Stones)
	RealityStone.Name = "RealityStone"
	RealityStone.Value = false
	
	local MStone = Instance.new("BoolValue", Stones)
	MStone.Name = "MindStone"
	MStone.Value = false
	
	local Skins = Instance.new("Folder",Owned)
	Skins.Name = "Skins"
	
	local Weapon_Skins = Instance.new("Folder", Skins)
	Weapon_Skins.Name = "Weapon"
	
	local Char_Skins = Instance.new("Folder", Skins)
	Char_Skins.Name = "Character"
	
	local Roblox_Texture_Weapon_Skin = Instance.new("BoolValue", Weapon_Skins)
	Roblox_Texture_Weapon_Skin.Name = "NewGenRobloxLogo"

	local OG_Roblox_Texture_Weapon_Skin = Instance.new("BoolValue", Weapon_Skins)
	OG_Roblox_Texture_Weapon_Skin.Name = "OGRobloxLogo"
	
	local TigerFurTexture = Instance.new("BoolValue", Weapon_Skins)
	TigerFurTexture.Name = "TigerFur"
	
	local GrassTexture = Instance.new("BoolValue", Weapon_Skins)
	GrassTexture.Name = "Grass"
	
	local Weapon_Skin = Instance.new("StringValue", leaderstats)
	Weapon_Skin.Name = "WeaponSkin"
	
	local Char_Skin = Instance.new("StringValue", leaderstats)
	Char_Skin.Name = "CharacterSkin"
	
	local NoobSkin = Instance.new("BoolValue", Char_Skins)
	NoobSkin.Name = "DefaultNoob"
	
	local BaconSkin = Instance.new("BoolValue", Char_Skins)
	BaconSkin.Name = "BaconHair"
	
	local MLGQuickSkopurSkin = Instance.new("BoolValue", Char_Skins)
	MLGQuickSkopurSkin.Name = "MLGQuickSkopur"
	
	local AsimoSkin = Instance.new("BoolValue", Char_Skins)
	AsimoSkin.Name = "Asimo3089"
	
	local BadccSkin = Instance.new("BoolValue", Char_Skins)
	BadccSkin.Name = "Badcc"
	
	player.Character.Humanoid.Died:Connect(function()
		wait(2)
		player:LoadCharacter()
	end)
	
	local timenow = os.time()
	
	local data
   
	local key = "user-" .. player.userId
	
	local storeditems = datastore:GetAsync(key)
	if storeditems then
		coins.Value = storeditems[1] --Value of the Points, change "points" if you changed line 10
		damage.Value = storeditems[2]--Value of the Wins, change "wins" if you changed line 14
		Thunderbolt.Value = storeditems[3]
		GrenadeShower.Value = storeditems[4]
		Nuke.Value = storeditems[5]
		GroundPound.Value = storeditems[6]
		MicroSupernova.Value = storeditems[7]
		Knife.Value = storeditems[8]
  		Rifle.Value = storeditems[9]
		Sniper.Value = storeditems[10]
		SpaceStone.Value = storeditems[11]
		TimeStone.Value = storeditems[12]
  		PowerStone.Value = storeditems[13]
		RealityStone.Value = storeditems[14]
		MStone.Value = storeditems[15]
		MapleLeafBoom.Value = storeditems[16]
		MapleLeafRocket.Value = storeditems[17]
		IndependenceBoom.Value = storeditems[18]
		IndependenceRocket.Value = storeditems[19]
		Roblox_Texture_Weapon_Skin.Value = storeditems[20]
		OG_Roblox_Texture_Weapon_Skin.Value = storeditems[21]
		if storeditems[22] ~= nil then
			Weapon_Skin.Value = storeditems[22]
		end
		if storeditems[23] ~= nil then
			Char_Skin.Value = storeditems[23]
		end
		TigerFurTexture.Value = storeditems[24]
		GrassTexture.Value = storeditems[25]
		NoobSkin.Value = storeditems[26]
		BaconSkin.Value = storeditems[27]
		MLGQuickSkopurSkin.Value = storeditems[28]
		AsimoSkin.Value = storeditems[29]
		BadccSkin.Value = storeditems[30]
	else
		Meteor.Value = true
		local items = {coins.Value, damage.Value , Thunderbolt.Value, GrenadeShower.Value, Nuke.Value, GroundPound.Value, MicroSupernova.Value,Knife.Value, Rifle.Value, Sniper.Value, SpaceStone.Value, TimeStone.Value, PowerStone.Value, RealityStone.Value, MStone.Value, MapleLeafBoom.Value, MapleLeafRocket.Value, IndependenceBoom.Value, IndependenceRocket.Value,
		Roblox_Texture_Weapon_Skin.Value, OG_Roblox_Texture_Weapon_Skin.Value, Weapon_Skin.Value, Char_Skin.Value,
		TigerFurTexture.Value, GrassTexture.Value, NoobSkin.Value,BaconSkin.Value, MLGQuickSkopurSkin.Value,
		AsimoSkin.Value, BadccSkin.Value} --Change Points or Wins if you changed line 10 or 14
		datastore:SetAsync(key, items)
	end
	pcall(function()
		data = datastore:GetAsync(player.UserId.."-dailyReward")
	end)
	print("Giving reward")
	if data then
		print("Player already played")
		 local timesinceplayed = timenow
		local reward = ((player.leaderstats.Debris.Value / 10) * math.random(1,1000))
		if MS:UserOwnsGamePassAsync(6610910) then
			reward = reward * 1.5
		end
		if (timesinceplayed / 3600) >= Hours then
			player.PlayerGui.DailyReward.Enabled = true
			game.ReplicatedStorage.GameRemotes.DailyEvent:FireClient(player,Hours,reward)
			print("Gave ".. player.Name.. " " ..reward.."$")
		end
	else
		print("New player")
	end
end)

game.Players.PlayerRemoving:connect(function(player)
	local items = {player.leaderstats.Coins.Value, player.leaderstats.Debris.Value, player.Owned.Powers.Thunderbolt.Value, 
	player.Owned.Powers.GrenadeShower.Value, player.Owned.Powers.Nuke.Value, player.Owned.Powers.GroundPound.Value, player.Owned.Powers.MicroSupernova.Value, 
	player.Owned.Weapons.Knife.Value, player.Owned.Weapons.Rifle.Value, player.Owned.Weapons.Sniper.Value, player.Owned.Stones.SpaceStone.Value, player.Owned.Stones.TimeStone.Value, player.Owned.Stones.PowerStone.Value, 
	player.Owned.Stones.RealityStone.Value, player.Owned.Stones.MindStone.Value, player.Owned.CanadaDay.MapleLeafExplosion.Value, player.Owned.CanadaDay.MapleLeafCannon.Value,  
	player.Owned.IndependenceDay.FireworkCannon.Value, player.Owned.IndependenceDay.FireworkNuke.Value,
	player.Owned.Skins.Weapon.NewGenRobloxLogo.Value, player.Owned.Skins.Weapon.OGRobloxLogo.Value, player.leaderstats.WeaponSkin.Value, player.leaderstats.CharacterSkin.Value
	,player.Owned.Skins.Weapon.TigerFur.Value, player.Owned.Skins.Weapon.Grass.Value, player.Owned.Skins.Character.DefaultNoob.Value,
	player.Owned.Skins.Character.BaconHair.Value, player.Owned.Skins.Character.MLGQuickSkopur.Value, player.Owned.Skins.Character.Asimo3089.Value, player.Owned.Skins.Character.Badcc.Value
	}  --Change Points or Wins if you changed line 10 or 14
	local key = "user-" .. player.userId
	datastore:SetAsync(key, items)
end)
