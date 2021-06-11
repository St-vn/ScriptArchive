local Chunk            = require(script.Chunk)
local List             = Chunk.List
local Camera           = workspace.CurrentCamera
local PreviousChunk    = nil

Chunk.SetSeed(math.random(-(2 ^ 16), 2 ^ 16))
List[0] = {[0] = Chunk.Generate(0, 0)}

game:GetService("RunService").RenderStepped:Connect(function()
    local Position = Camera.CFrame.Position
    local CurrentX, CurrentZ = math.floor(Position.X / 68 + 0.5), math.floor(Position.Z / 68 + 0.5)
    local CurrentChunk = List[CurrentX][CurrentZ]

    if CurrentChunk ~= PreviousChunk then
        PreviousChunk = CurrentChunk
        local Iterations = 0
        for X = -8, 8 do
            if not List[CurrentX + X] then List[CurrentX + X] = {} end

            local Cell = List[CurrentX + X]
            
            for Z = -8, 8 do
                if not Cell[CurrentZ + Z] then
                    Iterations += 1
                    Cell[CurrentZ + Z] = Chunk.Generate(CurrentX + X, CurrentZ + Z)
                end
            end
        end
    end
end)

return Chunk
