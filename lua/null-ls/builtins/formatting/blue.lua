local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/blue.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "blue",
    meta = {
        url = "https://github.com/grantjenks/blue",
        description = "Blue -- Some folks like black but I prefer blue.",
    },
    method = FORMATTING,
    filetypes = { "python" },
    generator_opts = {
        command = "blue",
        args = {
            "--stdin-filename",
            "$FILENAME",
            "--quiet",
            "-",
        },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
