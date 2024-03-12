local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TycoonItemData = require(ReplicatedStorage.Shared.TycoonItemData)
local Plot = require(game.ServerScriptService.Server.Plot)

local PlantSeed = ReplicatedStorage.RemoteEvents.PlantSeed
local WaterField = ReplicatedStorage.RemoteEvents.WaterField

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

local ServerTycoons = {}

--local DEBOUNCE_COOLDOWN = 2

function Tycoon.new(player, tycoonInstance, unlocked)
    local self = setmetatable({}, Tycoon)
    self.Owner = player
    self.Unlocked = {}                   --Saved
    self.Plots = {}                      --Saved
    self.Instance = tycoonInstance --Not Saved

    ServerTycoons[player.UserId] = self

    return self
end

function Tycoon:Init()
    local buttonsFolder = Instance.new("Folder")
    buttonsFolder.Name = "Buttons"
    buttonsFolder.Parent = self.Instance

    local itemsFolder = Instance.new("Folder")
    itemsFolder.Name = "Items"
    itemsFolder.Parent = self.Instance

    local plotsFolder = Instance.new("Folder")
    plotsFolder.Name = "Plots"
    plotsFolder.Parent = self.Instance

    --Initialize Plot Locations--
    local tycoonPlots = templatePlots:Clone()

    for _, plot in tycoonPlots:GetChildren() do
        local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(plot.CFrame)
        plot.CFrame = self.Instance.CFrame:ToWorldSpace(relativeCFrame)
        plot.Parent = plotsFolder
    end

    --Initialize Buttons--
    local tycoonButtons = templateButtons:Clone()

    for _, button in tycoonButtons:GetChildren() do
        local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(button.CFrame)
        button.CFrame = self.Instance.CFrame:ToWorldSpace(relativeCFrame)

        local debounce = false
        
        button.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if not player or self.Instance:GetAttribute("Owner") ~= self.Owner.UserId then 
                return
            end

            if not debounce then
                if self.Owner:GetAttribute("Cash") >= button:GetAttribute("ItemCost") then
                    debounce = true

                    if string.sub(button:GetAttribute("ItemUnlock"), 1, 4) == "Plot" then
                        --Create plot table, insert it into self.Plots
                        local plot = Plot.new(self.Owner, button:GetAttribute("Location"), self.Instance, button:GetAttribute("ItemUnlock"))
                        self.Plots[button:GetAttribute("Location")] = plot
                    else
                        table.insert(self.Unlocked, button:GetAttribute("ItemUnlock"))
                        self:UnlockItem(TycoonItems[button:GetAttribute("ItemUnlock")])
                    end
                    --TODO: Button Upgrades
                    button:Destroy()
                end
                print(ServerTycoons)
            end
        end)
        button.Parent = buttonsFolder
    end
end

function Tycoon:GetNewItemCFrame(itemCFrame)
    local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(itemCFrame)
    return self.Instance.CFrame:ToWorldSpace(relativeCFrame)
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
    
    itemClone.Parent = self.Instance.Items
end

function Tycoon:CleanUp()
    self.Instance:SetAttribute("Taken", false)
    self.Instance:SetAttribute("Owner", nil)
    self.Instance.Buttons:Destroy()
    self.Instance.Items:Destroy()
    self = nil
end

local function getPlotField(player, fieldInstance)
    if ServerTycoons[player.UserId] then
        local plots = ServerTycoons[player.UserId].Plots
        local fieldLocation = "Plot" .. string.upper(string.sub(fieldInstance.Name, 1,1))
        
        if plots[fieldLocation] then
            local f = plots[fieldLocation].Fields
            for fieldKey, _ in f do
                if fieldKey == fieldInstance.Name then
                    return plots[fieldLocation]
                else
                    continue
                end
            end
        end
    end
end

PlantSeed.OnServerEvent:Connect(function(player, fieldInstance, seed)
    local field = getPlotField(player, fieldInstance)
    field:Plant(fieldInstance, seed)
end)

WaterField.OnServerEvent:Connect(function(player, fieldInstance)
    local field = getPlotField(player, fieldInstance)
    field:Water(fieldInstance)
end)

return Tycoon