local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "terragrunt_fmt",
    meta = {
        url = "https://terragrunt.gruntwork.io/docs/reference/cli-options/#hclfmt",
        description = "The terragrunt hclfmt command rewrites `terragrunt` configuration files to a canonical format and style.",
    },
    method = FORMATTING,
    to_temp_file = true,
    from_temp_file = true,
    filetypes = { "hcl" },
    generator_opts = {
        command = "terragrunt",
        args = {
            "hclfmt",
            "$FILENAME",
        },
    },
    factory = h.formatter_factory,
})
