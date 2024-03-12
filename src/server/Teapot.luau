local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local TeapotData = require(ReplicatedStorage.Shared.TeapotData)

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
    local heightDiff = TeapotData[self.Name].MaxSize.Y / 2
    local growTime = TeapotData[self.Name].MaxSize.Z * 5

    local tweenGoal = {}
    tweenGoal.Size = self.Instance.Size + TeapotData[self.Name].MaxSize
    tweenGoal.Position = Vector3.new(self.Instance.Position.X, self.Instance.Position.Y + heightDiff, self.Instance.Position.Z)

    local tweenInfo = TweenInfo.new(
        growTime,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.In,
        0,
        false,
        0
    )

    local tweenMesh = TweenService:Create(self.Instance, tweenInfo, tweenGoal)
    tweenMesh:Play()
end

return Teapot