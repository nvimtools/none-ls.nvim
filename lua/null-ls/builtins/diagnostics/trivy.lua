local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

local severities = {
    CRITICAL = h.diagnostics.severities["error"],
    HIGH = h.diagnostics.severities["error"],
    MEDIUM = h.diagnostics.severities["warning"],
    LOW = h.diagnostics.severities["information"],
    UNKNOWN = h.diagnostics.severities["information"],
}

-- NOTE: (vkhitrin) custom logic to derive the directory name for trivy execution:
-- * If buffer is inside a helm chart, attempt to set the directory to the directory
--   containing Chart.yaml.
-- * Otherwise, set the directory to none-ls' '$DIRNAME'.
local trivy_working_dir = function()
    local filetype = vim.bo.filetype
    if filetype == "helm" then
        local dir = vim.fn.expand("%:p:h")
        while dir ~= "/" do
            local chart_path = dir .. "/Chart.yaml"
            if vim.fn.filereadable(chart_path) == 1 then
                return dir
            end
            dir = vim.fn.fnamemodify(dir, ":h")
        end
        return dir
    else
        return "$DIRNAME"
    end
end

return h.make_builtin({
    name = "trivy",
    meta = {
        url = "https://github.com/aquasecurity/trivy",
        description = "Find misconfigurations and vulnerabilities",
    },
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "terraform", "tf", "terraform-vars", "helm", "dockerfile" },
    generator_opts = {
        command = "trivy",
        timeout = 30000, -- Trivy can be slow, so increase timeout
        args = h.cache.by_bufnr(function(params)
            local trivy_args = {
                "config",
                "--format",
                "json",
                "--quiet",
                trivy_working_dir(),
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
        from_stderr = true, -- https://github.com/aquasecurity/trivy/pull/2289
        ignore_stderr = false,
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
                        end_row = misconfiguration.CauseMetadata.EndLine,
                        col = 0,
                        source = "trivy",
                        severity = severities[misconfiguration.Severity],
                        filename = result.Target,
                    }
                    table.insert(combined_diagnostics, rewritten_diagnostic)
                end
            end
            return combined_diagnostics
        end,
    },
    factory = h.generator_factory,
})
