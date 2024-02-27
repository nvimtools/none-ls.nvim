local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (diagnostics/jsonlint.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "jsonlint",
    meta = {
        url = "https://github.com/zaach/jsonlint",
        description = "A pure JavaScript version of the service provided at jsonlint.com.",
    },
    method = DIAGNOSTICS,
    filetypes = { "json" },
    generator_opts = {
        command = "jsonlint",
        args = { "--compact" },
        to_stdin = true,
        from_stderr = true,
        format = "line",
        check_exit_code = function(c)
            return c <= 1
        end,
        on_output = h.diagnostics.from_pattern("line (%d+), col (%d+), (.*)", { "row", "col", "message" }, {}),
    },
    factory = h.generator_factory,
})
