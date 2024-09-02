local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Teapot = require(ServerScriptService.Server.Teapot)
local PlaySoundEvent = ReplicatedStorage.RemoteEvents.PlaySound

local Field = {}
Field.__index = Field

function Field.new(owner, instance, type)
    local self = setmetatable({}, Field)
    self.Owner = owner
    self.Instance = instance
    self.Type = type
    self.Teapot = {}
    self:Init()
    return self
end

local function tweenFieldColor(field, newColor)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine)
    local tween = TweenService:Create(
        field,
        tweenInfo,
        { Color = newColor }
    )
    tween:Play()
end

function Field:Init()
    CollectionService:AddTag(self.Instance, "Field")
    self.Instance:SetAttribute("Owner", self.Owner.UserId)
    self.Instance:SetAttribute("Type", self.Type)
    self.Instance:SetAttribute("Taken", false)
    self.Instance:SetAttribute("Watered", false)
    
    self.Connection = self.Instance:GetAttributeChangedSignal("Watered"):Connect(function()
        if self.Instance:GetAttribute("Watered") then
            self:PlaySound("Water")
            local wetColor = Color3.fromRGB(59, 49, 42)
            tweenFieldColor(self.Instance, wetColor)

            if #self.Teapot == 1 then
                self.Teapot[1]:Grow()
            end
        else
            local dryColor = Color3.fromRGB(86,66,54)
            tweenFieldColor(self.Instance, dryColor)
        end
    end)
end

function Field:PlaySound(action)
    PlaySoundEvent:FireClient(self.Owner, action)
end

--Bug: Teapot doesn't grow when the field is already watered
function Field:Plant(seed)
    self:PlaySound("Plant")
    self.Instance:SetAttribute("Taken", true)

    local teapot = Teapot.new(self.Owner, seed, self.Instance)
    table.insert(self.Teapot, teapot)

    if self.Instance:GetAttribute("Watered") then
        teapot:Grow()
    end
end

function Field:Water()
    local isWatered = self.Instance:GetAttribute("Watered")

    if not isWatered then
        self.Instance:SetAttribute("Watered", true)
    end
end

function Field:Harvest()
    self:PlaySound("Harvest")
    
    --temp
    local playerCash = self.Owner:GetAttribute("Cash")
    self.Owner:SetAttribute("Cash", playerCash + self.Teapot[1].CurrentValue)

    --Deletes Teapot Instance and Clears Teapot Table--
    local teapotInstance = self.Teapot[1].Instance
    CollectionService:RemoveTag(teapotInstance, "Teapot")

    teapotInstance:Destroy()

    self.Teapot = {}
    self.Instance:SetAttribute("Watered", false)
    self.Instance:SetAttribute("Taken", false)
end

return Field