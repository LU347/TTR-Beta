local Tycoon = require(game.ReplicatedStorage.Shared.Tycoon)

local PlayerData = {}
PlayerData.__index = Player

local ServerPlayerData = {}

function PlayerData.new(player)
    local self = setmetatable({}, PlayerData)
    self.Cash = 50
    self.Inventory = {}
    self.Tycoon = {
        Unlocked = [],
        Plots = {}
    }
    ServerPlayerData[player.UserId] = self
end

function PlayerData.getData(player)
    return ServerPlayerData[player.UserId]
end

function PlayerData.setData(player, key, value)

end

return Player