local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/fixjson.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "fixjson",
    meta = {
        url = "https://github.com/rhysd/fixjson",
        description = "A JSON file fixer/formatter for humans using (relaxed) JSON5.",
    },
    method = FORMATTING,
    filetypes = { "json" },
    generator_opts = {
        command = "fixjson",
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
