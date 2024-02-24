local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/fourmolu.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "fourmolu",
    meta = {
        url = "https://hackage.haskell.org/package/fourmolu",
        description = "Fourmolu is a formatter for Haskell source code.",
    },
    method = FORMATTING,
    filetypes = { "haskell" },
    generator_opts = {
        command = "fourmolu",
        args = { "--stdin-input-file", "$FILENAME" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
