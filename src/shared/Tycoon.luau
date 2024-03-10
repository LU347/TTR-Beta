local TycoonItemData = require(game.ReplicatedStorage.Shared.TycoonItemData)
local Plot = require(game.ServerScriptService.Server.Plot)

local Tycoon = {}
Tycoon.__index = Tycoon

local TemplatePlot = game.Workspace.TemplatePlot --replace
local templateButtons = TemplatePlot.Buttons
local templateItems = TemplatePlot.Items
local templatePlots = TemplatePlot.Plots

local TycoonItems = {
    ["SmallPlot"] = templateItems.SmallPlot,
    ["PlotA"] = TemplatePlot.Plots.PlotA
}

--local DEBOUNCE_COOLDOWN = 2

function Tycoon.new(player, tycoonInstance, unlocked)
    local self = setmetatable({}, Tycoon)
    self.Owner = player
    self.Unlocked = {}                   --Saved
    self.Plots = {}                      --Saved
    self.TycoonInstance = tycoonInstance --Not Saved

    return self
end

function Tycoon:Init()
    local buttonsFolder = Instance.new("Folder")
    buttonsFolder.Name = "Buttons"
    buttonsFolder.Parent = self.TycoonInstance

    local itemsFolder = Instance.new("Folder")
    itemsFolder.Name = "Items"
    itemsFolder.Parent = self.TycoonInstance

    local plotsFolder = Instance.new("Folder")
    plotsFolder.Name = "Plots"
    plotsFolder.Parent = self.TycoonInstance

    --Initialize Plot Locations--
    local tycoonPlots = templatePlots:Clone()

    for _, plot in tycoonPlots:GetChildren() do
        local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(plot.CFrame)
        plot.CFrame = self.TycoonInstance.CFrame:ToWorldSpace(relativeCFrame)
        plot.Parent = plotsFolder
    end

    --Initialize Buttons--
    local tycoonButtons = templateButtons:Clone()

    for _, button in tycoonButtons:GetChildren() do
        local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(button.CFrame)
        button.CFrame = self.TycoonInstance.CFrame:ToWorldSpace(relativeCFrame)

        local debounce = false
        
        button.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if not player or self.TycoonInstance:GetAttribute("Owner") ~= self.Owner.UserId then 
                return
            end

            if not debounce then
                if self.Owner:GetAttribute("Cash") >= button:GetAttribute("ItemCost") then
                    debounce = true

                    if string.sub(button:GetAttribute("ItemUnlock"), 1, 4) == "Plot" then
                        --Create plot table, insert it into self.Plots
                        local plot = Plot.new(self.Owner, self.TycoonInstance, button:GetAttribute("Location"), button:GetAttribute("ItemUnlock"))
                        self.Plots[button:GetAttribute("Location")] = plot

                        print(self.Plots)
                    else
                        table.insert(self.Unlocked, button:GetAttribute("ItemUnlock"))
                        self:UnlockItem(TycoonItems[button:GetAttribute("ItemUnlock")])
                    end
                    --TODO: Button Upgrades
                    button:Destroy()
                end
            end
        end)
        
        button.Parent = buttonsFolder
    end
end

function Tycoon:GetNewItemCFrame(itemCFrame)
    local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(itemCFrame)
    return self.TycoonInstance.CFrame:ToWorldSpace(relativeCFrame)
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
    
    itemClone.Parent = self.TycoonInstance.Items
end

function Tycoon:CleanUp()
    self.TycoonInstance:SetAttribute("Taken", false)
    self.TycoonInstance:SetAttribute("Owner", nil)
    self.TycoonInstance.Buttons:Destroy()
    self.TycoonInstance.Items:Destroy()

    self = {}
    print(self)
end

return Tycoon