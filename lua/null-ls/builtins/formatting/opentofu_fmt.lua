local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "opentofu_fmt",
    meta = {
        url = "https://opentofu.org/docs/cli/commands/fmt/#usage",
        description = "The opentofu-fmt command rewrites `opentofu` configuration files to a canonical format and style.",
    },
    method = FORMATTING,
    filetypes = { "terraform", "tf", "terraform-vars" },
    generator_opts = {
        command = "tofu",
        args = {
            "fmt",
            "-",
        },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
