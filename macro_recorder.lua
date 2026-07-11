-- Roblox Macro Recorder & Player
-- Record mouse clicks and key presses, then replay them
-- Perfect for recording green shot timing

local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local recording = false
local playing = false
local macro = {}
local startTime = 0

-- Config System
local savedMacros = {}
local currentMacroName = "Macro 1"
local autoLoadEnabled = true -- Set to true to auto-load on inject
local autoLoadMacroName = "default" -- Name of macro to auto-load

local function SaveMacroToConfig()
    if #macro == 0 then
        warn("[Config] No macro to save!")
        return
    end
    
    savedMacros[currentMacroName] = {
        events = macro,
        timestamp = os.time(),
        duration = macro[#macro].time * 1000
    }
    
    if writefile then
        local success = pcall(function()
            local encoded = HttpService:JSONEncode(savedMacros)
            writefile("macro_config.json", encoded)
            print("[💾 SAVED] " .. currentMacroName .. " saved to config!")
        end)
        if not success then
            warn("[Config] Failed to write file")
        end
    else
        print("[⚠️ WARNING] writefile not supported on your executor")
    end
end

local function GetMacroCount()
    local count = 0
    for _ in pairs(savedMacros) do
        count = count + 1
    end
    return count
end

local function LoadMacroFromConfig()
    if readfile and isfile and isfile("macro_config.json") then
        local success, data = pcall(function()
            local content = readfile("macro_config.json")
            return HttpService:JSONDecode(content)
        end)
        
        if success and data then
            savedMacros = data
            print("[📂 LOADED] Config file loaded - " .. GetMacroCount() .. " macros found")
            
            -- Auto-load default macro if enabled
            if autoLoadEnabled and savedMacros[autoLoadMacroName] then
                macro = savedMacros[autoLoadMacroName].events
                currentMacroName = autoLoadMacroName
                print("[✅ AUTO-LOADED] '" .. autoLoadMacroName .. "' restored automatically!")
                return true
            end
            
            -- Otherwise try to load current macro if it exists
            if savedMacros[currentMacroName] then
                macro = savedMacros[currentMacroName].events
                print("[✅ LOADED] " .. currentMacroName .. " restored!")
                return true
            end
        end
    end
    return false
end

local function ListSavedMacros()
    print("========== SAVED MACROS ==========")
    local count = 0
    for name, data in pairs(savedMacros) do
        count = count + 1
        local isAutoLoad = (name == autoLoadMacroName) and " [AUTO-LOAD]" or ""
        local isCurrent = (name == currentMacroName) and " [CURRENT]" or ""
        print(string.format("[%d] %s - %.0fms (%d events)%s%s", 
            count, name, data.duration, #data.events, isAutoLoad, isCurrent))
    end
    if count == 0 then
        print("No saved macros found")
        print("Tip: Record a macro and save it with a name!")
    end
    print("==================================")
end

local function SetAutoLoadMacro()
    if savedMacros[currentMacroName] then
        autoLoadMacroName = currentMacroName
        
        -- Save the auto-load preference
        if writefile then
            pcall(function()
                writefile("macro_autoload.txt", currentMacroName)
            end)
        end
        
        print("[🔄 AUTO-LOAD] '" .. currentMacroName .. "' will auto-load on next inject!")
        return true
    else
        warn("[⚠️ ERROR] Current macro not saved yet!")
        return false
    end
end

-- Load auto-load preference
if readfile and isfile and isfile("macro_autoload.txt") then
    local success, name = pcall(function()
        return readfile("macro_autoload.txt")
    end)
    if success and name and name ~= "" then
        autoLoadMacroName = name
    end
end

-- Load config on startup
local configLoaded = LoadMacroFromConfig()

-- Auto-list configs on startup
print("========================================")
print("[Macro Recorder] LOADING...")
if configLoaded then
    print("[✅ SUCCESS] Config loaded!")
    ListSavedMacros()
else
    print("[ℹ️ INFO] No saved configs found")
    print("Create your first macro!")
end
print("========================================")


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
frame.Size = UDim2.new(0, 300, 0, 440)
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

-- Config name input
local configLabel = Instance.new("TextLabel")
configLabel.Parent = frame
configLabel.BackgroundTransparency = 1
configLabel.Position = UDim2.new(0, 10, 0, 265)
configLabel.Size = UDim2.new(0.3, 0, 0, 25)
configLabel.Font = Enum.Font.GothamBold
configLabel.Text = "Name:"
configLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
configLabel.TextSize = 11
configLabel.TextXAlignment = Enum.TextXAlignment.Left

local nameBox = Instance.new("TextBox")
nameBox.Parent = frame
nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nameBox.BorderSizePixel = 1
nameBox.BorderColor3 = Color3.fromRGB(100, 100, 255)
nameBox.Position = UDim2.new(0.25, 0, 0, 265)
nameBox.Size = UDim2.new(0.75, -10, 0, 25)
nameBox.Font = Enum.Font.Gotham
nameBox.PlaceholderText = "Enter macro name..."
nameBox.Text = currentMacroName
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.TextSize = 11
nameBox.ClearTextOnFocus = false

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 4)
nameCorner.Parent = nameBox

nameBox.FocusLost:Connect(function()
    if nameBox.Text ~= "" then
        currentMacroName = nameBox.Text
        print("[📝 NAME] Current macro: " .. currentMacroName)
        
        -- Update info label with loaded macro info if it exists
        if savedMacros[currentMacroName] then
            info.Text = "Events: " .. #savedMacros[currentMacroName].events .. " (saved)"
            info.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            info.Text = "Events: " .. #macro
            info.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end)

-- Save/Load buttons
local saveBtn = Instance.new("TextButton")
saveBtn.Parent = frame
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
saveBtn.Position = UDim2.new(0, 10, 0, 300)
saveBtn.Size = UDim2.new(0.48, -5, 0, 30)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Text = "💾 SAVE"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.TextSize = 12

local saveBtnCorner = Instance.new("UICorner")
saveBtnCorner.CornerRadius = UDim.new(0, 5)
saveBtnCorner.Parent = saveBtn

local loadBtn = Instance.new("TextButton")
loadBtn.Parent = frame
loadBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
loadBtn.Position = UDim2.new(0.52, 5, 0, 300)
loadBtn.Size = UDim2.new(0.48, -5, 0, 30)
loadBtn.Font = Enum.Font.GothamBold
loadBtn.Text = "📂 LOAD"
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.TextSize = 12

local loadBtnCorner = Instance.new("UICorner")
loadBtnCorner.CornerRadius = UDim.new(0, 5)
loadBtnCorner.Parent = loadBtn

-- List button
local listBtn = Instance.new("TextButton")
listBtn.Parent = frame
listBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
listBtn.Position = UDim2.new(0, 10, 0, 340)
listBtn.Size = UDim2.new(0.48, -5, 0, 30)
listBtn.Font = Enum.Font.GothamBold
listBtn.Text = "📋 LIST"
listBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
listBtn.TextSize = 12

local listBtnCorner = Instance.new("UICorner")
listBtnCorner.CornerRadius = UDim.new(0, 5)
listBtnCorner.Parent = listBtn

-- Set Auto-Load button
local autoLoadBtn = Instance.new("TextButton")
autoLoadBtn.Parent = frame
autoLoadBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
autoLoadBtn.Position = UDim2.new(0.52, 5, 0, 340)
autoLoadBtn.Size = UDim2.new(0.48, -5, 0, 30)
autoLoadBtn.Font = Enum.Font.GothamBold
autoLoadBtn.Text = "🔄 AUTO"
autoLoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLoadBtn.TextSize = 12

local autoLoadCorner = Instance.new("UICorner")
autoLoadCorner.CornerRadius = UDim.new(0, 5)
autoLoadCorner.Parent = autoLoadBtn

saveBtn.MouseButton1Click:Connect(function()
    SaveMacroToConfig()
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    saveBtn.Text = "✅ SAVED!"
    task.wait(1)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    saveBtn.Text = "💾 SAVE"
end)

loadBtn.MouseButton1Click:Connect(function()
    if savedMacros[currentMacroName] then
        macro = savedMacros[currentMacroName].events
        info.Text = "Events: " .. #macro
        loadBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        loadBtn.Text = "✅ LOADED!"
        status.Text = "Status: ✅ " .. currentMacroName .. " loaded!"
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
        print("[📂 LOADED] " .. currentMacroName .. " - " .. #macro .. " events")
        task.wait(1)
        loadBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        loadBtn.Text = "📂 LOAD"
    else
        loadBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        loadBtn.Text = "❌ NOT FOUND"
        task.wait(1)
        loadBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        loadBtn.Text = "📂 LOAD"
    end
end)

listBtn.MouseButton1Click:Connect(function()
    ListSavedMacros()
    listBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    listBtn.Text = "✅ F9"
    task.wait(1.5)
    listBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    listBtn.Text = "📋 LIST"
end)

autoLoadBtn.MouseButton1Click:Connect(function()
    if SetAutoLoadMacro() then
        autoLoadBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        autoLoadBtn.Text = "✅ SET!"
        task.wait(1.5)
        autoLoadBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
        autoLoadBtn.Text = "🔄 AUTO"
    else
        autoLoadBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        autoLoadBtn.Text = "❌ ERROR"
        task.wait(1.5)
        autoLoadBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
        autoLoadBtn.Text = "🔄 AUTO"
    end
end)

local instructions = Instance.new("TextLabel")
instructions.Parent = frame
instructions.BackgroundTransparency = 1
instructions.Position = UDim2.new(0, 10, 0, 380)
instructions.Size = UDim2.new(1, -20, 0, 50)
instructions.Font = Enum.Font.Gotham
instructions.Text = "💾 SAVE = Save macro | 📂 LOAD = Load macro\n📋 LIST = Show all | 🔄 AUTO = Set auto-load\nRightShift+P or R3 = Play"
instructions.TextColor3 = Color3.fromRGB(150, 150, 150)
instructions.TextSize = 9
instructions.TextWrapped = true
instructions.TextYAlignment = Enum.TextYAlignment.Top

-- Update the name box with current macro name on load
if configLoaded then
    nameBox.Text = currentMacroName
    if #macro > 0 then
        info.Text = "Events: " .. #macro .. " (loaded)"
        info.TextColor3 = Color3.fromRGB(100, 255, 100)
        status.Text = "Status: ✅ " .. currentMacroName .. " loaded!"
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end

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
    status.Text = "Status: ✅ Macro recorded!"
    status.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    print("[Macro] Recording stopped - " .. #macro .. " events captured")
    
    -- Auto-save to current name
    SaveMacroToConfig()
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
print("[Auto-Load] Enabled: " .. tostring(autoLoadEnabled))
if autoLoadMacroName ~= "" then
    print("[Auto-Load] Macro: " .. autoLoadMacroName)
end
print("[Instructions]")
print("1. Enter a name for your macro")
print("2. Click 'START RECORDING'")
print("3. Perform your perfect shot timing")
print("4. Click 'STOP RECORDING' (auto-saves)")
print("5. Click '🔄 AUTO' to set as auto-load")
print("")
print("[Keyboard Hotkeys]")
print("RightShift + H = Toggle GUI")
print("RightShift + P = Play Macro")
print("")
print("[PS5 Controller Hotkeys]")
print("Share Button = Toggle GUI")
print("R3 (Right Stick Click) = Play Macro")
print("========================================")
print("[Config System] Save/Load macros by name")
print("========================================")
