local h = require("null-ls.helpers")
local cmd_resolver = require("null-ls.helpers.command_resolver")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (diagnostics/semistandardjs.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "semistandardjs",
    meta = {
        url = "https://github.com/standard/semistandard",
        description = "JavaScript style guide, linter, and formatter.",
    },
    method = DIAGNOSTICS,
    filetypes = { "javascript", "javascriptreact" },
    generator_opts = {
        command = "semistandard",
        args = { "--stdin" },
        to_stdin = true,
        ignore_stderr = true,
        format = "line",
        check_exit_code = function(c)
            return c <= 1
        end,
        on_output = h.diagnostics.from_patterns({
            {
                pattern = ":(%d+):(%d+): Parsing error: (.*)",
                groups = { "row", "col", "message" },
                overrides = {
                    diagnostic = {
                        severity = h.diagnostics.severities.error,
                    },
                },
            },
            {
                pattern = ":(%d+):(%d+): (.*)",
                groups = { "row", "col", "message" },
                overrides = {
                    diagnostic = {
                        severity = h.diagnostics.severities.warning,
                    },
                },
            },
        }),
        dynamic_command = cmd_resolver.from_node_modules(),
    },
    factory = h.generator_factory,
})
