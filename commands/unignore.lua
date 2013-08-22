return function(msg, from)
    local json             = require 'json'

    local file = io.open('data/ignore.json')
    local data = json.decode(file:read())
    file:close()
    file = io.open('data/ignore.json', 'w')

    data[msg:lower()]  = nil
    file:write(json.encode(data))
    file:close()
    return(from .. ": " .. msg .. " has been unignored.")
end
