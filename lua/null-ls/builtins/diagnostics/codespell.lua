local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

local function sanitize(str)
    local rep_tbl = {
        ["%"] = "%%",
        ["-"] = "%-",
        ["+"] = "%+",
        ["*"] = "%*",
        ["?"] = "%?",
        ["^"] = "%^",
        ["$"] = "%$",
        ["."] = "%.",
        ["("] = "%(",
        [")"] = "%)",
        ["["] = "%[",
        ["]"] = "%]",
    }

    for what, with in pairs(rep_tbl) do
        what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
        with = string.gsub(with, "[%%]", "%%%%") -- escape replacement
        str = string.gsub(str, what, with)
    end

    return str
end

return h.make_builtin({
    name = "codespell",
    meta = {
        url = "https://github.com/codespell-project/codespell",
        description = "Codespell finds common misspellings in text files.",
    },
    method = DIAGNOSTICS,
    filetypes = {},
    generator_opts = {
        command = "codespell",
        args = { "-" },
        to_stdin = true,
        from_stderr = true,
        on_output = function(params, done)
            local output = params.output
            if not output then
                return done()
            end

            local diagnostics = {}
            local content = params.content
            local pat_diag = "(%d+): - [^\n]+\n\t((%S+)[^\n]+)"
            for row, message, misspelled in output:gmatch(pat_diag) do
                row = tonumber(row)
                -- Note: We cannot always get the misspelled columns directly from codespell (version 2.1.0) outputs,
                -- where indents in the detected lines have been truncated.
                if misspelled ~= nil then
                    local line = content[row]
                    misspelled = sanitize(misspelled)
                    local col, end_col = line:find(misspelled)
                    if col == nil then
                        col = 0
                    end
                    if end_col == nil then
                        end_col = 0
                    end
                    table.insert(diagnostics, {
                        row = row,
                        col = col,
                        end_col = end_col + 1,
                        source = "codespell",
                        message = message,
                        severity = 2,
                    })
                end
            end
            return done(diagnostics)
        end,
    },
    factory = h.generator_factory,
})
