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
function Plot:Upgrade(newPlotName)
    local oldFieldTables = {}

    oldFieldTables = self.Fields
    --Instance, Type, and Teapot (if present) need to be updated
    
    for _, field in pairs(self.Fields) do
        field["Instance"].Parent = self.PlotInstance --Not updating the parent for some reason
        print(field["Instance"].Parent)
    end

    print(oldFieldTables)
end

function Plot:Clean()
    if self.PlotInstance then
        self.PlotInstance:Destroy()
    end
    self = {}
end

return Plot