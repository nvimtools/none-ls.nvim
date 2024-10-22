local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local COMPLETION = methods.internal.COMPLETION

-- based on pattern from cmp-luasnip
local pattern = "\\%([^[:alnum:][:blank:]]\\+\\|\\w\\+\\)"
local regex = vim.regex([[\%(]] .. pattern .. [[\)\m$]])

return h.make_builtin({
    name = "nvim_snippets",
    can_run = function()
        local status, _ = pcall(require, "snippets")

        return status
    end,
    meta = {
        url = "https://github.com/garymjr/nvim-snippets",
        description = "Snippets managed by nvim-snippets.",
    },
    method = COMPLETION,
    filetypes = {},
    generator = {
        --- @param params NullLsParams
        --- @param done fun()
        fn = function(params, done)
            local line_to_cursor = params.content[params.row]:sub(1, params.col)
            local items = {}
            local snips = require("snippets").get_loaded_snippets()
            local targets = vim.tbl_filter(function(item)
                local start_col = regex:match_str(line_to_cursor)
                return (nil ~= start_col) and vim.startswith(item.prefix, line_to_cursor:sub(start_col + 1))
            end, snips)
            for _, item in ipairs(targets) do
                items[#items + 1] = {
                    label = item.prefix,
                    kind = vim.lsp.protocol.CompletionItemKind.Snippet,
                    insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
                    detail = item.description,
                    insertText = (type(item.body) == "table") and table.concat(item.body, "\n") or item.body,
                }
            end
            done({ { items = items, isIncomplete = #items == 0 } })
        end,
        async = true,
    },
})
