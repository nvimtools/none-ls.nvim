local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local u = require("null-ls.utils")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

local severities = {
    CRITICAL = h.diagnostics.severities["error"],
    HIGH = h.diagnostics.severities["error"],
    MEDIUM = h.diagnostics.severities["warning"],
    LOW = h.diagnostics.severities["information"],
    UNKNOWN = h.diagnostics.severities["information"],
}

return h.make_builtin({
    name = "trivy",
    meta = {
        url = "https://github.com/aquasecurity/trivy",
        description = "Find misconfigurations and vulnerabilities",
    },
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "terraform", "tf", "terraform-vars" },
    generator_opts = {
        command = "trivy",
        timeout = 30000, -- Trivy can be slow, so increase timeout
        args = h.cache.by_bufnr(function(params)
            local trivy_args = {
                "config",
                "--format",
                "json",
                "--quiet",
                "$DIRNAME",
            }

            local config_file_path = vim.fs.find("trivy.yaml", {
                path = params.bufname,
                upward = true,
                stop = vim.fs.dirname(os.getenv("HOME")),
            })[1]
            if config_file_path then
                trivy_args = vim.list_extend(trivy_args, { "--config", config_file_path })
            end

            local ignore_file_path = vim.fs.find(".trivyignore", {
                path = params.bufname,
                upward = true,
                stop = vim.fs.dirname(os.getenv("HOME")),
            })[1]
            if ignore_file_path then
                trivy_args = vim.list_extend(trivy_args, { "--ignorefile", ignore_file_path })
            end

            return trivy_args
        end),
        cwd = h.cache.by_bufnr(function(params)
            return vim.fs.dirname(params.bufname)
        end),
        from_stderr = false, -- Trivy outputs logs to stderr that even --quiet doesn't silence
        ignore_stderr = true,
        to_stdin = false,
        multiple_files = true,
        format = "json",
        check_exit_code = function(_code, _stderr)
            -- Trivy exits with 0 by default
            return false
        end,
        on_output = function(params)
            local combined_diagnostics = {}

            -- keep diagnostics from other directories
            -- see discussion here: https://github.com/jose-elias-alvarez/null-ls.nvim/pull/1302
            if params.source_id ~= nil then
                local namespace = require("null-ls.diagnostics").get_namespace(params.source_id)
                local old_diagnostics = vim.diagnostic.get(nil, { namespace = namespace })
                for _, old_diagnostic in ipairs(old_diagnostics) do
                    if not vim.startswith(old_diagnostic.filename, params.cwd) then
                        table.insert(combined_diagnostics, old_diagnostic)
                    end
                end
            end

            for _, result in pairs(params.output.Results or {}) do
                for _, misconfiguration in ipairs(result.Misconfigurations or {}) do
                    local rewritten_diagnostic = {
                        message = misconfiguration.ID .. " - " .. misconfiguration.Title,
                        row = misconfiguration.CauseMetadata.StartLine,
                        col = 0,
                        source = "trivy",
                        severity = severities[misconfiguration.Severity],
                        filename = u.path.join(params.cwd, result.Target),
                    }
                    table.insert(combined_diagnostics, rewritten_diagnostic)
                end
            end
            return combined_diagnostics
        end,
    },
    factory = h.generator_factory,
})
