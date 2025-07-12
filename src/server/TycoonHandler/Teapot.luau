local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local TeapotData = require(script.Parent.TeapotData)

local Teapot = {}
Teapot.__index = Teapot

local random = Random.new()

local function getRandomizedAngle()
    local angle = random:NextInteger(0, 180)
    return CFrame.fromEulerAngles(0, angle, 0)
end

function Teapot.FromSerializedData(owner, savedData, fieldInstance)
    local self = setmetatable({}, Teapot)
    
    self.Owner = owner
    self.Name = savedData.Name
    self.FieldInstance = fieldInstance
    self.CurrentSize = savedData.CurrentSize or 0
    self.CurrentValue = savedData.CurrentValue or 0
    self.MaxSize = TeapotData[self.Name].MaxSize
    self.MaxValue = TeapotData[self.Name].MaxValue
    self.Type = TeapotData[self.Name].Type
    self.Instance = nil
    
    self:Init()
    
    -- Position the teapot at the field instance first
    local teapotCFrame = CFrame.new(
        self.FieldInstance.CFrame.X,
        self.FieldInstance.CFrame.Y + 0.5,
        self.FieldInstance.CFrame.Z
    ) * getRandomizedAngle()
    self.Instance:PivotTo(teapotCFrame)
    
    -- Restore the saved size and position
    if savedData.CurrentSize then
        -- Convert the saved table back to Vector3
        local sizeVector = Vector3.new(
            savedData.CurrentSize.X,
            savedData.CurrentSize.Y,
            savedData.CurrentSize.Z
        )
        self.Instance.Size = sizeVector
        self.CurrentSize = sizeVector -- Update the CurrentSize property too
    end
    
    -- Restore the saved Y offset position
    if savedData.YOffset then
        local newPosition = Vector3.new(
            self.FieldInstance.Position.X,
            self.FieldInstance.Position.Y + savedData.YOffset,
            self.FieldInstance.Position.Z
        )
        self.Instance.Position = newPosition
    end
    
    -- Restore the saved value
    local currentValue = self.Instance:FindFirstChild("CurrentValue")
    if currentValue then
        currentValue.Value = self.CurrentValue
    end
    
    return self
end

function Teapot.new(owner, name, fieldInstance)
    local self = setmetatable({}, Teapot)
    self.Owner = owner
    self.Name = name    --Saved
    self.FieldInstance = fieldInstance
    self.CurrentSize = 0 --Saved
    self.CurrentValue = 0 --Saved
    self.MaxSize = TeapotData[self.Name].MaxSize
    self.MaxValue = TeapotData[self.Name].MaxValue
    self.Type = TeapotData[self.Name].Type
    self.Instance = nil
    self:Init()
    return self
end

function Teapot:Init()
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

    --Initialize Teapot Attributes--
    self.Instance:SetAttribute("Owner", self.Owner.UserId)
    self.Instance:SetAttribute("Location", self.FieldInstance.Name)
    self.Instance:SetAttribute("Growing", false)

    local currentValue = Instance.new("IntValue")
    currentValue.Name = "CurrentValue"
    currentValue.Value = 0
    currentValue.Parent = self.Instance

    --Instance Size Change Signal
    self.Instance:GetPropertyChangedSignal("Size"):Connect(function()
        self.CurrentSize = self.Instance.Size
    end)


    CollectionService:AddTag(self.Instance, "Teapot")
end

function Teapot:Grow()
    local heightDiff = self.MaxSize.Y / 2
    local growTime = self.MaxSize.Z * self.Type.GrowthRate
    print(growTime)

    local tweenGoal = {}
    tweenGoal.Size = self.Instance.Size + self.MaxSize
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

        currentValue.Changed:Connect(function(newValue)
            self.CurrentValue = newValue
        end)
    else
        print("value instance does not exist")
    end
end

function Teapot:ApplySavedData(data)
    if not data then return end
    
    -- Apply saved size
    if data.CurrentSize then
        -- Convert the saved table back to Vector3
        local sizeVector = Vector3.new(
            data.CurrentSize.X,
            data.CurrentSize.Y,
            data.CurrentSize.Z
        )
        self.Instance.Size = sizeVector
        self.CurrentSize = sizeVector -- Update the CurrentSize property too
    end
    
    -- Apply saved Y offset position
    if data.YOffset then
        local newPosition = Vector3.new(
            self.FieldInstance.Position.X,
            self.FieldInstance.Position.Y + data.YOffset,
            self.FieldInstance.Position.Z
        )
        self.Instance.Position = newPosition
    end
    
    -- Apply saved value
    local currentValue = self.Instance:FindFirstChild("CurrentValue")
    if currentValue and data.CurrentValue then
        currentValue.Value = data.CurrentValue
        self.CurrentValue = data.CurrentValue
    end
end

function Teapot:GetSerializedData()
    -- Save the current size and relative position
    local serializableData = {
        Name = self.Name,
        CurrentSize = {
            X = self.Instance.Size.X,
            Y = self.Instance.Size.Y,
            Z = self.Instance.Size.Z
        },
        CurrentValue = self.CurrentValue,
        -- Save the relative Y offset from the field
        YOffset = self.Instance.Position.Y - self.FieldInstance.Position.Y
    }

    return serializableData
end

function Teapot:CleanUp()
    if self.Instance then
        self.Instance:Destroy()
    end
    
    self = nil
end

return Teapot