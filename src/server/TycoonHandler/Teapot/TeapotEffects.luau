-- TeapotEffects.lua
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShakeEvent = ReplicatedStorage.RemoteEvents.TeapotShake

local TeapotEffects = {}

-- Internal cache for attached particle parts
local attached = {}

local function adjustEmitters(teapot, particlePart)
	local size = teapot.Size
	local scaleFactor = size.Y / 5 -- Used for particle properties

	-- ⬛ Scale particle part to match width of teapot
	local width = math.max(size.X, size.Z)
	particlePart.Size = Vector3.new(width, width * 0.2, width) -- Flat disc shape

	-- 📍 Position at bottom of teapot
	local teapotBottomY = teapot.Position.Y - (size.Y / 2)
	local particlePartBottomY = teapotBottomY - (particlePart.Size.Y / 2)
	particlePart.Position = Vector3.new(teapot.Position.X, particlePartBottomY, teapot.Position.Z)

	-- 🎇 Adjust emitters
	for _, emitter in ipairs(particlePart:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, scaleFactor),
				NumberSequenceKeypoint.new(1, scaleFactor * 1.5)
			})
			emitter.Speed = NumberRange.new(scaleFactor * 2, scaleFactor * 3)
			emitter.SpreadAngle = Vector2.new(10 + scaleFactor * 2, 10 + scaleFactor * 2)
			emitter.Rate = 5 + (scaleFactor * 3)
		end
	end
end

function TeapotEffects.AttachParticles(teapot)
	if not teapot then
		warn("Invalid teapot provided")
		return
	end

	if attached[teapot] then
		return
	end -- Prevent duplicate attachments

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
		Rotating = false,
	}

	-- Store for cleanup later
	attached[teapot].SizeConnection = teapot:GetPropertyChangedSignal("Size"):Connect(function()
		adjustEmitters(teapot, clone)
	end)

	-- Initial adjustment
	adjustEmitters(teapot, clone)
end

function TeapotEffects.StartShaking(teapot)
	if teapot then
		ShakeEvent:FireAllClients("start", teapot)
	end
end

function TeapotEffects.StopShaking(teapot)
	if teapot then
		ShakeEvent:FireAllClients("stop", teapot)
	end
end

function TeapotEffects.PlayEffect(teapot)
	local info = attached[teapot]
	if not info then
		return
	end

	if info.Dirt1 then
		info.Dirt1.Enabled = true
	end
	if info.Dirt2 then
		info.Dirt2.Enabled = true
	end
	if info.Sound then
		info.Sound.Looped = true
		info.Sound.Volume = 1
		info.Sound:Play()
	end
end

function TeapotEffects.StopEffect(teapot)
	local info = attached[teapot]
	if not info then
		return
	end

	if info.Dirt1 then
		info.Dirt1.Enabled = false
	end
	if info.Dirt2 then
		info.Dirt2.Enabled = false
	end
	if info.Sound then
		info.Sound:Stop()
	end
end

function TeapotEffects.Cleanup(teapot)
	local info = attached[teapot]
	if info and info.Part then
		info.Part:Destroy()
	end

	if attached[teapot] and attached[teapot].SizeConnection then
		attached[teapot].SizeConnection:Disconnect()
	end

	attached[teapot] = nil
end

return TeapotEffects
