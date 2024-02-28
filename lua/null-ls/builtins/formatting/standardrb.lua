local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/standardrb.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "standardrb",
    meta = {
        url = "https://github.com/testdouble/standard",
        description = "Ruby Style Guide, with linter & automatic code fixer. Based on Rubocop.",
    },
    method = FORMATTING,
    filetypes = { "ruby" },
    generator_opts = {
        command = "standardrb",
        args = {
            "--fix",
            "--format",
            "quiet",
            "--stderr",
            "--stdin",
            "$FILENAME",
        },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
