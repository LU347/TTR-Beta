local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlantSeedEvent = ReplicatedStorage.RemoteEvents.PlantSeed

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local tool = script.Parent

local function handleMouseClick()
	if not mouse or not mouse.Target then
		return
	end

	local target = mouse.Target

	if not CollectionService:HasTag(target, "Field") then
		return
	end
	if target:GetAttribute("Owner") ~= localPlayer.UserId then
		return
	end

	local seedName = tool:GetAttribute("SeedName")
	if not seedName then
		return
	end

	local seedType = tool:GetAttribute("SeedType")
	if not seedType then
		return
	end

	if target:GetAttribute("Taken") == false then
		PlantSeedEvent:FireServer(target, seedName, seedType)
	end
end

tool.Activated:Connect(handleMouseClick)
