local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "vfmt",
    meta = {
        url = "https://github.com/vlang/v",
        description = "Reformat Vlang source into canonical form.",
    },
    method = FORMATTING,
    filetypes = { "vlang" },
    generator_opts = {
        command = "v",
        args = { "fmt", "-w", "$FILENAME" },
        to_temp_file = true,
    },
    factory = h.formatter_factory,
})
