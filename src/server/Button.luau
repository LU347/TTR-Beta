local Players = game:GetService("Players")
local Plot = require(game.ServerScriptService.Server.Plot)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playSound = ReplicatedStorage.RemoteEvents.PlaySound

local Button = {}
Button.__index = Button

local DEBOUNCE_COOLDOWN = 1.75

function Button.new(tycoon, instance)
    local self = setmetatable({}, Button)
    self.Tycoon = tycoon
    self.Instance = instance.Head
    self.Debounce = false
    self.Upgradeable = instance.Head:GetAttribute("Upgradeable") and instance.Head:GetAttribute("Upgradeable") or false
    self.Cost = instance.Head:GetAttribute("ItemCost")
    self.Item = instance.Head:GetAttribute("ItemUnlock")
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
        playSound:FireClient(self.Tycoon.Owner, "Buy")
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

function Button:unlockTycoonItem()
    table.insert(self.Tycoon.Unlocked, self.Item)
    self.Tycoon:CloneItem(self.Item)
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

function Button:updateButtonForUpgrade()
    local buttonModel = self.Instance.Parent
    local nextUpgrade = ""
    local buttonLabels = {
        Plot_Medium = "Medium Plot: ",
        Plot_Large = "Large Plot: ",
        Plot_XLarge = "Extra Large Plot: ",
        Lanterns = "Lanterns: "
    }

    local buttonColors = {
        Color3.fromRGB(204, 142, 105),  --nougat
        Color3.fromRGB(245, 205, 48), --bright yellow
        Color3.fromRGB(13, 105, 172) -- bright blue
    }

    local function changeColor(color)
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Bounce)
        local changeColor = TweenService:Create(self.Instance, tweenInfo, { Color = color})
        changeColor:Play()
    end

    if string.sub(self.Item, 1, 4) == "Plot" then
        local maxUpgrade = self.Instance:GetAttribute("MaxUpgrade")
        local plotTypes = {"Plot_Small", "Plot_Medium", "Plot_Large", "Plot_XLarge"}
        local currentIndex = table.find(plotTypes, self.Item)

        if currentIndex < maxUpgrade then
            nextUpgrade = plotTypes[currentIndex + 1]
            self.Cost = currentIndex * 75 + (2 * self.Cost) -- new cost
            self:updateButtonLabel(buttonModel, buttonLabels[nextUpgrade], self.Cost)
            changeColor(buttonColors[currentIndex + 1])
        elseif currentIndex == maxUpgrade then
            self:Destroy()
        end
    elseif string.sub(self.Item, 1, 5) == "Fence" then
        nextUpgrade = "Lanterns" .. string.sub(self.Item, 6)
        self.Cost = self.Cost * 1.5 -- update
        self.Upgradeable = false
        self:updateButtonLabel(buttonModel, buttonLabels["Lanterns"], self.Cost)
        changeColor(buttonColors[2])
    end

    self.Item = nextUpgrade
    self.Instance:SetAttribute("ItemUnlock", self.Item)
    self.Instance:SetAttribute("Cost", self.Cost)
end

function Button:updateButtonLabel(buttonModel, label, cost)
    buttonModel.Name = label .. tostring(cost)
end

function Button:Destroy()
    self.Instance:Destroy()
    self.TouchConnection:Disconnect()
    self = nil
end

return Button
