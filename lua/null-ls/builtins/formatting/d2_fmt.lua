local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "d2 fmt",
    meta = {
        url = "https://github.com/terrastruct/d2",
        description = "d2 fmt is a tool built into the d2 compiler for formatting d2 diagram source",
    },
    method = FORMATTING,
    filetypes = { "d2" },
    generator_opts = {
        command = "d2",
        args = { "fmt", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
