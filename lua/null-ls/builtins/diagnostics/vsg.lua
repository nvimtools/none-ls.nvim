local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
    name = "vsg",
    meta = {
        url = "https://github.com/jeremiah-c-leary/vhdl-style-guide",
        description = "VHDL Style guide is a tool for linting for fixing styple in VHDL files",
        config = {
            {
                key = "config_file_name",
                type = "string",
                description = "Name of the VSG config file to use. If this file is present in the root, it will be passed to vsg with the `-c` option",
                usage = "vsg_config.yaml",
            },
        },
    },
    method = DIAGNOSTICS,
    filetypes = { "vhdl" },
    generator_opts = {
        command = "vsg",
        args = function(params)
            local rv = {}
            local config_file_name = params:get_config().config_file_name
            -- check if there is a config file in the root directory, if so
            -- insert the -c argument with it
            if config_file_name and vim.fn.filereadable(params.root .. "/" .. config_file_name) == 1 then
                table.insert(rv, "-c=" .. params.root .. "/" .. config_file_name)
            end
            table.insert(rv, "--stdin")
            table.insert(rv, "-of=syntastic")
            return rv
        end,
        cwd = nil,
        check_exit_code = function()
            return true
        end,
        from_stderr = false,
        ignore_stderr = true,
        to_stdin = true,
        format = "line",
        multiple_files = false,
        on_output = h.diagnostics.from_patterns({
            {
                pattern = [[(%w+).*%((%d+)%)(.*)%s+%-%-%s+(.*)]],
                groups = { "severity", "row", "code", "message" },
                overrides = {
                    severities = {
                        ["ERROR"] = 2,
                        ["WARNING"] = 3,
                        ["INFORMATION"] = 3,
                        ["HINT"] = 4,
                    },
                },
            },
        }),
    },
    factory = h.generator_factory,
})
