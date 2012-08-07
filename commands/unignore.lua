local msg, from, level = ...
local json             = require 'json'

local function setIgnore(user, val)
    local file = io.open('data/ignore.json')
    local data = json.decode(file:read())
    file:close()
    file = io.open('data/ignore.json', 'w')

    data[user:lower()]  = val
    file:write(json.encode(data))
    file:close()
end

if tonumber(level) == 1 then
    setIgnore(msg, nil)
    return(from .. ": " .. msg .. " has been unignored.")
else
    return(from .. ": Insufficient permissions")
end
