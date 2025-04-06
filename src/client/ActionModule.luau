-- ActionModule

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local PlantSeed = ReplicatedStorage.RemoteEvents:WaitForChild("PlantSeed")
local WaterField = ReplicatedStorage.RemoteEvents:WaitForChild("WaterField")
local HarvestPot = ReplicatedStorage.RemoteEvents:WaitForChild("HarvestPot")

local HotbarGuiModule = require(script.Parent:WaitForChild("HotbarGuiModule"))

local ActionModule = {}

function ActionModule.Init()
	local player = Players.LocalPlayer
	local mouse = player:GetMouse()
    
    local inventoryItems = {
        { Name = "Amazonite Seed", Action = "Plant", Quantity = 10 },
        { Name = "Watering Can", Action = "Water", Quantity = 5 },
        { Name = "Shears", Action = "Harvest", Quantity = 3 },
    }

	HotbarGuiModule.LoadInventory(inventoryItems)
	HotbarGuiModule.CreateUI()

	local currentAction = HotbarGuiModule.GetSelectedAction()

	HotbarGuiModule.OnSlotSelected(function(_, action)
		currentAction = action
	end)

	-- Hide default backpack
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	-- Create custom hotbar GUI
	HotbarGuiModule.CreateUI()

	-- Local state
	local currentAction = HotbarGuiModule.GetSelectedAction()

	-- Update action when player clicks a hotbar slot
	HotbarGuiModule.OnSlotSelected(function(_, action)
		currentAction = action
	end)

	-- Update action from keybinds
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		local keyToIndex = {
			[Enum.KeyCode.One] = 1,
			[Enum.KeyCode.Two] = 2,
			[Enum.KeyCode.Three] = 3,
		}

		local index = keyToIndex[input.KeyCode]
		if index then
			HotbarGuiModule.SetSelected(index)
			currentAction = HotbarGuiModule.GetSelectedAction()
		end

		-- Handle click interaction
		if input.UserInputType == Enum.UserInputType.MouseButton1 and currentAction and mouse.Target then
			local target = mouse.Target
			if target:GetAttribute("Owner") ~= player.UserId then return end

			if CollectionService:HasTag(target, "Field") then
				if currentAction == "Plant" and not target:GetAttribute("Taken") then
					PlantSeed:FireServer(target, "Amazonite")
				elseif currentAction == "Water" and not target:GetAttribute("Watered") then
					WaterField:FireServer(target)
				end
			elseif CollectionService:HasTag(target, "Teapot") and currentAction == "Harvest" then
				HarvestPot:FireServer(target)
			end
		end
	end)
end

return ActionModule
