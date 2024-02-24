local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/latexindent.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "latexindent",
    meta = {
        url = "https://github.com/cmhughes/latexindent.pl",
        description = "A perl script for formatting LaTeX files that is generally included in major TeX distributions.",
    },
    method = FORMATTING,
    filetypes = { "tex" },
    generator_opts = { command = "latexindent", args = { "-" }, to_stdin = true },
    factory = h.formatter_factory,
})
