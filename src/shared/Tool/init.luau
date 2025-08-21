-- ModuleScript: ToolModule.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local seedToolHandler = ReplicatedStorage.Shared.SeedToolHandler

local Tool = {}
Tool.__index = Tool

function Tool.new(player, seedName, seedType)
	local self = setmetatable({}, Tool)
	self.SeedName = seedName
	self.SeedType = seedType
	self.Quantity = amount or 4
	self.Owner = player

	return self
end

function Tool:CreateToolInstance()
	local backpack = self.Owner:FindFirstChild("Backpack")
	if not backpack then
		return
	end

	-- Check if a matching seed tool already exists
	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("SeedName") == self.SeedName then
			local currentQty = tool:GetAttribute("Quantity") or 1
			local newQty = currentQty + self.Quantity

			tool:SetAttribute("Quantity", newQty)

			self.Quantity = newQty

			tool.Name = self.SeedName .. " x" .. tostring(self.Quantity)

			return 
		end
	end

	-- Create a new tool
	local toolInstance = Instance.new("Tool")
	toolInstance.Name = self.SeedName .. " x" .. self.Quantity
	toolInstance.RequiresHandle = false

	toolInstance:SetAttribute("SeedName", self.SeedName)
	toolInstance:SetAttribute("SeedType", self.SeedType)
	toolInstance:SetAttribute("Quantity", self.Quantity)

	toolInstance:GetAttributeChangedSignal("Quantity"):Connect(function()
		local currQty = toolInstance:GetAttribute("Quantity")
		self.Quantity = currQty

		toolInstance.Name = self.SeedName .. " x" .. tostring(self.Quantity)

		if currQty <= 0 then
			toolInstance:Destroy()
			self = {}
			print(self)
		end
	end)

	local toolHandlerClone = seedToolHandler:Clone()
	toolHandlerClone.Parent = toolInstance

	toolInstance.Parent = backpack
	return toolInstance
end


return Tool
