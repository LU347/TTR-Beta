local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tool = require(ReplicatedStorage.Shared.Tool)

local button = workspace:WaitForChild("SeedButton")
local debounce = false

local TEST_SEED = "Original"
local TEST_TYPE = "Small"

button.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	if not debounce then
		debounce = true

		local char = humanoid.Parent
		local player = Players:GetPlayerFromCharacter(char)

		local seedTool = Tool.new(player, TEST_SEED)
		seedTool:CreateToolInstance()
	end
end)
