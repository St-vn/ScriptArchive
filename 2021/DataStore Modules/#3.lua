-- This one is a rough unrevised version of #4

local DataStore = game:GetService("DataStoreService"):GetDataStore("gato")
local CallScheduler = require(game:GetService("ReplicatedStorage").Modules.Auxiliary.CallScheduler)
local NewData = {} -- might make into a module!

local function HandleLoaded(Player, Data)
    for Name, Value in pairs(NewData) do
        Player:SetAttribute(Name, Data[Name] or Value)
    end

    Player:SetAttribute("Locked", false)
end

local function TransformFunction(Data)
    Data.Locked = assert(not Data.Locked, "Session locked.")

    return Data
end

local function RetrieveData(Player, Attempt)
    assert(Attempt < 3, "Failed to get data.")

    local Success, Result = pcall(DataStore.UpdateAsync, DataStore, Player.UserId, TransformFunction)
    local _ = (Success and HandleLoaded(Player, Result or {})) or CallScheduler.Add(8, RetrieveData, Player, Attempt + 1)
end

return {
    Load = function(Player)
        assert(Player, "Invalid Player.")

        Player:SetAttribute("Locked", true)
        RetrieveData(Player, 1)
    end,

    Save = function(Player)
        assert(Player, "Invalid Player.")
        assert(Player:GetAttribute("Locked"), "Locked session.")

        DataStore:SetAsync(Player.UserId, Player:GetAttributes())
    end
}
