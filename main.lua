-- modules requirements
local irc     = require 'irc'
local NETWORK = 'irc.freenode.org'
local CHANNEL = {'##codelab'}
local PRELUDE = '!'
local NICK    = 'cambot'

-- load passive matching
local passive = loadfile('passive.lua')()

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local function executeCommand(who, from, msg)
    local command, arg = msg:match('^%' .. PRELUDE .. '(%w+)%s*(.*)')

    -- command exists
    if command then
        local fcommand = io.open('commands/' .. command)
        if arg then arg = arg:split ' ' end

        -- real command
        if fcommand then
            -- escape " token
            for i,v in ipairs(arg) do
                arg[i] = '"' .. v:gsub('"', '\\"'):gsub('!', '\!') .. '"'
            end

            -- get result
            local result = io.popen('commands/' .. command .. ' "' .. from .. '" ' .. table.concat(arg, ' '))

            -- say result
            irc.say(who, result:read())
            
            -- close files
            fcommand:close()
            result:close()
        end
    -- check for passive matches
    else
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
    for q,r in ipairs(CHANNEL) do
	irc.join(r)
    end
end)

irc.register_callback("channel_msg", function(chan, from, msg)
    executeCommand(chan.name, from, msg)
end)

irc.register_callback("private_msg", function(from, msg)
    executeCommand(from, from, msg)
end)

irc.connect {
    network = NETWORK,
    nick = NICK
}
