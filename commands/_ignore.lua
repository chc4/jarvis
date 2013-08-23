local hooks = require "hooks"
local CONFIG = "config.lua"

local function isIgnored(who)
    local data   = loadfile("data/ignore.lua")()
    local status = data[who:lower()]
    return status
end

hooks.exe_command(function(who, command, arg, from)
    return not isIgnored(from)
end)
