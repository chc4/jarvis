local irc    = require "irc"
local lfs    = require "lfs"
local json   = require "json"
local CONFIG = "config.json"

local function loadConfigFile(name)
    if not name then return end

    local file = io.open(name)
    local data = json.decode(file:read("*all"))
    file:close()

    return data
end

local settings = loadConfigFile(CONFIG)

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
        if tv == v then return true end
    end
end

local function isIgnored(who)
    local file   = io.open "data/ignore.json"
    local status = json.decode(file:read())[who:lower()]
    file:close()

    return status
end

local function log(what, chan)
    local date  = os.date "*t"
    date        = date.year .. "_" .. date.month .. "_" .. date.day
    local filen = string.format("log/%s/%s", chan.name, date)
    local file  = io.open(filen, "a")

    if not file then
        file = io.open(filen, "w")
    end

    if file then
        file:write(what)
        file:close()
    end
end

local function clearNote(who)
    local file = io.open("data/note.json")
    local data = json.decode(file:read())
    file:close()
    file = io.open("data/note.json", "w")

    data[who:lower()] = nil

    file:write(json.encode(data))
    file:close()
end

local function getNotes(who)
    local file = io.open("data/note.json")
    local data = json.decode(file:read())
    file:close()

    return data[who:lower()]
end

local function notifyNotes(who, where)
    local notes = getNotes(who)

    if notes then
        for _,v in ipairs(notes) do
            irc.say(where, v.from .. " at " .. v.time .. " left " .. who .. " a note: " .. v.note)
        end

        clearNote(who)
    end
end

local addMessageCount;
do
    local file = io.open("data/count.json", "r");
    countData = json.decode(file:read("*a"));
    file:close();
    local countSaveInterval = countData.interval;
    function addMessageCount()
        local count = countData.count;
        count = count + 1;
        countData.count = count;

        if count % countSaveInterval == 0 then
        	local file = io.open("data/count.json", "w");
        	file:write(json.encode(countData));
        	file:close();
        end
    end
end

local function executeCommand(who, from, msg)
    local command, arg = msg:match("^%" .. settings.prelude .. "(%w+)%s*(.*)")
    -- command exists
    if command and not isIgnored(from) then
        local fcommand = loadfile("commands/" .. command .. ".lua")

        -- real command
        if fcommand then
            -- get result
            local isAdmin = table.contains(settings.admins, from)
            local result = fcommand(arg, from, isAdmin and 1 or 0)

            -- say result
            irc.say(who, result)
        else
            irc.say(who, settings.no_command)
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
    notifyNotes(from, chan.name)
    log(os.date() .." [".. from .."]: " .. msg .."\n", chan)
    executeCommand(chan.name, from, msg)
    addMessageCount();
end)

irc.register_callback("private_msg", function(from, msg)
    notifyNotes(from, from)
    executeCommand(from, from, msg)
end)

irc.register_callback("join", function(chan, user)
    notifyNotes(user, chan.name)
    log(os.date() .. " ".. user .." has joined the channel \n", chan)
end)

irc.register_callback("part", function(chan, user)
    log(os.date() .." ".. user .." has left the channel \n", chan)
end)

irc.connect {
    network = settings.network,
    nick = settings.nick
}
