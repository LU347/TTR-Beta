local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(game.ServerScriptService.Server.Button)

local PlantSeed = ReplicatedStorage.RemoteEvents.PlantSeed
local WaterField = ReplicatedStorage.RemoteEvents.WaterField
local HarvestPot = ReplicatedStorage.RemoteEvents.HarvestPot

local Tycoon = {}
Tycoon.__index = Tycoon

local TemplatePlot = game.Workspace.TemplatePlot --replace
local templateItemsFolder = TemplatePlot.Items
local templatePlotsFolder = TemplatePlot.Plots
local templateButtonsFolder = TemplatePlot.Buttons

local ServerTycoons = {}

function Tycoon.new(player, tycoonInstance, unlocked)
    local self = setmetatable({}, Tycoon)
    self.Owner = player
    self.Unlocked = {}                   --Saved
    self.Plots = {}                      --Saved
    self.Instance = tycoonInstance       --Not Saved
    self.Buttons = {}                    --Not Saved

    ServerTycoons[player.UserId] = self

    return self
end

function Tycoon:Init()
    local buttonsFolder = Instance.new("Folder")
    buttonsFolder.Name = "Buttons"
    buttonsFolder.Parent = self.Instance

    local itemsFolder = Instance.new("Folder")
    itemsFolder.Name = "Items"
    itemsFolder.Parent = self.Instance

    local plotsFolder = Instance.new("Folder")
    plotsFolder.Name = "Plots"
    plotsFolder.Parent = self.Instance

    --Initialize Plot Locations--
    local tycoonPlots = templatePlotsFolder:Clone()

    for _, plot in tycoonPlots:GetChildren() do
        self:ClonePart(plot)
        plot.Parent = plotsFolder
    end
    
    --Buttons from the template tycoon are cloned and transferred onto the player's tycoon--
    local tycoonButtons = templateButtonsFolder:Clone()

    for _, button in tycoonButtons:GetChildren() do
        self:CloneModel(button)
        button.Parent = buttonsFolder

        local b = Button.new(self, button)
        table.insert(self.Buttons, b)
    end

    --Owner Sign
    local ownerSign = TemplatePlot:WaitForChild("Sign")
    local ownerClone = ownerSign:Clone()
    local label = ownerClone.Part.SurfaceGui.Background.OwnerLabel
    label.Text = self.Owner.Name .. "'s Tycoon"
    self:CloneModel(ownerClone)
    ownerClone.Parent = self.Instance
end

function Tycoon:CloneModel(model)
    local modelCFrame = model:GetPivot()
    local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(modelCFrame)
    model:PivotTo(self.Instance.CFrame:ToWorldSpace(relativeCFrame))
end

function Tycoon:ClonePart(part)
    local relativeCFrame = TemplatePlot.CFrame:ToObjectSpace(part.CFrame)
    part.CFrame = self.Instance.CFrame:ToWorldSpace(relativeCFrame)
end

function Tycoon:CloneItem(item)
    local function TagLightBlocks(lanterns)
        local lightsFolder = lanterns.LightBlocks:GetChildren()
        for _, lightblock in lightsFolder do
            local light = lightblock.PointLight
            CollectionService:AddTag(light, "LightBlock")
        end

    end

    local itemClone = templateItemsFolder:FindFirstChild(item):Clone()
    local itemCFrame
    
    if itemClone:IsA("Model") then
        self:CloneModel(itemClone)
        --[[
        if string.sub(itemClone.Name, 1, 8) == "Lanterns" then
            TagLightBlocks(itemClone)
        end
        ]]
    else
        self:ClonePart(itemClone)
    end
    
    itemClone.Parent = self.Instance.Items
end

function Tycoon:CleanUp()
    self.Instance:SetAttribute("Taken", false)
    self.Instance:SetAttribute("Owner", nil)
    self.Instance.Buttons:Destroy()
    self.Instance.Items:Destroy()
    self = nil
end

local function getFieldTable(player, fieldName)
    --Finds the plot table and returns the field table that matches the fieldInstance
    if ServerTycoons[player.UserId] then
        local plots = ServerTycoons[player.UserId].Plots
        local plotLocation = "Plot" .. string.upper(string.sub(fieldName, 1,1))
        
        if plots[plotLocation] then
            local f = plots[plotLocation].Fields
            return f[fieldName]
        end
    end
end

PlantSeed.OnServerEvent:Connect(function(player, fieldInstance, seed)
    local fieldTable = getFieldTable(player, fieldInstance.Name)    
    fieldTable:Plant(seed)
end)

WaterField.OnServerEvent:Connect(function(player, fieldInstance)
    local fieldTable = getFieldTable(player, fieldInstance.Name)
    fieldTable:Water()
end)

HarvestPot.OnServerEvent:Connect(function(player, teapot)
    local fieldTable = getFieldTable(player, teapot:GetAttribute("Location"))
    fieldTable:Harvest()
end)

return Tycoon