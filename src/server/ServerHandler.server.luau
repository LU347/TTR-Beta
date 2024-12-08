--[[
    Handles player join: loading player data, tycoon setup
    Handles player leave: saving player data, tycoon cleanup
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tycoon = require(ReplicatedStorage.Shared.Tycoon)

local PlotsFolder = game.Workspace.Plots
local SpawnTag = "PlayerSpawn"

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
    --Initialize Player Stats and Spawn them in their tycoon
    if player.Name == "Soccerplayer25" then
        player:SetAttribute("Cash", 1000000)
    else
        player:SetAttribute("Cash", 0)
    end

    local playerTycoon = CreateTycoon(player)
    playerTycoons[player.UserId] = playerTycoon

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
    if playerTycoons[player.UserId] then
        --TODO: Save player data
        local playerTycoon = playerTycoons[player.UserId]
        playerTycoon:CleanUp()
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)