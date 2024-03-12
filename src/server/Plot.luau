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
    local plotClone
    local plotCFrame

    if self.Type == "Plot_Small" then
        plotClone = ReplicatedStorage.Assets:FindFirstChild("Plot_Small"):Clone()
        plotCFrame = plotClone:GetPivot()
        plotClone.Parent = placeHolder
        
        plotClone:PivotTo(placeHolder.CFrame)
        placeHolder:SetAttribute("Owner", self.Owner.UserId)
    end

    --Initialize Fields--
    for _, field in plotClone:GetChildren() do
        if string.len(field.Name) == 2 then
            --Instance Attributes--
            field:SetAttribute("Owner", self.Owner.UserId)
            field:SetAttribute("Type", string.sub(self.Type, 6, string.len(self.Type)))
            field:SetAttribute("Taken", false)
            field:SetAttribute("Watered", false)

            CollectionService:AddTag(field, "Field")

            --Table Attributes-- 
            self.Fields[field.Name] = {
                Teapot = {}
            }

            --Attribute Functions --
            field:GetAttributeChangedSignal("Watered"):Connect(function()
                if field:GetAttribute("Watered") == true then
                    field.Color = Color3.fromRGB(70,53,44)
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
    print(self.Fields)

    --Instance--
    local teapotCFrame = CFrame.new(fieldInstance.CFrame.X, fieldInstance.CFrame.Y + 0.5, fieldInstance.CFrame.Z)
    teapot.Instance:PivotTo(teapotCFrame)
    teapot.Instance.Parent = fieldInstance
    teapot.Instance:SetAttribute("Growing", true)
end

function Plot:Water(fieldInstance)
    --[[
        Dry Color: [86,66,54]
        Wet Color: [43,33,27]
    ]]--
    fieldInstance:SetAttribute("Watered", true)
end

return Plot