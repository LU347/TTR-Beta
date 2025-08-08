local ReplicatedStorage = game:GetService("ReplicatedStorage")
local random = Random.new()

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

return MutationTypes
