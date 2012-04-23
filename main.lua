-- modules requirements
local irc     = require 'irc'
local lfs     = require 'lfs'
local json    = require 'json'
local NETWORK = 'irc.freenode.net'
local LOG     = true
local PRELUDE = '!'
local NICK    = 'saboteur'
local CHANNEL = {'##codelab'}
local ADMINS  = {KnightMustard = 1, camoy = 1, bluh = 1}

-- load passive matching
local passive = loadfile('passive.lua')()

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local function isIgnored(who)
    local file   = io.open 'data/ignore.json'
    local status = json.decode(file:read())[who]
    file:close()

    return status
end

local function log(what, chan)
    local date  = os.date '*t'
    date        = date.year .. '_' .. date.month .. '_' .. date.day
    local filen = string.format('log/%s/%s', chan.name, date)
    local file  = io.open(filen, "a")

    if not file then
        file = io.open(filen, "w")
    end

    if file then
        file:write(what)
        file:close()
    end
end

local function executeCommand(who, from, msg)
    local command, arg = msg:match('^%' .. PRELUDE .. '(%w+)%s*(.*)')

    -- command exists
    if command and not isIgnored(from) then
        local fcommand = io.open('commands/' .. command)
        if arg then arg = arg:split ' ' end

        -- real command
        if fcommand then
            -- escape " token
            for i,v in ipairs(arg) do
                arg[i] = '"' .. v:gsub('"', '\\"'):gsub('!', '\!') .. '"'
            end

            -- get result
            local result = io.popen(string.format('commands/%s %q %q ', command, from, ADMINS[from] or 3) .. table.concat(arg, ' '))

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
        -- logs
        local path = 'log/' .. r

        if not lfs.chdir(path) then
            lfs.mkdir(path)
        else
            lfs.chdir '../..'
        end

        -- join
	irc.join(r)
    end
end)

irc.register_callback("channel_msg", function(chan, from, msg)
    log(os.date() .." [".. from .."]: " .. msg .."\n", chan)
    executeCommand(chan.name, from, msg)
end)

irc.register_callback("private_msg", function(from, msg)
    executeCommand(from, from, msg)
end)

irc.register_callback("join", function(chan, user)
    log(os.date() .. " ".. user .." has joined the channel \n", chan)
end)

irc.register_callback("part", function(chan, user)
    log(os.date() .." ".. user .." has left the channel \n", chan)
end)

irc.connect {
    network = NETWORK,
    nick = NICK
}
