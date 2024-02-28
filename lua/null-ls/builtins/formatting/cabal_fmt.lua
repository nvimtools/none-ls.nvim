local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/cabal_fmt.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "cabal_fmt",
    meta = {
        url = "https://hackage.haskell.org/package/cabal-fmt",
        description = "Format .cabal files preserving the original field ordering, and comments.",
    },
    method = FORMATTING,
    filetypes = { "cabal" },
    generator_opts = {
        command = "cabal-fmt",
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
