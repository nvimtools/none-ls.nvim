local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
    name = "systemdlint",
    meta = {
        url = "https://github.com/priv-kweihmann/systemdlint",
        description = "Systemd Linter",
    },
    method = DIAGNOSTICS,
    filetypes = { "systemd" },
    generator_opts = {
        command = "systemdlint",
        args = { "$FILENAME" },
        format = "line",
        from_stderr = true,
        on_output = h.diagnostics.from_pattern([[:(%d+):(%w+) (.*)]], { "row", "severity", "message" }, {
            severities = {
                error = h.diagnostics.severities["error"],
                warning = h.diagnostics.severities["warning"],
                info = h.diagnostics.severities["information"],
            },
        }),
    },
    factory = h.generator_factory,
})
