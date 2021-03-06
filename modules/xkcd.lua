-- modules
local http = require 'socket.http'
local url  = require 'socket.url'
local json = require 'json'

-- get data
return function(msg, from)
    local result
    local suc = pcall(function()
        result = http.request("http://www.xkcd.com/" .. (msg and msg .. '/' or '') ..'info.0.json')
        result = json.decode(result)
        result = result.title .. "-> " .. result.img
    end)

    if suc then
        return(from .. ": " .. result)
    else
        return(from .. ": Invalid comic")
    end
end
