local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local cmd_resolver = require("null-ls.helpers.command_resolver")

local FORMATTING = methods.internal.FORMATTING

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/dprint.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "dprint",
    meta = {
        url = "https://dprint.dev/",
        description = "A pluggable and configurable code formatting platform written in Rust.",
        notes = {
            [[you need to install dprint to use this builtin and then run `dprint init` to initialize it in your project directory.]],
        },
    },
    method = FORMATTING,
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "markdown",
        "python",
        "toml",
        "rust",
        "roslyn",
    },
    generator_opts = {
        command = "dprint",
        args = {
            "fmt",
            "--stdin",
            "$FILENAME",
        },
        to_stdin = true,
        dynamic_command = cmd_resolver.from_node_modules(),
    },
    factory = h.formatter_factory,
})
