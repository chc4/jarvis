local FS = require "file_slurp"

return function(msg, from)
    local data = loadfile("data/ignore.lua")()
    data[msg:lower()]  = nil
    FS.writefile("data/ignore.lua", "return " .. table.tostring(data))
    return(from .. ": " .. msg .. " has been unignored.")
end
