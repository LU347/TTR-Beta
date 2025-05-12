--[[
    Handles player join: loading player data, tycoon setup
    Handles player leave: saving player data, tycoon cleanup
]]

local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TycoonDataStore = DataStoreService:GetDataStore("TycoonData")
local Tycoon = require(ReplicatedStorage.Shared.Tycoon)

local PlotsFolder = game.Workspace.Plots
local SpawnTag = "PlayerSpawn"

local ServerTycoons = {}

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
    --Initialize Player Stats and Spawn them in their tycoon
    if player.Name == "lucile" or player.Name == "KaretaHana5734" then
        player:SetAttribute("Cash", 1000000)
    else
        player:SetAttribute("Cash", 0)
    end

    local playerTycoon = CreateTycoon(player)
    ServerTycoons[player.UserId] = playerTycoon

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
    local playerTycoon = ServerTycoons[player.UserId]
    if playerTycoon then
        -- Save player data (example: save to DataStore or custom system)
        local dataToSave = {
            Unlocked = playerTycoon.Unlocked,
            Plots = playerTycoon.Plots
        }

        --Save data
        local success, err = pcall(function()
            SavePlayerTycoonData(player.UserId, dataToSave)
        end)

        if not success then
            warn("Failed to save tycoon data for " .. player.Name .. ": " .. err)

        end

        -- Clean up tycoon instance
        playerTycoon:CleanUp()

        -- Remove reference from the tycoon table
        ServerTycoons[player.UserId] = nil
    end
end

--[[

TODO:
⚠️ Important Tips:
data must be a table containing only serializable values (strings, numbers, booleans, tables). No Instances, Vector3s, etc.

Use tostring(userId) as the key to ensure consistency in SetAsync/GetAsync.
]]--
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

    return true
end

--Retrieves player tycoon data from the Tycoon module
function setPlayerData(player, key, value)
    local playerData = Tycoon.getPlayerData(player)
    if playerData then
        ServerTycoons[player.UserId] = playerData
    else
        warn("Failed to fetch data for " .. player.Name)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)