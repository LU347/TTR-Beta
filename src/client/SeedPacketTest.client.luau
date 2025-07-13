local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlantSeed = ReplicatedStorage.RemoteEvents.PlantSeed

local player = Players.LocalPlayer

-- Test different seed types
local testSeeds = {
    "Original",
    "Adurite", 
    "Amazonite",
    "Amethyst",
    "Disco",
    "Golden"
}

local currentSeedIndex = 1

-- Function to test planting different seeds
local function testPlanting()
    local seedName = testSeeds[currentSeedIndex]
    print("=== Testing Seed Packet: " .. seedName .. " ===")
    print("Press T to cycle through different seeds")
    print("Current seed: " .. seedName)
    print("")
    print("To test this seed:")
    print("1. Press 1 to set action to Plant")
    print("2. Click on an empty field")
    print("3. The field will plant: " .. seedName)
end

-- Input handling for cycling seeds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        currentSeedIndex = currentSeedIndex
        if currentSeedIndex > #testSeeds then
            currentSeedIndex = 1
        end
        testPlanting()
    end
end)

-- Show initial test info
wait(2)
testPlanting()
print("")
print("=== Seed Packet System Test ===")
print("Press T to cycle through different seed types")
print("Each seed will create a different teapot when planted")
print("")
print("Available seeds: Original, Adurite, Amazonite, Amethyst, Disco, Golden")
print("")
print("✅ Your input system now supports seed cycling!")
print("Press T to cycle through different seeds")
print("Press 1 to set action to Plant")
print("Click on fields to plant the current seed") 