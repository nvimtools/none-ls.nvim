local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/taplo.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "taplo",
    meta = {
        url = "https://taplo.tamasfe.dev/",
        description = "A versatile, feature-rich TOML toolkit.",
    },
    method = FORMATTING,
    filetypes = { "toml" },
    generator_opts = {
        command = "taplo",
        args = { "format", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
