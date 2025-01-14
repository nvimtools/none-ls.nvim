local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local COMPLETION = methods.internal.COMPLETION

-- based on pattern from cmp-luasnip
local regex = vim.regex([===[\%(\%([^[:alnum:][:blank:]]\+\|\w\+\)\)\m$]===])

local function nvim_snippet_exists()
    local status, _ = pcall(require, "snippets")

    return status
end

local function get_loaded_snippets(filetype)
    return require("snippets").load_snippets_for_ft(filetype)
end

return h.make_builtin({
    name = "nvim_snippets",
    can_run = nvim_snippet_exists,
    condition = nvim_snippet_exists,
    --- @param params NullLsParams
    runtime_condition = h.cache.by_bufnr(function(params)
        return not vim.tbl_isempty(get_loaded_snippets(params.filetype))
    end),
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
            local start_col = regex:match_str(line_to_cursor)

            if nil == start_col then
                done({ { items = {}, isIncomplete = true } })
                return
            end

            local prefix = vim.trim(line_to_cursor:sub(start_col))
            local items = {}
            local snippets = get_loaded_snippets(params.filetype)

            for _, item in pairs(snippets) do
                if vim.startswith(item.prefix, prefix) then
                    local insertText = (type(item.body) == "table") and table.concat(item.body, "\n") or item.body
                    local textEdit = {
                        range = {
                            start = { line = params.row - 1, character = start_col },
                            ["end"] = { line = params.row - 1, character = params.col - start_col },
                        },
                        newText = insertText,
                    }

                    items[#items + 1] = {
                        label = item.prefix,
                        kind = vim.lsp.protocol.CompletionItemKind.Snippet,
                        insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
                        detail = item.description,
                        insertText = insertText,
                        textEdit = textEdit,
                    }
                end
            end
            done({ { items = items, isIncomplete = #items == 0 } })
        end,
        async = true,
    },
})
