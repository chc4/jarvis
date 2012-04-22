-- modules requirements
local irc     = require 'irc'
local NETWORK = 'irc.freenode.net'
local CHANNEL = {'##mustardsgrounds'}
local PRELUDE = '!'
local NICK    = 'saboteur'
local IGNORED = {'Frypanman'}
ADMINS	      = {'KnightMustard', 'camoy'}

-- load passive matching
local passive = loadfile('passive.lua')()

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local function executeCommand(who, from, msg)
    local log = io.open(who ..".txt", "a")
    log:write(os.date() .." [".. from .."]: " .. msg .."\n")
    log:close()

    local command, arg = msg:match('^%' .. PRELUDE .. '(%w+)%s*(.*)')

    -- command exists
    if command and IGNORED[from] == nil then
	print(from)
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
    elseif command == 'ignore' and ADMINS[from] then
	for c, v in ipairs(arg) do
	    IGNORED[v] = true
	    irc.say(chan, v .." has been successfully ignored.")
	end
    elseif command == 'unignore' and ADMINS[from] then
	    for c, v in ipairs(arg) do
		IGNORED[v] = nil
		irc.say(chan, v .." has been successfully unignored.")
	    end

    elseif command == 'part' and ADMINS[from] then
	irc.part(who)

    elseif command == 'join' and ADMINS[from] then
	irc.join(msg)

    elseif command == 'quit' and ADMINS[from] then
	irc.quit()

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

irc.register_callback("join", function(chan, user)
    local log = io.open(chan ..".txt", "a")
    log:write(os.date() .. " ".. user .." has joined the channel \n")
    log:close()
end)

irc.register_callback("part", function(chan, user)
local log = io.open(chan ..".txt", "a")
    log:write(os.date() .." ".. user .." has lefted the channel \n")
    log:close()
end)

irc.connect {
    network = NETWORK,
    nick = NICK
}
