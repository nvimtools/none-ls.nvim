local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "mdsf",
    meta = {
        url = "https://github.com/hougesen/mdsf",
        description = "Format markdown code blocks using your favorite code formatters.",
    },
    method = FORMATTING,
    filetypes = { "markdown" },
    generator_opts = {
        command = "mdsf",
        args = { "format", "$FILENAME" },
        to_temp_file = true,
    },
    factory = h.formatter_factory,
})
