-- ModuleScript: ToolModule.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local seedToolHandler = ReplicatedStorage.Shared.SeedToolHandler

local Tool = {}
Tool.__index = Tool

function Tool.new(player, seedName, amount)
	local self = setmetatable({}, Tool)
	self.SeedName = seedName
	self.SeedType = "Small"
	self.Quantity = amount or 1
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
			tool.Name = self.SeedName .. " x" .. newQty

			return tool
		end
	end

	-- Create a new tool
	local toolInstance = Instance.new("Tool")
	toolInstance.Name = self.SeedName .. " x" .. self.Quantity
	toolInstance.RequiresHandle = false

	toolInstance:SetAttribute("SeedName", self.SeedName)
	toolInstance:SetAttribute("SeedType", self.SeedType)
	toolInstance:SetAttribute("Quantity", self.Quantity)

	local toolHandlerClone = seedToolHandler:Clone()
	toolHandlerClone.Parent = toolInstance

	toolInstance.Parent = backpack
	return toolInstance
end

return Tool
