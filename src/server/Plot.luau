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
function Plot:Upgrade(newPlot)
    local oldFields = self.Fields
    local teapotStorage = {}

    for fieldName, field in pairs(oldFields) do
        for _, child in pairs(field.Instance:GetChildren()) do
            if child and child:HasTag("Teapot") then
                child.Parent = ReplicatedStorage
                teapotStorage[fieldName] = child
                break
            end
        end
    end

    self.PlotInstance:Destroy()

    self.Type = newPlot

    self:Init()

    for _, field in pairs(self.PlotInstance:GetChildren()) do
        if field.Name ~= "Base" then
            local oldField = oldFields[field.Name]
            if oldField then
                self.Fields[field.Name] = oldField
                oldField.Instance = field

                local teapot = teapotStorage[field.Name]
                if teapot then
                    teapot.Parent = field 
                    teapot:PivotTo(CFrame.new(field.CFrame.X, field.CFrame.Y + 0.5, field.CFrame.Z)) -- Position it correctly
                end
            end
        end
    end
end

function Plot:Clean()
    if self.PlotInstance then
        self.PlotInstance:Destroy()
    end
    self = {}
end

return Plot