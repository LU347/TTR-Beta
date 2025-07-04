--[[
    Handles player join: loading player data, tycoon setup
    Handles player leave: saving player data, tycoon cleanup
]]
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Tycoon = require(ServerScriptService.Server.TycoonHandler)

local TycoonDataStore = DataStoreService:GetDataStore("TycoonData")

local PlotsFolder = game.Workspace.Plots
local SpawnTag = "PlayerSpawn"

function LoadPlayerTycoonData(userId)
    local success, playerData = pcall(function()
        return TycoonDataStore:GetAsync(tostring(userId))
    end)

    if success then
        return playerData
    end
end

function CreateTycoon(player, unlocked, plotData)
    unlocked = unlocked or nil
    plotData = plotData or nil

    for _, plotBase in PlotsFolder:GetChildren() do
        if not plotBase:GetAttribute("Taken") then
            plotBase:SetAttribute("Taken", true)
            plotBase:SetAttribute("Owner", player.UserId)
            
            --TODO: Get player save data and load items
            local playerTycoon = Tycoon.new(player, plotBase, unlocked, plotData)
            playerTycoon:Init()

            return playerTycoon
        end
    end
end

function onPlayerAdded(player)
    --Initialize Player Stats and Spawn them in their tycoon
    if player.Name == "lucile" or player.Name == "KaretaHana5734" then
        player:SetAttribute("Cash", 1000000)
    else
        player:SetAttribute("Cash", 0)
    end

    local playerData = LoadPlayerTycoonData(player.UserId)
    local playerTycoon

    if playerData then
        player:SetAttribute("Cash", playerData["Cash"])
        playerTycoon = CreateTycoon(player, playerData["Unlocked"], playerData["Plots"])
    else
        playerTycoon = CreateTycoon(player)
    end

    Tycoon.PlayerTycoons[player.UserId] = playerTycoon

    player.CharacterAdded:Connect(function(char) 
        if char then
            wait()
            for _, spawn in pairs(CollectionService:GetTagged(SpawnTag)) do
                if spawn:GetAttribute("Owner") == player.UserId then
                    local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
                    humanoidRootPart.CFrame = spawn.CFrame
                    break
                end
            end
        end

        char.Humanoid.Died:Connect(function()
            wait(3)
            player:LoadCharacter()
        end)
    end)
    
    player:LoadCharacter()
end

function onPlayerRemoving(player)
    local playerSaveData = Tycoon.GetSerializedData(player)
    if playerSaveData then

        --Save data
        local success, err = pcall(function()
            print(playerSaveData)
            SavePlayerTycoonData(player.UserId, playerSaveData)
        end)

        if not success then
            warn("Failed to save tycoon data for " .. player.Name .. ": " .. err)
        end

        -- Clean up tycoon instance
        Tycoon.PlayerTycoons[player.UserId]:CleanUp()

        -- Remove reference from the tycoon table
        Tycoon.PlayerTycoons[player.UserId] = nil
    end
end

function SavePlayerTycoonData(userId, data)
    -- Convert to JSON-safe format if necessary
    -- (e.g., avoid instances or userdata inside `data`)
    
    local success, result = pcall(function()
        TycoonDataStore:SetAsync(tostring(userId), data)
    end)

    if not success then
        warn("Failed to save data for userId " .. userId .. ": " .. result)
        return false
    end

    print("Save success!")

    return true
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)