local irc    = require "irc"
local lfs    = require "lfs"
local json   = require "json"
local hooks  = require "hooks"
local CONFIG = "config.lua"
local command_cache = {}

local function loadConfigFile(name)
    if not name then
        return {}
    end
    return loadfile(name)()
end

local settings = loadConfigFile(CONFIG)

local function source()
    for file in lfs.dir("commands/") do
        local command_name = file:match("(%w+)%.lua")
        local get_chunk = loadfile("commands/" .. file)
        if get_chunk then
            local chunk = get_chunk()
            if chunk then
                command_cache[command_name] = chunk
            end
        end
    end
    return "Sourced!"
end

command_cache.source = source
source()

if settings.debug == true then
    irc.debug.enable()
end

-- load passive matching
local passive = loadfile("passive.lua")()

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function table.contains(t, v)
    for _, tv in ipairs(t) do
        if tv == v then
            return true
        end
    end
end

local function isIgnored(who)
    local data   = loadfile("data/ignore.lua")()
    local status = data[who:lower()]
    return status
end

local function executeCommand(who, from, msg)
    local command, arg = msg:match("^%" .. settings.prelude .. "(%w+)%s*(.*)")
    -- command exists
    if command and not isIgnored(from) then
        local fcommand = command_cache[command]

        -- real command
        if fcommand then
            -- get result
            if table.contains(settings.adminCommands, command) and table.contains(settings.admins, from) == nil then
                irc.say(who, from .. ": " .. settings.need_permission)
            else
                local succ, err = pcall(function()
                    irc.say(who, fcommand(arg, from, who))
                end)

                if not succ then
                    irc.say(who, "This command errored with " .. err)
                end
            end
        else
            irc.say(who, settings.no_command)
        end
        -- check for passive matches
    elseif settings.word_patterns then
        for pattern,v in pairs(passive) do
            local ret = msg:match(pattern)
            if ret then
                irc.say(who, v(who, msg))
                break
            end
        end
    end
end

-- connect callback
irc.register_callback("connect", function()
    -- join CHANNEL
    for q,r in ipairs(settings.channel) do
        -- logs
        local path = "log/" .. r

        if not lfs.chdir(path) then
            lfs.mkdir(path)
        else
            lfs.chdir "../.."
        end

        -- join
        irc.join(r)
    end
end)

irc.register_callback("channel_msg", function(chan, from, msg)
    hooks.call("channel_msg", chan, from ,msg)
    executeCommand(chan.name, from, msg)
end)

irc.register_callback("private_msg", function(from, msg)
    hooks.call("private_msg", from ,msg)
    executeCommand(from, from, msg)
end)

irc.register_callback("join", function(chan, user)
    hooks.call("join", chan, user)
end)

irc.register_callback("part", function(chan, user)
    hooks.call("part", chan, user)
end)

irc.connect {
    network = settings.network,
    nick = settings.nick,
    realname = "LuaIRC"
}
