local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "cljfmt",
    meta = {
        url = "https://github.com/weavejester/cljfmt",
        description = "A tool for formatting Clojure code",
    },
    method = FORMATTING,
    filetypes = { "clojure" },
    generator_opts = {
        command = "cljfmt",
        args = { "fix", "-" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
