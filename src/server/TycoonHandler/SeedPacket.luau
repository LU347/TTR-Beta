
local TeapotData = require(script.Parent.TeapotData)

local SeedPacket = {}

function SeedPacket.new(owner, name, quantity)
    local self = setmetatable({}, SeedPacket)
    self.Owner = owner
    self.Name = name
    self.Quantity = quantity
    self.Type = TeapotData[self.Name].Type
end