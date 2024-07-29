
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local tag = "LightBlock"
local lightingAttribute = "isDay"

local tweenInfo = TweenInfo.new(5)

function togglePointLight(pointLight)
    local onTween = TweenService:Create(pointLight, tweenInfo, { Brightness = 0.96 })
    local offTween = TweenService:Create(pointLight, tweenInfo, { Brightness = 0 })

    local isDay = game.Lighting:GetAttribute("isDay")

    if isDay then
        offTween:Play()
    else
        onTween:Play()
    end
end

local function onInstanceAdded(lightBlock)
    if lightBlock:IsA("PointLight") then
        togglePointLight(lightBlock)
    end
end

local function toggleAllExistingLights()
    for _, lightblock in pairs(CollectionService:GetTagged(tag)) do
        togglePointLight(lightblock)
    end
end

CollectionService:GetInstanceAddedSignal(tag):Connect(onInstanceAdded)
Lighting:GetAttributeChangedSignal(lightingAttribute):Connect(toggleAllExistingLights)