local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local DIAGNOSTICS = methods.internal.DIAGNOSTICS

local errors_to_diagnostic = function(error)
    local diagnostic = nil
    -- initial diagnostic
    diagnostic = {
        message = error.msg,
        ruleId = error.rule,
        level = error.severity,
        line = error.line,
    }
    -- some errors have a range
    if error.range then
        -- set endColumn to 0 if start and ending line is the same
        if error.range.start.line ~= error.range["end"].line then
            diagnostic = vim.tbl_extend("force", diagnostic, {
                line = error.range.start.line,
                endLine = error.range["end"].line,
                column = error.range.start.character,
                endColumn = 0,
            })
        else
            diagnostic = vim.tbl_extend("force", diagnostic, {
                line = error.range.start.line,
                endLine = error.range["end"].line,
                column = error.range.start.character,
                endColumn = error.range["end"].character,
            })
        end
    end
    return diagnostic
end

local handle_npm_groovy_lint_output = function(params)
    if params.output and params.output.files then
        local file_key = vim.tbl_keys(params.output.files)[1]
        local file = params.output.files[file_key]
        if file and file.errors then
            local parser = h.diagnostics.from_json({
                severities = {
                    info = h.diagnostics.severities.information,
                    error = h.diagnostics.severities.error,
                    warning = h.diagnostics.severities.warning,
                },
            })
            local errors = {}
            -- create table with null_ls compatible tables from json output
            for _, error in ipairs(file.errors) do
                table.insert(errors, errors_to_diagnostic(error))
            end
            return parser({ output = errors })
        end
    end
    return {}
end

return h.make_builtin({
    name = "npm-groovy-lint",
    meta = {
        url = "https://github.com/nvuillam/npm-groovy-lint",
        description = "Lint, format and auto-fix Groovy, Jenkinsfile, and Gradle files.",
    },
    method = DIAGNOSTICS,
    filetypes = { "groovy", "java", "Jenkinsfile" },
    generator_opts = {
        command = "npm-groovy-lint",
        args = function(params)
            local args = {
                "--failon",
                "none",
                "-o",
                "json",
                "$FILENAME",
            }
            if params.bufname:find("Jenkinsfile") then
                -- https://github.com/nvuillam/npm-groovy-lint/issues/422#issuecomment-2324321544
                table.insert(args, #args, "--no-parse")
            end
            return args
        end,
        to_stdin = false,
        to_temp_file = true,
        from_stderr = false,
        ignore_stderr = true,
        format = "json_raw",
        check_exit_code = function(code)
            return code <= 1
        end,
        on_output = handle_npm_groovy_lint_output,
    },
    factory = h.generator_factory,
})
