local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/xmlformat.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "xmlformat",
    meta = {
        url = "https://github.com/pamoller/xmlformatter",
        description = "xmlformatter is an Open Source Python package, which provides formatting of XML documents.",
    },
    method = FORMATTING,
    filetypes = { "xml" },
    generator_opts = {
        command = "xmlformat",
        args = { "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
