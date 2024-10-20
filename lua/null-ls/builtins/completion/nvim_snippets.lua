local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local COMPLETION = methods.internal.COMPLETION

return h.make_builtin({
    name = "nvim_snippets",
    meta = {
        url = "https://github.com/garymjr/nvim-snippets",
        description = "Snippets managed by nvim-snippets.",
    },
    method = COMPLETION,
    filetypes = {},
    generator = {
        fn = function(params, done)
            local items = {}
            local snips = require("snippets").get_loaded_snippets()
            local targets = vim.tbl_filter(function(item)
                return string.match(item.prefix, "^" .. params.word_to_complete)
            end, snips)
            for _, item in ipairs(targets) do
                table.insert(items, {
                    label = item.prefix,
                    kind = vim.lsp.protocol.CompletionItemKind.Snippet,
                    insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
                    detail = item.description,
                    insertText = (type(item.body) == "table") and table.concat(item.body, "\n") or item.body,
                })
            end
            done({ { items = items, isIncomplete = #items == 0 } })
        end,
        async = true,
    },
})
