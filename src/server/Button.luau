
local Players = game:GetService("Players")
local Plot = require(game.ServerScriptService.Server.Plot)

local Button = {}
Button.__index = Button

local DEBOUNCE_COOLDOWN = 1.75

function Button.new(tycoon, instance)
    local self = setmetatable({}, Button)
    self.Tycoon = tycoon
    self.Instance = instance    --Not saved
    self.Debounce = false
    self.Upgradeable = instance:GetAttribute("Upgradeable")
    self.Cost = instance:GetAttribute("ItemCost");
    self.Item = instance:GetAttribute("ItemUnlock");
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
        self.Location = self.Instance:GetAttribute("Location");

        --Upgrades the current plot if there is an existing plot table
        if self.Tycoon.Plots[self.Location] ~= nil then
            self.Tycoon.Plots[self.Location]:Upgrade(self.Item)
        else
            --Creates a Plot table and inserts it into self.Plots / Tycoon.Plots--
            local plot = Plot.new(self.Tycoon.Owner, self.Location, self.Tycoon.Instance, self.Item)
            self.Tycoon.Plots[self.Location] = plot
        end

        --TODO: Finish cleanup
        --Plot Upgrade Progression (Need to move to Plot:Upgrade())
        local maxUpgrade = self.Instance:GetAttribute("MaxUpgrade")
        local plotTypes = {"Plot_Small", "Plot_Medium", "Plot_Large", "Plot_XLarge"}
        local currentIndex = table.find(plotTypes, self.Item)
        local buttonLabels = {
            ["Plot_Medium"] = "Medium Plot: ",
            ["Plot_Large"] = "Large Plot: ",
            ["Plot_XLarge"] = "Extra Large Plot: "
        }

        if currentIndex < maxUpgrade then
            local nextUpgrade = plotTypes[currentIndex + 1]
            self.Item = nextUpgrade
            self.Cost = 0 -- new cost
            self.Instance:SetAttribute("ItemUnlock", self.Item)
            self.Instance:SetAttribute("Cost", 0) -- new cost

            local buttonGui = self.Instance.BillboardGui
            buttonGui.TextLabel.Text = buttonLabels[nextUpgrade] .. tostring(self.Cost)
        elseif currentIndex == maxUpgrade then
            self:Destroy()
        end
    else
        self.Tycoon:UnlockItem(self.Item)
        table.insert(self.Tycoon.Unlocked, self.Item)
        self:Destroy()
    end

    wait(DEBOUNCE_COOLDOWN)
        
    self.Debounce = false
end

function Button:Destroy()
    self.Instance:Destroy()
    self.TouchConnection:Disconnect()
    self = {}
end

return Button