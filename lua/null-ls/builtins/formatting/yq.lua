local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/yq.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "yq",
    meta = {
        url = "https://github.com/mikefarah/yq",
        description = "yq is a portable command-line YAML, JSON, XML, CSV and properties processor.",
    },
    method = FORMATTING,
    filetypes = { "yml", "yaml" },
    generator_opts = {
        command = "yq",
        args = { ".", "$FILENAME" },
        to_stdin = true,
        to_temp_file = false,
    },
    factory = h.formatter_factory,
})
