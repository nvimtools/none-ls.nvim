local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

return helpers.make_builtin({
    name = "kube_linter",
    meta = {
        url = "https://github.com/stackrox/kube-linter",
        description =
        "KubeLinter is a static analysis tool that checks Kubernetes YAML files and Helm charts to ensure the applications represented in them adhere to best practices.",
    },
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { "helm", "yaml" },
    factory = helpers.generator_factory,
    generator_opts = {
        command = "kube-linter",
        args = {
            "lint",
            "--format",
            "json",
            "$ROOT",
        },
        from_stderr = false,
        ignore_stderr = true,
        multiple_files = true,
        format = "json",
        check_exit_code = function(c)
            return c <= 1
        end,
        on_output = function(params)
            local diags = {}
            for _, diag in ipairs(params.output.Reports) do
                table.insert(diags, {
                    source = "kube-linter",
                    code = diag.Check,
                    message = diag.Diagnostic.Message .. "\n" .. diag.Remediation,
                    severity = helpers.diagnostics.severities["error"],
                    filename = diag.Object.Metadata.FilePath,
                })
            end
            return diags
        end,
    },
})
