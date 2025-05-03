local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "tex_fmt",
    meta = {
        url = "https://github.com/WGUNDERWOOD/tex-fmt",
        description = "tex-fmt is a LaTeX code formatter.",
    },
    method = FORMATTING,
    filetypes = { "tex" },
    generator_opts = {
        command = "tex-fmt",
        args = { "--stdin" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
