local methods = require("null-ls.methods")
local h = require("null-ls.helpers")

local FORMATTING = methods.internal.FORMATTING

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/ruff_format.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "ruff",
    meta = {
        url = "https://github.com/astral-sh/ruff/",
        description = "An extremely fast Python formatter, written in Rust.",
    },
    method = FORMATTING,
    filetypes = { "python" },
    generator_opts = {
        command = "ruff",
        args = { "format", "-n", "--stdin-filename", "$FILENAME", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
