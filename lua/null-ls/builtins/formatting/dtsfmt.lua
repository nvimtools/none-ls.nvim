local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/dtsfmt.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "dtsfmt",
    meta = {
        url = "https://github.com/dts-lang/rustfmt",
        description = "Auto formatter for device tree source files",
        notes = { "Requires that `dtsfmt` is executable and on $PATH." },
    },
    method = FORMATTING,
    filetypes = { "dts" },
    generator_opts = {
        command = "dtsfmt",
        args = { "--stdin", "$FILENAME" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
