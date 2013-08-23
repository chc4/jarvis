local hook_list = {
    exe_command = {},
    channel_msg = {},
    private_msg = {},
    join = {},
    part = {}
}

local function factory(hook)
    return function(callback)
        table.insert(hook_list[hook], callback)
    end
end

return {
    exe_command = factory "exe_command",
    channel_msg = factory "channel_msg",
    private_msg = factory "private_msg",
    join = factory "join",
    part = factory "part",
    call = function(hook_name, ...)
        local ret = true
        for _,cb in ipairs(hook_list[hook_name]) do
            -- TODO: pcall this cb since it could break
            ret = ret and cb(...)
        end
        return ret
    end
}
