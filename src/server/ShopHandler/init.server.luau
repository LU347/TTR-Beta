local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local seedData = require(script.seedData)
local Tool = require(ReplicatedStorage.Shared.Tool)

local buySeedEvent = ReplicatedStorage.RemoteEvents.BuySeeds

local function createSeedTool(player, seedName)
	local seedTool = Tool.new(player, seedName)
	seedTool:CreateToolInstance()
end

--server should just check the seedtype
buySeedEvent.OnServerEvent:Connect(function(player, seedName)
	local seedType = seedData[seedName]["Type"]
	local seedCost = seedData[seedName]["Cost"]
	if not seedType then
		warn("Error processing transaction")
	end
	
	local playerCash = player:GetAttribute("Cash")
	
	if playerCash >= seedCost then
		player:SetAttribute("Cash", playerCash - seedCost)
		
		local seedTool = Tool.new(player, seedName, seedType)
		seedTool:CreateToolInstance()
	else 
		warn("Not enough cash")
	end
end)
