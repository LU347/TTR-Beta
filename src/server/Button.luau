local Players = game:GetService("Players")
local Plot = require(game.ServerScriptService.Server.Plot)

local Button = {}
Button.__index = Button

local DEBOUNCE_COOLDOWN = 1.75

function Button.new(tycoon, instance)
    local self = setmetatable({}, Button)
    self.Tycoon = tycoon
    self.Instance = instance
    self.Debounce = false
    self.Upgradeable = instance:GetAttribute("Upgradeable")
    self.Cost = instance:GetAttribute("ItemCost")
    self.Item = instance:GetAttribute("ItemUnlock")
    self.TouchConnection = self.Instance.Touched:Connect(function(hit)
        self:OnTouch(hit)
    end)
    return self
end

function Button:OnTouch(hit)
    if self.Debounce then return end
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if not player or player.UserId ~= self.Tycoon.Owner.UserId then
        return
    end

    local playerCash = player:GetAttribute("Cash")
    if playerCash >= self.Cost then
        self.Debounce = true
        player:SetAttribute("Cash", playerCash - self.Cost)
        self:UnlockItem()
    end
end

function Button:UnlockItem()
    if string.sub(self.Item, 1, 4) == "Plot" then
        self:upgradePlot()
    else
        self:unlockTycoonItem()
    end

    if self.Upgradeable then
        self:updateButtonForUpgrade()
    else
        self:Destroy()
    end

    wait(DEBOUNCE_COOLDOWN)
    self.Debounce = false
end

function Button:upgradePlot()
    self.Location = self.Instance:GetAttribute("Location")
    if self.Tycoon.Plots[self.Location] then
        self.Tycoon.Plots[self.Location]:Upgrade(self.Item)
    else
        local plot = Plot.new(self.Tycoon.Owner, self.Location, self.Tycoon.Instance, self.Item)
        self.Tycoon.Plots[self.Location] = plot
    end
end

function Button:unlockTycoonItem()
    self.Tycoon:UnlockItem(self.Item)
    table.insert(self.Tycoon.Unlocked, self.Item)
end

function Button:updateButtonForUpgrade()
    local buttonGui = self.Instance.BillboardGui
    local nextUpgrade = ""
    local buttonLabels = {
        Plot_Medium = "Medium Plot: ",
        Plot_Large = "Large Plot: ",
        Plot_XLarge = "Extra Large Plot: ",
        Lanterns = "Lanterns: "
    }

    if string.sub(self.Item, 1, 4) == "Plot" then
        local maxUpgrade = self.Instance:GetAttribute("MaxUpgrade")
        local plotTypes = {"Plot_Small", "Plot_Medium", "Plot_Large", "Plot_XLarge"}
        local currentIndex = table.find(plotTypes, self.Item)

        if currentIndex < maxUpgrade then
            nextUpgrade = plotTypes[currentIndex + 1]
            self.Cost = 0 -- new cost
            self:updateButtonLabel(buttonGui, buttonLabels[nextUpgrade], self.Cost)
        elseif currentIndex == maxUpgrade then
            self:Destroy()
        end
    elseif string.sub(self.Item, 1, 5) == "Fence" then
        nextUpgrade = "Lanterns" .. string.sub(self.Item, 6)
        self.Cost = self.Cost * 1.5 -- update
        self.Upgradeable = false
        self:updateButtonLabel(buttonGui, buttonLabels["Lanterns"], self.Cost)
    end

    self.Item = nextUpgrade
    self.Instance:SetAttribute("ItemUnlock", self.Item)
    self.Instance:SetAttribute("Cost", self.Cost)
end

function Button:updateButtonLabel(buttonGui, label, cost)
    buttonGui.TextLabel.Text = label .. tostring(cost)
end

function Button:Destroy()
    self.Instance:Destroy()
    self.TouchConnection:Disconnect()
    self = nil
end

return Button
