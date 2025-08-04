--[[
    Handles player join: loading player data, tycoon setup
    Handles player leave: saving player data, tycoon cleanup
]]
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Tycoon = require(script.Tycoon)

local TycoonDataStore = DataStoreService:GetDataStore("TycoonData")

local PLOTS_FOLDER = workspace.Plots

local SpawnTag = "PlayerSpawn"

local STARTING_CASH = 50

function LoadPlayerTycoonData(userId)
	local success, playerData = pcall(function()
		return TycoonDataStore:GetAsync(tostring(userId))
	end)

	if success then
		return playerData
	end
end

function createTycoon(player, playerData)
	playerData = playerData or nil

	--create tycoon instance
	for _, plotBase in ipairs(PLOTS_FOLDER:GetChildren()) do
		if not plotBase:GetAttribute("Taken") then
			plotBase:SetAttribute("Taken", true)
			plotBase:SetAttribute("Owner", player.UserId)

			local tycoonObject = Tycoon.new(player, plotBase, playerData)
			Tycoon.PlayerTycoons[player.UserId] = tycoonObject
			tycoonObject:Init()

			if playerData then
				tycoonObject:ApplySavedData(playerData)
			end

			return
		end
	end
end

function removeTycoon(player)
	if Tycoon.PlayerTycoons[player.UserId] then
		Tycoon.PlayerTycoons[player.UserId]:CleanUp()
		Tycoon.PlayerTycoons[player.UserId] = nil
	end
end

function onPlayerAdded(player)
	--Initialize Player Stats and Spawn them in their tycoon
	if player.Name == "seydou_x" or player.Name == "KaretaHana5734" then
		player:SetAttribute("Cash", 1000000)
	end

	local playerData = LoadPlayerTycoonData(player.UserId)
	local playerTycoon

	if playerData then
		--TycoonHandler.ApplySavedData(player, playerData)
		player:SetAttribute("Cash", playerData["Cash"])
	else
		player:SetAttribute("Cash", STARTING_CASH)
	end

	createTycoon(player, playerData)

	player.CharacterAdded:Connect(function(char)
		if char then
			wait()

			local wateringCan = Instance.new("Tool")
			wateringCan.RequiresHandle = false
			wateringCan.Name = "Watering Can"

			local wateringCanHandler = ReplicatedStorage.Shared:WaitForChild("WateringCanHandler"):Clone()
			wateringCanHandler.Parent = wateringCan
			
			wateringCan.Parent = player.Backpack

			for _, spawn in pairs(CollectionService:GetTagged(SpawnTag)) do
				if spawn:GetAttribute("Owner") == player.UserId then
					local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
					humanoidRootPart.CFrame = spawn.CFrame
					break
				end
			end
		end

		char.Humanoid.Died:Connect(function()
			wait(3)
			player:LoadCharacter()
		end)
	end)

	player:LoadCharacter()
end

function onPlayerRemoving(player)
	local playerSaveData = Tycoon.GetSerializedData(player)
	if playerSaveData then
		--Save data
		local success, err = pcall(function()
			print(playerSaveData)
			SavePlayerTycoonData(player.UserId, playerSaveData)
		end)

		if not success then
			warn("Failed to save tycoon data for " .. player.Name .. ": " .. err)
		end

		-- Clean up tycoon instance
		removeTycoon(player)
		--Tycoon.PlayerTycoons[player.UserId]:CleanUp()
	end
end

function SavePlayerTycoonData(userId, data)
	-- Convert to JSON-safe format if necessary
	-- (e.g., avoid instances or userdata inside `data`)

	local success, result = pcall(function()
		TycoonDataStore:SetAsync(tostring(userId), data)
	end)

	if not success then
		warn("Failed to save data for userId " .. userId .. ": " .. result)
		return false
	end

	print("Save success!")

	return true
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
