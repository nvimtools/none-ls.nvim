local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/perltidy.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "perltidy",
    meta = {
        url = "http://perltidy.sourceforge.net/",
        description = "perl script which indents and reformats perl scripts to make them easier to read. If you write perl scripts, or spend much time reading them, you will probably find it useful.",
    },
    method = FORMATTING,
    filetypes = { "perl" },
    generator_opts = {
        command = "perltidy",
        args = { "-q" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
