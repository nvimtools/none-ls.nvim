local h = require("null-ls.helpers")
local u = require("null-ls.utils")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "duster",
    meta = {
        url = "https://github.com/tighten/duster",
        description = "Automatic configuration for Laravel apps to apply Tighten's standard linting & code standards.",
    },
    method = FORMATTING,
    filetypes = { "php" },
    generator_opts = {
        command = vim.fn.executable("./vendor/bin/duster") == 1 and "./vendor/bin/duster" or "duster",
        args = {
            "fix",
            "$FILENAME",
            "--no-interaction",
            "--quiet",
        },
        cwd = h.cache.by_bufnr(function(params)
            return u.root_pattern("duster.json", "composer.json", "composer.lock")(params.bufname)
        end),
        to_stdin = true,
        to_temp_file = true,
    },
    factory = h.formatter_factory,
})
