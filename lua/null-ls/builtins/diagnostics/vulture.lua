local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (diagnostics/vulture.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "vulture",
    meta = {
        url = "https://github.com/jendrikseipp/vulture",
        description = "Vulture finds unused code in Python programs.",
    },
    method = DIAGNOSTICS,
    filetypes = { "python" },
    generator_opts = {
        command = "vulture",
        args = { "$FILENAME" },
        to_temp_file = true,
        from_stderr = true,
        format = "line",
        on_output = h.diagnostics.from_pattern([[:(%d+): (.*)]], { "row", "message" }),
    },
    factory = h.generator_factory,
})
