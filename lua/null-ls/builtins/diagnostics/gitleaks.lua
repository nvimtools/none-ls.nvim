local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

local handle_gitleaks_output = function(params)
    local parser = h.diagnostics.from_json({
        attributes = {
            code = "code",
        },
        diagnostic = {
            source = "gitleaks",
        },
    })

    local offenses = {}
    for _, finding in ipairs(params.output or {}) do
        table.insert(offenses, {
            message = finding.Description,
            ruleId = finding.RuleID,
            code = finding.RuleID,
            line = finding.StartLine,
            column = finding.StartColumn,
            endLine = finding.EndLine,
            endColumn = finding.EndColumn,
        })
    end

    return parser({ output = offenses })
end

return h.make_builtin({
    name = "gitleaks",
    meta = {
        url = "https://github.com/gitleaks/gitleaks",
        description = "Gitleaks is a SAST tool for detecting and preventing hardcoded secrets like passwords, API keys, and tokens in git repos.",
    },
    method = DIAGNOSTICS,
    filetypes = {},
    generator_opts = {
        command = "gitleaks",
        args = {
            "stdin",
            "--report-format",
            "json",
            "--report-path",
            "-",
            "--exit-code",
            "0",
            "--no-banner",
        },
        format = "json",
        to_stdin = true,
        from_stderr = true,
        ignore_stderr = true,
        check_exit_code = function(code)
            return code == 0
        end,
        on_output = handle_gitleaks_output,
    },
    factory = h.generator_factory,
})
