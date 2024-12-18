local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "treefmt",
    meta = {
        url = "https://github.com/numtide/treefmt-nix",
        description = "Fast and convenient multi-file formatting with Nix",
    },
    method = FORMATTING,
    filetypes = {},
    generator_opts = {
        command = "treefmt-nix",
        args = { "--allow-missing-formatter", "--stdin", "$FILENAME" },
        to_stdin = true,
        -- treefmt-nix wrapper needs to be available
    },
    condition = function(utils)
        return utils.is_executable("treefmt-nix")
    end,
    factory = h.formatter_factory,
})
