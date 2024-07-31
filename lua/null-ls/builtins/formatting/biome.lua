local h = require("null-ls.helpers")
local cmd_resolver = require("null-ls.helpers.command_resolver")
local methods = require("null-ls.methods")
local u = require("null-ls.utils")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "biome",
    meta = {
        url = "https://biomejs.dev",
        description = "Formatter, linter, bundler, and more for JavaScript, TypeScript, JSON, HTML, Markdown, and CSS.",
        notes = {
            "Currently support only JavaScript, TypeScript and JSON. See status [here](https://biomejs.dev/internals/language-support/)",
        },
    },
    method = FORMATTING,
    filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "jsonc" },
    generator_opts = {
        command = "biome",
        args = {
            "format",
            "--stdin-file-path",
            "$FILENAME",
        },
        dynamic_command = cmd_resolver.from_node_modules(),
        cwd = h.cache.by_bufnr(function(params)
            return u.root_pattern("rome.json", "biome.json", "biome.jsonc")(params.bufname)
        end),
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
