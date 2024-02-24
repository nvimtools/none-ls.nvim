local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/brittany.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "brittany",
    meta = {
        url = "https://github.com/lspitzner/brittany",
        description = "haskell source code formatter",
    },
    method = FORMATTING,
    filetypes = { "haskell" },
    generator_opts = {
        command = "brittany",
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
