local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/pyflyby.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "pyflyby",
    meta = {
        url = "https://github.com/deshaw/pyflyby",
        description = "Pyflyby is a set of Python programming productivity tools, useful for auto-import libraries",
    },
    method = FORMATTING,
    filetypes = { "python" },
    generator_opts = {
        command = "tidy-imports",
        args = {
            "-n", -- do not reformat imports
        },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
