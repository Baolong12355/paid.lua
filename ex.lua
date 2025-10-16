-- [[ LIST OF VALID KEYS ]]
local validKeys = {
    "KEY"
    -- You can add more keys here, like "KEY_2", "KEY_3"
}

-- [[ CONFIGURATION AND URLS ]]
-- All URLs have been corrected to point to the correct raw files.
local jsonURL = "https://raw.githubusercontent.com/Baolong12355/paid.lua/main/ex.json"
local loaderURL = "https://raw.githubusercontent.com/Baolong12355/loader.lua/main/loader.lua"
local skipWaveURL = "https://raw.githubusercontent.com/Baolong12355/loader.lua/main/auto_skip.lua"
local webhookURL = "https://discord.com/api/webhooks/1425775708562522183/DpwrsVPt6lgFU1Y0SU1J5ACMv4lN5JeKFES2Ips-RFF66tvTbclQCiTxGCWrqJDcVaZ7"
local blackURL = "https://raw.githubusercontent.com/Baolong12355/loader.lua/main/black.lua"
local fpsURL = "https://raw.githubusercontent.com/Baolong12355/loader.lua/main/fps.lua"
local psURL = "https://raw.githubusercontent.com/Baolong12355/loader.lua/main/ps.lua"

local macroFolder = "tdx/macros"
local macroFile = macroFolder.."/x.json"

local HttpService = game:GetService("HttpService")

-- Function to send info to Webhook
local function sendToWebhook(key, playerName, playerId)
    local data = {
        ["embeds"] = {{
            ["title"] = "Script Execution Log",
            ["color"] = 3447003,
            ["fields"] = {
                { ["name"] = "Key", "value"] = key or "N/A", "inline" = true },
                { ["name"] = "Player Name", "value"] = playerName or "N/A", "inline" = true },
                { ["name"] = "Player ID", "value"] = tostring(playerId) or "N/A", "inline" = true },
                { ["name"] = "Executor", "value"] = identifyexecutor() or "Unknown", "inline" = true },
                { ["name"] = "Time", "value"] = os.date("%Y-%m-%d %H:%M:%S"), "inline" = false }
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    local jsonData = HttpService:JSONEncode(data)
    pcall(function()
        return request({ Url = webhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = jsonData })
    end)
end

-- Key validation function (checks against the internal list)
local function validateKey(keyToValidate)
    for _, validKey in ipairs(validKeys) do
        if keyToValidate == validKey then
            return true
        end
    end
    return false
end

-- Wait for the game to load and get player info
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local player = game.Players.LocalPlayer
local playerName = player.Name
local playerId = player.UserId

-- Get the key entered by the user
getgenv().TDX_Config = getgenv().TDX_Config or {} -- Ensure the config table exists
local inputKey = getgenv().TDX_Config.Key
if not inputKey or inputKey == "" then
    print("SCRIPT: No key detected. Please set your key in getgenv().TDX_Config.Key")
    return
end

local cleanKey = inputKey:match("^%s*(.-)%s*$")
if not cleanKey or #cleanKey == 0 then
    print("SCRIPT: The provided key is empty. Please set your key in getgenv().TDX_Config.Key")
    return
end

-- Perform the key check
if not validateKey(cleanKey) then
    print("SCRIPT: Invalid key. Please check the key and try again.")
    return
else
    print("SCRIPT: [SUCCESS] Key validated. Executing script...")
end

-- Send info to webhook after successful validation
sendToWebhook(cleanKey, playerName, playerId)

-- =================================================================
-- Main Script Logic
-- =================================================================

if game.PlaceId == 9503261072 and #game.Players:GetPlayers() > 1 then
    pcall(function() loadstring(game:HttpGet(psURL))() end)
end

if game.PlaceId == 11739766412 then
    pcall(function() loadstring(game:HttpGet(blackURL))() end)
    pcall(function() loadstring(game:HttpGet(fpsURL))() end)
end

if not isfolder("tdx") then makefolder("tdx") end
if not isfolder(macroFolder) then makefolder(macroFolder) end

local success, result = pcall(function() return game:HttpGet(jsonURL) end)
if success and result then
    writefile(macroFile, result)
else
    warn("SCRIPT: Failed to download macro file from URL.")
    return
end

-- [[ FIXED CONFIGURATION ]]
-- This now ADDS settings to the existing config table instead of overwriting it.
getgenv().TDX_Config["Return Lobby"] = false
getgenv().TDX_Config["x1.5 Speed"] = true
getgenv().TDX_Config["DOKf"] = true
getgenv().TDX_Config["Auto Skill"] = true
getgenv().TDX_Config["Map"] = "SCORCHED PASSAGE"
getgenv().TDX_Config["Macros"] = "run"
getgenv().TDX_Config["Macro Name"] = "x"
getgenv().TDX_Config["Auto Difficulty"] = "Expert"

-- Load the main loader
pcall(function()
    loadstring(game:HttpGet(loaderURL))()
end)

-- Configure and load the wave skipper
_G.WaveConfig = {}
for i = 1, 50 do
    _G.WaveConfig["WAVE " .. i] = "now"
end

pcall(function()
    loadstring(game:HttpGet(skipWaveURL))()
end)