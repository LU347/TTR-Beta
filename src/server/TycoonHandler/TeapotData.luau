
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local seedTypes = require(ReplicatedStorage.Shared.Enums).seedTypes

local teapotData = {
    ["Adurite"] = { MaxSize = Vector3.new(5,4,10), MaxValue = 50, Type = seedTypes.Small },
    ["Amazonite"] = { MaxSize = Vector3.new(9,8,14), MaxValue = 70, Type = seedTypes.Small },
    ["Original"] = { MaxSize = Vector3.new(4,3,7), MaxValue = 10, Type = seedTypes.Small },
    ["Amethyst"] = { MaxSize = Vector3.new(12,11,17), MaxValue = 200, Type = seedTypes.Medium },
    ["Disco"] = { MaxSize = Vector3.new(15,14,20), MaxValue = 300, Type = seedTypes.Medium },
    ["Golden"] = { MaxSize = Vector3.new(10,9,15), MaxValue = 100, Type = seedTypes.Medium },
    ["Diamond"] = { MaxSize = Vector3.new(38,37,59), MaxValue = 1500, Type = seedTypes.Large },
    ["Emerald"] = { MaxSize = Vector3.new(40,39,61), MaxValue = 2000, Type = seedTypes.Large },
    ["Heavenly"] = { MaxSize = Vector3.new(46,45,75), MaxValue = 3000, Type = seedTypes.Large },
    ["Lilypad"] = { MaxSize = Vector3.new(70,71,101), MaxValue = 20000, Type = seedTypes.Large }, --XL, change later
    ["Rainbow"] = { MaxSize = Vector3.new(60,61,91), MaxValue = 10000, Type = seedTypes.Large }, --XL, change later
    ["StarPot"] = { MaxSize = Vector3.new(80,81,111), MaxValue = 30000, Type = seedTypes.Large }  --XL, change later
}

return teapotData