-- StarterPlayerScripts > ToolHandler (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local PlantSeed = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlantSeed")

print("ToolHandler LocalScript started")

-- Function to connect a tool when added
local function connectTool(tool)
	task.wait() -- wait for attributes to exist
	print("Connecting tool:", tool.Name)

	if not tool:IsA("Tool") then
		print("Not a Tool:", tool.Name)
		return
	end

	local seedName = tool:GetAttribute("SeedName")
	if not seedName then
		print("Tool has no SeedName attribute:", tool.Name)
		return
	end

	print("Tool connected:", tool.Name)

	tool.Activated:Connect(function()
		print("Tool activated:", tool.Name)
		local mouse = player:GetMouse()
		print("Mouse:", mouse)

		if mouse and mouse.Target then
			print("Target:", mouse.Target.Name)
			PlantSeed:FireServer(tool, seedName, mouse.Hit.Position, mouse.Target)
		else
			print("No mouse target.")
		end
	end)
end

-- Debug backpack contents
task.wait(1)
print("Backpack contents:")
for _, item in ipairs(backpack:GetChildren()) do
	print("-", item.Name)
	connectTool(item)
end

-- Connect future tools
backpack.ChildAdded:Connect(function(tool)
	print("New tool added to backpack:", tool.Name)
	task.wait(0.1)
	connectTool(tool)
end)

player.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			print("Tool equipped:", child.Name)
		end
	end)
end)
