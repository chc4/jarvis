local msg, from = ...
local file = io.open("data/count.json", "r")
local countData = json.decode(file:read("*a"))
file:close()
return ("%s: 0x%08x"):format(from, countData.count)
