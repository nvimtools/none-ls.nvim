local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "treefmt",
    meta = {
        url = "https://github.com/numtide/treefmt",
        description = "One CLI to format your repo",
    },
    method = FORMATTING,
    filetypes = {},
    generator_opts = {
        command = "treefmt",
        args = { "--allow-missing-formatter", "--stdin", "$FILENAME" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
