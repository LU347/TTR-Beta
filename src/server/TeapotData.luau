local seedTypes = {
    ["Small"] = 1,
    ["Medium"] = 2,
    ["Large"] = 3,
    ["X-Large"] = 4
}

return {
    ["Original"] = {
        ["MaxSize"] = Vector3.new(4,3,6),
        ["MaxValue"] = 10,
        ["Type"] = seedTypes.Small
    },
    ["Hybrid"] = {
        ["MaxSize"] = Vector3.new(6,4,8),
        ["MaxValue"] = 20,
        ["Type"] = seedTypes.Medium
    },
    ["GMO"] = {
        ["MaxSize"] = Vector3.new(8,5,10),
        ["MaxValue"] = 30,
        ["Type"] = seedTypes.Large
    },
    ["Mega"] = {
        ["MaxSize"] = Vector3.new(10,6,12),
        ["MaxValue"] = 40,
        ["Type"] = seedTypes["X-Large"]
    }
}