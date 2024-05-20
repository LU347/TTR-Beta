local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TycoonItemData = require(ReplicatedStorage.Shared.TycoonItemData)
local TycoonComponents = require(ReplicatedStorage.Shared.TycoonComponents)
local Plot = require(game.ServerScriptService.Server.Plot)

local PlantSeed = ReplicatedStorage.RemoteEvents.PlantSeed
local WaterField = ReplicatedStorage.RemoteEvents.WaterField
local HarvestPot = ReplicatedStorage.RemoteEvents.HarvestPot

local Tycoon = {}
Tycoon.__index = Tycoon

local TemplatePlot = game.Workspace.TemplatePlot --replace
local templatePlotsFolder = TemplatePlot.Plots
local templateButtonsFolder = TemplatePlot.Buttons

local ServerTycoons = {}

local DEBOUNCE_COOLDOWN = 1.75

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
    local tycoonPlots = templatePlotsFolder:Clone()

    for _, plot in tycoonPlots:GetChildren() do
        local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(plot.CFrame)
        plot.CFrame = self.Instance.CFrame:ToWorldSpace(relativeCFrame)
        plot.Parent = plotsFolder
    end

    --[[
        Buttons from the template tycoon are cloned and transferred onto the player's tycoon
    ]]
    local tycoonButtons = templateButtonsFolder:Clone()

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
                local itemCost = button:GetAttribute("ItemCost")
                local itemName = button:GetAttribute("ItemUnlock")
                local itemLocation = button:GetAttribute("Location")
                local playerCash = self.Owner:GetAttribute("Cash")

                if playerCash >= itemCost then
                    debounce = true
                    playerCash = playerCash - itemCost
                    self.Owner:SetAttribute("Cash", playerCash)
                    
                    if string.sub(itemName, 1, 4) == "Plot" then
                        --Clears the old plot table and replaces it with the upgraded plot
                        if self.Plots[itemLocation] ~= nil then
                            self.Plots[itemLocation]:Clean()
                        end
                        --Creates a Plot table and inserts it into self.Plots / Tycoon.Plots--
                        local plot = Plot.new(self.Owner, itemLocation, self.Instance, itemName)
                        self.Plots[itemLocation] = plot
                        --Plot Upgrade Progression
                        local maxUpgrade = button:GetAttribute("MaxUpgrade")
                        local plots = {"Plot_Small", "Plot_Medium", "Plot_Large", "Plot_XLarge"}
                        local currentIndex = table.find(plots, itemName)
                        
                        local buttonLabels = {
                            ["Plot_Medium"] = "Medium Plot: ",
                            ["Plot_Large"] = "Large Plot: ",
                            ["Plot_XLarge"] = "Extra Large Plot: "
                        }

                        if currentIndex < maxUpgrade then
                            local nextItem = plots[currentIndex + 1]
                            button:SetAttribute("ItemUnlock", nextItem)
                            local buttonGui = button.BillboardGui
                            --need to get cost of next item
                            buttonGui.TextLabel.Text = buttonLabels[nextItem] .. tostring(button:GetAttribute("ItemCost"))
                        elseif currentIndex == maxUpgrade then
                            button:Destroy()
                        end
                    else
                        self:UnlockItem(TycoonItemData[itemName])
                        button:Destroy()
                    end
                    
                    if table.find(self.Unlocked, itemLocation) == nil then
                        table.insert(self.Unlocked, itemLocation)
                    end
                end

                wait(DEBOUNCE_COOLDOWN)

                debounce = false

                print(ServerTycoons) --printing how a user's save data would look like
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

local function getFieldTable(player, fieldInstance)
    --Finds the plot table and returns the field table that matches the fieldInstance
    if ServerTycoons[player.UserId] then
        local plots = ServerTycoons[player.UserId].Plots
        local plotLocation = "Plot" .. string.upper(string.sub(fieldInstance, 1,1))
        
        if plots[plotLocation] then
            local f = plots[plotLocation].Fields
            for fieldKey, _ in f do
                if fieldKey == fieldInstance then
                    return plots[plotLocation]
                else
                    continue
                end
            end
        end
    end

    return nil
end

PlantSeed.OnServerEvent:Connect(function(player, fieldInstance, seed)
    local fieldTable = getFieldTable(player, fieldInstance.Name)    
    fieldTable:Plant(fieldInstance, seed)
end)

WaterField.OnServerEvent:Connect(function(player, fieldInstance)
    local fieldTable = getFieldTable(player, fieldInstance.Name)
    fieldTable:Water(fieldInstance)
end)

HarvestPot.OnServerEvent:Connect(function(player, teapot)
    local fieldTable = getFieldTable(player, teapot:GetAttribute("Location"))
    local location = teapot:GetAttribute("Location")
    fieldTable:Harvest(fieldTable.Fields[location], fieldTable.Fields[location].Instance)
end)

return Tycoon