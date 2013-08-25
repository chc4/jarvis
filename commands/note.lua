local json = require 'json'
local hooks = require "hooks"
local FS = require "file_slurp"
require "table_util"

local function clearNote(who)
    local data = loadfile("data/note.lua")()
    data[who:lower()] = nil
    FS.writefile("data/note.lua", "return " .. table.tostring(data))
end

local function getNotes(who)
    local data = loadfile("data/note.lua")()
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

local function addNote(to, from, note)
    if from and to and note then
        local data = loadfile("data/note.lua")()
        local note = {from = from, note = note, time = os.date()}

        if data[to:lower()] then
            table.insert(data[to:lower()], note)
        else
            data[to:lower()] = {note}
        end

        FS.writefile("data/note.lua", "return " .. table.tostring(data))

        return true
    end
end

hooks.channel_msg(function(chan, from, msg)
    notifyNotes(from, chan.name)
end)

hooks.private_msg(function(from, msg)
    notifyNotes(from, from)
end)

hooks.join(function(chan, user)
    notifyNotes(user, chan.name)
end)

return function(msg, from)
    local to, note = msg:match "(%w+) ", msg:match "%w+ (.+)"
    local succ     = addNote(to, from, note)

    if succ then
        return(from .. ": Note added!")
    else
        return(from .. ": Failed to add note.")
    end
end
