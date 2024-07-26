-- Get the Lighting service
local Lighting = game:GetService("Lighting")

-- Set the duration of a full day in seconds
local dayDuration = 300 -- 10 minutes for a full cycle

-- Define time properties
local dawn = 6 -- 6 AM
local dusk = 18 -- 6 PM

-- Function to update the time of day
local function updateDayNightCycle()
    while true do
        for hour = 0, 24, 0.1 do
            -- Set the ClockTime
            Lighting.ClockTime = hour
            
            -- Adjust brightness and ambient color based on time
            if hour >= dawn and hour <= dusk then
                -- Daytime settings
                Lighting.Brightness = 2
                Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127) -- Soft daylight ambient
            else
                -- Nighttime settings
                Lighting.Brightness = 1 -- Brighter light for nighttime
                Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 100) -- Brighter night ambient
            end
            
            -- Wait a bit before updating the time again
            wait(dayDuration / 240) -- Adjust the wait time to achieve smooth transition
        end
    end
end

-- Start the day-night cycle
updateDayNightCycle()
