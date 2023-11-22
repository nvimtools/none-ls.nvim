local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local log = require("null-ls.logger")
local severities = h.diagnostics.severities

local handle_regal_output = function(params)
    local diags = {}
    if params.output.violations ~= nil then
        for _, d in ipairs(params.output.violations) do
            if d.location ~= nil then
                local l = d.location
                local end_col = (l.text ~= nil) and (l.text:len() + 1) or 0
                table.insert(diags, {
                    row = l.row,
                    col = l.col,
                    end_col = end_col,
                    source = "regal",
                    message = d.description,
                    severity = severities[d.level] or severities.error,
                    filename = l.file,
                    code = d.title,
                    user_data = { category = d.category },
                })
            end
        end
    elseif params.err ~= nil then
        log:error(params.output)
    end

    return diags
end

return h.make_builtin({
    name = "regal",
    meta = {
        url = "https://docs.styra.com/regal",
        description = "Regal is a linter for Rego, with the goal of making your Rego magnificent!.",
    },
    method = methods.internal.DIAGNOSTICS_ON_SAVE,
    filetypes = { "rego" },
    generator_opts = {
        command = "regal",
        args = {
            "lint",
            "-f",
            "json",
            "$ROOT",
        },
        format = "json_raw",
        check_exit_code = function(code)
            return code <= 1
        end,
        to_stdin = false,
        from_stderr = true,
        multiple_files = true,
        on_output = handle_regal_output,
    },
    factory = h.generator_factory,
})
