local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/dtsfmt.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

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
