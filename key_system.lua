--[[
    UNIVERSAL BASKETBALL MACRO - KEY SYSTEM
    Using work.ink API v2
]]

-- Copy the entire key system code from Da Hood but change these lines:

local KeySystem = {}

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
KeySystem.Config = {
    LinkId = "2JiA", -- Same as Da Hood
    FullLink = "https://work.ink/2JiA/d653afbe-06a3-4fc9-ba5f-674b59ebcbbd", -- Same as Da Hood
    KeyLink = "", -- Will be auto-set
    ValidateEndpoint = "https://work.ink/_api/v2/token/isValid/",
    
    -- Script Info - CHANGED FOR BASKETBALL MACRO
    ScriptName = "🏀 Universal Basketball Macro",
    ScriptVersion = "v1.0",
    SaveKey = true,
    VerifyIP = false,
    DeleteToken = false,
    MaxAttempts = 5,
    CooldownTime = 30,
    DiscordInvite = "t9xNXQzSvs", -- Your Discord server
}

KeySystem.Config.KeyLink = KeySystem.Config.FullLink

-- Variables
local LocalPlayer = Players.LocalPlayer
local KeyValidated = false
local FailedAttempts = 0
local LastAttemptTime = 0

-- Storage - CHANGED FILENAME
local function SaveKey(key)
    if not KeySystem.Config.SaveKey then return end
    pcall(function()
        writefile("basketball_macro_key.txt", key)
    end)
end

local function LoadKey()
    if not KeySystem.Config.SaveKey then return nil end
    local success, key = pcall(function()
        return readfile("basketball_macro_key.txt")
    end)
    return success and key or nil
end

-- API Validation
local function ValidateKey(key)
    if tick() - LastAttemptTime < KeySystem.Config.CooldownTime and FailedAttempts >= KeySystem.Config.MaxAttempts then
        local remainingTime = math.ceil(KeySystem.Config.CooldownTime - (tick() - LastAttemptTime))
        return false, "Too many failed attempts. Wait " .. remainingTime .. "s"
    end
    
    if not key or key == "" or #key < 10 then
        return false, "Please enter a valid key"
    end
    
    key = key:gsub("%s+", "")
    
    local apiUrl = KeySystem.Config.ValidateEndpoint .. key
    if KeySystem.Config.DeleteToken then
        apiUrl = apiUrl .. "?deleteToken=1"
    end
    
    local success, response = pcall(function()
        return game:HttpGet(apiUrl)
    end)
    
    if not success then
        LastAttemptTime = tick()
        FailedAttempts = FailedAttempts + 1
        return false, "Connection error"
    end
    
    local decoded
    success, decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not success then
        LastAttemptTime = tick()
        FailedAttempts = FailedAttempts + 1
        return false, "Invalid response"
    end
    
    if decoded.valid == true then
        KeyValidated = true
        SaveKey(key)
        FailedAttempts = 0
        return true, "Key validated successfully!"
    else
        LastAttemptTime = tick()
        FailedAttempts = FailedAttempts + 1
        return false, "Invalid key"
    end
end

-- UI Creation (same as Da Hood version)
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar
    
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 12)
    TopBarFix.Position = UDim2.new(0, 0, 1, -12)
    TopBarFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = KeySystem.Config.ScriptName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    local Version = Instance.new("TextLabel")
    Version.Name = "Version"
    Version.Size = UDim2.new(0, 60, 1, 0)
    Version.Position = UDim2.new(1, -70, 0, 0)
    Version.BackgroundTransparency = 1
    Version.Text = KeySystem.Config.ScriptVersion
    Version.TextColor3 = Color3.fromRGB(150, 150, 150)
    Version.TextSize = 14
    Version.Font = Enum.Font.Gotham
    Version.TextXAlignment = Enum.TextXAlignment.Right
    Version.Parent = TopBar
    
    local Description = Instance.new("TextLabel")
    Description.Name = "Description"
    Description.Size = UDim2.new(1, -40, 0, 40)
    Description.Position = UDim2.new(0, 20, 0, 65)
    Description.BackgroundTransparency = 1
    Description.Text = "Enter your key to unlock the macro recorder"
    Description.TextColor3 = Color3.fromRGB(180, 180, 180)
    Description.TextSize = 14
    Description.Font = Enum.Font.Gotham
    Description.TextWrapped = true
    Description.Parent = MainFrame
    
    local InputContainer = Instance.new("Frame")
    InputContainer.Name = "InputContainer"
    InputContainer.Size = UDim2.new(1, -40, 0, 45)
    InputContainer.Position = UDim2.new(0, 20, 0, 115)
    InputContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    InputContainer.BorderSizePixel = 0
    InputContainer.Parent = MainFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputContainer
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(1, -20, 1, -10)
    KeyInput.Position = UDim2.new(0, 10, 0, 5)
    KeyInput.BackgroundTransparency = 1
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    KeyInput.TextSize = 14
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = InputContainer
    
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Size = UDim2.new(1, -40, 0, 45)
    GetKeyButton.Position = UDim2.new(0, 20, 0, 175)
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange for basketball theme
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Text = "🏀 Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 15
    GetKeyButton.Font = Enum.Font.GothamBold
    GetKeyButton.AutoButtonColor = false
    GetKeyButton.Parent = MainFrame
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyButton
    
    local ValidateButton = Instance.new("TextButton")
    ValidateButton.Name = "ValidateButton"
    ValidateButton.Size = UDim2.new(1, -40, 0, 45)
    ValidateButton.Position = UDim2.new(0, 20, 0, 235)
    ValidateButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    ValidateButton.BorderSizePixel = 0
    ValidateButton.Text = "✅ Validate Key"
    ValidateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValidateButton.TextSize = 15
    ValidateButton.Font = Enum.Font.GothamBold
    ValidateButton.AutoButtonColor = false
    ValidateButton.Parent = MainFrame
    
    local ValidateCorner = Instance.new("UICorner")
    ValidateCorner.CornerRadius = UDim.new(0, 8)
    ValidateCorner.Parent = ValidateButton
    
    local DiscordButton = Instance.new("TextButton")
    DiscordButton.Name = "DiscordButton"
    DiscordButton.Size = UDim2.new(1, -40, 0, 35)
    DiscordButton.Position = UDim2.new(0, 20, 1, -45)
    DiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    DiscordButton.BorderSizePixel = 0
    DiscordButton.Text = "💬 Join Discord"
    DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordButton.TextSize = 14
    DiscordButton.Font = Enum.Font.GothamBold
    DiscordButton.AutoButtonColor = false
    DiscordButton.Parent = MainFrame
    
    local DiscordCorner = Instance.new("UICorner")
    DiscordCorner.CornerRadius = UDim.new(0, 8)
    DiscordCorner.Parent = DiscordButton
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -40, 0, 20)
    StatusLabel.Position = UDim2.new(0, 20, 0, 290)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame
    
    -- Dragging
    local dragging = false
    local dragInput, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Button Animations
    local function ButtonHover(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
        end)
    end
    
    ButtonHover(GetKeyButton, Color3.fromRGB(255, 175, 20), Color3.fromRGB(255, 165, 0))
    ButtonHover(ValidateButton, Color3.fromRGB(60, 210, 110), Color3.fromRGB(50, 200, 100))
    ButtonHover(DiscordButton, Color3.fromRGB(98, 111, 252), Color3.fromRGB(88, 101, 242))
    
    -- Discord Button
    DiscordButton.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard("https://discord.gg/" .. KeySystem.Config.DiscordInvite)
                StatusLabel.Text = "Discord invite copied!"
                StatusLabel.TextColor3 = Color3.fromRGB(88, 101, 242)
            end
        end)
        task.wait(3)
        if StatusLabel.Text == "Discord invite copied!" then
            StatusLabel.Text = ""
        end
    end)
    
    -- Get Key Button
    GetKeyButton.MouseButton1Click:Connect(function()
        StatusLabel.Text = "Opening key link..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        
        pcall(function()
            if setclipboard then
                setclipboard(KeySystem.Config.KeyLink)
                StatusLabel.Text = "Link copied to clipboard!"
            end
        end)
        
        task.wait(2)
        StatusLabel.Text = ""
    end)
    
    -- Validate Button
    ValidateButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        StatusLabel.Text = "Validating..."
        StatusLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
        ValidateButton.Text = "Validating..."
        
        task.wait(0.5)
        
        local success, message = ValidateKey(key)
        
        if success then
            StatusLabel.Text = message
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            ValidateButton.Text = "Success!"
            ValidateButton.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
            
            task.wait(1)
            
            -- Fade out
            TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            for _, obj in ipairs(MainFrame:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    TweenService:Create(obj, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                end
                if obj:IsA("Frame") or obj:IsA("ImageLabel") then
                    TweenService:Create(obj, TweenInfo.new(0.5), {
                        BackgroundTransparency = 1,
                        ImageTransparency = 1
                    }):Play()
                end
            end
            
            task.wait(0.5)
            ScreenGui:Destroy()
        else
            StatusLabel.Text = message
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            ValidateButton.Text = "✅ Validate Key"
            
            -- Shake
            local originalPos = ValidateButton.Position
            for i = 1, 3 do
                ValidateButton.Position = originalPos + UDim2.new(0, 5, 0, 0)
                task.wait(0.05)
                ValidateButton.Position = originalPos - UDim2.new(0, 5, 0, 0)
                task.wait(0.05)
            end
            ValidateButton.Position = originalPos
        end
    end)
    
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            ValidateButton.MouseButton1Click:Fire()
        end
    end)
    
    return ScreenGui
end

-- Main Function
function KeySystem:Initialize(callback)
    local savedKey = LoadKey()
    if savedKey then
        print("[Key System] Checking saved key...")
        local success, message = ValidateKey(savedKey)
        
        if success then
            print("[Key System] Saved key valid! Loading macro...")
            task.wait(0.5)
            callback()
            return
        end
    end
    
    print("[Key System] Showing key system UI...")
    local ui = CreateUI()
    
    while not KeyValidated do
        task.wait(0.5)
    end
    
    print("[Key System] Key validated! Loading macro...")
    callback()
end

function KeySystem:IsValidated()
    return KeyValidated
end

return KeySystem
