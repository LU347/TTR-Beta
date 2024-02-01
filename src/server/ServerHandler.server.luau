--[[
    Handles player join: loading player data, tycoon setup
    Handles player leave: saving player data, tycoon cleanup
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tycoon = require(ReplicatedStorage.Shared.Tycoon)

local Plots = game.Workspace.Plots

local playerTycoons = {}

local function AssignTycoon(plr)
    for _, plot in Plots:GetChildren() do
        if plot:GetAttribute("Taken") then 
            continue 
        else
            plot:SetAttribute("Taken", true)
            plot:SetAttribute("Owner", plr.UserId)
            
            --TODO: Get player save data and load items
            local playerTycoon = Tycoon.new(plr, plot, "")
            playerTycoons[plr.UserId] = playerTycoon
            playerTycoon:Init()

            break
        end

    end
end

function onPlayerAdded(player)
    AssignTycoon(player)
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