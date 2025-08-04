local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WaterFieldEvent = ReplicatedStorage.RemoteEvents.WaterField

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

	if target:GetAttribute("Watered") == false then
		WaterFieldEvent:FireServer(target)
	end
end

tool.Activated:Connect(handleMouseClick)
