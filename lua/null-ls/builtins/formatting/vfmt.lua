local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/vfmt.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "vfmt",
    meta = {
        url = "https://github.com/vlang/v",
        description = "Reformat Vlang source into canonical form.",
    },
    method = FORMATTING,
    filetypes = { "vlang" },
    generator_opts = {
        command = "v",
        args = { "fmt", "-w", "$FILENAME" },
        to_temp_file = true,
    },
    factory = h.formatter_factory,
})
