local h = require("null-ls.helpers")
local u = require("null-ls.utils")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING
local RANGE_FORMATTING = methods.internal.RANGE_FORMATTING

return h.make_builtin({
    name = "black",
    meta = {
        url = "https://github.com/psf/black",
        description = "The uncompromising Python code formatter",
    },
    method = { FORMATTING, RANGE_FORMATTING },
    filetypes = { "python" },
    generator_opts = {
        command = "black",
        args = function(params)
            if params.method == FORMATTING then
                return {
                    "--stdin-filename",
                    "$FILENAME",
                    "--quiet",
                    "-",
                }
            end

            local row, end_row = params.range.row, params.range.end_row
            return {
                "--line-ranges=" .. row .. "-" .. end_row,
                "--stdin-filename",
                "$FILENAME",
                "--quiet",
                "-",
            }
        end,
        to_stdin = true,
        cwd = h.cache.by_bufnr(function(params)
            return u.root_pattern(
                -- https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html#configuration-via-a-file
                "pyproject.toml"
            )(params.bufname)
        end),
    },
    factory = h.formatter_factory,
})
