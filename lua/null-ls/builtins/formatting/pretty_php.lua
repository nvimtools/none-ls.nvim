local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "prettyphp",
    meta = {
        url = "https://github.com/lkrms/pretty-php",
        description = "The opinionated PHP code formatter.",
    },
    method = FORMATTING,
    filetypes = { "php" },
    generator_opts = {
        command = "pretty-php",
        args = { "$FILENAME" },
        stdin = false,
    },
    factory = h.formatter_factory,
})
