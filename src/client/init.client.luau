local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlantSeed = ReplicatedStorage.RemoteEvents.PlantSeed

local currentAction = ""
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local function onInputBegan(input, _gameProcessed)
    if not _gameProcessed then
        if input.KeyCode == Enum.KeyCode.One then
            --TODO: Change actions to player attribute
            currentAction = "Plant"
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if currentAction == "Plant" then
                if mouse.Target:GetAttribute("Owner") then
                    if mouse.Target:HasTag("Field") then
                        print(mouse.Target)
                        PlantSeed:FireServer(mouse.Target, "Original")
                    end
                end
                --PlantSeed:FireServer("A1", "testing")
            end
        end
    end
end

UserInputService.InputBegan:Connect(onInputBegan)