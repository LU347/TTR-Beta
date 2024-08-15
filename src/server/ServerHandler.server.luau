--[[
    Handles player join: loading player data, tycoon setup
    Handles player leave: saving player data, tycoon cleanup
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tycoon = require(ReplicatedStorage.Shared.Tycoon)

local PlotsFolder = game.Workspace.Plots

local playerTycoons = {}

function CreateTycoon(player)
    for _, plot in PlotsFolder:GetChildren() do
        if not plot:GetAttribute("Taken") then
            plot:SetAttribute("Taken", true)
            plot:SetAttribute("Owner", player.UserId)
            
            --TODO: Get player save data and load items
            local playerTycoon = Tycoon.new(player, plot, "")
            playerTycoon:Init()
            return playerTycoon
        end
    end
end

function onPlayerAdded(player)
    player:SetAttribute("Cash", 0)

    local playerTycoon = CreateTycoon(player)
    playerTycoons[player.UserId] = playerTycoon
end

function onPlayerRemoving(player)
    if playerTycoons[player.UserId] then
        --TODO: Save player data
        local playerTycoon = playerTycoons[player.UserId]
        playerTycoon:CleanUp()
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)