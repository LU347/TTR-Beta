
local TeapotData = require(script.Parent.TeapotData)

local SeedPacket = {}
SeedPacket.__index = SeedPacket

-- Create a new seed packet
function SeedPacket.new(seedName, quantity)
    local self = setmetatable({}, SeedPacket)
    
    self.Name = seedName
    self.Quantity = quantity or 1
    self.Type = TeapotData[seedName] and TeapotData[seedName].Type or nil
    self.MaxValue = TeapotData[seedName] and TeapotData[seedName].MaxValue or 0
    self.MaxSize = TeapotData[seedName] and TeapotData[seedName].MaxSize or Vector3.new(1, 1, 1)
    
    return self
end

-- Check if a seed name is valid
function SeedPacket.isValidSeed(seedName)
    return TeapotData[seedName] ~= nil
end

-- Get all available seed names
function SeedPacket.getAllSeedNames()
    local seedNames = {}
    for seedName, _ in pairs(TeapotData) do
        table.insert(seedNames, seedName)
    end
    return seedNames
end

-- Plant the seed packet to create a teapot
function SeedPacket:Plant(owner, fieldInstance)
    if not self.Type then
        warn("Invalid seed packet: " .. tostring(self.Name))
        return nil
    end
    
    -- Create teapot from the seed packet
    local Teapot = require(script.Parent.Teapot)
    local teapot = Teapot.new(owner, self.Name, fieldInstance)
    
    return teapot
end

return SeedPacket