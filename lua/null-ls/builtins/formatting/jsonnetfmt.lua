local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/jsonnetfmt.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "jsonnetfmt",
    meta = {
        url = "https://github.com/google/jsonnet",
        description = "Formats jsonnet files.",
    },
    method = methods.internal.FORMATTING,
    filetypes = { "jsonnet" },
    generator_opts = {
        command = "jsonnetfmt",
        args = { "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
