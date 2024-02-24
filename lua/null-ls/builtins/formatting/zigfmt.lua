local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/zigfmt.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "zigfmt",
    meta = {
        url = "https://github.com/ziglang/zig",
        description = "Reformat Zig source into canonical form.",
    },
    method = FORMATTING,
    filetypes = { "zig" },
    generator_opts = {
        command = "zig",
        args = { "fmt", "--stdin" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
