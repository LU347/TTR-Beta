local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Plot = {}
Plot.__index = Plot

function Plot.new(player, tycoonInstance, location, type)
    local self = setmetatable({}, Plot)
    self.Owner = player
    self.Tycoon = tycoonInstance
    self.Location = location
    self.Type = type
    self.Fields = {}
    
    self:Init()

    return self
end

function Plot:Init()
    local plotClone

    if self.Type == "Plot_Small" then
        plotClone = ReplicatedStorage.Assets:FindFirstChild("Plot_Small"):Clone()
        plotClone.PrimaryPart.CFrame = self.Tycoon.Plots:FindFirstChild(self.Location).CFrame
        plotClone.Parent = self.Tycoon.Plots:FindFirstChild(self.Location)
    end

    --Initialize Fields--
    for _, field in plotClone:GetChildren() do
        if string.len(field.Name) == 2 then
            --Instance Attributes--
            field:SetAttribute("Owner", self.Owner.UserId)
            field:SetAttribute("Type", string.sub(self.Type, 6, string.len(self.Type)))
            field:SetAttribute("Taken", false)

            --Table Attributes--
            self.Fields[field.Name] = {
                Teapot = nil
            }
        end
    end
    print(self.Fields)
    print(self)
end

function Plot:Plant(field, seed)
    --Instance--
    --Table--

    self.Fields[field.Name].Teapot = seed --store teapot table?
end

return Plot