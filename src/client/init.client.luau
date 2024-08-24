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
    if _gameProcessed then return end

    local actionMap = {
        [Enum.KeyCode.One] = "Plant",
        [Enum.KeyCode.Two] = "Water",
        [Enum.KeyCode.Three] = "Harvest"
    }
    
    currentAction = actionMap[input.KeyCode] or currentAction

    if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not mouse.Target then return end
    
    local target = mouse.Target
    if target:GetAttribute("Owner") ~= player.UserId then return end
    
    if target:HasTag("Field") then
        if currentAction == "Plant" and not target:GetAttribute("Taken") then
            PlantSeed:FireServer(target, "Original")
        elseif currentAction == "Water" and not target:GetAttribute("Watered") then
            WaterField:FireServer(target)
        end
    elseif target:HasTag("Teapot") and currentAction == "Harvest" then
        HarvestPot:FireServer(target)
    end
end

UserInputService.InputBegan:Connect(onInputBegan)



