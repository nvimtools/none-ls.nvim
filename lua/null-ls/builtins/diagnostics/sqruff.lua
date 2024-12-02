local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

return helpers.make_builtin({
    name = "sqruff",
    meta = {
        url = "https://github.com/quarylabs/sqruff",
        description = "A high-speed SQL linter written in Rust.",
    },
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { "sql" },
    factory = helpers.generator_factory,
    generator_opts = {
        command = "sqruff",
        args = {
            "lint",
            "--format",
            "github-annotation-native",
            "$FILENAME",
        },
        from_stderr = true,
        to_stdin = false,
        to_temp_file = true,
        format = "line",
        check_exit_code = function(c)
            return c <= 1
        end,
        on_output = helpers.diagnostics.from_pattern(
            [[^::(%w+) .*,file=(.*),line=(%d+),col=(%d+)::(%w+: .*)]],
            { "severity", "filename", "row", "col", "message" },
            {
                severities = {
                    ["error"] = helpers.diagnostics.severities.error,
                },
            }
        ),
    },
})
