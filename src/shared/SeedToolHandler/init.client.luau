local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlantSeedEvent = ReplicatedStorage.RemoteEvents.PlantSeed

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local tool = script.Parent

local seedName = tool:GetAttribute("SeedName")
local seedType = tool:GetAttribute("SeedType")
local quantity = tool:GetAttribute("Quantity")

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

	if target:GetAttribute("Taken") == false then
		PlantSeedEvent:FireServer(target, seedName, seedType)
		quantity -= 1

		tool:SetAttribute("Quantity", quantity)
		tool.Name = seedName .. " x" .. tostring(quantity)
	end

	if quantity <= 0 then
		tool:Destroy()
	end
end

tool.Activated:Connect(handleMouseClick)
