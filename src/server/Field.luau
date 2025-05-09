local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Teapot = require(ServerScriptService.Server.Teapot)
local TeapotData = require(ServerScriptService.Server.TeapotData)
local Enums = require(ReplicatedStorage.Shared.Enums)
local PlaySoundEvent = ReplicatedStorage.RemoteEvents.PlaySound

local DRY_COLOR = Color3.fromRGB(86,66,54)
local WET_COLOR = Color3.fromRGB(62, 53, 47)

local Field = {}
Field.__index = Field

function Field.new(owner, instance, type)
    local self = setmetatable({}, Field)
    self.Owner = owner
    self.Instance = instance
    self.Type = type
    self.Teapot = {}
    self.IsTaken = false
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
            tweenFieldColor(self.Instance, WET_COLOR)

            if #self.Teapot == 1 then
                self.Teapot[1]:Grow()
            end
        else
            tweenFieldColor(self.Instance, DRY_COLOR)
        end
    end)
end

function Field:PlaySound(action)
    PlaySoundEvent:FireClient(self.Owner, action)
end

function Field:Plant(seed)
    local seedType = TeapotData[seed] and TeapotData[seed].Type
    local fieldType = Enums.fieldTypes[self.Type]

    if not seedType or not fieldType then
        warn("Invalid seed or field type")
        return
    end

    if seedType.Order > fieldType.Order then
        return
    end

    self:PlaySound("Plant")
    self.IsTaken = true
    self.Instance:SetAttribute("Taken", true)
        
    local teapot = Teapot.new(self.Owner, seed, self.Instance)
    table.insert(self.Teapot, teapot)
    
    --This should be in the getattributechanged func
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
    
    --TODO: Module that handles player attribute updates
    local playerCash = self.Owner:GetAttribute("Cash")
    self.Owner:SetAttribute("Cash", playerCash + self.Teapot[1].CurrentValue)

    --Debug Output
    print("Field Table")
    print(self)
    print("Teapot Table")
    print(self.Teapot)
    print("Teapot[1]")
    print(self.Teapot[1])

    self.IsTaken = false

    --Deletes Teapot Instance and Clears Teapot Table--
    local teapotInstance = self.Teapot[1].Instance
    CollectionService:RemoveTag(teapotInstance, "Teapot")

    teapotInstance:Destroy()

    self.Teapot = {}
    self.Instance:SetAttribute("Watered", false)
    self.Instance:SetAttribute("Taken", false)
end

function Field:GetTeapotTable()
    return self.Teapot
end

function Field:GetTeapotInstance()
    if self.Teapot[1] then
        return self.Teapot[1].Instance
    end

    return nil
end

return Field