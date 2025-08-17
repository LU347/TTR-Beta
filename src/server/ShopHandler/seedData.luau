local ReplicatedStorage = game:GetService("ReplicatedStorage")
local seedTypes = require(ReplicatedStorage.Shared.Enums).seedTypes

local teapotData = {
	["Adurite"]   = {Cost = 50,  Type = "Small"},
	["Amazonite"] = {Cost = 75,  Type = "Small"},
	["Original"]  = {Cost = 10,   Type = "Small"},
	["Amethyst"]  = {Cost = 120, Type = "Medium"},
	["Disco"]     = {Cost = 150, Type = "Medium"},
	["Golden"]    = {Cost = 200, Type = "Medium"},
	["Diamond"]   = {Cost = 500, Type = "Large"},
	["Emerald"]   = {Cost = 600, Type = "Large"},
	["Heavenly"]  = {Cost = 750, Type = "Large"},
	["Lilypad"]   = {Cost = 1000,Type = "Large"}, -- XL later
	["Rainbow"]   = {Cost = 1250,Type = "Large"}, -- XL later
	["StarPot"]   = {Cost = 1500,Type = "Large"}  -- XL later
}

return teapotData