local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/stylish_haskell.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "stylish_haskell",
    meta = {
        url = "https://github.com/haskell/stylish-haskell",
        description = [[Format Haskell code]],
    },
    method = FORMATTING,
    filetypes = { "haskell" },
    generator_opts = {
        command = "stylish-haskell",
        args = {},
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
