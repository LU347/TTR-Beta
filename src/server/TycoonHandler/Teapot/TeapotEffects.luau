-- TeapotEffects.lua
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShakeEvent = ReplicatedStorage.RemoteEvents.TeapotShake

local TeapotEffects = {}

-- Internal cache for attached particle parts
local attached = {}

function TeapotEffects.AttachParticles(teapot)
	if not teapot then
		warn("Invalid teapot provided")
		return
	end

	if attached[teapot] then return end -- Prevent duplicate attachments

    print("Attaching to:", teapot, "with name:", teapot.Name)

	local prefab = ReplicatedStorage:WaitForChild("TeapotParticles")
	if not prefab then
		warn("TeapotParticles prefab missing from ReplicatedStorage")
		return
	end

	local clone = prefab:Clone()
	clone.Name = "ParticleEffect"
	clone.CFrame = teapot.CFrame
	clone.Anchored = false
	clone.CanCollide = false
	clone.Parent = teapot

	-- Weld it to the teapot
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = teapot
	weld.Part1 = clone
	weld.Parent = teapot

	attached[teapot] = {
		Part = clone,
		Dirt1 = clone:WaitForChild("Dirt1"),
		Dirt2 = clone:WaitForChild("Dirt2"),
		Sound = clone:WaitForChild("dirt"),
        BaseOrientation = teapot.Orientation,
        Rotating = false
	}
end

function TeapotEffects.StartShaking(teapot)
    if teapot then
        ShakeEvent:FireAllClients("start", teapot)
    end
    --[[
	local info = attached[teapot]
	if not info or info.Rotating then return end

	info.Rotating = true
	coroutine.wrap(function()
		local twistSpeedY = 10
		local rockSpeedX = 25
		local largeTwistAmount = 15
		local smallRockAmount = 5
		local base = info.BaseOrientation

		while info.Rotating and teapot and teapot.Parent do
			local t = tick()
			local y = math.sin(t * twistSpeedY) * largeTwistAmount
			local x = math.sin(t * rockSpeedX) * smallRockAmount

			teapot.Orientation = base + Vector3.new(x, y, 0)
			RunService.RenderStepped:Wait()
		end

		-- Reset to base orientation
		local tween = TweenService:Create(teapot, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Orientation = base
		})
		tween:Play()
	end)()
    ]]--
end

function TeapotEffects.StopShaking(teapot)
    if teapot then
        ShakeEvent:FireAllClients("stop", teapot)
    end
end

function TeapotEffects.PlayEffect(teapot)
	local info = attached[teapot]
	if not info then return end

	if info.Dirt1 then info.Dirt1.Enabled = true end
	if info.Dirt2 then info.Dirt2.Enabled = true end
	if info.Sound then
		info.Sound.Looped = true
		info.Sound.Volume = 1
		info.Sound:Play()
	end
end

function TeapotEffects.StopEffect(teapot)
	local info = attached[teapot]
	if not info then return end

	if info.Dirt1 then info.Dirt1.Enabled = false end
	if info.Dirt2 then info.Dirt2.Enabled = false end
	if info.Sound then info.Sound:Stop() end
end

function TeapotEffects.Cleanup(teapot)
	local info = attached[teapot]
	if info and info.Part then
		info.Part:Destroy()
	end
	attached[teapot] = nil
end

return TeapotEffects
