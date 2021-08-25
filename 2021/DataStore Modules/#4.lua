-- St_vn#3931, St_vnC
-- 19/07/2021

local DataStore   = game:GetService("DataStoreService"):GetDataStore("Test4")
local Players     = game:GetService("Players")
local Util        = require(script.Util)
local JobId       = game.JobId
local Module      = {}

local function TransformFunction(Data)
    --if Data and not Util.ValidateJobId(Data.JobId) then return end

    Data.JobId = JobId

    return Data or Util.Create()
end

local function RetrieveData(Player, Attempt, Error)
    assert(Attempt < 3, "Failed to get data.")

    local Success, Result = --[[true, Util.Create()]]xpcall(DataStore.UpdateAsync, function(Error)
        task.delay(8, RetrieveData, Player, Attempt + 1, Error)
    end, DataStore, Player.UserId, TransformFunction)

    local _ = Success and (Result and Util.HandleLoaded(Player, Result) or Player:Kick())
end

local function AutoSave()
    task.delay(90, AutoSave)

    for _, Player in ipairs(Players:GetPlayers()) do
        Module.Save(Player)
    end
end

function Module.Load(Player)
    assert(Player, "Invalid Player.")

    Player:SetAttribute("Locked", true)
    RetrieveData(Player, 1)
end

function Module.Save(Player, Leaving) -- needs to save full data
    assert(Player, "Invalid Player.")
    assert(not Player:GetAttribute("Locked"), "Locked session.")
    
    if not Player:GetAttribute("SaveSlot") and not Player:FindFirstChild("Slots") then return end -- specific to my game
    
    DataStore:UpdateAsync(Player.UserId, function(Data)
        if Util.ValidateJobId(Data.JobId) then
            if Leaving then
                Player:SetAttribute("JobId", nil)
                Player:SetAttribute("SaveSlot", nil)
            end

            Util.UpdateData(Player, Player:GetAttribute("SaveSlot") and Player:GetAttributes() or Data)
        end
    end)
end

game:BindToClose(function()
    for _, Player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(Module.Save)(Player, true)
    end
end)

task.delay(90, AutoSave)

return Module
