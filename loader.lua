local LOADER_BASE = "http://mineminyee-lua.kro.kr:5000"
local SCRIPT_NAME = "loader.lua"

local function getHWID()
    local ok, id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if ok and id and id ~= "" then
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
            Text = msg,
            Duration = 5,
        })
    end)
    print("[Mineminyee]", msg)
end

local key = rawget(_G, "script_key")
    or (getgenv and getgenv().script_key)
    or (getfenv and getfenv().script_key)

if type(key) ~= "string" or key == "" then
    error([[
[Mineminyee] 키가 없습니다.
아래처럼 입력한 뒤 다시 실행하세요:

script_key = "여기에키입력"
loadstring(game:HttpGet("https://raw.githubusercontent.com/mineminyee222/Mineminyee_Enhancements/refs/heads/main/loader.lua"))()
]])
end

local hwid = getHWID()
if hwid == "UNKNOWN" then
    error("[Mineminyee] HWID를 읽을 수 없습니다.")
end

local url = LOADER_BASE:gsub("/+$", "") .. "/" .. SCRIPT_NAME
local HttpService = game:GetService("HttpService")
local body = HttpService:JSONEncode({
    key = key,
    hwid = hwid,
})

notify("인증 중...")

local ok, res = pcall(function()
    return httpPost(url, body)
end)

if not ok or not res then
    error("[Mineminyee] 서버 요청 실패: " .. tostring(res))
end

local status = res.StatusCode or res.Status or 0
local responseBody = res.Body or res.body or ""

if status ~= 200 then
    if type(responseBody) == "string" and #responseBody > 0 then
        local fn = loadstring(responseBody)
        if fn then fn() end
    end
    error("[Mineminyee] 인증 실패 (" .. tostring(status) .. ")")
end

local fn, err = loadstring(responseBody)
if not fn then
    error("[Mineminyee] 스크립트 로드 오류: " .. tostring(err))
end

notify("스크립트 로드 중...")
fn()
