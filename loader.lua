local LOADER_BASE = "http://mineminyee-lua.kro.kr:5000"

local function doKick(msg)
    pcall(function()
        game:GetService("Players").LocalPlayer:Kick("[Mineminyee] " .. tostring(msg))
    end)
end

if not game or not game.GetService then
    error("[Mineminyee] Roblox runtime only")
end

-- script_key / script_name: 호출한 쪽 환경에서 찾기 (loadstring 새 환경 문제 대응)
local function pick_string(v)
    if type(v) == "string" and #v > 0 then
        return v
    end
    return nil
end

local function find_from_env(env, name)
    if type(env) ~= "table" then
        return nil
    end
    local ok, v = pcall(function()
        return env[name]
    end)
    if ok then
        return pick_string(v)
    end
    return nil
end

local function find_var(name)
    local v
    -- 1) 직접 전역 (일부 실행기)
    v = pick_string(rawget(_G, name))
    if v then return v end

    -- 2) 호출 스택 환경 (script_key = ... 한 스크립트에서 loadstring 호출 시)
    for level = 1, 6 do
        local ok, env = pcall(function()
            return getfenv(level)
        end)
        if ok then
            v = find_from_env(env, name)
            if v then return v end
        end
    end

    -- 3) shared / getgenv / getrenv (실행기마다 다름 — 유저 입력 방식은 script_key = 유지)
    pcall(function()
        if shared then
            v = pick_string(shared[name])
        end
    end)
    if v then return v end

    pcall(function()
        if getgenv then
            v = pick_string(getgenv()[name])
        end
    end)
    if v then return v end

    pcall(function()
        if getrenv then
            v = pick_string(getrenv()[name])
        end
    end)
    if v then return v end

    return nil
end

local key = find_var("script_key")
local SCRIPT_NAME = find_var("script_name") or "loader.lua"

if not key then
    doKick('Set script_key = "YOUR_KEY" first')
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
local url = LOADER_BASE:gsub("/+$", "") .. "/" .. tostring(SCRIPT_NAME)

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
        if fn then
            pcall(fn)
        end
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
