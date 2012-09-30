local msg, from = ...
local to, note         = msg:match "(%w+) ", msg:match "%w+ (.+)"
local json             = require 'json'

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

local succ = addNote(to, from, note)

if succ then
    return(from .. ": Note added!")
else
    return(from .. ": Failed to add note.")
end
