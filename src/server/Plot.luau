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
    local plotClone = plotModel:Clone()

    self.PlotInstance = plotClone
    self.PlotInstance.Parent = placeHolder
        
    self.PlotInstance:PivotTo(placeHolder.CFrame)
    placeHolder:SetAttribute("Owner", self.Owner.UserId)

    local function initializeField(field)
        --Replaces default field name from 1 to A1 or B1 .. depending on PlotLocation
        local newName = string.sub(self.Location, 5, 6) .. field.Name
        field.Name = newName

        --Creates a field object and inserts it into self.Fields--
        local fieldType = string.sub(self.Type, 6, string.len(self.Type))
        self.Fields[field.Name] = Field.new(self.Owner, field, fieldType)
    end

    --Initialize Fields--
    for _, field in plotClone:GetChildren() do
        if field.Name ~= "Base" then
            initializeField(field)    
        end
    end
end

function Plot:Upgrade(newPlot)
    self.PlotInstance:Destroy()
    self.Type = newPlot
    self:Init()
end

function Plot:Clean()
   self.PlotInstance:Destroy()
   self = {}
end

return Plot