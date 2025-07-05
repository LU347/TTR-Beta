local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Plot = require(script.Parent.Plot)

local playSound = ReplicatedStorage.RemoteEvents.PlaySound

local Button = {}
Button.__index = Button

local DEBOUNCE_COOLDOWN = 1.75

local PLOT_UPGRADES = {
    Plot_Small = { next = "Plot_Medium", label = "Medium Plot: ", color = Color3.fromRGB(204, 142, 105) },
    Plot_Medium = { next = "Plot_Large", label = "Large Plot: ", color = Color3.fromRGB(245, 205, 48) },
    Plot_Large = { next = "Plot_ExtraLarge", label = "Extra Large Plot: ", color = Color3.fromRGB(13, 105, 172) },
}

function Button.new(tycoon, instance)
    local self = setmetatable({}, Button)
    self.Tycoon = tycoon
    self.Instance = instance.Head
    self.Debounce = false
    self.Upgradeable = instance.Head:GetAttribute("Upgradeable") and instance.Head:GetAttribute("Upgradeable") or false
    self.MaxUpgrade = instance.Head:GetAttribute("MaxUpgrade")
    self.Cost = instance.Head:GetAttribute("ItemCost")
    self.Item = instance.Head:GetAttribute("ItemUnlock")
    self.TouchConnection = self.Instance.Touched:Connect(function(hit)
        self:OnTouch(hit)
    end)
    return self
end

function Button:OnTouch(hit)
    if self.Debounce then return end

    local character = hit.Parent
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end

    local owner = self.Tycoon.Owner
    if player.UserId ~= owner.UserId then return end

    self.Debounce = true

    local function resetDebounce()
        task.wait(DEBOUNCE_COOLDOWN)
        self.Debounce = false
    end

    local playerCash = player:GetAttribute("Cash")
    if playerCash < self.Cost then
        playSound:FireClient(owner, "Error")
        resetDebounce()
        return
    end

    local success = self:UnlockItem()
    if success then
        player:SetAttribute("Cash", playerCash - self.Cost)
        playSound:FireClient(owner, "Buy")
        self:UpdateButtonForUpgrade()
    else
        playSound:FireClient(owner, "Error")
    end

    resetDebounce()
end

function Button:UnlockItem()
    if self.Upgradeable then
        --Plots are the only items that can be upgraded for now
        if string.sub(self.Item, 1, 4) == "Plot" then
            local success = self:UpgradePlot()
            if not success then
                return false
            end
        end
    else
        self:UnlockTycoonItem()
        self:Destroy()
    end

    return true
end

function Button:UnlockTycoonItem()
    table.insert(self.Tycoon.Unlocked, self.Item)
    self.Tycoon:CloneItem(self.Item)
end

function Button:UpgradePlot()
    self.Location = self.Instance:GetAttribute("Location")

    if self.Tycoon.Plots[self.Location] then
        return self.Tycoon.Plots[self.Location]:Upgrade(self.Item)
    else
        local plot = Plot.new(self.Tycoon.Owner, self.Location, self.Tycoon.Instance, self.Item)
        self.Tycoon.Plots[self.Location] = plot
    end

    return true
end

-- self.Cost = currentIndex * 75 + (2 * self.Cost) -- new cost
function Button:UpdateButtonForUpgrade()
    local upgradeInfo = PLOT_UPGRADES[self.Item]
    local buttonModel = self.Instance.Parent

    if not upgradeInfo then return end

    local plotOrder = { "Plot_Small", "Plot_Medium", "Plot_Large", "Plot_ExtraLarge" }
    local currentIndex = table.find(plotOrder, self.Item)

    if currentIndex then
        self.Cost = currentIndex * 75 + (2 * self.Cost)
    end

    self.Item = upgradeInfo.next
    self.Instance:SetAttribute("ItemUnlock", self.Item)
    self.Instance:SetAttribute("Cost", self.Cost)

    self:UpdateButtonLabel(buttonModel, upgradeInfo.label, self.Cost)

    local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Bounce)
    local changeColor = TweenService:Create(self.Instance, tweenInfo, { Color = upgradeInfo.color })

    changeColor:Play()

    if currentIndex >= self.Instance:GetAttribute("MaxUpgrade") then
        self:Destroy()
    end
end

function Button:UpdateButtonLabel(buttonModel, label, cost)
    buttonModel.Name = label .. tostring(cost)
end

function Button:Destroy()
    self.Instance:Destroy()
    self.TouchConnection:Disconnect()
    self = nil
end

return Button
