local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/templ.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "templ",
    meta = {
        url = "https://templ.guide/commands-and-tools/cli/#formatting-templ-files",
        description = "Formats templ template files.",
    },
    method = FORMATTING,
    filetypes = { "templ" },
    generator_opts = {
        command = "templ",
        args = { "fmt" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
