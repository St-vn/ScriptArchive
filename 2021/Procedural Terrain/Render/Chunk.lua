local Terrain = workspace.Terrain
local XOffset, ZOffset = 0, 0

local HeightMap = { -- needs some work
    [80] = Enum.Material.Snow,
    [76] = Enum.Material.Snow,
    [72] = Enum.Material.Snow,
    [68] = Enum.Material.Snow,
    [64] = Enum.Material.Snow,
    [60] = Enum.Material.Rock,
    [56] = Enum.Material.Rock,
    [52] = Enum.Material.Grass,
    [48] = Enum.Material.Grass,
    [44] = Enum.Material.Grass,
    [40] = Enum.Material.Grass,
    [36] = Enum.Material.Grass,
    [32] = Enum.Material.Grass,
    [28] = Enum.Material.Grass,
    [24] = Enum.Material.Grass,
    [20] = Enum.Material.Grass,
    [16] = Enum.Material.Ground,
    [12] = Enum.Material.Sand,
    [8] = Enum.Material.Sand,
    [4] = Enum.Material.Sand,
    [0] = Enum.Material.Water
}

return {
    Generate = function(X, Z)
        local CellX, CellZ = X * 68, Z * 68

        for BlockX = -16, 16 do
            for BlockZ = -16, 16 do
                local AbsoluteX, AbsoluteZ = BlockX * 4 + CellX, BlockZ * 4 + CellZ
                local Noise = math.clamp(
                    math.floor(math.noise((AbsoluteX + XOffset) * 0.005, (AbsoluteZ + ZOffset) * 0.005) * 32 + .5) * 4,
                    0,
                    80
                )
                
                Terrain:FillBall(Vector3.new(AbsoluteX, Noise, AbsoluteZ), 3, HeightMap[Noise])
            end
        end

        return true
    end,

    SetSeed = function(Seed)
        Terrain:Clear()
        
        XOffset, ZOffset = Random.new(Seed):NextInteger(-1e3, 1e3), Random.new(-Seed):NextInteger(-1e3, 1e3)
    end,

    List = {}
}