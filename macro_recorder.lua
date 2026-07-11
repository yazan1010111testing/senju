-- Roblox Macro Recorder & Player
-- Record mouse clicks and key presses, then replay them
-- Perfect for recording green shot timing

local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local recording = false
local playing = false
local macro = {}
local startTime = 0

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name = "MacroRecorder"
sg.ResetOnSpawn = false

pcall(function()
    sg.Parent = game:GetService("CoreGui")
end)

if not sg.Parent then
    sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Parent = sg
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(100, 100, 255)
frame.Position = UDim2.new(0.4, 0, 0.3, 0)
frame.Size = UDim2.new(0, 300, 0, 310)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Size = UDim2.new(1, 0, 0, 35)
title.Font = Enum.Font.GothamBold
title.Text = "MACRO RECORDER"
title.TextColor3 = Color3.fromRGB(100, 150, 255)
title.TextSize = 16

-- Close/Hide button
local hideBtn = Instance.new("TextButton")
hideBtn.Parent = frame
hideBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
hideBtn.Position = UDim2.new(1, -30, 0, 2.5)
hideBtn.Size = UDim2.new(0, 28, 0, 30)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.Text = "_"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.TextSize = 20
hideBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

local status = Instance.new("TextLabel")
status.Parent = frame
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 10, 0, 45)
status.Size = UDim2.new(1, -20, 0, 30)
status.Font = Enum.Font.Gotham
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left

local recordBtn = Instance.new("TextButton")
recordBtn.Parent = frame
recordBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
recordBtn.Position = UDim2.new(0, 10, 0, 85)
recordBtn.Size = UDim2.new(1, -20, 0, 40)
recordBtn.Font = Enum.Font.GothamBold
recordBtn.Text = "🔴 START RECORDING"
recordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
recordBtn.TextSize = 14

local stopBtn = Instance.new("TextButton")
stopBtn.Parent = frame
stopBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
stopBtn.Position = UDim2.new(0, 10, 0, 135)
stopBtn.Size = UDim2.new(1, -20, 0, 40)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.Text = "⏹️ STOP RECORDING"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 14
stopBtn.Visible = false

local playBtn = Instance.new("TextButton")
playBtn.Parent = frame
playBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
playBtn.Position = UDim2.new(0, 10, 0, 185)
playBtn.Size = UDim2.new(1, -20, 0, 40)
playBtn.Font = Enum.Font.GothamBold
playBtn.Text = "▶️ PLAY MACRO"
playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playBtn.TextSize = 14

local info = Instance.new("TextLabel")
info.Parent = frame
info.BackgroundTransparency = 1
info.Position = UDim2.new(0, 10, 0, 235)
info.Size = UDim2.new(1, -20, 0, 30)
info.Font = Enum.Font.Gotham
info.Text = "Events: 0"
info.TextColor3 = Color3.fromRGB(150, 150, 150)
info.TextSize = 11
info.TextXAlignment = Enum.TextXAlignment.Left

local instructions = Instance.new("TextLabel")
instructions.Parent = frame
instructions.BackgroundTransparency = 1
instructions.Position = UDim2.new(0, 10, 0, 265)
instructions.Size = UDim2.new(1, -20, 0, 40)
instructions.Font = Enum.Font.Gotham
instructions.Text = "KB: RightShift+H (GUI) | RightShift+P (Play)\nPS5: Share (GUI) | R3 (Play)"
instructions.TextColor3 = Color3.fromRGB(150, 150, 150)
instructions.TextSize = 10
instructions.TextWrapped = true
instructions.TextYAlignment = Enum.TextYAlignment.Top

-- Record input
local function RecordInput(inputType, keyCode, delta)
    if not recording then return end
    
    local event = {
        time = tick() - startTime,
        type = inputType,
        keyCode = keyCode,
        delta = delta or 0
    }
    
    table.insert(macro, event)
    info.Text = "Events: " .. #macro
end

-- Start recording
recordBtn.MouseButton1Click:Connect(function()
    recording = true
    macro = {}
    startTime = tick()
    
    recordBtn.Visible = false
    stopBtn.Visible = true
    status.Text = "Status: 🔴 Recording..."
    status.TextColor3 = Color3.fromRGB(255, 0, 0)
    info.Text = "Events: 0"
    
    print("[Macro] Recording started")
end)

-- Stop recording
stopBtn.MouseButton1Click:Connect(function()
    recording = false
    
    recordBtn.Visible = true
    stopBtn.Visible = false
    status.Text = "Status: ✅ Macro saved!"
    status.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    print("[Macro] Recording stopped - " .. #macro .. " events captured")
end)

-- Play macro
local function PlayMacro()
    if #macro == 0 then
        status.Text = "Status: ⚠️ No macro recorded!"
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    if playing then
        status.Text = "Status: ⚠️ Already playing!"
        return
    end
    
    playing = true
    status.Text = "Status: ▶️ Playing macro..."
    status.TextColor3 = Color3.fromRGB(0, 150, 255)
    
    task.spawn(function()
        local macroStart = tick()
        
        for _, event in ipairs(macro) do
            -- Wait for correct timing
            local targetTime = macroStart + event.time
            while tick() < targetTime do
                task.wait()
            end
            
            -- Execute event
            if event.type == "MouseButton1Down" then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            elseif event.type == "MouseButton1Up" then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            elseif event.type == "MouseButton2Down" then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            elseif event.type == "MouseButton2Up" then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
            elseif event.type == "KeyDown" then
                VirtualInputManager:SendKeyEvent(true, event.keyCode, false, game)
            elseif event.type == "KeyUp" then
                VirtualInputManager:SendKeyEvent(false, event.keyCode, false, game)
            elseif event.type == "MouseWheel" then
                VirtualInputManager:SendMouseWheelEvent(0, 0, event.delta > 0, game)
            elseif event.type == "GamepadButtonDown" then
                -- Simulate gamepad button press
                game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0))
            elseif event.type == "GamepadButtonUp" then
                game:GetService("VirtualUser"):Button1Up(Vector2.new(0, 0))
            end
        end
        
        playing = false
        status.Text = "Status: ✅ Playback complete!"
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        print("[Macro] Playback complete")
    end)
end

playBtn.MouseButton1Click:Connect(PlayMacro)

-- Monitor inputs
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Hotkeys (always work, even when game is processing input)
    if input.KeyCode == Enum.KeyCode.H and UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
        frame.Visible = not frame.Visible
        return
    end
    
    if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
        PlayMacro()
        return
    end
    
    -- PS5 Controller Hotkeys
    if input.KeyCode == Enum.KeyCode.ButtonSelect then -- Share button
        frame.Visible = not frame.Visible
        return
    end
    
    if input.KeyCode == Enum.KeyCode.ButtonR3 then -- R3 (right stick click)
        PlayMacro()
        return
    end
    
    -- Recording (don't record if game is processing)
    if gameProcessed then return end
    if not recording then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        RecordInput("MouseButton1Down")
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        RecordInput("MouseButton2Down")
    elseif input.UserInputType == Enum.UserInputType.Keyboard then
        RecordInput("KeyDown", input.KeyCode)
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        RecordInput("MouseWheel", nil, input.Position.Z)
    elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
        -- Record gamepad buttons
        RecordInput("GamepadButtonDown", input.KeyCode)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not recording then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        RecordInput("MouseButton1Up")
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        RecordInput("MouseButton2Up")
    elseif input.UserInputType == Enum.UserInputType.Keyboard then
        RecordInput("KeyUp", input.KeyCode)
    elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
        RecordInput("GamepadButtonUp", input.KeyCode)
    end
end)

print("========================================")
print("[Macro Recorder] LOADED")
print("[Instructions]")
print("1. Click 'START RECORDING'")
print("2. Perform your perfect shot timing")
print("3. Click 'STOP RECORDING'")
print("4. Click 'PLAY MACRO' or use hotkeys")
print("")
print("[Keyboard Hotkeys]")
print("RightShift + H = Toggle GUI")
print("RightShift + P = Play Macro")
print("")
print("[PS5 Controller Hotkeys]")
print("Share Button = Toggle GUI")
print("R3 (Right Stick Click) = Play Macro")
print("========================================")
print("[Note] Controller buttons are recorded!")
print("========================================")
