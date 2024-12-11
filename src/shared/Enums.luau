local Enums = {}

Enums.seedTypes = {
    ["Small"] = { Order = 1, GrowthRate = 3},
    ["Medium"] = { Order = 2, GrowthRate = 7},
    ["Large"] = { Order = 3, GrowthRate = 8},
    ["X-Large"] = { Order = 4, GrowthRate = 10}
}

Enums.fieldTypes = {
    ["Small"] = { Order = 1},
    ["Medium"] = { Order = 2},  --Can plant small and medium
    ["Large"] = { Order = 3},   --Can plant small -> large
    ["X-Large"] = { Order = 4}  --Can plant small -> x-Large
}

return Enums