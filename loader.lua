local LOADER_BASE = "http://mineminyee-lua.kro.kr:5000"

local SCRIPT_NAME = tostring(
    rawget(_G, "script_name")
    or (getgenv and getgenv().script_name)
    or "loader.lua"
)

local function doKick(msg)
    pcall(function()
        game:GetService("Players").LocalPlayer:Kick("[Mineminyee] " .. tostring(msg))
    end)
end

if not game or not game.GetService then
    error("[Mineminyee] Roblox runtime only")
end

local key = rawget(_G, "script_key") or (getgenv and getgenv().script_key)
if type(key) ~= "string" or key == "" then
    doKick("Set script_key = \"YOUR_KEY\" first")
    return
end

local function getHWID()
    local ok, id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if ok and id and tostring(id) ~= "" then
        return tostring(id)
    end
    ok, id = pcall(function()
        return game:GetService("Players").LocalPlayer.UserId
    end)
    if ok and id then
        return "UID_" .. tostring(id)
    end
    return "UNKNOWN"
end

local hwid = getHWID()
if hwid == "UNKNOWN" then
    doKick("HWID failed")
    return
end

local HttpService = game:GetService("HttpService")
local body = HttpService:JSONEncode({ key = key, hwid = hwid })
local url = LOADER_BASE:gsub("/+$", "") .. "/" .. SCRIPT_NAME

local headers = {
    ["Content-Type"] = "application/json",
    ["User-Agent"] = "SecureLoader/2.0",
    ["X-Client"] = "mineminyee-roblox-loader",
}

local req = (syn and syn.request)
    or (http and http.request)
    or http_request
    or request
if not req then
    doKick("No HTTP request function")
    return
end

print("[Mineminyee] Auth...")
print("[Mineminyee] URL:", url)

local ok, res = pcall(function()
    return req({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body,
    })
end)

if not ok or not res then
    doKick("Server request failed")
    return
end

local status = tonumber(res.StatusCode or res.Status or 0) or 0
local responseBody = res.Body or res.body or ""
print("[Mineminyee] Status:", status)

if status ~= 200 then
    if type(responseBody) == "string" and responseBody:find("Kick") then
        local fn = loadstring(responseBody)
        if fn then pcall(fn) end
    else
        doKick("Authentication failed")
    end
    return
end

if type(responseBody) ~= "string" or #responseBody < 1 then
    doKick("Empty script — put code in admin Scripts")
    return
end

local fn, err = loadstring(responseBody)
if not fn then
    doKick("Script parse error")
    return
end

local eok, eerr = pcall(fn)
if not eok then
    doKick("Script error: " .. tostring(eerr))
end
