local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/autoflake.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "autoflake",
    meta = {
        url = "https://github.com/PyCQA/autoflake",
        description = "Removes unused imports and unused variables as reported by pyflakes",
    },
    method = { FORMATTING },
    filetypes = { "python" },
    generator_opts = {
        command = "autoflake",
        args = { "--stdin-display-name", "$FILENAME", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
