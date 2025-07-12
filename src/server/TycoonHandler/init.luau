local Tycoon = require(script.Tycoon)

local TycoonHandler = {}

local PLOTS_FOLDER = workspace.Plots

--Contains non-serialized data (plot, field, and teapot instances)
local playerTycoons = {}

function TycoonHandler.createTycoon(player, playerData)
    print(playerData)
    playerData = playerData or nil

    --create tycoon instance
    for _, plotBase in ipairs(PLOTS_FOLDER:GetChildren()) do
        if not plotBase:GetAttribute("Taken") then
            plotBase:SetAttribute("Taken", true)
            plotBase:SetAttribute("Owner", player.UserId)

            local tycoonObject = Tycoon.new(player, plotBase, playerData)
            Tycoon.PlayerTycoons[player.UserId] = tycoonObject
            tycoonObject:Init()

            if playerData then
                tycoonObject:ApplySavedData(playerData)
            end

            break
        end
    end
end

function TycoonHandler.removeTycoon(player)
    if Tycoon.PlayerTycoons[player.UserId] then
        Tycoon.PlayerTycoons[player.UserId]:CleanUp()
        Tycoon.PlayerTycoons[player.UserId] = nil
    end
end

return TycoonHandler