local msg, from, level = ...

local function callSandbox(str)
    local result = {}
    local suc, err, co

    local function copyTable(tab)
        local new = {}

        for k,v in pairs(tab) do
            new[k] = v
        end

        return new
    end

    local function errorHandler()
        error("application caught hanging", 0)
    end

    -- load chunk
    local chunk, err = loadstring(str)

    -- construct sandbox
    local env = copyTable(_G)
    local blacklist = {'getfenv', 'setfenv', 'io', 'newproxy', 'os', 'debug', 'load', 'loadfile', 'dofile', 'require', 'package', 'loadstring', 'lpeg', 'socket', 'lfs', 'irc', 'module', 'collectgarbage', 'gcinfo', 'jit', 'bit', 'json', 'arg'}

    -- blacklist evil functions
    for i,v in ipairs(blacklist) do
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

    env.getmetatable = function(tab)
        -- prevent altering string type metatable
        if tab ~= 'table' then
            error 'cannot alter metatable'
        else
            return getmetatable(tab)
        end
    end

    env.print = function(...)
        for i,v in ipairs({...}) do
            table.insert(result, tostring(v))
        end
    end

    -- no compliation errors
    if chunk then
        suc, err = pcall(function()
            local thread = coroutine.create(setfenv(chunk, env))

            -- prevent hanging
            debug.sethook(thread, errorHandler, '', 10000)

            -- call chunk
            suc, err = coroutine.resume(thread)
        end)
    else
        suc, err = false, err
    end

    return not suc and err or (#result ~= 0  and table.concat(result, "\t") or "No output.")
end

return not suc and from .. ": " .. callSandbox(msg:gsub('\\"', '"'))
