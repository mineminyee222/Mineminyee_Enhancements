
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

local key = rawget(_G, "script_key")
    or (getgenv and getgenv().script_key)
    or (getfenv and getfenv().script_key)

if type(key) ~= "string" or key == "" then
    error([[
[Mineminyee] 키가 없습니다.

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
print("[Mineminyee] URL:", url)
print("[Mineminyee] HWID:", hwid)

local ok, res = pcall(function()
    return httpPost(url, body)
end)

if not ok then
    error("[Mineminyee] 서버 요청 실패: " .. tostring(res))
end
if not res then
    error("[Mineminyee] 서버 응답 없음 (도메인/포트/서버 실행 확인)")
end

local status = tonumber(res.StatusCode or res.Status or 0) or 0
local responseBody = res.Body or res.body or ""

print("[Mineminyee] Status:", status)
print("[Mineminyee] Body length:", #tostring(responseBody))

if status ~= 200 then
    local msg = tostring(responseBody)
    -- error() 문자열만 추출
    local extracted = msg:match('%[Mineminyee%][^"]*') or msg:sub(1, 200)
    error("[Mineminyee] 인증 실패 (" .. status .. "): " .. extracted)
end

if type(responseBody) ~= "string" or #responseBody < 1 then
    error("[Mineminyee] 서버가 빈 스크립트를 반환했습니다. 관리자 Scripts에 코드를 넣으세요.")
end

-- Kick/error 응답이 200으로 온 경우 방어
if responseBody:find("LocalPlayer:Kick") or responseBody:find('error("%[Mineminyee%]') then
    error("[Mineminyee] 서버가 오류 응답을 보냈습니다: " .. responseBody:sub(1, 150))
end

local fn, err = loadstring(responseBody)
if not fn then
    error("[Mineminyee] 스크립트 문법 오류: " .. tostring(err) .. "\n(관리자에 넣은 Lua 코드를 확인하세요)")
end

notify("스크립트 실행")
local execOk, execErr = pcall(fn)
if not execOk then
    error("[Mineminyee] 스크립트 실행 오류: " .. tostring(execErr))
end
