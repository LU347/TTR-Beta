local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")

local tag = "LightBlock"
local lightingAttribute = "isDay"

function togglePointLight(pointLight)
    pointLight.Enabled = not game.Lighting:GetAttribute("isDay")
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