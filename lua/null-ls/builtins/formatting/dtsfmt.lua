local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "dtsfmt",
    meta = {
        url = "https://github.com/dts-lang/rustfmt",
        description = "Auto formatter for device tree source files",
        notes = { "Requires that `dtsfmt` is executable and on $PATH." },
    },
    method = FORMATTING,
    filetypes = { "dts" },
    generator_opts = {
        command = "dtsfmt",
        args = { "--emit=stdout" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
