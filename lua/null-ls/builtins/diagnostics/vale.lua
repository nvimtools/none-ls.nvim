local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

local severities = { error = 1, warning = 2, suggestion = 4 }

return h.make_builtin({
    name = "vale",
    meta = {
        url = "https://vale.sh/",
        description = "Syntax-aware linter for prose built with speed and extensibility in mind.",
        notes = {
            [[vale doesn't include a syntax by itself, so you need to [create a `vale.ini`](https://vale.sh/generator)) and download [styles](https://vale.sh/docs/vale-cli/structure/#styles) with `vale sync`.]],
        },
    },
    method = DIAGNOSTICS,
    filetypes = { "markdown", "tex", "asciidoc" },
    generator_opts = {
        command = "vale",
        format = "json",
        to_stdin = true,
        cwd = function(params)
            return vim.fn.fnamemodify(params.bufname, ":h")
        end,
        args = function(params)
            return { "--no-exit", "--output", "JSON", "--ext", "." .. vim.fn.fnamemodify(params.bufname, ":e") }
        end,
        on_output = function(params)
            local output = params.output["stdin." .. vim.fn.fnamemodify(params.bufname, ":e")]
                or params.output[params.bufname]
                or {}

            local diagnostics = {}
            for _, diagnostic in ipairs(output) do
                table.insert(diagnostics, {
                    row = diagnostic.Line,
                    col = diagnostic.Span[1],
                    end_col = diagnostic.Span[2] + 1,
                    code = diagnostic.Check,
                    message = diagnostic.Message,
                    severity = severities[diagnostic.Severity],
                })
            end

            return diagnostics
        end,
    },
    factory = h.generator_factory,
})
