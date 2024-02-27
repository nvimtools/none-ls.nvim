local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/xq.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "xq",
    meta = {
        url = "https://github.com/sibprogrammer/xq",
        description = "Command-line XML and HTML beautifier and content extractor",
    },
    method = FORMATTING,
    filetypes = { "xml" },
    generator_opts = {
        command = "xq",
        args = { ".", "$FILENAME" },
        to_stdin = true,
        to_temp_file = false,
    },
    factory = h.formatter_factory,
})
