-- HotbarGuiModule

local Players = game:GetService("Players")
local HotbarGuiModule = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local slots = {}
local currentIndex = 1
local inventoryItems = {} -- we’ll populate this with real data
local onSlotSelectedCallback = nil

function HotbarGuiModule.LoadInventory(items)
	inventoryItems = items
end

function HotbarGuiModule.CreateUI()
	local existingGui = playerGui:FindFirstChild("CustomHotbar")
	if existingGui then
		existingGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CustomHotbar"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "HotbarFrame"
	frame.Size = UDim2.new(0, 100 * #inventoryItems, 0, 50)
	frame.Position = UDim2.new(0.5, -(50 * #inventoryItems), 1, -60)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 5)
	layout.Parent = frame

	for i = 1, 6 do
		local item = inventoryItems[i] or { Name = "Empty", Action = "", Quantity = 0 }

		local button = Instance.new("TextButton")
		button.Name = "Slot" .. i
		button.Size = UDim2.new(0, 90, 1, 0)
		button.Text = i .. " - " .. item.Name
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.BorderSizePixel = 0
		button.Parent = frame

		button.MouseButton1Click:Connect(function()
			HotbarGuiModule.SetSelected(i)
			if onSlotSelectedCallback then
				onSlotSelectedCallback(i, item.Action)
			end
		end)

		slots[i] = {
			Button = button,
			Action = item.Action,
			Name = item.Name,
			Quantity = item.Quantity,
		}
	end

	HotbarGuiModule.SetSelected(1)
end

function HotbarGuiModule.SetSelected(index)
	currentIndex = index
	for i, data in pairs(slots) do
		data.Button.BackgroundColor3 = i == index and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
	end
end

function HotbarGuiModule.GetSelectedAction()
	return slots[currentIndex] and slots[currentIndex].Action or nil
end

function HotbarGuiModule.OnSlotSelected(callback)
	onSlotSelectedCallback = callback
end

function HotbarGuiModule.GetInventory()
	return inventoryItems
end

function HotbarGuiModule.UpdateQuantity(index, newQuantity)
	local item = slots[index]
	if item then
		item.Quantity = newQuantity
		item.Button.Text = item.Name .. " (" .. newQuantity .. ")"
		if newQuantity == 0 then
			-- Disable the button if quantity is zero
			item.Button.Text = item.Name .. " (Out of stock)"
			item.Button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			item.Button.Active = false
		end
	end
end

return HotbarGuiModule
