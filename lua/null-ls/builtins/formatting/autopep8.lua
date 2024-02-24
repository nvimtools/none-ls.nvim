local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING
local RANGE_FORMATTING = methods.internal.RANGE_FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/autopep8.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "autopep8",
    meta = {
        url = "https://github.com/hhatto/autopep8",
        description = "A tool that automatically formats Python code to conform to the PEP 8 style guide.",
    },
    method = { FORMATTING, RANGE_FORMATTING },
    filetypes = { "python" },
    generator_opts = {
        command = "autopep8",
        args = h.range_formatting_args_factory({
            "-",
        }, "--line-range", nil, { use_rows = true }),
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
