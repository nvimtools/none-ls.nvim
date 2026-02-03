local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
    name = "proselint",
    meta = {
        url = "https://github.com/amperser/proselint",
        description = "An English prose linter.",
    },
    method = DIAGNOSTICS,
    filetypes = { "markdown", "tex" },
    generator_opts = {
        command = "proselint",
        args = { "check", "--output-format=json" },
        format = "json",
        to_stdin = true,
        check_exit_code = function(c)
            return c <= 1
        end,
        on_output = function(params)
            local diags = {}
            local sev = {
                error = 1,
                warning = 2,
                suggestion = 4,
            }

            local output = params.output
            if not output then
                return diags
            end

            if output.error then
                return diags
            end

            local result = output.result
            if not result then
                return diags
            end

            for _, file_output in pairs(result) do
                if file_output.diagnostics then
                    for _, d in ipairs(file_output.diagnostics) do
                        local line = d.pos[1]
                        local col = d.pos[2]

                        -- span = {start_col, end_col}
                        local end_col = d.span[2]

                        table.insert(diags, {
                            row = line,
                            col = col,
                            end_col = end_col,
                            code = d.check_path,
                            message = d.message,
                            -- Proselint no longer includes a severity -> choose warning
                            severity = sev.warning,
                        })
                    end
                end
            end

            return diags
        end,
    },
    factory = h.generator_factory,
})
