local teapotCollider = workspace.Obby:WaitForChild("TeapotCollider") -- location of the "gap" between the two paths
local spawnWall = workspace.Obby:WaitForChild("SpawnWall")

local function isHumanoid(hit)
    if hit.Parent:FindFirstChildWhichIsA("Humanoid") then
        return true
    end

    return false
end

teapotCollider.Touched:Connect(function(hit)
    if isHumanoid(hit) then
        teapotCollider.CanCollide = false
    end
end)

spawnWall.Touched:Connect(function(hit)
    if isHumanoid(hit) then
        spawnWall.CanCollide = false
    end
end)