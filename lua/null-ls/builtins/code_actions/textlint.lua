local h = require("null-ls.helpers")
local cmd_resolver = require("null-ls.helpers.command_resolver")
local methods = require("null-ls.methods")
local u = require("null-ls.utils")

local CODE_ACTION = methods.internal.CODE_ACTION

local handle_output = function(params)
    params.messages = params.output and params.output[1] and params.output[1].messages or {}
    if params.err then
        return {}
    end

    local actions = {}
    for _, d in ipairs(params.messages) do
        if d.fix ~= nil and params.row == d.line then
            table.insert(actions, {
                title = vim.split(d.message, "\n")[1],
                action = function()
                    -- adapt for multibyte strings
                    local row = d.line - 1
                    local line = vim.api.nvim_buf_get_lines(params.bufnr, row, row + 1, false)[1]
                    local length = d.fix.range[2] - d.fix.range[1]
                    local col_beg = vim.fn.byteidx(line, d.loc.start.column - 1)
                    local col_end = vim.fn.byteidx(line, d.loc.start.column + length - 1)

                    vim.api.nvim_buf_set_text(params.bufnr, row, col_beg, row, col_end, { d.fix.text })
                end,
            })
        end
    end
    return actions
end

return h.make_builtin({
    name = "textlint",
    meta = {
        url = "https://github.com/textlint/textlint",
        description = "Linter for text and Markdown. Can fix some issues via code actions.",
    },
    method = CODE_ACTION,
    filetypes = { "text", "markdown" },
    generator_opts = {
        command = "textlint",
        to_stdin = true,
        args = { "-f", "json", "--stdin", "--stdin-filename", "$FILENAME" },
        format = "json_raw",
        check_exit_code = { 0, 1 },
        on_output = handle_output,
        dynamic_command = cmd_resolver.from_node_modules(),
        cwd = h.cache.by_bufnr(function(params)
            return u.root_pattern(
                -- https://textlint.github.io/docs/configuring.html
                ".textlintrc",
                ".textlintrc.js",
                ".textlintrc.json",
                ".textlintrc.yml",
                ".textlintrc.yaml",
                "package.json"
            )(params.bufname)
        end),
    },
    factory = h.generator_factory,
})
