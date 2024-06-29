local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "mdslw",
    meta = {
        url = "https://github.com/razziel89/mdslw",
        description = [[The MarkDown Sentence Line Wrapper, an auto-formatter that prepares your markdown for easy diff'ing.]],
    },
    method = FORMATTING,
    filetypes = { "markdown" },
    generator_opts = {
        command = "mdslw",
        args = {},
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
