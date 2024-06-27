local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "cbfmt",
    meta = {
        url = "https://github.com/lukas-reineke/cbfmt",
        description = "A tool to format codeblocks inside markdown and org documents.",
    },
    method = FORMATTING,
    filetypes = { "markdown", "org" },
    generator_opts = {
        command = "cbfmt",
        args = {
            "--stdin-filepath",
            "$FILENAME",
            "--best-effort",
        },
        to_stdin = true,
        -- cbfmt requires a config file
        condition = function(utils)
            return utils.root_has_file(".cbfmt.toml")
        end,
    },
    factory = h.formatter_factory,
})
