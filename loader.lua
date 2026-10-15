local LOADER_BASE = "http://mineminyee-lua.kro.kr:5000"
local SCRIPT_NAME = "loader.lua"

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

local function httpPost(url, body)
    local req = (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
    if not req then
        error("[Mineminyee] 이 실행기에서는 HTTP 요청을 지원하지 않습니다.")
    end
    return req({
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "SecureLoader/2.0",
        },
        Body = body,
    })
end

local function notify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Mineminyee",
            Text = tostring(msg),
            Duration = 5,
        })
    end)
    print("[Mineminyee]", msg)
end

local function doKick(msg)
    msg = tostring(msg or "Access denied")
    pcall(function()
        game:GetService("Players").LocalPlayer:Kick("[Mineminyee] " .. msg)
    end)
end

local function runResponse(body)
    if type(body) ~= "string" or #body < 1 then
        return false, "empty"
    end
    -- 서버가 Kick 코드를 보낸 경우 실행
    if body:find("LocalPlayer:Kick") or body:find(":Kick(") then
        local fn = loadstring(body)
        if fn then
            pcall(fn)
        else
            doKick("Access denied")
        end
        return true, "kicked"
    end
    local fn, err = loadstring(body)
    if not fn then
        return false, tostring(err)
    end
    local ok, execErr = pcall(fn)
    if not ok then
        return false, tostring(execErr)
    end
    return true, "ok"
end

local key = rawget(_G, "script_key")
    or (getgenv and getgenv().script_key)
    or (getfenv and getfenv().script_key)

if type(key) ~= "string" or key == "" then
    doKick("Key required. Set script_key = \"YOUR-KEY\"")
    return
end

local hwid = getHWID()
if hwid == "UNKNOWN" then
    doKick("Could not read HWID")
    return
end

local url = LOADER_BASE:gsub("/+$", "") .. "/" .. SCRIPT_NAME
local HttpService = game:GetService("HttpService")
local body = HttpService:JSONEncode({
    key = key,
    hwid = hwid,
})

notify("인증 중...")
print("[Mineminyee] URL:", url)
print("[Mineminyee] HWID:", hwid)

local ok, res = pcall(function()
    return httpPost(url, body)
end)

if not ok or not res then
    doKick("Server request failed")
    return
end

local status = tonumber(res.StatusCode or res.Status or 0) or 0
local responseBody = res.Body or res.body or ""

print("[Mineminyee] Status:", status)
print("[Mineminyee] Body length:", #tostring(responseBody))

if status ~= 200 then
    local ran, why = runResponse(tostring(responseBody))
    if not ran or why == "empty" then
        doKick("Auth failed (" .. tostring(status) .. ")")
    end
    return
end

if type(responseBody) ~= "string" or #responseBody < 1 then
    doKick("Empty script from server. Put code in admin Scripts.")
    return
end

notify("스크립트 실행")
local ran, why = runResponse(responseBody)
if not ran then
    doKick("Script error: " .. tostring(why))
end
