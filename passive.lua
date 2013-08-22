local function wordPattern(word)
    return "%f[%w][" .. word:sub(1, 1) .. word:sub(1, 1):upper() .."]" .. word:sub(2) .. "s?%f[%W]"
end

return {
    [wordPattern "buffer"] = function()
        return "You mean pony."
    end,

    [wordPattern "rawr"] = function()
        return "I think that means 'I love you' in dinosaur..."
    end
}
