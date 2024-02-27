local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/beautysh.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "beautysh",
    meta = {
        url = "https://github.com/lovesegfault/beautysh",
        description = "A Bash beautifier for the masses.",
        notes = { "In addition to Bash, Beautysh can format csh, ksh, sh and zsh." },
    },
    method = FORMATTING,
    filetypes = { "bash", "csh", "ksh", "sh", "zsh" },
    generator_opts = { command = "beautysh", args = { "$FILENAME" }, to_temp_file = true },
    factory = h.formatter_factory,
})
