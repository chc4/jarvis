local hook_list = {
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
    channel_msg = factory "channel_msg",
    private_msg = factory "private_msg",
    join = factory "join",
    part = factory "part",
    call = function(hook_name, ...)
        for _,cb in ipairs(hook_list[hook_name]) do
            cb(...)
        end
    end
}
