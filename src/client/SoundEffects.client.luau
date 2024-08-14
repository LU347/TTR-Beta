local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaySound = ReplicatedStorage.RemoteEvents.PlaySound

local soundFolder = ReplicatedStorage.Assets.SoundFX

local soundEffects = {
    Buy = soundFolder:WaitForChild("Buy"),
    Harvest = {
        soundFolder:WaitForChild("HighPop1"),
        soundFolder:WaitForChild("HighPop2"),
        soundFolder:WaitForChild("LowPop1"),
        soundFolder:WaitForChild("LowPop2")
    },
    Plant = soundFolder:WaitForChild("Plant"),
    Water = soundFolder:WaitForChild("Water")
}

function onPlaySound(sound)
    local function getRandomInt()
        local random = Random.new()
        return random:NextInteger(1,4)
    end

    if sound == "Harvest" then
        soundEffects["Harvest"][getRandomInt()]:Play()
    else
        soundEffects[sound]:Play()
    end
end

PlaySound.OnClientEvent:Connect(onPlaySound)
