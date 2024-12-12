local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local playSound = ReplicatedStorage.RemoteEvents.PlaySound

local Field = require(game.ServerScriptService.Server.Field)
local Teapot = require(game.ServerScriptService.Server.Teapot)

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

function Plot:Upgrade(newPlot)
    self.PlotInstance:Destroy()
    self.Type = newPlot
    self:Init()
end

function Plot:Clean()
    if self.PlotInstance then
        self.PlotInstance:Destroy()
    end
   self = {}
end

return Plot