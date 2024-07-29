local Lighting = game:GetService("Lighting")

local TIME_SPEED = 360 -- 1 min = 1 hour
local START_TIME = 8 -- Starting time

local minutesAfterMidnight = START_TIME * 60
local waitTime = 60 / TIME_SPEED
local debounce = true

while true do
    minutesAfterMidnight = minutesAfterMidnight + 1
    
    local minutesNormalized = minutesAfterMidnight % (60 * 24)
    local hours = minutesNormalized / 60

    Lighting.ClockTime = hours

	task.wait(waitTime)

    if  hours >= 18 or hours <= 06 then
        if not debounce then
            Lighting:SetAttribute("isDay", false)
            debounce = true
        end
    elseif hours > 6.2 and hours < 18 then
        if debounce then
            Lighting:SetAttribute("isDay", true)
            debounce = false
        end
    end
end
