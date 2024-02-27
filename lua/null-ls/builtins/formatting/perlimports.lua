local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (formatting/perlimports.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "perlimports",
    meta = {
        url = "https://metacpan.org/dist/App-perlimports/view/script/perlimports",
        description = "A command line utility for cleaning up imports in your Perl code",
    },
    method = FORMATTING,
    filetypes = { "perl" },
    generator_opts = {
        command = "perlimports",
        to_stdin = true,
        args = { "--read-stdin", "--filename", "$FILENAME" },
        timeout = 5000, -- this can take a long time
    },
    factory = h.formatter_factory,
})
