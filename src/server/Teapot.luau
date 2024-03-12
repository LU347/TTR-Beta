local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Teapot = {}
Teapot.__index = Teapot

function Teapot.new(name, value)
    local self = setmetatable({}, Teapot)
    self.Name = name
    self.Instance = nil
    self.Size = 0

    self:Init()
    
    return self
end

function Teapot:Init()
    local teapot = ReplicatedStorage.Teapots:FindFirstChild(self.Name)
    self.Instance = teapot:Clone()
    self.Instance:SetAttribute("Growing", false)
    self.Size = self.Instance.Size

    self.Instance:GetAttributeChangedSignal("Growing"):Connect(function()
        self:Grow()
    end)
end

function Teapot:Grow()
    print("hello")
end

return Teapot