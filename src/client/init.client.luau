-- LocalScript in StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ShakeEvent = ReplicatedStorage.RemoteEvents.TeapotShake

local rotating = {}

ShakeEvent.OnClientEvent:Connect(function(action, teapot)
	if not teapot then return end

	if action == "start" and not rotating[teapot] then
		rotating[teapot] = true
		local base = teapot.Orientation
		local twistSpeedY = 10
		local rockSpeedX = 25
		local largeTwistAmount = 15
		local smallRockAmount = 5

		coroutine.wrap(function()
			while rotating[teapot] and teapot and teapot.Parent do
				local t = tick()
				local y = math.sin(t * twistSpeedY) * largeTwistAmount
				local x = math.sin(t * rockSpeedX) * smallRockAmount
				teapot.Orientation = base + Vector3.new(x, y, 0)
				RunService.RenderStepped:Wait()
			end

			-- Smooth reset
			local tween = TweenService:Create(teapot, TweenInfo.new(0.75), { Orientation = base })
			tween:Play()
		end)()
	elseif action == "stop" then
		rotating[teapot] = false
	end
end)
