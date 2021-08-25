-- St_vn#3931, 02/08/2021
-- There are a few more modules made earlier this year but they're a lot more embarassing to show.

local callScheduler = require(game.ReplicatedStorage.Modules.Clock)
local dataStore = game:GetService("DataStoreService"):GetDataStore("869b9f7e-b4f3-4851")

local function Retrieve(profile, attempts)
    attempts += 1

    local success, results = pcall(function()
        return dataStore:UpdateAsync(profile.Key, function(current)
            if current then
                if not current.Locked then
                    current.Locked = true
                end

                return current.Locked and nil or current
            else
                return {
                    Data = {
                        PlayerStats = {} -- default data
                    },
                    Locked = true
                }
            end
        end)
    end)
    
    if success and results then
        return results
    else
        callScheduler[os.clock() + 8] = function()
            Retrieve(profile, attempts)
        end
    end
end

local function Store(profile, leaving)
    if not profile.Session or os.clock() - profile.Time < 8 then return end

    if leaving then
        profile.Session.Locked = false
    end

    pcall(function()
        dataStore:SetAsync(profile.Key, profile.Session)
    end)

    profile.Time = os.clock()
end

return function(player)
    local profile = {
        Key = player.UserId,
        Time = 0,
        Save = Store
    }; profile.Session = Retrieve(profile, 0) or player:Kick("Failed to get data, please try again later.")

    return profile
end
