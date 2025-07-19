local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local TeapotData = require(script.Parent.TeapotData)
local TeapotEffects = require(script.TeapotEffects)

local Teapot = {}
Teapot.__index = Teapot

local random = Random.new()

local function getRandomizedAngle()
    local angle = random:NextInteger(0, 180)
    return CFrame.fromEulerAngles(0, angle, 0)
end

local function createProximityPrompt(teapotInstance, teapotObject)
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ObjectText = "Teapot"
    proximityPrompt.ActionText = "Harvest"
    proximityPrompt.HoldDuration = 0.5
    proximityPrompt.MaxActivationDistance = 20
    proximityPrompt.RequiresLineOfSight = false
    proximityPrompt.Parent = teapotInstance
    
    -- Connect the proximity prompt trigger to the harvest function
    proximityPrompt.Triggered:Connect(function(player)
        if player.UserId == teapotInstance:GetAttribute("Owner") then
            teapotObject:Harvest()
        end
    end)
    
    return proximityPrompt
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
    self.OriginalCFrame = self.Instance.CFrame
    
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
    
    -- Add proximity prompt for harvesting (for teapots loaded from saved data)
    --self.ProximityPrompt = createProximityPrompt(self.Instance, self)
    
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
    self.OriginalCFrame = self.Instance.CFrame
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

    -- Add proximity prompt for harvesting
    self.ProximityPrompt = createProximityPrompt(self.Instance, self)

    --Instance Size Change Signal
    self.Instance:GetPropertyChangedSignal("Size"):Connect(function()
        self.CurrentSize = self.Instance.Size
    end)

    TeapotEffects.AttachParticles(self.Instance)

    CollectionService:AddTag(self.Instance, "Teapot")
    self:ConnectPromptEvents()
end

function Teapot:CreateGrowTween()
    -- Clamp the target size so it never exceeds MaxSize
    local currentSize = self.Instance.Size
    local maxSize = self.MaxSize

    -- If already at or above max size, do not grow further
    if currentSize.X >= maxSize.X and currentSize.Y >= maxSize.Y and currentSize.Z >= maxSize.Z then
        self.GrowTween = nil
        self.GrowValueTween = nil
        return
    end

    -- Tween to MaxSize, not current + MaxSize
    local tweenGoal = {}
    tweenGoal.Size = maxSize
    local heightDiff = (maxSize.Y - currentSize.Y) / 2
    tweenGoal.Position = Vector3.new(self.Instance.Position.X, self.Instance.Position.Y + heightDiff, self.Instance.Position.Z)
    local growTime = (maxSize.Z - currentSize.Z) * self.Type.GrowthRate
    local tweenInfo = TweenInfo.new(
        math.max(growTime, 0.1),
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.In,
        0,
        false,
        0
    )
    self.GrowTween = TweenService:Create(self.Instance, tweenInfo, tweenGoal)
    local currentValue = self.Instance:FindFirstChild("CurrentValue")
    if currentValue then
        self.GrowValueTween = TweenService:Create(currentValue, tweenInfo, { Value = self.MaxValue })
    else
        self.GrowValueTween = nil
    end
end

function Teapot:Grow()
    self:CreateGrowTween()
    if self.GrowTween then self.GrowTween:Play() end
    if self.GrowValueTween then self.GrowValueTween:Play() end
    local currentValue = self.Instance:FindFirstChild("CurrentValue")
    if currentValue then
        currentValue.Changed:Connect(function(newValue)
            self.CurrentValue = newValue
        end)
    end
end

function Teapot:CreateShakeTween()
    if not self.OriginalCFrame then
        self.OriginalCFrame = self.Instance.CFrame
    end
    local shakeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 10, true)
    local shakeGoal = { CFrame = self.OriginalCFrame * CFrame.Angles(0, 0, math.rad(5)) }
    self.ShakeTween = TweenService:Create(self.Instance, shakeInfo, shakeGoal)
end

function Teapot:PlayShakeTween()
    if not self.ShakeTween then self:CreateShakeTween() end
    if self.ShakeTween then self.ShakeTween:Play() end
end

function Teapot:PauseGrowTween()
    if self.GrowTween and self.GrowTween.PlaybackState == Enum.PlaybackState.Playing then
        self.GrowTween:Pause()
    end
    if self.GrowValueTween and self.GrowValueTween.PlaybackState == Enum.PlaybackState.Playing then
        self.GrowValueTween:Pause()
    end
end

function Teapot:ResumeGrowTween()
    if self.GrowTween and self.GrowTween.PlaybackState == Enum.PlaybackState.Paused then
        self.GrowTween:Play()
    end
    if self.GrowValueTween and self.GrowValueTween.PlaybackState == Enum.PlaybackState.Paused then
        self.GrowValueTween:Play()
    end
end

function Teapot:StopShakeTween()
    if self.ShakeTween then
        self.ShakeTween:Cancel()
        self.ShakeTween = nil
    end
    if self.OriginalCFrame then
        self.Instance.CFrame = self.OriginalCFrame
    end
end

-- Hook up ProximityPrompt hold events for this teapot
function Teapot:ConnectPromptEvents()
    if not self.ProximityPrompt then return end
    if self._promptConnections then
        for _, conn in ipairs(self._promptConnections) do
            conn:Disconnect()
        end
    end
    self._promptConnections = {}
    local function isOwner(player)
        return player and player.UserId == self.Instance:GetAttribute("Owner")
    end
    table.insert(self._promptConnections, ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
        if prompt == self.ProximityPrompt and isOwner(player) then
            self:PauseGrowTween()
            --self:PlayShakeTween()
            TeapotEffects.PlayEffect(self.Instance)
        end
    end))
    table.insert(self._promptConnections, ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, player)
        if prompt == self.ProximityPrompt and isOwner(player) then
            --self:StopShakeTween()
            self:ResumeGrowTween()
            TeapotEffects.StopEffect(self.Instance)
        end
    end))
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

function Teapot:Harvest()
    -- Find the field that contains this teapot and call its harvest method
    local fieldName = self.Instance:GetAttribute("Location")
    if fieldName then
        -- Get the field instance
        local fieldInstance = self.FieldInstance
        if fieldInstance then
            -- Find the field table by searching through the player's tycoon
            local playerTycoon = require(script.Parent.Tycoon).PlayerTycoons[self.Owner.UserId]
            if playerTycoon then
                for plotName, plot in pairs(playerTycoon.Plots) do
                    if plot.Fields and plot.Fields[fieldName] then
                        plot.Fields[fieldName]:Harvest()
                        return
                    end
                end
            end
        end
    end
end

function Teapot:CleanUp()
    if self.ProximityPrompt then
        self.ProximityPrompt:Destroy()
        self.ProximityPrompt = nil
    end
    
    if self.Instance then
        TeapotEffects.Cleanup(self.Instance)
        self.Instance:Destroy()
    end

    self = nil
end

return Teapot