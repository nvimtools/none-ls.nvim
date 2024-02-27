local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

if not vim.g.nonels_supress_issue58 then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (diagnostics/clang_check.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "clang_check",
    meta = {
        url = "https://releases.llvm.org/14.0.0/tools/clang/docs/ClangTools.html",
        description = "ClangCheck combines the LibTooling framework for running a Clang tool with the basic Clang diagnostics by syntax checking specific files in a fast, command line interface.",
        notes = {
            "`clang-check` will be run only when files are saved to disk, so that `compile_commands.json` files can be used. It is recommended to use this linter in combination with `compile_commands.json` files.",
        },
    },
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "c", "cpp" },
    generator_opts = {
        command = "clang-check",
        args = {
            "--analyze",
            "--extra-arg=-Xclang",
            "--extra-arg=-analyzer-output=text",
            "--extra-arg=-fno-color-diagnostics",
            "-p",
            "build",
            "$FILENAME",
        },
        from_stderr = true,
        format = "line",
        check_exit_code = function(code)
            return code <= 1
        end,
        on_output = h.diagnostics.from_pattern(":(%d+):(%d+): (%w+): (.*)$", { "row", "col", "severity", "message" }),
    },
    factory = h.generator_factory,
})
