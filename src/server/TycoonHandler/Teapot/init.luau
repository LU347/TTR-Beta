local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local TeapotData = require(script.Parent.TeapotData)
local TeapotEffects = require(script.TeapotEffects)

local Teapot = {}
Teapot.__index = Teapot

local random = Random.new()

-- Add this near the top of your module
local MUTATION_CHANCE = 0.15 -- 15% chance
local MUTATION_VALUE_MULTIPLIER_RANGE = { 1.2, 1.5 } -- between +20% and +50%

-- Optional: a table of visual indicators for mutations
local MutationVisuals = {
	Color = Color3.fromRGB(255, 223, 0), -- golden glow
	ParticleEffect = "MutationParticles", -- name of particle in ReplicatedStorage
}

local MUTATION_CHANCE = 0.15 -- 15% chance overall
local MutationTypes = {
	Golden = {
		ValueMultiplier = function()
			return random:NextNumber(1.3, 1.7)
		end,
		ApplyVisual = function(teapot)
			local color = Color3.fromRGB(255, 215, 0) -- gold
			local basePart = teapot.Instance:IsA("BasePart") and teapot.Instance
				or teapot.Instance:FindFirstChildWhichIsA("BasePart")
			if basePart then
				basePart.Color = color
			end
			local particles = ReplicatedStorage:FindFirstChild("GoldenParticles")
			if particles then
				local p = particles:Clone()
				p.Parent = teapot.Instance
				p.Enabled = true
			end
		end,
	},
	Giant = {
		SizeMultiplier = function()
			return random:NextNumber(1.2, 1.5)
		end,
		ValueMultiplier = function()
			return random:NextNumber(1.1, 1.3)
		end,
		ApplyVisual = function(teapot)
			local basePart = teapot.Instance:IsA("BasePart") and teapot.Instance
				or teapot.Instance:FindFirstChildWhichIsA("BasePart")
			if basePart then
				basePart.Color = Color3.fromRGB(150, 255, 150)
			end
		end,
	},
	FastGrower = {
		GrowthRateMultiplier = function()
			return random:NextNumber(0.5, 0.75)
		end, -- lower = faster
		ApplyVisual = function(teapot)
			local basePart = teapot.Instance:IsA("BasePart") and teapot.Instance
				or teapot.Instance:FindFirstChildWhichIsA("BasePart")
			if basePart then
				basePart.Color = Color3.fromRGB(100, 200, 255)
			end
		end,
	},
	DoubleValue = {
		ValueMultiplier = function()
			return 2
		end,
		ApplyVisual = function(teapot)
			local basePart = teapot.Instance:IsA("BasePart") and teapot.Instance
				or teapot.Instance:FindFirstChildWhichIsA("BasePart")
			if basePart then
				basePart.Color = Color3.fromRGB(255, 100, 100)
			end
		end,
	},
	Miniature = {
		SizeMultiplier = function()
			return random:NextNumber(0.5, 0.7)
		end,
		ValueMultiplier = function()
			return random:NextNumber(1.8, 2.2)
		end,
		ApplyVisual = function(teapot)
			local basePart = teapot.Instance:IsA("BasePart") and teapot.Instance
				or teapot.Instance:FindFirstChildWhichIsA("BasePart")
			if basePart then
				basePart.Color = Color3.fromRGB(200, 200, 255)
			end
		end,
	},
	Radiant = {
		ValueMultiplier = function()
			return random:NextNumber(1.15, 1.3)
		end,
		ApplyVisual = function(teapot)
			local glow = ReplicatedStorage:FindFirstChild("RadiantParticles")
			if glow then
				local g = glow:Clone()
				g.Parent = teapot.Instance
				g.Enabled = true
			end
		end,
	},
}

local function applyRandomMutation(self)
	if random:NextNumber() > MUTATION_CHANCE then
		self.IsMutated = false
		self.MutationType = nil
		self.MutationEffects = {}
		return
	end

	-- Pick random mutation type
	local keys = {}
	for k in pairs(MutationTypes) do
		table.insert(keys, k)
	end
	local mutationName = keys[random:NextInteger(1, #keys)]
	local mutation = MutationTypes[mutationName]

	self.IsMutated = true
	self.MutationType = mutationName
	self.MutationEffects = {}

	-- Apply numerical effects
	if mutation.ValueMultiplier then
		local mult = mutation.ValueMultiplier()
		self.MutationEffects.ValueMultiplier = mult
		self.MaxValue = math.floor(self.MaxValue * mult)
	end
	if mutation.SizeMultiplier then
		local mult = mutation.SizeMultiplier()
		self.MutationEffects.SizeMultiplier = mult
		self.Instance.Size *= mult
		self.CurrentSize = self.Instance.Size
	end
	if mutation.GrowthRateMultiplier then
		local mult = mutation.GrowthRateMultiplier()
		self.MutationEffects.GrowthRateMultiplier = mult
		self.Type.GrowthRate = self.Type.GrowthRate * mult
	end

	-- Apply visuals
	if mutation.ApplyVisual then
		mutation.ApplyVisual(self)
	end
end

local function getRandomizedAngle()
	local angle = random:NextInteger(0, 180)
	return CFrame.fromEulerAngles(0, angle, 0)
end

local function createProximityPrompt(teapotInstance, teapotObject)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ObjectText = "Teapot"
	proximityPrompt.ActionText = "Harvest"
	proximityPrompt.HoldDuration = 1.5
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = teapotInstance

	-- Connect the proximity prompt trigger to the harvest function
	proximityPrompt.Triggered:Connect(function(player)
		if player.UserId == teapotInstance:GetAttribute("Owner") then
			teapotObject:Harvest()
		end
	end)

	return proximityPrompt
end

function Teapot.FromSerializedData(owner, savedData, fieldInstance)
	local self = setmetatable({}, Teapot)

	self.Owner = owner
	self.Name = savedData.Name
	self.FieldInstance = fieldInstance
	self.CurrentSize = savedData.CurrentSize or 0
	self.CurrentValue = savedData.CurrentValue or 0
	self.MaxSize = TeapotData[self.Name].MaxSize
	self.MaxValue = TeapotData[self.Name].MaxValue
	self.Type = TeapotData[self.Name].Type
	self.Instance = nil

	self:Init()

	-- If mutation data is saved, restore it; otherwise possibly apply new one
	if savedData.IsMutated and savedData.MutationType then
		local mutation = MutationTypes[savedData.MutationType]
		if mutation then
			self.IsMutated = true
			self.MutationType = savedData.MutationType
			self.MutationEffects = savedData.MutationEffects or {}

			if self.MutationEffects.ValueMultiplier then
				self.MaxValue = math.floor(self.MaxValue * self.MutationEffects.ValueMultiplier)
			end
			if self.MutationEffects.SizeMultiplier then
				self.Instance.Size *= self.MutationEffects.SizeMultiplier
				self.CurrentSize = self.Instance.Size
			end
			if self.MutationEffects.GrowthRateMultiplier then
				self.Type.GrowthRate = self.Type.GrowthRate * self.MutationEffects.GrowthRateMultiplier
			end

			if mutation.ApplyVisual then
				mutation.ApplyVisual(self)
			end
		end
	end

	-- Position the teapot at the field instance first
	local teapotCFrame = CFrame.new(
		self.FieldInstance.CFrame.X,
		self.FieldInstance.CFrame.Y + 0.5,
		self.FieldInstance.CFrame.Z
	) * getRandomizedAngle()
	self.Instance:PivotTo(teapotCFrame)
	self.OriginalCFrame = self.Instance.CFrame

	-- Restore the saved size and position
	if savedData.CurrentSize then
		-- Convert the saved table back to Vector3
		local sizeVector = Vector3.new(savedData.CurrentSize.X, savedData.CurrentSize.Y, savedData.CurrentSize.Z)
		self.Instance.Size = sizeVector
		self.CurrentSize = sizeVector -- Update the CurrentSize property too
	end

	-- Restore the saved Y offset position
	if savedData.YOffset then
		local newPosition = Vector3.new(
			self.FieldInstance.Position.X,
			self.FieldInstance.Position.Y + savedData.YOffset,
			self.FieldInstance.Position.Z
		)
		self.Instance.Position = newPosition
	end

	-- Restore the saved value
	local currentValue = self.Instance:FindFirstChild("CurrentValue")
	if currentValue then
		currentValue.Value = self.CurrentValue
	end

	return self
end

function Teapot.new(owner, name, fieldInstance)
	local self = setmetatable({}, Teapot)
	self.Owner = owner
	self.Name = name --Saved
	self.FieldInstance = fieldInstance
	self.CurrentSize = 0 --Saved
	self.CurrentValue = 0 --Saved
	self.MaxSize = TeapotData[self.Name].MaxSize
	self.MaxValue = TeapotData[self.Name].MaxValue
	self.Type = TeapotData[self.Name].Type
	self.Instance = nil
	self:Init()
	applyRandomMutation(self)
	return self
end

function Teapot:Init()
	local teapot = ReplicatedStorage.Teapots:FindFirstChild(self.Name)
	local teapotCFrame = CFrame.new(
		self.FieldInstance.CFrame.X,
		self.FieldInstance.CFrame.Y + 0.5,
		self.FieldInstance.CFrame.Z
	) * getRandomizedAngle()

	self.Instance = teapot:Clone()
	self.Instance:PivotTo(teapotCFrame)
	self.OriginalCFrame = self.Instance.CFrame
	self.Instance.Anchored = true
	self.Instance.Parent = self.FieldInstance

	--Initialize Teapot Attributes--
	self.Instance:SetAttribute("Owner", self.Owner.UserId)
	self.Instance:SetAttribute("Location", self.FieldInstance.Name)
	self.Instance:SetAttribute("Growing", false)

	local currentValue = Instance.new("IntValue")
	currentValue.Name = "CurrentValue"
	currentValue.Value = 0
	currentValue.Parent = self.Instance

	-- Add proximity prompt for harvesting
	self.ProximityPrompt = createProximityPrompt(self.Instance, self)

	--Instance Size Change Signal
	self.Instance:GetPropertyChangedSignal("Size"):Connect(function()
		self.CurrentSize = self.Instance.Size
	end)

	TeapotEffects.AttachParticles(self.Instance)

	CollectionService:AddTag(self.Instance, "Teapot")
	self:ConnectPromptEvents()
end

function Teapot:CreateGrowTween()
	-- Clamp the target size so it never exceeds MaxSize
	local currentSize = self.Instance.Size
	local maxSize = self.MaxSize

	-- If already at or above max size, do not grow further
	if currentSize.X >= maxSize.X and currentSize.Y >= maxSize.Y and currentSize.Z >= maxSize.Z then
		self.GrowTween = nil
		self.GrowValueTween = nil
		return
	end

	-- Tween to MaxSize, not current + MaxSize
	local tweenGoal = {}
	tweenGoal.Size = maxSize

	local heightDiff = (maxSize.Y - currentSize.Y) / 2
	tweenGoal.Position =
		Vector3.new(self.Instance.Position.X, self.Instance.Position.Y + heightDiff, self.Instance.Position.Z)

	local growTime = (maxSize.Z - currentSize.Z) * self.Type.GrowthRate
	local tweenInfo =
		TweenInfo.new(math.max(growTime, 0.1), Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)

	self.GrowTween = TweenService:Create(self.Instance, tweenInfo, tweenGoal)

	local currentValue = self.Instance:FindFirstChild("CurrentValue")

	if currentValue then
		self.GrowValueTween = TweenService:Create(currentValue, tweenInfo, { Value = self.MaxValue })
	else
		self.GrowValueTween = nil
	end
end

function Teapot:Grow()
	self:CreateGrowTween()

	if self.GrowTween then
		self.GrowTween:Play()
	end
	if self.GrowValueTween then
		self.GrowValueTween:Play()
	end

	local currentValue = self.Instance:FindFirstChild("CurrentValue")
	if currentValue then
		currentValue.Changed:Connect(function(newValue)
			self.CurrentValue = newValue
		end)
	end
end

function Teapot:PauseGrowTween()
	if self.GrowTween and self.GrowTween.PlaybackState == Enum.PlaybackState.Playing then
		self.GrowTween:Pause()
	end

	if self.GrowValueTween and self.GrowValueTween.PlaybackState == Enum.PlaybackState.Playing then
		self.GrowValueTween:Pause()
	end
end

function Teapot:ResumeGrowTween()
	if self.GrowTween and self.GrowTween.PlaybackState == Enum.PlaybackState.Paused then
		self.GrowTween:Play()
	end

	if self.GrowValueTween and self.GrowValueTween.PlaybackState == Enum.PlaybackState.Paused then
		self.GrowValueTween:Play()
	end
end

-- Hook up ProximityPrompt hold events for this teapot
function Teapot:ConnectPromptEvents()
	if not self.ProximityPrompt then
		return
	end
	if self._promptConnections then
		for _, conn in ipairs(self._promptConnections) do
			conn:Disconnect()
		end
	end

	self._promptConnections = {}

	local function isOwner(player)
		return player and player.UserId == self.Instance:GetAttribute("Owner")
	end
	table.insert(
		self._promptConnections,
		ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
			if prompt == self.ProximityPrompt and isOwner(player) then
				self:PauseGrowTween()
				TeapotEffects.PlayEffect(self.Instance)
				TeapotEffects.StartShaking(self.Instance)
			end
		end)
	)
	table.insert(
		self._promptConnections,
		ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, player)
			if prompt == self.ProximityPrompt and isOwner(player) then
				self:ResumeGrowTween()
				TeapotEffects.StopEffect(self.Instance)
				TeapotEffects.StopShaking(self.Instance)
			end
		end)
	)
end

function Teapot:ApplySavedData(data)
	if not data then
		return
	end

	-- Apply saved size
	if data.CurrentSize then
		-- Convert the saved table back to Vector3
		local sizeVector = Vector3.new(data.CurrentSize.X, data.CurrentSize.Y, data.CurrentSize.Z)
		self.Instance.Size = sizeVector
		self.CurrentSize = sizeVector -- Update the CurrentSize property too
	end

	-- Apply saved Y offset position
	if data.YOffset then
		local newPosition = Vector3.new(
			self.FieldInstance.Position.X,
			self.FieldInstance.Position.Y + data.YOffset,
			self.FieldInstance.Position.Z
		)
		self.Instance.Position = newPosition
	end

	-- Apply saved value
	local currentValue = self.Instance:FindFirstChild("CurrentValue")
	if currentValue and data.CurrentValue then
		currentValue.Value = data.CurrentValue
		self.CurrentValue = data.CurrentValue
	end
end

function Teapot:GetSerializedData()
	-- Save the current size and relative position
	local serializableData = {
		Name = self.Name,
		CurrentSize = {
			X = self.Instance.Size.X,
			Y = self.Instance.Size.Y,
			Z = self.Instance.Size.Z,
		},
		CurrentValue = self.CurrentValue,
		-- Save the relative Y offset from the field
		YOffset = self.Instance.Position.Y - self.FieldInstance.Position.Y,

		-- Save mutation data
		IsMutated = self.IsMutated,
		MutationType = self.MutationType,
		MutationEffects = self.MutationEffects,
	}

	return serializableData
end

function Teapot:Harvest()
	-- Find the field that contains this teapot and call its harvest method
	local fieldName = self.Instance:GetAttribute("Location")
	if fieldName then
		-- Get the field instance
		local fieldInstance = self.FieldInstance
		if fieldInstance then
			-- Find the field table by searching through the player's tycoon
			local playerTycoon = require(script.Parent.Tycoon).PlayerTycoons[self.Owner.UserId]
			if playerTycoon then
				for plotName, plot in pairs(playerTycoon.Plots) do
					if plot.Fields and plot.Fields[fieldName] then
						plot.Fields[fieldName]:Harvest()
						return
					end
				end
			end
		end
	end
end

function Teapot:CleanUp()
	if self.ProximityPrompt then
		self.ProximityPrompt:Destroy()
		self.ProximityPrompt = nil
	end

	if self.Instance then
		TeapotEffects.Cleanup(self.Instance)
		self.Instance:Destroy()
	end

	self = nil
end

return Teapot
