local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local TeapotData = require(ReplicatedStorage.Shared.TeapotData)

local Teapot = {}
Teapot.__index = Teapot

function Teapot.new(owner, name, fieldInstance)
    local self = setmetatable({}, Teapot)
    self.Owner = owner
    self.Name = name
    self.FieldInstance = fieldInstance
    self.CurrentValue = 0
    self.MaxValue = TeapotData[self.Name].MaxValue
    self.Instance = nil
    self.Size = 0
    self:Init()
    
    return self
end

function Teapot:Init()
    local function getRandomizedAngle()
        local random = Random.new()
        local angle = random:NextInteger(0, 180)
        return CFrame.fromEulerAngles(0, angle, 0)
    end

    local teapot = ReplicatedStorage.Teapots:FindFirstChild(self.Name)
    local teapotCFrame = CFrame.new(
        self.FieldInstance.CFrame.X,
        self.FieldInstance.CFrame.Y + 0.5,
        self.FieldInstance.CFrame.Z
    ) * getRandomizedAngle()

    self.Instance = teapot:Clone()
    self.Instance:PivotTo(teapotCFrame)
    self.Instance.Anchored = true
    self.Instance.Parent = self.FieldInstance
    self.Size = self.Instance.Size --tbd

    --Initialize Teapot Attributes--
    self.Instance:SetAttribute("Owner", self.Owner.UserId)
    self.Instance:SetAttribute("Location", self.FieldInstance.Name)
    self.Instance:SetAttribute("Growing", false)

    local currentValue = Instance.new("IntValue")
    currentValue.Name = "CurrentValue"
    currentValue.Value = 0
    currentValue.Parent = self.Instance

    CollectionService:AddTag(self.Instance, "Teapot")
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

    local currentValue = self.Instance:FindFirstChild("CurrentValue")
    if currentValue then
        local tweenValue = TweenService:Create(currentValue, tweenInfo, { Value = self.MaxValue })
        tweenValue:Play()
    else
        print("value instance does not exist")
    end

    currentValue.Changed:Connect(function(newValue)
        self.CurrentValue = newValue
    end)
end

return Teapot