local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlantSeed = ReplicatedStorage.RemoteEvents.PlantSeed
local WaterField = ReplicatedStorage.RemoteEvents.WaterField

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
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if mouse.Target:GetAttribute("Owner") == player.UserId then
                if currentAction == "Plant" then
                    if mouse.Target:HasTag("Field") and mouse.Target:GetAttribute("Taken") == false then
                        --TODO: Change the way seeds are planted
                        PlantSeed:FireServer(mouse.Target, "Original")
                    end
                elseif currentAction == "Water" then
                    --TODO: Water Functionality
                    if mouse.Target:HasTag("Field")  and mouse.Target:GetAttribute("Watered") == false then
                        WaterField:FireServer(mouse.Target)
                    end
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(onInputBegan)