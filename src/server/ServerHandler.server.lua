--[[
    Handles player join: loading player data, tycoon setup
    Handles player leave: saving player data, tycoon cleanup
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tycoon = require(ReplicatedStorage.Shared.Tycoon)

local Plots = game.Workspace.Plots

local SPRINT_COOLDOWN = 3
local MAX_WALKSPEED = 24
local DEFAULT_WALKSPEED = 16
local playerSprinting = false
local playerRunning = false
local debounce = false

local startTime = os.clock()
local currentTime = os.clock()

local playerTycoons = {}

function AssignTycoon(plr)
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
    player:SetAttribute("Cash", 0)
    AssignTycoon(player)
    player.CharacterAdded:Connect(function(char)
        local humanoid = char.Humanoid
        local dustParticle = ReplicatedStorage.Assets:FindFirstChild("DustParticle")
        local dustLeftClone = dustParticle:Clone()
        local dustRightClone = dustParticle:Clone()

        dustLeftClone.Parent = char.LeftFoot
        dustRightClone.Parent = char.RightFoot

        humanoid.Running:Connect(function(speed: number)
            if speed > 0 then
                playerRunning = true
            else 
                playerRunning = false
                playerSprinting = false
                debounce = false
            end

            --todo: fix sprint
            if playerSprinting then
                dustLeftClone.Enabled = true
                dustRightClone.Enabled = true
                humanoid.WalkSpeed = MAX_WALKSPEED
            else
                dustRightClone.Enabled = false
                dustRightClone.Enabled = false
                humanoid.WalkSpeed = DEFAULT_WALKSPEED
            end
        end)
    end)
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