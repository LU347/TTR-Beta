local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isRunning = true
local originalTeapot = ReplicatedStorage.Teapots.ObbyTeapot
local random = Random.new()

local obby = workspace.Obby     --tempp location
local spawnWall = obby.SpawnWall
local teapotCollider = obby.TeapotCollider

local DEBRIS_COOLDOWN = 2.5
local FORCE_AMOUNT = 45000
local SPAWN_COOLDOWN = 0.5
local TEAPOT_SIZE = Vector3.new(12,10,18.69)

local function getRandomColor()
    local teapotColors = {"Pastel Blue", "Light green", "Brick yellow", "Bright green", "Bright purple"}
    return teapotColors[random:NextInteger(1, #teapotColors)]
end

local function getRandomSpawner()
    local spawnerFolder = obby.Spawners:GetChildren()
    return spawnerFolder[random:NextInteger(1, #spawnerFolder)]
end

local function getRandomAngle()
    return math.rad(random:NextInteger(1,10))
end

local function generateTeapots()
    while isRunning do
        local clone = originalTeapot:Clone()
        CollectionService:AddTag(clone, "ObbyTeapot")

        local vectorForce = clone:FindFirstChild("VectorForce")
        vectorForce.Force = Vector3.new(FORCE_AMOUNT, 0, 0)
        vectorForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment1

        local spawner = getRandomSpawner()
        clone.Size = TEAPOT_SIZE
        clone.BrickColor = BrickColor.new(getRandomColor())
        clone.CFrame = CFrame.Angles(0, getRandomAngle(), 0)
        clone.Position = Vector3.new(spawner.Position.X, spawner.Position.Y + 5, spawner.Position.Z)
        clone.Parent = workspace
        clone.Anchored = false

        clone.Touched:Connect(function(hit)
            if hit.Parent:IsA("Model") then
                if hit.Parent:FindFirstChildWhichIsA("Humanoid") then
                    local humanoid = hit.Parent.Humanoid
                    humanoid.Health = 0
                end
            end
        end)

        Debris:AddItem(clone, DEBRIS_COOLDOWN)

        wait(SPAWN_COOLDOWN)
    end
end

spawnWall.Touched:Connect(function(hit)
    if hit:HasTag("ObbyTeapot") then
        hit:Destroy()
    end
end)

teapotCollider.Touched:Connect(function(hit)
    if hit:HasTag("ObbyTeapot") then
        teapotCollider.CanCollide = true
    end
end)

generateTeapots()