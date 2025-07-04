local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local TIME_SPEED = 360 -- 1 min = 1 hour
local START_TIME = 8 -- Starting time
local DAY_BRIGHTNESS = 2
local NIGHT_BRIGHTNESS = 10
local NIGHT_CONTRAST = -0.2
local LIGHTING_ATTRIBUTE = "isDay"

local minutesAfterMidnight = START_TIME * 60
local waitTime = 60 / TIME_SPEED
local debounce = true

local function tweenLighting(contrast, brightness)
    local tweenInfo = TweenInfo.new(3)
    local nightEffect = game.Lighting.NightEffect
    
    local contrastTransition = TweenService:Create(nightEffect, tweenInfo, { Contrast = contrast })
    contrastTransition:Play()

    local brightnessTransition = TweenService:Create(Lighting, tweenInfo, { Brightness = brightness })
    brightnessTransition:Play()
end

local function updateGameLighting()
    if Lighting:GetAttribute(LIGHTING_ATTRIBUTE) == false then
        tweenLighting(NIGHT_CONTRAST, NIGHT_BRIGHTNESS)
    else
        tweenLighting(0, DAY_BRIGHTNESS)
    end
end

local function dayNightCycle()
    while true do
        local minutesNormalized = minutesAfterMidnight % (60 * 24)
        local hours = minutesNormalized / 60
        Lighting.ClockTime = hours
        
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

        minutesAfterMidnight = minutesAfterMidnight + 1
        task.wait(waitTime)
    end
end

Lighting:GetAttributeChangedSignal("isDay"):Connect(updateGameLighting)

dayNightCycle()

