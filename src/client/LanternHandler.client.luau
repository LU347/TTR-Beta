local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local toggleLamps = ReplicatedStorage.RemoteEvents.ToggleLamps

function toggleLight(player, lantern)
    local lanterns = CollectionService:GetTagged("Lantern")
    for _, lantern in pairs(lanterns) do
        lantern.PointLight.Enabled = bool
        print("lantern toggled")
    end
end

toggleLamps.OnClientEvent:Connect(toggleLight)
