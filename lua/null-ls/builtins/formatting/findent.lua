local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "findent",
    meta = {
        url = "https://pypi.org/project/findent/",
        description = "findent indents/beautifies/converts and can optionally generate the dependencies of Fortran sources.",
    },
    method = FORMATTING,
    filetypes = { "fortran" },
    generator_opts = {
        command = "findent",
        args = {},
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
