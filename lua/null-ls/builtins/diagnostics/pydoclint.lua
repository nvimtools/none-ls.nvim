local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
    name = "pydoclint",
    meta = {
        url = "https://github.com/jsh9/pydoclint",
        description = "Pydoclint is a Python docstring linter to check whether a docstring's sections (arguments, returns, raises, ...) match the function signature or function implementation. To see all violation codes go to [pydoclint](https://jsh9.github.io/pydoclint/violation_codes.html)",
    },
    method = DIAGNOSTICS,
    filetypes = { "python" },
    generator_opts = {
        command = "pydoclint",
        args = {
            "--show-filenames-in-every-violation-message=true",
            "-q",
            "$FILENAME",
        },
        to_temp_file = true,
        from_stderr = true,
        format = "line",
        check_exit_code = function(code)
            return code <= 2
        end,
        multiple_files = false,
        on_output = function(line, params)
            local path = params.temp_path
            -- rel/path/to/file.py:42: DOC000: Diagnostic message
            local pattern = path .. [[:(%d+): (DOC%d+: .*)]]
            return h.diagnostics.from_pattern(pattern, { "row", "message" })(line, params)
        end,
    },
    factory = h.generator_factory,
})
