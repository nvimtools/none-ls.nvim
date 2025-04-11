local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local log = require("null-ls.logger")
local u = require("null-ls.utils")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

return h.make_builtin({
    name = "golangci_lint",
    meta = {
        url = "https://golangci-lint.run/",
        description = "A Go linter aggregator.",
    },
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "go" },
    generator_opts = {
        command = "golangci-lint",
        to_stdin = true,
        from_stderr = false,
        ignore_stderr = true,
        multiple_files = true,
        cwd = h.cache.by_bufnr(function(params)
            -- find the nearest config and use that directory since v2 defaults to
            -- "relative-path-mode: cfg" which reports file names relative to
            -- the directory of the config file
            local cfg_path_yml = u.root_pattern(".golangci.yml")(params.bufname)
            if cfg_path_yml then
                return cfg_path_yml
            end
            local cfg_path_yaml = u.root_pattern(".golangci.yaml")(params.bufname)
            if cfg_path_yaml then
                return cfg_path_yaml
            end
            local cfg_path_toml = u.root_pattern(".golangci.toml")(params.bufname)
            if cfg_path_toml then
                return cfg_path_toml
            end
            local cfg_path_json = u.root_pattern(".golangci.json")(params.bufname)
            if cfg_path_json then
                return cfg_path_json
            end
            -- nil defaults to git root
            return nil
        end),
        args = h.cache.by_bufnr(function(params)
            -- params.command respects prefer_local and only_local options
            local version = vim.system({ params.command, "version" }, { text = true }):wait().stdout
            -- from observation the version can be either v2.x.x or 2.x.x
            -- depending on packaging
            if version and (version:match("version v2") or version:match("version 2")) then
                return { "run", "--fix=false", "--show-stats=false", "--output.json.path=stdout", "$DIRNAME" }
            end
            -- DIRNAME is the absolute path to the directory of the file being
            -- linted
            return { "run", "--fix=false", "--out-format=json", "$DIRNAME" }
        end),
        format = "json",
        check_exit_code = function(code)
            return code <= 2
        end,
        on_output = function(params)
            local diags = {}
            if params.output["Report"] and params.output["Report"]["Error"] then
                log:warn(params.output["Report"]["Error"])
                return diags
            end
            local issues = params.output["Issues"]
            if type(issues) == "table" then
                for _, d in ipairs(issues) do
                    table.insert(diags, {
                        source = string.format("golangci-lint: %s", d.FromLinter),
                        row = d.Pos.Line,
                        col = d.Pos.Column,
                        message = d.Text,
                        severity = h.diagnostics.severities["warning"],
                        filename = u.path.join(params.cwd, d.Pos.Filename),
                    })
                end
            end
            return diags
        end,
    },
    factory = h.generator_factory,
})
