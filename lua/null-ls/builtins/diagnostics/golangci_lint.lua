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
            -- there might be cases when it's needed to setup cwd manually:
            -- check the golangci-lint docs for relative-path-mode.
            -- usually projects contain settings in root so this is sane default.
            return u.root_pattern("go.mod")(params.bufname)
        end),
        args = h.cache.by_bufnr(function(params)
            -- params.command respects prefer_local and only_local options
            local version = vim.system({ params.command, "version" }, { text = true }):wait().stdout
            -- from observation the version can be either v2.x.x or 2.x.x
            -- depending on packaging
            if version and (version:match("version v2.0.") or version:match("version 2.0.")) then
                -- for v2.0.{0,1,2} Go submodules (with golangci-lint config at
                -- the project root) require "relative-path-mode: gomod" or cwd
                -- set to where the golangci-lint config file is and $DIRNAME
                -- in extra_args
                return { "run", "--fix=false", "--show-stats=false", "--output.json.path=stdout" }
            elseif version and (version:match("version v2") or version:match("version 2")) then
                return { "run", "--fix=false", "--show-stats=false", "--output.json.path=stdout", "--path-mode=abs" }
            end
            return { "run", "--fix=false", "--out-format=json" }
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
                    -- prepend cwd to filename to get absolute path unless
                    -- already absolute
                    local filename = d.Pos.Filename
                    if filename:sub(1, #params.cwd) ~= params.cwd then
                        filename = u.path.join(params.cwd, d.Pos.Filename)
                    end
                    table.insert(diags, {
                        source = string.format("golangci-lint: %s", d.FromLinter),
                        row = d.Pos.Line,
                        col = d.Pos.Column,
                        message = d.Text,
                        severity = h.diagnostics.severities["warning"],
                        filename = filename,
                    })
                end
            end
            return diags
        end,
    },
    factory = h.generator_factory,
})
