local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "dxfmt",
    meta = {
        url = "https://github.com/dioxuslabs/dioxus",
        description = "Format rust file with dioxus cli",
    },
    method = FORMATTING,
    filetypes = { "rust" },
    generator_opts = {
        command = "dx",
        args = {
            "fmt",
            "--file",
            "$FILENAME",
        },
        to_stdin = false,
        to_temp_file = true,
        from_temp_file = true,
    },
    factory = h.formatter_factory,
})
