local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    local plotClone
    local plotCFrame

    plotClone = plotModel:Clone()
    self.PlotInstance = plotClone
    plotCFrame = plotClone:GetPivot()
    plotClone.Parent = placeHolder
        
    plotClone:PivotTo(placeHolder.CFrame)
    placeHolder:SetAttribute("Owner", self.Owner.UserId)

    --Initialize Fields--
    for _, field in plotClone:GetChildren() do
        if field.Name ~= "Base" then
            --Replaces default field name from 1 to A1 or B1 .. depending on PlotLocation
            local newName = string.sub(self.Location, 5, 6) .. field.Name
            field.Name = newName

            --Instance Attributes--
            field:SetAttribute("Owner", self.Owner.UserId)
            field:SetAttribute("Type", string.sub(self.Type, 6, string.len(self.Type)))
            field:SetAttribute("Taken", false)
            field:SetAttribute("Watered", false)

            CollectionService:AddTag(field, "Field")

            --Table Attributes-- 
            self.Fields[field.Name] = {
                Instance = field,
                Teapot = {}
            }

            --Attribute Functions --
            field:GetAttributeChangedSignal("Watered"):Connect(function()
                if field:GetAttribute("Watered") == true then
                    field.Color = Color3.fromRGB(70,53,44)
                    if field:GetAttribute("Taken") == true then
                        self.Fields[field.Name].Teapot:Grow()
                    end
                else 
                    field.Color = Color3.fromRGB(86,66,54)
                end
            end)
        end
    end
end

function Plot:Plant(fieldInstance, seed)
    fieldInstance:SetAttribute("Taken", true)

    --Table--
    local teapot = Teapot.new(seed)
    self.Fields[fieldInstance.Name].Teapot = teapot

    --Instance--
    local teapotCFrame = CFrame.new(fieldInstance.CFrame.X, fieldInstance.CFrame.Y + 0.5, fieldInstance.CFrame.Z)
    teapot.Instance:PivotTo(teapotCFrame)
    teapot.Instance:SetAttribute("Owner", self.Owner.UserId)
    teapot.Instance:SetAttribute("Location", fieldInstance.Name)
    teapot.Instance.Parent = fieldInstance
    
    CollectionService:AddTag(teapot.Instance, "Teapot")
    if fieldInstance:GetAttribute("Watered") == true then
        teapot:Grow()
    end
end

function Plot:Water(fieldInstance)
    --[[
        Dry Color: [86,66,54]
        Wet Color: [43,33,27]
    ]]--
    fieldInstance:SetAttribute("Watered", true)
end

function Plot:Harvest(fieldTable, fieldInstance)
    CollectionService:RemoveTag(fieldTable.Teapot.Instance, "Teapot")

    fieldTable.Teapot.Instance:Destroy()
    fieldTable.Teapot = {}

    fieldInstance:SetAttribute("Watered", false)
    fieldInstance:SetAttribute("Taken", false)
end

function Plot:Clean()
   self.PlotInstance:Destroy()
   self = {}
end

return Plot