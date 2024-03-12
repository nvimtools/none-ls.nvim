local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local u = require("null-ls.utils")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "gleam_format",
    meta = {
        url = "https://github.com/gleam-lang/gleam/",
        description = [[Default formater for the Gleam programming language]],
    },
    method = { FORMATTING },
    filetypes = { "gleam" },
    generator_opts = {
        command = "gleam",
        args = { "format", "--stdin" },
        to_stdin = true,
        cwd = h.cache.by_bufnr(function(params)
            return u.root_pattern("gleam.toml")(params.bufname)
        end),
    },
    factory = h.formatter_factory,
})
