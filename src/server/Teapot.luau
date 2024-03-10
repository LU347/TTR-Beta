local Teapot = {}
Teapot.__index = Teapot

function Teapot.new(name, value)
    local self = setmetatable({}, Teapot)
    self.Name = name
    self.Value = value
    self.Size = Vector3.new(1,1,1)

    self:Init()
    
    return self
end

function Teapot:Init()

end

return Teapot