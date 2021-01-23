local playerService = game.Players
local dataStore = game:GetService("DataStoreService"):GetDataStore("person person is")

local playerData = require(script.Data)
local compression = require(script.Compression)
local clockService = require(game.ReplicatedStorage.Modules.Util.ClockService)

local autoSave = 60
local sessions = {}

local function UpdateAsync(current)
	local decompressed
	
	if current then
		decompressed = compression.Decompress(current)
		
		return decompressed.Locked and nil or decompressed
	else
		
	end
	
	return not current and { -- default data
		Locked = true,
		Data = {
			Inventory = {
				Equipments = {}
			},
			Equipments = {
				Weapon = {
					Name = "Stick",
					Refinement = 0
				}
			},
			MainStats = {},
			Stats = {},
			Attributes = {
				Strength = 5,
				Intelligence = 5,
			},
			Skills = {}
		}
	} or decompressed.Locked and nil or decompressed
end

local function GetData(player)
	local _, results = pcall(function()
		return dataStore:UpdateAsync(player.UserId, UpdateAsync)
	end)
	
	return not results or type(results) == "string" and player:Kick("fat man") or results
end

local function SaveData(self, leaving) -- using self, ez
	if not self.Info and time() - self.Time < 8 then return end

	self.Info.Locked = not leaving
	pcall(dataStore.SetAsync, dataStore, self.Key, compression.Compress(self.Info))

	self.Time = time()
	self.AutoSave = self.Time
end

local function Recurse(self)
	if not self.Info then return end
	
	SaveData(self)
	clockService(autoSave, Recurse, true, self)
end

local function SetupPlayer(player)
	sessions[player.Name] = {
		Info = playerData.A(GetData(player)),
		Key = player.UserId,
		Time = 0,
	}
	
	clockService(autoSave, Recurse, true, sessions[player.Name])
end

local function Destroy(player)
	SaveData(sessions[player.Name], true)
	sessions[player.Name] = nil
end

if not game:GetService("RunService"):IsStudio() then
	game:BindToClose(function()
		for _, player in pairs(game:GetService("Players"):GetPlayers()) do
			coroutine.wrap(Destroy)(player)
		end
	end)
end

for _, player in ipairs(playerService:GetPlayers()) do
	SetupPlayer(player)
end

playerService.PlayerAdded:Connect(SetupPlayer)
playerService.PlayerRemoving:Connect(Destroy)

return SaveData
