local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local totalDuration = 300 -- Total duration of the cycle (5 minutes) in seconds
local toggleLamps = ReplicatedStorage.RemoteEvents:WaitForChild("ToggleLamps")
--local dayEvent = ReplicatedStorage:WaitForChild("DayEvent") -- Assuming you have a RemoteEvent named "DayEvent"
--local nightEvent = ReplicatedStorage:WaitForChild("NightEvent") -- Assuming you have a RemoteEvent named "NightEvent"

local isDay = true -- Start assuming it's daytime
local startTime = 0.25

while true do
    for i = startTime, 1, 0.01 do
        local minutesAfterMidnight = i * 24 * 60
        Lighting:SetMinutesAfterMidnight(minutesAfterMidnight)

        -- Check for transitions between day and night
        if minutesAfterMidnight < 18 * 60 then
            if not isDay then
                --dayEvent:FireAllClients() -- Fire day event once at the start of the day
                toggleLamps:FireAllClients(false)
                isDay = true
            end
        else
            if isDay then
                --nightEvent:FireAllClients() -- Fire night event once at the start of the night
                print("is night")
                toggleLamps:FireAllClients(true)
                isDay = false
            end
        end

        wait(totalDuration / 100)
    end

    startTime = 0
end
