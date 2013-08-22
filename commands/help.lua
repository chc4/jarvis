return function(msg, from)
    local json      = require 'json'
    local data      = loadfile('data/help.lua')()
    local desc      = data[msg]

    if desc then
        return(from .. ": " .. msg .. " -> " .. desc)
    elseif msg == "" then
        local commands = {}
        for k,_ in pairs(data) do table.insert(commands, k) end

        return(from .. ": Commands -> " .. table.concat(commands, ", "))
    else
        return(from .. ": That command doesn't have a help entry")
    end
end
