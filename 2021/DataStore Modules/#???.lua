-- St_vn#3931, 06/02/2021

local DataStore = game:GetService("DataStoreService"):GetDataStore("gato")
local NewData = {}

local function TransformFunction(Data)
    Data.Locked = assert(not Data.Locked, "Session locked.")

    return Data
end

return {
    Get = function(Player)
        Player:SetAttribute("Locked", true)

        local Success, Result = pcall(DataStore.UpdateAsync, DataStore, Player.UserId, TransformFunction)
        Result = Result or NewData

        if Success then
            Player:SetAttribute("Locked", false)

            for Name, Value in pairs(NewData) do
                Player:SetAttribute(Name, Result[Name] or Value)
            end

            return
        end
        
        Player:Kick("Failed to fetch data : ".. Result)
    end,

    Set = function(Player, Leaving)
        local Data = Player:GetAttributes()

        if not Data.Locked then
            Data.Locked = not Leaving

            DataStore:SetAsync(Player.UserId, Data)
        end
    end
}
