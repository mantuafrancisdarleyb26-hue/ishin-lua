-- ISHIN MULTI SYSTEM FLOATING GUI
-- Re-Engineered for Ishin Cross-Play Engine Compatibility
-- Delta Executor Mobile Override Layer

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "IshinFloatingGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main UI Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 290)
frame.Position = UDim2.new(0, 25, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(24, 18, 22)
frame.Parent = gui

local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 8)

-- Window Drag Handler
local mainDragging = false
local mainDragStart, mainStartPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		mainDragging = true
		mainDragStart = input.Position
		mainStartPos = frame.Position
	end
end)

-- Header Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 45)
title.BackgroundTransparency = 1
title.Text = "ISHIN | MULTI SYSTEM"
title.TextColor3 = Color3.fromRGB(255, 65, 65)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.Parent = frame

-- Minimize Button
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 35)
minimize.Position = UDim2.new(1, -40, 0, 5)
minimize.Text = "–"
minimize.TextSize = 24
minimize.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Parent = frame

local minCorner = Instance.new("UICorner", minimize)
minCorner.CornerRadius = UDim.new(0, 6)

-- Minimized Sticker Bubble
local sticker = Instance.new("TextButton")
sticker.Size = UDim2.fromOffset(55, 55)
sticker.Position = UDim2.new(0, 25, 0.5, 0)
sticker.Text = "ISHIN"
sticker.TextSize = 12
sticker.Font = Enum.Font.GothamBold
sticker.TextColor3 = Color3.new(1,1,1)
sticker.BackgroundColor3 = Color3.fromRGB(160, 15, 25)
sticker.Visible = false
sticker.Parent = gui

local stickerCorner = Instance.new("UICorner", sticker)
stickerCorner.CornerRadius = UDim.new(1, 0)

-- Core System States
local states = {
	["Auto Parry"] = false,
	["ESP"] = false,
	["Auto Farm"] = false,
	["Combat Automation"] = false
}

-- ESP Renderer Worker
local function handleEsp()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			if not hrp:FindFirstChild("IshinESP") then
				local box = Instance.new("BoxHandleAdornment")
				box.Name = "IshinESP"
				box.Size = Vector3.new(4, 5, 1)
				box.Color3 = Color3.fromRGB(255, 65, 65)
				box.AlwaysOnTop = true
				box.ZIndex = 5
				box.Adornee = p.Character
				box.Parent = hrp
			end
		end
	end
end

local function clearEsp()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp and hrp:FindFirstChild("IshinESP") then
				hrp.IshinESP:Destroy()
			end
		end
	end
end

local lastAttack = 0
local lastParry = 0

-- Engine Heartbeat Loop Processing Engine
RunService.RenderStepped:Connect(function()
	if states["ESP"] then
		handleEsp()
	else
		clearEsp()
	end

	local localChar = player.Character
	local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

	if localHrp then
		for _, enemy in ipairs(Workspace:GetChildren()) do
			local enemyHum = enemy:FindFirstChildOfClass("Humanoid")
			local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
			
			if enemyHum and enemyHrp and enemy ~= localChar and enemyHum.Health > 0 then
				local distance = (localHrp.Position - enemyHrp.Position).Magnitude
				
				-- 1. FIXED ENGINE LEVEL AUTO PARRY (Bypasses touch layers entirely)
				if states["Auto Parry"] and distance < 13 then
					local enemyAttacking = enemy:GetAttribute("Attacking") or enemy:FindFirstChild("IsStriking") or enemy:FindFirstChildOfClass("Tool")
					
					if enemyAttacking then
						if tick() - lastParry > 0.08 then
							lastParry = tick()
							-- Forces a direct engine block call mimicking standard key frameworks
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
							task.wait(0.04)
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
						end
					end
				end

				-- 2. SMART COMBAT HARDWARE MACRO (Swaps Attack vs Critical finishers)
				if states["Combat Automation"] and distance < 11 then
					if tick() - lastAttack > 0.14 then
						lastAttack = tick()
						
						-- Scan if enemy guard status or posture state is broken
						local isBroken = enemy:GetAttribute("Stunned") or enemy:FindFirstChild("Stunned") or enemyHum.WalkSpeed < 4
						
						if isBroken then
							-- Fires raw cross-play Critical shortcut triggers ('E' key + M1 combo)
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
							VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
							task.wait(0.01)
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
							VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
						else
							-- Default fallback continuous strike signals
							VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
							task.wait(0.01)
							VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
						end
					end
				end
			end
		end

		-- 3. AUTO FARM MAP ASSETS
		if states["Auto Farm"] then
			for _, mapObject in ipairs(Workspace:GetChildren()) do
				if mapObject.Name:lower():find("trash") or mapObject.Name:lower():find("job") then
					local dist = (localHrp.Position - mapObject.Position).Magnitude
					if dist < 60 then
						localHrp.CFrame = mapObject.CFrame + Vector3.new(0, 3, 0)
						local prompt = mapObject:FindFirstChildOfClass("ProximityPrompt")
						if prompt and typeof(fireproximityprompt) == "function" then
							fireproximityprompt(prompt)
						end
						break
					end
				end
			end
		end
	end
end)

-- UI Button Spawner Logic
local systems = {"Auto Parry", "ESP", "Auto Farm", "Combat Automation"}

for i, name in ipairs(systems) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.88, 0, 0, 42)
	button.Position = UDim2.new(0.06, 0, 0, 52 + (i-1)*49)
	button.Text = name .. ": OFF"
	button.TextColor3 = Color3.new(1,1,1)
	button.BackgroundColor3 = Color3.fromRGB(48,40,45)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = frame

	local btnCorner = Instance.new("UICorner", button)
	btnCorner.CornerRadius = UDim.new(0, 6)

	button.MouseButton1Click:Connect(function()
		states[name] = not states[name]
		button.Text = name .. (states[name] and ": ON" or ": OFF")
		button.BackgroundColor3 = states[name] and Color3.fromRGB(130,25,25) or Color3.fromRGB(48,40,45)
	end)
end

-- Layout Screen Visibility Clean Switches
minimize.MouseButton1Click:Connect(function()
	frame.Visible = false
	sticker.Visible = true
end)

sticker.MouseButton1Click:Connect(function()
	sticker.Visible = false
	frame.Visible = true
end)

-- Minimized Sticker Bubble Drag Processing
local stickerDragging = false
local stickerDragStart, stickerStartPos

sticker.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		stickerDragging = true
		stickerDragStart = input.Position
		stickerStartPos = sticker.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		if mainDragging then
			local delta = input.Position - mainDragStart
			frame.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
		elseif stickerDragging then
			local delta = input.Position - stickerDragStart
			sticker.Position = UDim2.new(stickerStartPos.X.Scale, stickerStartPos.X.Offset + delta.X, stickerStartPos.Y.Scale, stickerStartPos.Y.Offset + delta.Y)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		stickerDragging = false
		mainDragging = false
	end
end)
