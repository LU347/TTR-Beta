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

    local function initializeAttributes()
        self.Instance:SetAttribute("Owner", self.Owner.UserId)
        self.Instance:SetAttribute("Location", self.FieldInstance.Name)
        self.Instance:SetAttribute("Growing", false)
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

    initializeAttributes()

    CollectionService:AddTag(self.Instance, "Teapot")

    --This is not being triggered
    --[[
    self.Instance:GetAttributeChangedSignal("Growing"):Connect(function()
        local isGrowing = self.Instance:GetAttribute("Growing")
        if not isGrowing then
            self:Grow()
            print("hello")
        end
    end)
    ]]--
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