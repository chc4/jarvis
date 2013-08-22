local json = require 'json'
local hooks = require "hooks"

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

local function addNote(to, from, note)
    if from and to and note then
        local file = io.open('data/note.json')
        local data = json.decode(file:read())
        local note = {from = from, note = note, time = os.date()}
        file:close()
        file = io.open('data/note.json', 'w')

        if data[to:lower()] then
            table.insert(data[to:lower()], note)
        else
            data[to:lower()] = {note}
        end

        file:write(json.encode(data))
        file:close()

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
