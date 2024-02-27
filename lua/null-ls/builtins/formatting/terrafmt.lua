local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/terrafmt.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "terrafmt",
    meta = {
        url = "https://github.com/katbyte/terrafmt",
        description = "The terrafmt command formats `terraform` blocks embedded in Markdown files.",
    },
    method = FORMATTING,
    filetypes = { "markdown" },
    generator_opts = {
        command = "terrafmt",
        args = {
            "fmt",
            "$FILENAME",
        },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
