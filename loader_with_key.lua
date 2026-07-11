--[[
    UNIVERSAL BASKETBALL MACRO - KEY SYSTEM LOADER
    
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
    -- Work.ink Configuration (SAME AS DA HOOD - REUSING LINK!)
    LinkId = "2JiA",
    FullKeyLink = "https://work.ink/2JiA/d653afbe-06a3-4fc9-ba5f-674b59ebcbbd",
    DiscordInvite = "t9xNXQzSvs",
    
    -- Script URLs (UPDATE THESE WITH YOUR GITHUB RAW URLS)
    KeySystemURL = "https://raw.githubusercontent.com/yazan1010111testing/senju/refs/heads/main/key_system.lua",
    MainScriptURL = "https://raw.githubusercontent.com/yazan1010111testing/senju/refs/heads/main/macro_recorder.lua",
    
    -- Settings
    SaveKey = true, -- Save key locally
    KeyFileName = "basketball_macro_key.txt" -- Different filename than Da Hood (won't conflict)
}

-- ============================================================================
-- KEY VALIDATION FUNCTION
-- ============================================================================
local function ValidateKey(key)
    local cleanKey = key:gsub("%s+", "") -- Remove spaces only (keep dashes!)
    
    print("[Key System] Validating key: " .. cleanKey)
    
    local apiUrl = string.format("https://work.ink/_api/v2/token/isValid/%s?t=%d", cleanKey, tick())
    
    local success, response = pcall(function()
        return game:HttpGet(apiUrl)
    end)
    
    if not success then
        warn("[Key System] API request failed: " .. tostring(response))
        return false
    end
    
    print("[Key System] API Response: " .. response)
    
    local decoded = game:GetService("HttpService"):JSONDecode(response)
    
    if decoded.valid == true then
        print("[Key System] ✅ Key is valid!")
        return true
    else
        print("[Key System] ❌ Key is invalid")
        return false
    end
end

-- ============================================================================
-- LOAD KEY SYSTEM
-- ============================================================================
print("[Loader] Loading key system UI...")

local keySystemUrl = Config.KeySystemURL .. "?t=" .. tick()

local keySystemSuccess, keySystemError = pcall(function()
    -- Load the key system with configuration
    local keySystem = loadstring(game:HttpGet(keySystemUrl))()
    
    if keySystem and type(keySystem) == "function" then
        -- Call key system with config and validation callback
        keySystem({
            LinkId = Config.LinkId,
            FullKeyLink = Config.FullKeyLink,
            DiscordInvite = Config.DiscordInvite,
            SaveKey = Config.SaveKey,
            KeyFileName = Config.KeyFileName,
            ValidateKey = ValidateKey,
            OnSuccess = function()
                print("[Loader] ✅ Key validated! Loading main script...")
                
                -- Load the main macro recorder script
                local mainScriptUrl = Config.MainScriptURL .. "?t=" .. tick()
                
                task.wait(0.5) -- Small delay for UI transition
                
                local mainSuccess, mainError = pcall(function()
                    loadstring(game:HttpGet(mainScriptUrl))()
                end)
                
                if not mainSuccess then
                    warn("[Loader] Failed to load main script: " .. tostring(mainError))
                end
            end
        })
    else
        warn("[Loader] Key system did not return expected function")
    end
end)

if not keySystemSuccess then
    warn("[Loader] Failed to load key system: " .. tostring(keySystemError))
    
    -- Fallback: Try loading key system from alternate source
    warn("[Loader] Attempting direct key system load...")
    
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/key_system.lua"))()
    end)
end

print("🏀 Universal Basketball Macro - Loader initialized")
