local hooks = require "hooks"
local CONFIG = "config.lua"

-- TODO: DRY this up, it's in main too
local function loadConfigFile(name)
    if not name then
        return {}
    end
    return loadfile(name)()
end

local settings = loadConfigFile(CONFIG)

hooks.exe_command(function(who, command, arg, from)
    local isAdminCommand = table.contains(settings.adminCommands, command)
    local isAdmin = table.contains(settings.admins, from)
    if isAdminCommand and not isAdmin then
        irc.say(who, from .. ": " .. settings.need_permission)
        return false
    end
    return true
end)
