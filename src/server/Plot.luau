local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Field = require(game.ServerScriptService.Server.Field)

local Plot = {}
Plot.__index = Plot

function Plot.new(player, location, tycoonInstance, type)
    local self = setmetatable({}, Plot)
    self.Owner = player
    self.Location = location
    self.Tycoon = tycoonInstance
    self.Type = type
    self.Fields = {}
    self:Init()

    return self
end

function Plot:Init()
    local placeHolder = self.Tycoon.Plots:FindFirstChild(self.Location)
    local plotModel = ReplicatedStorage.Assets:FindFirstChild(self.Type)
    if not plotModel then
        warn("Plot model not found: " .. self.Type)
        return
    end

    local plotClone = plotModel:Clone()
    self.PlotInstance = plotClone
    self.PlotInstance.Parent = placeHolder
    self.PlotInstance:PivotTo(placeHolder.CFrame)
    placeHolder:SetAttribute("Owner", self.Owner.UserId)

    --Initialize Fields--
    local locationSuffix = string.sub(self.Location, 5, 6)
    local fieldType = string.sub(self.Type, 6)
    for _, field in plotClone:GetChildren() do
        if field.Name ~= "Base" then
            field.Name = locationSuffix .. field.Name
            self.Fields[field.Name] = Field.new(self.Owner, field, fieldType)
        end
    end
end

--TODO: Replace Instance that stores the current value and tween it a different way
--Get rid of that nested loop

local function findFirstChildWithTag(parent, tag)
    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child:HasTag(tag) then
                return child
            end
        end
    end

    return nil
end

function Plot:Upgrade(newPlotName)
    -- Safety check: Ensure no teapots exist before upgrading
    for _, field in pairs(self.Fields) do
        if field.IsTaken == true then
            return false
        end
    end

    -- Store reference to placeholder
    local placeHolder = self.Tycoon.Plots:FindFirstChild(self.Location)
    if not placeHolder then
        warn("Placeholder not found at location: " .. self.Location)
        return
    end

    -- Clean up old plot instance and fields
    if self.PlotInstance then
        self.PlotInstance:Destroy()
        self.PlotInstance = nil
    end
    self.Fields = {}

    -- Load new plot model
    local newPlotModel = ReplicatedStorage.Assets:FindFirstChild(newPlotName)
    if not newPlotModel then
        warn("New plot model not found: " .. newPlotName)
        return
    end

    -- Clone and place new plot
    local newClone = newPlotModel:Clone()
    self.PlotInstance = newClone
    self.PlotInstance.Parent = placeHolder
    self.PlotInstance:PivotTo(placeHolder.CFrame)
    placeHolder:SetAttribute("Owner", self.Owner.UserId)

    -- Update type
    self.Type = newPlotName

    -- Reinitialize Fields
    local locationSuffix = string.sub(self.Location, 5, 6)
    local fieldType = string.sub(self.Type, 6)
    for _, field in newClone:GetChildren() do
        if field.Name ~= "Base" then
            field.Name = locationSuffix .. field.Name
            self.Fields[field.Name] = Field.new(self.Owner, field, fieldType)
        end
    end

    return true
end

function Plot:Clean()
    if self.PlotInstance then
        self.PlotInstance:Destroy()
    end
    self = {}
end

return Plot