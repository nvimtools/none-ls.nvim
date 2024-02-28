local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/xmllint.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "xmllint",
    meta = {
        url = "http://xmlsoft.org/xmllint.html",
        description = "Despite the name, xmllint can be used to format XML files as well as lint them, and that's the mode this builtin is using.",
    },
    method = FORMATTING,
    filetypes = { "xml" },
    generator_opts = {
        command = "xmllint",
        args = { "--format", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
