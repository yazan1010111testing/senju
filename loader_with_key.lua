--[[
    UNIVERSAL BASKETBALL MACRO - KEY SYSTEM LOADER (FIXED)
    
    This loader will:
    1. Show key system UI
    2. Validate key with work.ink API
    3. Load the macro recorder script after validation
]]

print("🏀 Universal Basketball Macro - Loading...")

-- ============================================================================
-- CONFIGURATION
-- ============================================================================
local Config = {
    -- Work.ink Configuration
    LinkId = "2JiA",
    FullKeyLink = "https://work.ink/2JiA/d653afbe-06a3-4fc9-ba5f-674b59ebcbbd",
    DiscordInvite = "t9xNXQzSvs",
    
    -- Script URLs
    KeySystemURL = "https://raw.githubusercontent.com/yazan1010111testing/senju/refs/heads/main/key_system.lua",
    MainScriptURL = "https://raw.githubusercontent.com/yazan1010111testing/senju/refs/heads/main/macro_recorder.lua",
    
    -- Settings
    SaveKey = true,
    KeyFileName = "basketball_macro_key.txt"
}

-- ============================================================================
-- LOAD KEY SYSTEM
-- ============================================================================
print("[Loader] Loading key system...")

local keySystemUrl = Config.KeySystemURL .. "?t=" .. tick()

local success, keySystem = pcall(function()
    return loadstring(game:HttpGet(keySystemUrl))()
end)

if not success then
    warn("[Loader] Failed to load key system: " .. tostring(keySystem))
    return
end

if not keySystem or type(keySystem) ~= "table" then
    warn("[Loader] Key system did not return expected table, got: " .. type(keySystem))
    return
end

print("[Loader] Key system loaded! Type:", type(keySystem))

-- Initialize the key system with callback
keySystem:Initialize(function()
    print("[Loader] ✅ Key validated! Loading main script...")
    
    local mainScriptUrl = Config.MainScriptURL .. "?t=" .. tick()
    
    task.wait(0.5)
    
    local mainSuccess, mainError = pcall(function()
        loadstring(game:HttpGet(mainScriptUrl))()
    end)
    
    if not mainSuccess then
        warn("[Loader] Failed to load main script: " .. tostring(mainError))
    else
        print("[Loader] ✅ Main script loaded successfully!")
    end
end)

print("🏀 Universal Basketball Macro - Loader initialized")
