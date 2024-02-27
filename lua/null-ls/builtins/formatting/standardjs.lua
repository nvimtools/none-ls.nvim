local h = require("null-ls.helpers")
local cmd_resolver = require("null-ls.helpers.command_resolver")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/standardjs.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "standardjs",
    meta = {
        url = "https://standardjs.com/",
        description = "JavaScript Standard Style, a no-configuration automatic code formatter that just works.",
    },
    method = FORMATTING,
    filetypes = { "javascript", "javascriptreact" },
    generator_opts = {
        command = "standard",
        args = { "--stdin", "--fix" },
        to_stdin = true,
        dynamic_command = cmd_resolver.from_node_modules(),
    },
    factory = h.formatter_factory,
})
