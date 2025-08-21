local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlantSeedEvent = ReplicatedStorage.RemoteEvents.PlantSeed

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local tool = script.Parent

local seedName = tool:GetAttribute("SeedName")
local seedType = tool:GetAttribute("SeedType")

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

	local currQty = tool:GetAttribute("Quantity")
	if not currQty then 
		return
	end

	if target:GetAttribute("Taken") == false then
		PlantSeedEvent:FireServer(target, seedName, seedType, tool)
	end
end

tool.Activated:Connect(handleMouseClick)
