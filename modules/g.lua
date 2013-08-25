local http = require "socket.http"
local json = require "json"

-- get data
return function(msg, from)
    msg = msg:gsub(" ", "+")

    if not msg:match("%w") then
        return("This command requires an argument")
    else
        local blah,code,tab = http.request{url=("https://www.google.com/search?site=&source=hp&q=%s&oq=r&btnI=1"):format(msg),
                            redirect = false};
        if (blah and code~=403 and code~=404 and tab.location) then --bleh, i forget http codes
            return(from .. ": " ..tab.location)
        else
            return("Error with google request.");
        end
    end
end
