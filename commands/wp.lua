-- modules
local http = require "socket.http"
local json = require "json"


-- get data
return function(msg, from)
    msg = msg:gsub(" ", "_")

    if not msg:match("%w") then
        return("This command requires an argument")
    else
        local result = http.request("http://en.wikipedia.org/w/api.php?action=query&prop=info&inprop=url&format=json&titles=" .. msg)
        local result = json.decode(result)
        if (result and result.query and result.query.pages) then
            local result = select(2, next(result.query.pages))
            if not (result and result.title and result.fullurl) then
                return("Error with wikipedia request")
            end
            -- format data
            return(from .. ": " .. result.title .. " -> " .. result.fullurl)
        else
            return("Error with wikipedia request.");
        end
    end
end
