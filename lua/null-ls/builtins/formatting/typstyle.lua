local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "typstyle",
    meta = {
        url = "https://github.com/Enter-tainer/typstyle/",
        description = "Beautiful and reliable typst code formatter",
    },
    method = FORMATTING,
    filetypes = { "typ", "typst" },
    generator_opts = {
        command = "typstyle",
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
