local LOADER_BASE = "http://mineminyee-lua.kro.kr:5000"
local HMAC_SECRET = "Z_RkEJAO3RCsjTVpNfrR5dGMobYWxHy-u-Vah5vD5HAIQVTyyQNhouVM0C1oSJ4o"

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
if type(HMAC_SECRET) ~= "string" or HMAC_SECRET == "CHANGE_ME_TO_SERVER_HMAC_SECRET" or #HMAC_SECRET < 8 then
    doKick("HMAC_SECRET not set in loader.lua (must match server .env)")
    return
end

local function getHWID()
    local ok, id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if ok and id and tostring(id) ~= "" then return tostring(id) end
    ok, id = pcall(function()
        return game:GetService("Players").LocalPlayer.UserId
    end)
    if ok and id then return "UID_" .. tostring(id) end
    return "UNKNOWN"
end

-- SHA256 hex: prefer executor crypt, else pure Lua
local function sha256_hex(msg)
    msg = tostring(msg)
    -- Synapse / many executors
    if crypt and crypt.hash then
        local ok, r = pcall(function() return crypt.hash(msg, "sha256") end)
        if ok and r and #tostring(r) == 64 then return string.lower(tostring(r)) end
    end
    if syn and syn.crypt and syn.crypt.hash then
        local ok, r = pcall(function() return syn.crypt.hash(msg, "sha256") end)
        if ok and r and #tostring(r) == 64 then return string.lower(tostring(r)) end
    end
    -- Some executors: crypt.hash(data) returns binary; encode
    if crypt and crypt.hash then
        local ok, r = pcall(crypt.hash, msg)
        if ok and r then
            if #r == 64 and r:match("^[0-9a-fA-F]+$") then return string.lower(r) end
            if crypt.hexencode then
                local ok2, h = pcall(crypt.hexencode, r)
                if ok2 and h then return string.lower(h) end
            end
        end
    end

    -- Pure Lua SHA-256 (standard)
    local band, bxor, bnot, rshift, lshift, bor
    if bit32 then
        band, bxor, bnot, rshift, lshift, bor = bit32.band, bit32.bxor, bit32.bnot, bit32.rshift, bit32.lshift, bit32.bor
    elseif bit then
        band, bxor, bnot, rshift, lshift, bor = bit.band, bit.bxor, bit.bnot, bit.rshift, bit.lshift, bit.bor
    else
        error("[Mineminyee] No bit/crypt library for SHA256")
    end

    local function rrotate(x, n)
        n = n % 32
        return band(bor(rshift(x, n), lshift(x, 32 - n)), 0xFFFFFFFF)
    end

    local K = {
        0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
        0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
        0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
        0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
        0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
        0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
        0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
        0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
    }

    local bytes = {msg:byte(1, #msg)}
    local bitLen = #bytes * 8
    bytes[#bytes + 1] = 0x80
    while (#bytes % 64) ~= 56 do bytes[#bytes + 1] = 0 end
    for i = 1, 4 do bytes[#bytes + 1] = 0 end
    for i = 3, 0, -1 do bytes[#bytes + 1] = band(rshift(bitLen, i * 8), 0xFF) end

    local h = {
        0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
        0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
    }

    for off = 0, #bytes - 1, 64 do
        local w = {}
        for i = 0, 15 do
            local j = off + i * 4
            w[i] = lshift(bytes[j + 1] or 0, 24)
                + lshift(bytes[j + 2] or 0, 16)
                + lshift(bytes[j + 3] or 0, 8)
                + (bytes[j + 4] or 0)
        end
        for i = 16, 63 do
            local v0, v1 = w[i - 15], w[i - 2]
            local s0 = bxor(bxor(rrotate(v0, 7), rrotate(v0, 18)), rshift(v0, 3))
            local s1 = bxor(bxor(rrotate(v1, 17), rrotate(v1, 19)), rshift(v1, 10))
            w[i] = band(w[i - 16] + s0 + w[i - 7] + s1, 0xFFFFFFFF)
        end
        local a, b, c, d, e, f, g, hh = h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8]
        for i = 0, 63 do
            local S1 = bxor(bxor(rrotate(e, 6), rrotate(e, 11)), rrotate(e, 25))
            local ch = bxor(band(e, f), band(bnot(e), g))
            local t1 = band(hh + S1 + ch + K[i + 1] + w[i], 0xFFFFFFFF)
            local S0 = bxor(bxor(rrotate(a, 2), rrotate(a, 13)), rrotate(a, 22))
            local maj = bxor(bxor(band(a, b), band(a, c)), band(b, c))
            local t2 = band(S0 + maj, 0xFFFFFFFF)
            hh = g
            g = f
            f = e
            e = band(d + t1, 0xFFFFFFFF)
            d = c
            c = b
            b = a
            a = band(t1 + t2, 0xFFFFFFFF)
        end
        h[1] = band(h[1] + a, 0xFFFFFFFF)
        h[2] = band(h[2] + b, 0xFFFFFFFF)
        h[3] = band(h[3] + c, 0xFFFFFFFF)
        h[4] = band(h[4] + d, 0xFFFFFFFF)
        h[5] = band(h[5] + e, 0xFFFFFFFF)
        h[6] = band(h[6] + f, 0xFFFFFFFF)
        h[7] = band(h[7] + g, 0xFFFFFFFF)
        h[8] = band(h[8] + hh, 0xFFFFFFFF)
    end

    local out = {}
    for i = 1, 8 do out[i] = string.format("%08x", h[i]) end
    return table.concat(out)
end

local hwid = getHWID()
if hwid == "UNKNOWN" then
    doKick("HWID failed")
    return
end

local HttpService = game:GetService("HttpService")
local body = HttpService:JSONEncode({ key = key, hwid = hwid })
local timestamp = tostring(os.time())
local nonce = (HttpService:GenerateGUID(false):gsub("%-", "") .. HttpService:GenerateGUID(false):gsub("%-", "")):sub(1, 32)
local payload = HMAC_SECRET .. ":" .. timestamp .. ":" .. nonce .. ":" .. body
local sig = sha256_hex(payload)

-- self-check empty hash (must be e3b0c442...)
local empty = sha256_hex("")
if empty ~= "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" then
    print("[Mineminyee] WARN sha256 self-check failed:", empty)
end

local url = LOADER_BASE:gsub("/+$", "") .. "/" .. SCRIPT_NAME
local headers = {
    ["Content-Type"] = "application/json",
    ["User-Agent"] = "SecureLoader/2.0",
    ["X-Timestamp"] = timestamp,
    ["X-Nonce"] = nonce,
    ["X-Signature"] = sig,
    ["X-Client"] = "mineminyee-roblox-loader",
}

local req = (syn and syn.request) or (http and http.request) or http_request or request
if not req then
    doKick("No HTTP request function")
    return
end

print("[Mineminyee] Auth...")
print("[Mineminyee] URL:", url)
local ok, res = pcall(function()
    return req({ Url = url, Method = "POST", Headers = headers, Body = body })
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
