local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "typstfmt",
    meta = {
        url = "https://github.com/astrale-sharp/typstfmt",
        description = "Formatter for typst",
    },
    method = FORMATTING,
    filetypes = { "typ", "typst" },
    generator_opts = {
        command = "typstfmt",
        args = { "-o", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
