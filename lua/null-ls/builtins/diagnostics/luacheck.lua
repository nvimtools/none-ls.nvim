local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

vim.notify_once(
    [[[null-ls] You required a deprecated builtin (diagnostics/luacheck.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
    vim.log.levels.WARN
)

return h.make_builtin({
    name = "luacheck",
    meta = {
        url = "https://github.com/lunarmodules/luacheck",
        description = "A tool for linting and static analysis of Lua code.",
    },
    method = DIAGNOSTICS,
    filetypes = { "lua" },
    generator_opts = {
        command = "luacheck",
        to_stdin = true,
        from_stderr = true,
        args = {
            "--formatter",
            "plain",
            "--codes",
            "--ranges",
            "--filename",
            "$FILENAME",
            "-",
        },
        format = "line",
        on_output = h.diagnostics.from_pattern(
            [[:(%d+):(%d+)-(%d+): %((%a)(%d+)%) (.*)]],
            { "row", "col", "end_col", "severity", "code", "message" },
            {
                severities = {
                    E = h.diagnostics.severities["error"],
                    W = h.diagnostics.severities["warning"],
                },
                offsets = { end_col = 1 },
            }
        ),
    },
    factory = h.generator_factory,
})
