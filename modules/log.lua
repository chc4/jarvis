local hooks = require "hooks"

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

local config = loadfile(CONFIG)()
for _,v in pairs(config.channel or {}) do
    local path = "log/" .. v

    if not lfs.chdir(path) then
        lfs.mkdir(path)
    else
        lfs.chdir "../.."
    end
end

hooks.channel_msg(function(chan, from ,msg)
    log(os.date() .." [".. from .."]: " .. msg .."\n", chan)
end)

hooks.join(function(chan, user)
    log(os.date() .. " ".. user .." has joined the channel \n", chan)
end)

hooks.part(function(chan, user)
    log(os.date() .." ".. user .." has left the channel \n", chan)
end)
