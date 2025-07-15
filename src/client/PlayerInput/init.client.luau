local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlantSeed = ReplicatedStorage.RemoteEvents.PlantSeed
local WaterField = ReplicatedStorage.RemoteEvents.WaterField

local currentAction = ""
local currentSeed = "Amazonite" -- Default seed
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Available seeds for testing
local availableSeeds = {
    "Original",
    "Adurite", 
    "Amazonite",
    "Amethyst",
    "Disco",
    "Golden"
}
local currentSeedIndex = 3 -- Start with Amazonite (index 3)

local function onInputBegan(input, _gameProcessed)
    if _gameProcessed then return end

    local actionMap = {
        [Enum.KeyCode.One] = "Plant",
        [Enum.KeyCode.Two] = "Water"
    }
    
    currentAction = actionMap[input.KeyCode] or currentAction
    
    -- Cycle through seeds with T key
    if input.KeyCode == Enum.KeyCode.T then
        currentSeedIndex = currentSeedIndex + 1
        if currentSeedIndex > #availableSeeds then
            currentSeedIndex = 1
        end
        currentSeed = availableSeeds[currentSeedIndex]
        print("Current seed: " .. currentSeed)
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not mouse.Target then return end
    
    local target = mouse.Target
    if target:GetAttribute("Owner") ~= player.UserId then return end
    
    if target:HasTag("Field") then
        if currentAction == "Plant" and not target:GetAttribute("Taken") then
            PlantSeed:FireServer(target, currentSeed)
        elseif currentAction == "Water" and not target:GetAttribute("Watered") then
            WaterField:FireServer(target)
        end
    end
end

UserInputService.InputBegan:Connect(onInputBegan)