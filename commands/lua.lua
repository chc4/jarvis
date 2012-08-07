local msg, from, level = ...
local LIMIT            = 10000
local BLACKLIST        = {'getfenv', 'setfenv', 'io', 'newproxy', 'os', 'debug', 'load', 'loadfile', 'dofile', 'require', 'package', 'loadstring', 'lpeg', 'socket', 'lfs', 'irc', 'module', 'collectgarbage', 'gcinfo', 'jit', 'bit', 'json', 'arg'}

local function callSandbox(str)
    local result = {}
    local suc
    local err

    local function errorHandler()
        error('application caught hanging', 0)
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

    -- don't use __gc to escape
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

    -- no compliation errors
    if chunk then
        local thread = coroutine.create(setfenv(chunk, env))

        -- prevent hanging
        debug.sethook(thread, errorHandler, '', LIMIT)

        -- call chunk
        suc, err = coroutine.resume(thread)
    else
        suc, err = false, err
    end

    result = #result > 0 and result or {"No output."}

    return not suc and {err} or result
end

return not suc and from .. ": " .. table.concat(callSandbox(msg), "\t")
