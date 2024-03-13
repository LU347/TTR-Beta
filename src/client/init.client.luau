local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlantSeed = ReplicatedStorage.RemoteEvents.PlantSeed
local WaterField = ReplicatedStorage.RemoteEvents.WaterField
local HarvestPot = ReplicatedStorage.RemoteEvents.HarvestPot

local currentAction = ""
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local function onInputBegan(input, _gameProcessed)
    if not _gameProcessed then
        if input.KeyCode == Enum.KeyCode.One then
            --TODO: Change actions to player attribute
            currentAction = "Plant"
        elseif input.KeyCode == Enum.KeyCode.Two then
            currentAction = "Water"
        elseif input.KeyCode == Enum.KeyCode.Three then
            currentAction = "Harvest"
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if mouse.Target == nil then return end

            if mouse.Target:GetAttribute("Owner") == player.UserId then
                if mouse.Target:HasTag("Field") then
                    if currentAction == "Plant" then
                        if mouse.Target:GetAttribute("Taken") == false then
                            PlantSeed:FireServer(mouse.Target, "Original")
                        end
                    elseif currentAction == "Water" then
                        if mouse.Target:GetAttribute("Watered") == false then
                            WaterField:FireServer(mouse.Target)
                        end
                    end
                elseif mouse.Target:HasTag("Teapot") then
                    if currentAction == "Harvest" then
                        HarvestPot:FireServer(mouse.Target)
                    end
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(onInputBegan)