local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (diagnostics/protoc_gen_lint.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "protoc-gen-lint",
    meta = {
        url = "https://github.com/ckaznocha/protoc-gen-lint",
        description = "A plug-in for Google's Protocol Buffers (protobufs) compiler to lint .proto files for style violations.",
    },
    method = DIAGNOSTICS,
    filetypes = { "proto" },
    generator_opts = {
        command = "protoc",
        args = { "--lint_out", "$FILENAME", "-I", "/tmp", "$FILENAME" },
        from_stderr = true,
        to_temp_file = true,
        format = "line",
        check_exit_code = function(code)
            return code <= 1
        end,
        on_output = h.diagnostics.from_patterns({
            {
                pattern = [[:(%d+):(%d+): (.*)]],
                groups = { "row", "col", "message" },
            },
            {
                pattern = [[.*] (.*)]],
                groups = { "message" },
            },
        }),
    },
    factory = h.generator_factory,
})
