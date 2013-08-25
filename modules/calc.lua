-- modules
local http = require 'socket.http'
local url  = require 'socket.url'
local json = require 'json'

return function(msg, from)
    if not msg:match("%w") then
        return from .. ": This command requires an argument"
    else
        local result = http.request("http://www.google.com/ig/calculator?q=" .. url.escape(msg))
        local result = json.decode(result)
        local err    = result.error

        if err == "" then
            return from .. ": " .. result.lhs .. " is " .. result.rhs
        else
            return from .. ": An error occured"
        end
    end
end
