local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

local diagnostics = h.diagnostics.from_pattern(
    "[^:]+:(%d+):  (.+)  %[(.+)%/(.+)%] %[%d+%]",
    { "row", "message", "severity", "label" },
    {
        severities = {
            build = h.diagnostics.severities["warning"],
            whitespace = h.diagnostics.severities["hint"],
            runtime = h.diagnostics.severities["warning"],
            legal = h.diagnostics.severities["information"],
            readability = h.diagnostics.severities["information"],
        },
    }
)

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (diagnostics/cpplint.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "cpplint",
    meta = {
        url = "https://github.com/cpplint/cpplint",
        description = "Cpplint is a command-line tool to check C/C++ files for style issues following Google's C++ style guide",
    },
    method = DIAGNOSTICS,
    filetypes = { "cpp", "c" },
    generator_opts = {
        command = "cpplint",
        args = {
            "$FILENAME",
        },
        format = "line",
        to_stdin = false,
        from_stderr = true,
        to_temp_file = true,
        on_output = function(line, params)
            local rez = diagnostics(line, params)

            if rez and rez.severity == 2 and (rez.label == "include_order" or rez.label == "header_guard") then
                return nil
            end

            return rez
        end,
        check_exit_code = function(code)
            return code >= 1
        end,
    },
    factory = h.generator_factory,
})
