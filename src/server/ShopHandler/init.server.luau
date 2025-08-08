local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tool = require(ReplicatedStorage.Shared.Tool)

local button = workspace:WaitForChild("SeedButton")
local debounce = false

local TEST_SEED = "Disco"
local TEST_TYPE = "Medium"

local function createSeedTool(player, seedName)
	local seedTool = Tool.new(player, seedName)
	seedTool:CreateToolInstance()
end

button.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	if not debounce then
		debounce = true

		local char = humanoid.Parent
		local player = Players:GetPlayerFromCharacter(char)

		local seedTool = Tool.new(player, TEST_SEED, TEST_TYPE)
		seedTool:CreateToolInstance()
	end

	task.wait(5)

	debounce = false
end)
