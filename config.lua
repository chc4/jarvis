return {
    log             = false,
    network         = "irc.freenode.net",
    prelude         = "!",
    debug           = false,
    word_patterns   = false,
    wolframalphaKey = "",

    nick    = "_jarvis",
    channel = { "##codelab" },
    admins  = {
        "KnightMustard",
        "tiffany",
        "camoy",
        "Socks",
        "chc4"
    },

    no_command      = "Lol, that's not a command silly head!",
    adminCommands   = { "ignore", "unignore", "lua", "join", "leave" },
    need_permission = "Insufficient permission."
}
