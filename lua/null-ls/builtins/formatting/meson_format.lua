local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "meson_format",
    meta = {
        url = "https://mesonbuild.com/Commands.html#format",
        description = "Meson's builtin formatter",
    },
    method = FORMATTING,
    filetypes = { "meson" },
    generator_opts = {
        command = "meson",
        args = { "format", "--", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
