local Tycoon = {}
Tycoon.__index = Tycoon

local Plots = game.Workspace.Plots

local TemplatePlot = game.Workspace.TemplatePlot --replace
local templateButtons = TemplatePlot.Buttons
local templateItems = TemplatePlot.Items

local TycoonItems = {
    [1] = templateItems.Teapot,
    }

function Tycoon.new(player, plot, items)
    local self = setmetatable({}, Tycoon)
    self.Owner = player
    self.Plot = plot
    self.Items = items

    return self
end

function Tycoon:Init()
    local buttonsFolder = Instance.new("Folder")
    buttonsFolder.Name = "Buttons"
    buttonsFolder.Parent = self.Plot

    local itemsFolder = Instance.new("Folder")
    itemsFolder.Name = "Items"
    itemsFolder.Parent = self.Plot

    --TODO: Clone Whole Model instead and initialize buttons
    local tycoonButtons = templateButtons:Clone()
   
    for _, button in tycoonButtons:GetChildren() do
        local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(button.CFrame)
        button.CFrame = self.Plot.CFrame:ToWorldSpace(relativeCFrame)
        
        button.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if not player or self.Plot:GetAttribute("Owner") ~= self.Owner.UserId then 
                return
            else
                --TODO: Check if ItemID is valid
                self:UnlockItem(TycoonItems[button:GetAttribute("ItemUnlock")])
            end
        end)
        
        button.Parent = buttonsFolder
    end
end

function Tycoon:CleanUp()
    self.Plot:SetAttribute("Taken", false)
    self.Plot:SetAttribute("Owner", nil)

    for _, b in pairs(self.Plot.Buttons:GetChildren()) do
        b:Destroy()
    end
    
    for _, i in pairs(self.Plot.Items:GetChildren()) do
        i:Destroy()
    end
    
    self = {}
    print(self)
end

function Tycoon:GetNewItemCFrame(itemCFrame)
    local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(itemCFrame)
    return self.Plot.CFrame:ToWorldSpace(relativeCFrame)
end

function Tycoon:UnlockItem(item)
    local itemClone = item:Clone()
    local itemCFrame

    if itemClone:IsA("Model") then
        itemCFrame = itemClone:GetPivot()
        itemClone:PivotTo(self:GetNewItemCFrame(itemCFrame))
    else
        itemCFrame = itemClone.CFrame
        itemClone.CFrame = self:GetNewItemCFrame(itemCFrame)
    end

    itemClone.Parent = self.Plot.Items
end

return Tycoon