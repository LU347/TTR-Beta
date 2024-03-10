local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
            print(self.Fields)
        end
    end
end

function Plot:Plant(fieldInstance, seed)
    --Instance--
    --Table--
    self.Fields[fieldInstance.Name].Teapot = seed --store teapot table?
    print("In Plot Module")
    print(self.Fields[fieldInstance.Name])
end

return Plot