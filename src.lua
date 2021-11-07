--
local Uis = game:GetService("UserInputService")
local RunService = game:GetService('RunService')
local Down = {}
local LocomotionAmplitude = 8
local RotationAmplitude = 2
local Dist = 100
local RayCount = 200
local Player = workspace:WaitForChild("Player")
local PlayerA = game.Players.LocalPlayer
local Frame

local CastParams = RaycastParams.new()
CastParams.FilterDescendantsInstances = {Player}
CastParams.FilterType = Enum.RaycastFilterType.Blacklist


local function DistanceCheck(Vec1,Vec2)
	return (Vec1 - Vec2).Magnitude
end

local function SetupGui()
	Frame = PlayerA:WaitForChild("PlayerGui"):WaitForChild("ScreenGui").Frame
	Frame.CurrentCamera = workspace.CurrentCamera
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	
	for i = 1,RayCount do
		local NewFrame = Instance.new("Frame")
		NewFrame.AnchorPoint = Vector2.new(.5,.5)
		NewFrame.Position = UDim2.new((i/RayCount) - (1/RayCount),0,.5,0)
		NewFrame.Size = UDim2.new((1/RayCount),0,1,0)
		NewFrame.BorderSizePixel = 0
		NewFrame.Name = tostring(i)
		
		NewFrame.Parent = Frame
	end
end

local function Shader(Cast,Distance)
	local Color = Cast.Instance.Color
	local Normal = Cast.Normal
	local Fog = (Distance/Dist) - 1
	
	if Normal.X == 0 then Normal = Vector3.new(.5,Normal.Y,Normal.Z) end
	if Normal.Y == 0 then Normal = Vector3.new(Normal.X,.5,Normal.Z) end
	if Normal.Z == 0 then Normal = Vector3.new(Normal.X,Normal.Y,.5) end
	Normal = Vector3.new(math.abs(Normal.X),math.abs(Normal.Y),math.abs(Normal.Z))


	
	local R = ( (Color.R ) *.8) * Normal.X * math.abs(Fog) 
	local G = ( (Color.G ) *.8) * Normal.X * math.abs(Fog)
	local B = ( (Color.B ) *.8) * Normal.X * math.abs(Fog) 

	
	return Color3.new(R,G,B)
end

local function Cast()
	local Rays = {}
	local Int = 90 / RayCount
	
	for i = 1,RayCount do
		script.Rot.Orientation = Player.Orientation + Vector3.new(0,Int * i,0) + Vector3.new(0,-40,0)
		script.Rot.Position = Player.Position
		
		Rays[i] = {Ray = workspace:Raycast(Player.Position,script.Rot.CFrame.LookVector * Dist,CastParams), Angle = script.Rot.Orientation}
	end
	workspace.Camera.CFrame = Player.CFrame
	return Rays
end


local function Render(Rays)
	for i,v in ipairs(Rays) do
		if v.Ray then
			local Distance = DistanceCheck(v.Ray.Position,Player.Position)
			local Distance2 = Distance
			local POrientation = Player.Orientation
			local ROrientation = v.Angle
			
			
			local CosAngle = POrientation - ROrientation
			CosAngle = Vector3.new(0,1/(math.abs(CosAngle.Y - 1) ),0)
			
			
			local Slot = Frame[i]
			Slot.BackgroundColor3 = Shader(v.Ray,Distance)
			Slot.Size = UDim2.new(1/RayCount,0,( (1*4) /Distance2 ),0)
		end
	end
end


SetupGui()
RunService.Heartbeat:Connect(function(dt)
	if Uis:IsKeyDown("W") then
		Player.CFrame = Player.CFrame + (Player.CFrame.LookVector * dt * LocomotionAmplitude )
	end
	
	if Uis:IsKeyDown("S") then
		Player.CFrame = Player.CFrame - (Player.CFrame.LookVector * dt * LocomotionAmplitude )
	end
	
	if Uis:IsKeyDown("D") then
		Player.Orientation += Vector3.new(0,1,0) * RotationAmplitude
	end
	
	if Uis:IsKeyDown("A") then
		Player.Orientation -= Vector3.new(0,1,0) * RotationAmplitude
	end
	Render(Cast())
end)
