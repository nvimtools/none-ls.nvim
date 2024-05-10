local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "reformat-gherkin",
    meta = {
        url = "https://github.com/ducminh-phan/reformat-gherkin",
        description = "Formatter for Gherkin language.",
    },
    method = FORMATTING,
    filetypes = { "cucumber", "gherkin" },
    generator_opts = {
        command = "reformat-gherkin",
        args = { "$FILENAME" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
