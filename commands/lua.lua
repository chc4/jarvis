local msg, from, level = ...
local LIMIT            = 8000
local BLACKLIST        = {'error', 'loadstring','xpcall', 'coroutine' ,'getfenv', 'setfenv', 'io', 'newproxy', 'os', 'debug', 'load', 'loadfile', 'dofile', 'require', 'package', 'lpeg', 'socket', 'lfs', 'irc', 'module', 'collectgarbage', 'gcinfo', 'jit', 'bit', 'json', 'arg', 'ltn12', 'mime'}
local Reasons = {"Errors entire program",
 "Calls enviorment without debug hook",
 "Calls errorhandler without debug hook",
 "Doesn't catch hanging" , 
 "Stealing function enviorments", 
 "Stealing function enviorments", 
 "Obvious reasons", 
 "Allows for escapment of sandbox",
 "Obvious reasons", 
 "Allows for clearing of debug hooks", 
 "Obvious reasons", 
 "Obvious reasons", 
 "Obvious reaons", 
 "Obvious reasons", 
 "Doesn't load debug hook"};
local function callSandbox(str)
    local result = {}
    local suc
    local err
    local count = 0;

    local function errorHandler(s)
		if s=="call" then 
		count=count+1
		if count>400 then
		error("Too many function calls!",0) --Catches recurserive functions
		end
		else
        error('Application caught hanging!', 0) --Catches hanging
		end
    end

    local function copyTable(tab)
        local new = {}

        for k,v in pairs(tab) do
            new[k] = v
        end

        return new
    end

    -- load chunk
    local chunk, err = loadstring(str)

    -- construct sandbox
    local env = copyTable(_G)

    -- blacklist evil functions
    for i,v in ipairs(BLACKLIST) do
        env[v] = nil
    end

    -- wrap tables into userdata
    for k,v in pairs(env) do
        if type(v) == 'table' then
            local wrapper = newproxy(true)
            getmetatable(wrapper).__index = copyTable(v)
            env[k] = wrapper
        end
    end

    -- special cases
    env._G = env

    -- prevent altering string type metatable
    env.getmetatable = function(tab)
        if type(tab) ~= 'table' then
            error 'cannot alter metatable'
        else
            return getmetatable(tab)
        end
    end

    -- don't use __gc to escape sandbox
    env.setmetatable = function(tab, mt)
        mt.__gc = nil

        return setmetatable(tab, mt)
    end

    env.print = function(...)
        for i,v in ipairs({...}) do
            if type(v) == "table" then
                table.insert(result, "[table address]")
            else
                table.insert(result, tostring(v))
            end
        end
    end
	
	env.error = function(...)
		error("Error has been called",0); --So it doesn't error entire bot
	end
	
	env.loadstring = function(...)
		local flag = false
		local arg={...}
		pcall(function()
			if arg[1]:sub(1,1)==string.char(27) then --Disallows bytecode
				flag=true
			end
		end)
		if flag then
			error("No bytecode!",0)
		end
		local l=loadstring(...);
		setfenv(l,env) --Loads loadstring in the correct enviorment
		return l
	end

    -- no compliation errors
    if chunk then
        local thread = coroutine.create(setfenv(chunk, env))

        -- prevent hanging
        debug.sethook(thread, errorHandler, 'c', LIMIT) --Catches function calls

        -- call chunk
        suc, err = coroutine.resume(thread)
    else
        suc, err = false, err
    end

    result = #result > 0 and result or {"No output."}

    return not suc and {err} or result
end

return not suc and from .. ": " .. table.concat(callSandbox(msg), "\t")
