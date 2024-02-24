local methods = require("null-ls.methods")
local h = require("null-ls.helpers")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/ruff.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "ruff",
    meta = {
        url = "https://github.com/astral-sh/ruff/",
        description = "An extremely fast Python linter, written in Rust.",
    },
    method = FORMATTING,
    filetypes = { "python" },
    generator_opts = {
        command = "ruff",
        args = { "--fix", "-e", "-n", "--stdin-filename", "$FILENAME", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
