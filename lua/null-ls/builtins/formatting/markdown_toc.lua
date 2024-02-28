local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/markdown_toc.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "markdown_toc",
    meta = {
        url = "https://github.com/jonschlinkert/markdown-toc",
        description = "API and CLI for generating a markdown TOC (table of contents) for a README or any markdown files.",
        notes = {
            "To generate a TOC, add `<!-- toc -->` before headers in your markdown file.",
        },
    },
    method = FORMATTING,
    filetypes = { "markdown" },
    generator_opts = {
        command = "markdown-toc",
        args = { "-i", "$FILENAME" },
        to_temp_file = true,
    },
    factory = h.formatter_factory,
})
