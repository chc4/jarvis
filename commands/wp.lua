-- modules
local http = require "socket.http"
local json = require "json"

-- get data
local msg, from, level = ...
msg = msg:gsub(" ", "_")

if not msg:match("%w") then
    return("This command requires an argument")
else
    local result = http.request("http://en.wikipedia.org/w/api.php?action=query&prop=info&inprop=url&format=json&titles=" .. msg)
    local result = json.decode(result)
    local result = select(2, next(result.query.pages))

    -- format data
    return(from .. ": " .. result.title .. " -> " .. result.fullurl)
end
