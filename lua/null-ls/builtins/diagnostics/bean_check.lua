local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

return h.make_builtin({
    name = "bean_check",
    meta = {
        url = "https://github.com/beancount/beancount",
        description = "Beancount: text-based double-entry accounting tool",
    },
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "beancount" },
    generator = h.generator_factory({
        command = "bean-check",
        args = { "$FILENAME" },
        from_stderr = true,
        to_stdin = true,
        format = "line",
        check_exit_code = function(exit_code)
            return exit_code == 0
        end,
        on_output = h.diagnostics.from_patterns({
            {
                pattern = [[(.+):(%d+):%s*(.+)]],
                groups = { "filename", "row", "message" },
            },
        }),
    }),
})
