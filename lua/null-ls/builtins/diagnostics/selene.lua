local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local u = require("null-ls.utils")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
    name = "selene",
    meta = {
        url = "https://kampfkarren.github.io/selene/",
        description = "Command line tool designed to help write correct and idiomatic Lua code.",
    },
    method = DIAGNOSTICS,
    filetypes = { "lua", "luau" },
    generator_opts = {
        command = "selene",
        args = { "--display-style", "json2", "-" },
        to_stdin = true,
        format = "raw",
        check_exit_code = function(code)
            return code <= 3
        end,
        on_output = function(params, done)
            local output = vim.split(params.output, "\n")
            local all_diagnostics = {}
            for _, v in ipairs(output) do
                local _, decoded = pcall(vim.json.decode, v)
                if decoded == vim.NIL or decoded == "" then
                    decoded = nil
                end
                if decoded and decoded.primary_label and decoded.primary_label.span then
                    decoded.line = decoded.primary_label.span.start_line
                    decoded.column = decoded.primary_label.span.start_column
                    decoded.endLine = decoded.primary_label.span.end_line
                    decoded.endColumn = decoded.primary_label.span.end_column
                    decoded.message = decoded.message .. "\n" .. table.concat(decoded.notes, ", ")
                    decoded.primary_label = nil
                end
                if decoded.type == "Diagnostic" then
                    table.insert(all_diagnostics, decoded)
                end
            end
            local parser = h.diagnostics.from_json({
                severities = {
                    Warning = h.diagnostics.severities["warning"],
                    Error = h.diagnostics.severities["error"],
                },
                attributes = {
                    code = "code",
                    severity = "severity",
                },
                offsets = {
                    col = 1,
                    end_col = 1,
                    row = 1,
                    end_row = 1,
                },
            })
            return done(parser({ output = all_diagnostics }))
        end,
        cwd = h.cache.by_bufnr(function(params)
            -- https://kampfkarren.github.io/selene/usage/configuration.html
            return u.root_pattern("selene.toml")(params.bufname)
        end),
    },
    factory = h.generator_factory,
})
