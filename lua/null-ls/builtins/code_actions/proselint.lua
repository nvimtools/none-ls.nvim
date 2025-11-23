local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local CODE_ACTION = methods.internal.CODE_ACTION

return h.make_builtin({
    name = "proselint",
    meta = {
        url = "https://github.com/amperser/proselint",
        description = "An English prose linter. Can fix some issues via code actions.",
    },
    method = CODE_ACTION,
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
            local actions = {}

            local output = params.output
            if not output or output.error then
                return actions
            end

            local result = output.result
            if not result then
                return actions
            end

            local buf = params.bufnr
            local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")

            for _, file_output in pairs(result) do
                if file_output.diagnostics then
                    for _, d in ipairs(file_output.diagnostics) do
                        if d.replacements and d.replacements ~= vim.NIL then
                            -- byte offsets (1-based)
                            local byte_start = d.span[1]
                            local byte_end = d.span[2]

                            -- turn into 0-based Lua string indices
                            local sub = text:sub(byte_start, byte_end)

                            -- find the (line, col) from byte indices
                            local before = text:sub(1, byte_start - 1)
                            local line = select(2, before:gsub("\n", "")) + 1
                            local col = #before:match("[^\n]*$") + 1

                            -- end col
                            local length = #sub
                            local end_col = col + length - 1

                            table.insert(actions, {
                                title = d.message,
                                action = function()
                                    vim.api.nvim_buf_set_text(
                                        buf,
                                        line - 1,
                                        col - 1,
                                        line - 1,
                                        end_col,
                                        { d.replacements }
                                    )
                                end,
                            })
                        end
                    end
                end
            end

            return actions
        end,
    },
    factory = h.generator_factory,
})
