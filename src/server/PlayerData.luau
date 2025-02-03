local DataStoreService = game:GetService("DataStoreService")

local PlayerData = {}
PlayerData.__index = PlayerData

local ServerPlayerData = {}
local DataStore = DataStoreService:GetDataStore("PlayerDataStore")

function PlayerData.new(player)
    if ServerPlayerData[player.UserId] then
        return ServerPlayerData[player.UserId]
    end

    local self = setmetatable({}, PlayerData)
    self.Cash = 50
    self.Inventory = {}
    self.Tycoon = {
        Unlocked = {}, -- Will store unlocked items
        Plots = {}, -- Will store unlocked plots and its field data
    }

    self:loadData(player)

    ServerPlayerData[player.UserId] = self

    return self
end

function PlayerData:getCash()
    return self.Cash
end

function PlayerData:setCash(cash)
    if type(cash) == "number" and cash >= 0 then
        self.Cash = cash
    else
        warn("Invalid cash value: " .. tostring(cash))
    end
end

function PlayerData:loadData(player)
    local success, data = pcall(function()
        return DataStore:GetAsync(tostring(player.UserId))
    end)

    if success and data then
        self.Cash = data.Cash or 50
        self.Inventory = data.Inventory or {}
        self.Tycoon = data.Tycoon or { Unlocked = {}, Plots = {} }
    else
        warn("Failed to load data for player: " .. player.UserId)
    end
end

function PlayerData:saveData(player)
    local success, err = pcall(function ()
        DataStore:UpdateAsync(tostring(player.UserId), function(oldData)
            return {
                Cash = self.Cash,
                Inventory = self.Inventory,
                Tycoon = self.Tycoon
            }
        end)
    end)

    if not success then
        warn("Failed to save data for player: " .. player.UserId .. " | Error: " .. err)
    end
end

game.Players.PlayerRemoving:Connect(function(player)
    if ServerPlayerData[player.UserId] then
        ServerPlayerData[player.UserId]:saveData(player)
        ServerPlayerData[player.UserId] = nil
    end
end)

return PlayerData