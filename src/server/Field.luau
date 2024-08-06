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

function Field:Init()
    CollectionService:AddTag(self.Instance, "Field")
    self.Instance:SetAttribute("Owner", self.Owner.UserId)
    self.Instance:SetAttribute("Type", self.Type)
    self.Instance:SetAttribute("Taken", false)
    self.Instance:SetAttribute("Watered", false)
    self.Connection = self.Instance:GetAttributeChangedSignal("Watered"):Connect(function()
       if #self.Teapot == 1 then
        self.Teapot[1]:Grow()
       end
    end)
end

function Field:PlaySound(action)
    PlaySoundEvent:FireClient(self.Owner, action)
end

function Field:Plant(seed)
    self:PlaySound("Plant")
    self.Instance:SetAttribute("Taken", true)

    local teapot = Teapot.new(self.Owner, seed, self.Instance)
    table.insert(self.Teapot, teapot)
end

function Field:Water()
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine)
    local isWatered = self.Instance:GetAttribute("Watered")

    local function tweenFieldColor(newColor)
        local tween = TweenService:Create(
            self.Instance,
            tweenInfo,
            { Color = newColor }
        )
        tween:Play()
    end
    
    if not isWatered then
        self:PlaySound("Water")

        local wetColor = Color3.fromRGB(70,53,44)
        tweenFieldColor(wetColor)

        self.Instance:SetAttribute("Watered", true)
    else
        local dryColor = Color3.fromRGB(86,66,54)
        tweenFieldColor(dryColor)

        self.Instance:SetAttribute("Watered", false)
    end
end

function Field:Harvest()
end



return Field