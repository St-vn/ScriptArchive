-- Written by St_vn#3931 in September of 2020
-- Latest Update : 11/11/2020
-- aka St_vnC in roblox
-- Meant to imitate RBXScriptSignals and RBXScriptConnections' behavior
 
--[[
    API :
        Constructor function, creates new signal
            Signal:Yield() : yields the current thread until the signal fires
            Signal:Destroy() : Removes the signal and its connections
            Signal:Fire() : Fires the signal
            Signal:Connect() : Connects the signal to the callback and will call the callback when it fires
                Connection:Disconnect() : Disconnects the function
]]
 
local wrap, yield, running, resume = coroutine.wrap, coroutine.yield, coroutine.running, coroutine.resume
 
local signal = {}
signal.__index = signal
 
local connection = {}
connection.__index = connection
 
function signal:Connect(callback)
    self.Connections[callback] = setmetatable({
        Thread = wrap(callback),
        Callback = callback,
        Signal = self
    }, connection)
 
    return self.Connections[callback]
end
 
function signal:Yield()
    table.insert(self.Threads, running())
 
    return yield()
end
 
function signal:Fire(...)
    local threads = self.Threads
 
    for callback, connection in pairs(self.Connections) do
        connection.Thread(...)
        connection.Thread = wrap(callback)
    end
 
    for _, thread in pairs(threads) do
        table.remove(threads)
        resume(thread, ...)
    end
end
 
function signal:Destroy()
    local threads = self.Threads
 
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
 
    for _ in pairs(threads) do
        table.remove(threads)
    end
end
 
function connection:Disconnect()
    self.Signal.Connections[self.Callback] = nil
end
 
return function()
    return setmetatable({
        Connections = {},
        Threads = {},
    }, signal)
end
