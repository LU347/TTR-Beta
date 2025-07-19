local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Teapot = require(script.Parent.Teapot)
local TeapotData = require(script.Parent.TeapotData)
local SeedPacket = require(script.Parent.SeedPacket)
local Enums = require(ReplicatedStorage.Shared.Enums)

local PlaySoundEvent = ReplicatedStorage.RemoteEvents.PlaySound

local DRY_COLOR = Color3.fromRGB(86, 66, 54)
local WET_COLOR = Color3.fromRGB(62, 53, 47)

local Field = {}
Field.__index = Field

function Field.FromSerializedData(owner, instance, savedData)
	local self = setmetatable({}, Field)

	self.Owner = owner
	self.Instance = instance
	self.Type = savedData.Type
	self.IsTaken = savedData.IsTaken
	self.IsWatered = savedData.IsWatered
	self.Teapot = {}
	self.Connection = nil

	self:Init()

	if savedData.Teapot then
		-- Recreate the teapot (assuming Teapot has a similar FromSerializedData method)
		local teapot = Teapot.FromSerializedData(owner, savedData.Teapot, instance)
		table.insert(self.Teapot, teapot)

		if self.IsWatered then
			teapot:Grow() -- optional, if you want to grow it immediately
		end
	end

	self.Instance:SetAttribute("Taken", self.IsTaken)
	self.Instance:SetAttribute("Watered", self.IsWatered)

	return self
end

function Field:ApplySavedData(data)
	if not data then
		return
	end

	-- Apply saved field properties
	self.IsTaken = data.IsTaken or false
	self.IsWatered = data.IsWatered or false

	-- Set field attributes
	self.Instance:SetAttribute("Taken", self.IsTaken)
	self.Instance:SetAttribute("Watered", self.IsWatered)

	-- Apply saved teapot data if it exists
	if data.Teapot and data.Teapot.Name then
		-- Create teapot from saved data
		local teapot = Teapot.FromSerializedData(self.Owner, data.Teapot, self.Instance)
		table.insert(self.Teapot, teapot)

		-- If the field was watered, grow the teapot
		if self.IsWatered then
			teapot:Grow()
		end
	end
end

function Field.new(owner, instance, type)
	local self = setmetatable({}, Field)

	self.Owner = owner
	self.Instance = instance
	self.Type = type --saved
	self.Teapot = {} --saved
	self.IsTaken = false --saved
	self.IsWatered = false --saved
	self.Connection = nil

	self:Init()

	return self
end

local function tweenFieldColor(field, newColor)
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine)
	local tween = TweenService:Create(field, tweenInfo, { Color = newColor })

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

			self.IsWatered = true
		else
			tweenFieldColor(self.Instance, DRY_COLOR)

			self.IsWatered = false
		end
	end)
end

function Field:PlaySound(action)
	PlaySoundEvent:FireClient(self.Owner, action)
end

function Field:Plant(seed)
	-- Create a seed packet from the seed name
	local seedPacket = SeedPacket.new(seed, 1)

	local seedType = seedPacket.Type
	local fieldType = Enums.fieldTypes[self.Type]

	if not seedType or not fieldType then
		warn("Invalid seed or field type")
		return false
	end

	if seedType.Order > fieldType.Order then
		warn("Seed type too large for this field")
		return false
	end

	self:PlaySound("Plant")

	self.IsTaken = true
	self.Instance:SetAttribute("Taken", true)

	-- Plant the seed packet to create a teapot
	local teapot = seedPacket:Plant(self.Owner, self.Instance)

	if teapot then
		table.insert(self.Teapot, teapot)

		--This should be in the getattributechanged func
		if self.Instance:GetAttribute("Watered") then
			teapot:Grow()
		end

		return true
	else
		warn("Failed to create teapot from seed packet")
		return false
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

	self.IsTaken = false

	--Deletes Teapot Instance and Clears Teapot Table--
	local teapotInstance = self.Teapot[1].Instance

	CollectionService:RemoveTag(teapotInstance, "Teapot")

	teapotInstance:Destroy()

	self.Teapot[1]:CleanUp()

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

function Field:GetSerializedData()
	if not self.Teapot[1] then
		return {}
	end

	local teapotData = self.Teapot[1]:GetSerializedData()

	local serializableData = {
		Type = self.Type,
		Teapot = teapotData,
		IsTaken = self.IsTaken,
		IsWatered = self.IsWatered,
	}

	return serializableData
end

function Field:CleanUp()
	if self.Teapot[1] then
		self.Teapot[1]:CleanUp()
	end

	self.Connection:Disconnect()
	self.Connection = nil

	self.Instance:Destroy()

	self = nil
end

return Field
