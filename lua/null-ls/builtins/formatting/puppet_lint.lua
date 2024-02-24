local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (formatting/puppet_lint.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "puppet-lint",
    meta = {
        url = "http://puppet-lint.com/",
        description = "Check that your Puppet manifest conforms to the style guide",
    },
    method = FORMATTING,
    filetypes = { "puppet", "epuppet" },
    generator_opts = {
        command = "puppet-lint",
        args = {
            "--fix",
            "$FILENAME",
        },
        to_temp_file = true,
    },
    factory = h.formatter_factory,
})
