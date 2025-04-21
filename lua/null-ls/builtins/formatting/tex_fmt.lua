local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "tex-fmt",
    meta = {
        url = "https://github.com/WGUNDERWOOD/tex-fmt",
        description = "An extremely fast LaTeX formatter written in Rust",
    },
    method = FORMATTING,
    filetypes = { "tex" },
    generator_opts = {
        command = "tex-fmt",
        args = { "-s" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
