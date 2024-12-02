local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "sqruff",
    meta = {
        url = "https://github.com/quarylabs/sqruff",
        description = "A high-speed SQL linter written in Rust.",
    },
    method = FORMATTING,
    filetypes = { "sql" },
    generator_opts = {
        command = "sqruff",
        args = {
            "fix",
            "-",
        },
        from_stdin = true,
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
